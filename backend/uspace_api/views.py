"""Database rows converted into contract-safe public and private views."""

from __future__ import annotations

import base64
import hashlib
import json
import os
from datetime import UTC, date, datetime, time
from uuid import uuid4

from psycopg import AsyncConnection

from uspace_api.catalog import PRESETS
from uspace_api.errors import ApiError


def new_id(prefix: str) -> str:
    return f"{prefix}_{uuid4().hex}"


def iso(value: date | datetime | time | None) -> str | None:
    return value.isoformat() if value is not None else None


def page(items: list[dict], *, offset: int, limit: int, fingerprint: str) -> dict:
    next_offset = offset + limit
    cursor = None
    if len(items) > limit:
        cursor = base64.urlsafe_b64encode(
            json.dumps({"offset": next_offset, "fingerprint": fingerprint}).encode()
        ).decode().rstrip("=")
    return {"items": items[:limit], "nextCursor": cursor}


def parse_cursor(cursor: str | None, fingerprint: str) -> int:
    if not cursor:
        return 0
    try:
        padded = cursor + "=" * (-len(cursor) % 4)
        parsed = json.loads(base64.urlsafe_b64decode(padded))
        if parsed["fingerprint"] != fingerprint or not isinstance(parsed["offset"], int):
            raise ValueError
        if parsed["offset"] < 0:
            raise ValueError
        return parsed["offset"]
    except (ValueError, KeyError, TypeError) as exc:
        raise ApiError(400, "VALIDATION_ERROR", "Nieprawidłowy kursor listy.") from exc


def fingerprint(value: object) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True, default=str).encode()).hexdigest()[:16]


async def balance(conn: AsyncConnection, user_id: str) -> int:
    row = await (
        await conn.execute(
            "SELECT COALESCE(SUM(delta),0) AS balance FROM points_entries WHERE user_id=%s",
            (user_id,),
        )
    ).fetchone()
    return int(row["balance"])


async def membership_views(conn: AsyncConnection, user_id: str) -> list[dict]:
    rows = await (
        await conn.execute(
            """SELECT DISTINCT ON (city_id) city_id,status,valid_until,card_masked
            FROM card_verifications WHERE user_id=%s ORDER BY city_id,created_at DESC""",
            (user_id,),
        )
    ).fetchall()
    return [
        {"cityId": row["city_id"], "status": row["status"], "validUntil": iso(row["valid_until"]), "cardMasked": row["card_masked"]}
        for row in rows
    ]


async def me_view(conn: AsyncConnection, user: dict) -> dict:
    stats = await (
        await conn.execute(
            """SELECT (SELECT count(*) FROM reviews WHERE author_id=%s) AS review_count,
            (SELECT count(*) FROM votes WHERE voter_id=%s) AS verification_count""",
            (user["id"], user["id"]),
        )
    ).fetchone()
    return {
        "id": user["id"], "displayName": user["display_name"],
        "appearance": user["appearance"],
        "memberships": await membership_views(conn, user["id"]),
        "stats": {"reviewCount": stats["review_count"], "verificationCount": stats["verification_count"]},
        "achievements": [], "pointsBalance": await balance(conn, user["id"]),
        "preferences": user["preferences"], "uiSettings": user["ui_settings"],
        "privacy": user["privacy"],
    }


async def public_profile_view(conn: AsyncConnection, user: dict) -> dict:
    stats = await (
        await conn.execute(
            """SELECT (SELECT count(*) FROM reviews WHERE author_id=%s) AS review_count,
            (SELECT count(*) FROM votes WHERE voter_id=%s) AS verification_count""",
            (user["id"], user["id"]),
        )
    ).fetchone()
    body = {
        "id": user["id"], "displayName": user["display_name"],
        "appearance": user["appearance"], "badges": [],
        "stats": {"reviewCount": stats["review_count"], "verificationCount": stats["verification_count"]},
    }
    if user["privacy"]["needsVisibility"] == "public":
        body["needs"] = user["preferences"]["needIds"]
    return body


def effective_rules(preferences: dict) -> list[dict]:
    merged: dict[str, dict] = {}
    for preset in PRESETS:
        if preset["id"] in preferences["presetIds"]:
            merged.update({rule["featureId"]: rule for rule in preset["rules"]})
    merged.update({rule["featureId"]: rule for rule in preferences["rules"]})
    return list(merged.values())


def match_place(place: dict, rules: list[dict]) -> dict:
    if not rules:
        return {"status": "not_evaluated", "reasons": [], "unknownFeatureIds": []}
    by_feature: dict[str, list[dict]] = {}
    for feature in place["features"]:
        by_feature.setdefault(feature["featureId"], []).append(feature)
    reasons: list[dict] = []
    unknown: list[str] = []
    failed = False
    for rule in rules:
        if rule["importance"] != "required":
            continue
        candidates = by_feature.get(rule["featureId"], [])
        if any(item.get("sourceLabel") == "Zaakceptowane obserwacje użytkowników" for item in candidates):
            unknown.append(rule["featureId"])
            continue
        if any(item["presence"] == "present" and item.get("operationalState") != "not_working" for item in candidates):
            if rule.get("minRating") is not None:
                # The approved dimensions and average formula are pending.
                unknown.append(rule["featureId"])
            continue
        if not candidates or any(item["presence"] in {"unknown", "disputed"} for item in candidates):
            unknown.append(rule["featureId"])
            continue
        failed = True
        reasons.append({"featureId": rule["featureId"], "targetId": candidates[0].get("targetId"), "code": "NOT_AVAILABLE", "label": "Udogodnienie niedostępne"})
    status = "does_not_match" if failed else ("insufficient_data" if unknown else "matches")
    return {"status": status, "reasons": reasons, "unknownFeatureIds": unknown}


async def current_features(conn: AsyncConnection, place: dict) -> list[dict]:
    """Conservative feature summary: conflicting accepted observations are disputed."""
    summaries = {
        (item["featureId"], item.get("targetId")): {
            **item, "ratingCount": 0, "observedAt": None,
            "lastVerifiedAt": None, "sourceLabel": "Dane demonstracyjne",
        }
        for item in place["features"]
    }
    rows = await (
        await conn.execute(
            """SELECT a.*,r.visited_on,r.created_at FROM review_answers a
            JOIN reviews r ON r.id=a.review_id
            WHERE r.place_id=%s AND r.publication_status='visible'
            AND r.verification_status='accepted'
            ORDER BY r.created_at DESC,a.id""",
            (place["id"],),
        )
    ).fetchall()
    groups: dict[tuple[str, str | None], list[dict]] = {}
    for row in rows:
        groups.setdefault((row["feature_id"], row["target_id"]), []).append(row)
    for key, observations in groups.items():
        substantive = {row["presence"] for row in observations if row["presence"] != "unknown"}
        presence = "disputed" if len(substantive) > 1 else (next(iter(substantive)) if substantive else "unknown")
        states = {row["operational_state"] for row in observations if row["operational_state"]}
        latest = observations[0]
        summaries[key] = {
            "featureId": key[0], "targetId": key[1], "presence": presence,
            "operationalState": next(iter(states)) if presence == "present" and len(states) == 1 else None,
            "rating": latest["rating"] if presence == "present" else None,
            "ratingCount": sum(row["rating"] is not None for row in observations),
            "observedAt": iso(max(row["visited_on"] for row in observations)),
            "lastVerifiedAt": iso(max(row["created_at"] for row in observations)),
            "sourceLabel": "Zaakceptowane obserwacje użytkowników",
        }
    return list(summaries.values())


def place_statistics(observations: list[dict]) -> dict:
    """Equal weight for every subordinate score, excluding absence/unknown and metadata."""
    values = []
    for observation in observations:
        rating = observation.get("rating")
        if observation.get("presence") != "present" or not isinstance(rating, dict):
            continue
        values.extend(value for name, value in rating.items()
            if name != "average_rating" and isinstance(value, (int, float))
            and not isinstance(value, bool) and 1 <= value <= 5)
    return {
        "aggregateRating": sum(values) / len(values) if values else None,
        "reviewCount": len({row["review_id"] for row in observations}),
    }


def sort_places(places: list[dict], sort: str) -> None:
    def score(item: dict) -> float:
        return item.get("aggregateRating") if item.get("aggregateRating") is not None else -1
    if sort == "best_rated":
        places.sort(key=lambda item: (-score(item), -item["reviewCount"], item["name"].casefold(), item["id"]))
    elif sort == "review_count":
        places.sort(key=lambda item: (-item["reviewCount"], -score(item), item["name"].casefold(), item["id"]))


async def place_view(conn: AsyncConnection, place: dict, *, detail: bool = False) -> dict:
    issue_count = await (
        await conn.execute(
            """SELECT count(*) AS n FROM temporary_issues i JOIN reviews r ON r.id=i.review_id
            WHERE i.place_id=%s AND i.status='active' AND r.verification_status='accepted'
            AND r.publication_status='visible'""",
            (place["id"],),
        )
    ).fetchone()
    features = await current_features(conn, place)
    observations = await (await conn.execute(
        """SELECT r.id AS review_id,a.presence,a.rating FROM reviews r
        LEFT JOIN review_answers a ON a.review_id=r.id
        WHERE r.place_id=%s AND r.publication_status='visible' AND r.verification_status='accepted'""",
        (place["id"],),
    )).fetchall()
    verified_dates = [item["lastVerifiedAt"] for item in features if item["lastVerifiedAt"]]
    body = {
        "id": place["id"], "name": place["name"], "categoryId": place["category_id"],
        **place_statistics(observations),
        "cityId": place["city_id"], "address": place["address"],
        "location": {"lat": place["lat"], "lon": place["lon"]},
        "match": {"status": "not_evaluated", "reasons": [], "unknownFeatureIds": []},
        "activeIssueCount": issue_count["n"], "lastVerifiedAt": max(verified_dates) if verified_dates else None,
    }
    if detail:
        parts = await (
            await conn.execute(
                """SELECT p.* FROM place_parts p LEFT JOIN reviews r ON r.id=p.origin_review_id
                WHERE p.place_id=%s AND (p.origin_review_id IS NULL OR
                (r.verification_status='accepted' AND r.publication_status='visible')) ORDER BY p.name""",
                (place["id"],),
            )
        ).fetchall()
        issues = await (
            await conn.execute(
                """SELECT i.* FROM temporary_issues i JOIN reviews r ON r.id=i.review_id
                WHERE i.place_id=%s AND r.verification_status='accepted'
                AND r.publication_status='visible' ORDER BY i.reported_at DESC""",
                (place["id"],),
            )
        ).fetchall()
        body.update({
            "parts": [{"id": row["id"], "kind": row["kind"], "name": row["name"], "description": row["description"], "location": None} for row in parts],
            "features": features,
            "temporaryIssues": [issue_view(row) for row in issues],
            "allowedActions": ["create_review"],
        })
    return body


def issue_view(row: dict) -> dict:
    return {
        "id": row["id"], "featureId": row["feature_id"], "targetId": row["target_id"],
        "kind": row["kind"], "description": row["description"], "status": row["status"],
        "reportedAt": iso(row["reported_at"]),
    }


async def review_view(conn: AsyncConnection, review: dict, viewer_id: str | None) -> dict:
    author = await (await conn.execute("SELECT * FROM users WHERE id=%s", (review["author_id"],))).fetchone()
    answers = await (
        await conn.execute("SELECT * FROM review_answers WHERE review_id=%s ORDER BY created_at,id", (review["id"],))
    ).fetchall()
    issues = await (
        await conn.execute("SELECT * FROM temporary_issues WHERE review_id=%s ORDER BY reported_at,id", (review["id"],))
    ).fetchall()
    answer_views = []
    for answer in answers:
        counts = await (
            await conn.execute(
                """SELECT count(*) FILTER (WHERE verdict='confirm') AS confirms,
                count(*) FILTER (WHERE verdict='dispute') AS disputes
                FROM votes WHERE answer_id=%s""",
                (answer["id"],),
            )
        ).fetchone()
        answer_views.append({
            "id": answer["id"], "featureId": answer["feature_id"],
            "targetId": answer["target_id"], "presence": answer["presence"],
            "operationalState": answer["operational_state"], "rating": answer["rating"],
            "comment": answer["comment"] if viewer_id == author["id"] or review["verification_status"] == "accepted" else None,
            "communitySummary": {"confirmedCount": counts["confirms"], "disputedCount": counts["disputes"]},
        })
    allowed = []
    if viewer_id and viewer_id != author["id"] and review["publication_status"] == "visible" and review["verification_status"] == "accepted":
        allowed = ["report"]
        visit_allowed = True
        if os.environ.get("USPACE_REQUIRE_VISIT_FOR_VOTE", "false").lower() in {"true", "1"}:
            visit_allowed = bool(await (
                await conn.execute(
                    "SELECT 1 FROM visit_attestations WHERE user_id=%s AND place_id=%s LIMIT 1",
                    (viewer_id, review["place_id"]),
                )
            ).fetchone())
        if visit_allowed:
            voted = await (
                await conn.execute(
                    "SELECT count(*) AS n FROM votes WHERE review_id=%s AND voter_id=%s",
                    (review["id"], viewer_id),
                )
            ).fetchone()
            if voted["n"] < len(answers):
                allowed.insert(0, "vote")
    body = {
        "id": review["id"], "placeId": review["place_id"],
        "author": {"id": author["id"], "displayName": author["display_name"], "appearance": author["appearance"], "badges": []},
        "visitedOn": iso(review["visited_on"]),
        "visitedAtLocalTime": review["visited_at_local_time"].strftime("%H:%M") if review["visited_at_local_time"] else None,
        "timeZone": review["time_zone"], "createdAt": iso(review["created_at"]),
        "mode": review["mode"], "recommendation": review.get("recommendation"), "answers": answer_views,
        "temporaryIssues": [issue_view(issue) for issue in issues] if viewer_id == author["id"] or review["verification_status"] == "accepted" else [],
        "publicationStatus": review["publication_status"],
        "verificationStatus": review["verification_status"], "allowedActions": allowed,
    }
    if viewer_id == author["id"]:
        body["pointAward"] = {
            "status": review["point_status"], "amount": review["point_amount"],
            "reasonCode": review["point_reason_code"],
        }
    return body


async def reward_view(conn: AsyncConnection, reward: dict, user_id: str | None) -> dict:
    eligible = True
    reason = None
    if reward["city_id"]:
        if user_id is None:
            eligible = False
            reason = "LOGIN_REQUIRED"
        else:
            memberships = await membership_views(conn, user_id)
            eligible = any(
                item["cityId"] == reward["city_id"] and item["status"] == "verified"
                and (item["validUntil"] is None or item["validUntil"] >= datetime.now(UTC).date().isoformat())
                for item in memberships
            )
            reason = None if eligible else "CARD_REQUIRED"
    return {
        "id": reward["id"], "name": reward["name"], "description": reward["description"],
        "kind": reward["kind"], "costPoints": reward["cost_points"],
        "cityId": reward["city_id"], "availability": reward["availability"],
        "eligibility": {"eligible": eligible, "reasonCode": reason},
        "deliveryMethods": reward["delivery_methods"], "imageUrl": reward["image_url"],
    }


def redemption_view(row: dict, *, points_balance: int | None = None) -> dict:
    body = {
        "id": row["id"], "rewardId": row["reward_id"], "rewardName": row["reward_name"],
        "costPoints": row["cost_points"], "deliveryMethod": row["delivery_method"],
        "status": row["status"], "createdAt": iso(row["created_at"]),
        "code": row["code"], "expiresAt": iso(row["expires_at"]),
        "instructions": row["instructions"], "failureCode": row["failure_code"],
        "pointsStatus": row["points_status"],
    }
    if points_balance is not None:
        body["pointsBalance"] = points_balance
    return body
