"""Asynchronous KindSpot v1 product routes."""
# ruff: noqa: B008  FastAPI dependency and parameter declarations use call defaults.

from __future__ import annotations

import asyncio
import hashlib
import json
import os

import psycopg
from fastapi import APIRouter, Depends, Header, Query
from psycopg.types.json import Jsonb

from uspace_api.assistance import questions_for_draft
from uspace_api.auth import (
    current_user,
    hash_password,
    issue_session,
    optional_user,
    revoke_session,
    verify_password,
)
from uspace_api.catalog import CARD_TYPES, CONFIGURATION, FEATURE_BY_ID, NEED_LABELS, PRESETS
from uspace_api.db import connect
from uspace_api.errors import ApiError
from uspace_api.models import (
    AssistanceRequest,
    CardVerificationCreate,
    Login,
    PlaceSearch,
    Preferences,
    PrivacyPatch,
    ProfilePatch,
    RedemptionCreate,
    Register,
    ReportCreate,
    ReviewCreate,
    UiSettings,
    VoteCreate,
)
from uspace_api.similarity import review_vector
from uspace_api.views import (
    balance,
    current_features,
    effective_rules,
    fingerprint,
    me_view,
    new_id,
    page,
    parse_cursor,
    place_view,
    public_profile_view,
    redemption_view,
    review_view,
    reward_view,
    sort_places,
)

router = APIRouter(prefix="/api/v1")
DUMMY_PASSWORD_HASH = hash_password("nonexistent-account")


def _idempotency_hash(payload: object) -> str:
    return hashlib.sha256(json.dumps(payload, sort_keys=True, default=str).encode()).hexdigest()


def _check_key(key: str | None) -> str:
    if not key or len(key) > 128 or any(ord(char) < 33 or ord(char) > 126 for char in key):
        raise ApiError(400, "VALIDATION_ERROR", "Podaj poprawny Idempotency-Key.")
    return key


async def _claim(conn, user_id: str, scope: str, key: str, payload: object) -> dict | None:
    digest = _idempotency_hash(payload)
    await conn.execute(
        """INSERT INTO idempotency_records(user_id,scope,key,request_hash)
        VALUES (%s,%s,%s,%s) ON CONFLICT DO NOTHING""",
        (user_id, scope, key, digest),
    )
    row = await (
        await conn.execute(
            """SELECT request_hash,status_code,response FROM idempotency_records
            WHERE user_id=%s AND scope=%s AND key=%s FOR UPDATE""",
            (user_id, scope, key),
        )
    ).fetchone()
    if row["request_hash"] != digest:
        raise ApiError(409, "IDEMPOTENCY_CONFLICT", "Ten klucz użyto z innymi danymi.")
    return row["response"]


async def _complete(conn, user_id: str, scope: str, key: str, body: dict, status_code: int) -> None:
    await conn.execute(
        """UPDATE idempotency_records SET response=%s,status_code=%s
        WHERE user_id=%s AND scope=%s AND key=%s""",
        (Jsonb(body), status_code, user_id, scope, key),
    )


@router.post("/auth/register", status_code=201)
async def register(body: Register) -> dict:
    user_id = new_id("usr")
    email = body.email.strip().lower()
    appearance = {"avatarId": "avatar_default", "frameId": "frame_default", "titleId": "title_default"}
    encoded_password = await asyncio.to_thread(hash_password, body.password)
    try:
        async with await connect() as conn:
            await conn.execute(
                """INSERT INTO users(id,email,password_hash,display_name,appearance)
                VALUES (%s,%s,%s,%s,%s)""",
                (user_id, email, encoded_password, body.displayName.strip(), Jsonb(appearance)),
            )
    except psycopg.errors.UniqueViolation as exc:
        raise ApiError(409, "EMAIL_TAKEN", "Ten adres email jest już używany.", field_errors=[{"path": "email", "code": "EMAIL_TAKEN"}]) from exc
    return {"userId": user_id}


@router.post("/auth/login")
async def login(body: Login) -> dict:
    email = body.email.strip().lower()
    email_hash = hashlib.sha256(email.encode()).hexdigest()
    async with await connect() as conn:
        recent = await (
            await conn.execute(
                """SELECT count(*) AS n FROM login_attempts
                WHERE email_hash=%s AND created_at>now()-interval '15 minutes'""",
                (email_hash,),
            )
        ).fetchone()
        if recent["n"] >= 5:
            raise ApiError(429, "RATE_LIMITED", "Spróbuj ponownie za 15 minut.", retryable=True, headers={"Retry-After": "900"})
        user = await (
            await conn.execute("SELECT * FROM users WHERE email=%s", (email,))
        ).fetchone()
        valid = await asyncio.to_thread(
            verify_password, body.password, user["password_hash"] if user else DUMMY_PASSWORD_HASH
        )
        if not valid or user is None:
            await conn.execute("INSERT INTO login_attempts(email_hash) VALUES (%s)", (email_hash,))
        else:
            await conn.execute("DELETE FROM login_attempts WHERE email_hash=%s", (email_hash,))
    if not valid or user is None:
        raise ApiError(401, "INVALID_CREDENTIALS", "Nieprawidłowe dane logowania.")
    token, expires = await issue_session(user["id"])
    async with await connect() as conn:
        me = await me_view(conn, user)
    return {"accessToken": token, "expiresAt": expires.isoformat(), "me": me}


@router.post("/auth/logout", status_code=204)
async def logout(
    user: dict = Depends(current_user), authorization: str = Header(),
) -> None:
    await revoke_session(authorization)


@router.get("/configuration")
async def configuration() -> dict:
    return CONFIGURATION


@router.get("/me")
async def me(user: dict = Depends(current_user)) -> dict:
    async with await connect() as conn:
        return await me_view(conn, user)


@router.patch("/me/profile")
async def patch_profile(body: ProfilePatch, user: dict = Depends(current_user)) -> dict:
    appearance = user["appearance"].copy()
    if body.appearance is not None:
        changes = body.appearance.model_dump(exclude_none=True)
        owned = {"avatar_default", "frame_default", "title_default"}
        async with await connect() as conn:
            rows = await (
                await conn.execute(
                    """SELECT reward_id FROM redemptions WHERE user_id=%s
                    AND status IN ('ready','fulfilled')""",
                    (user["id"],),
                )
            ).fetchall()
        if any(row["reward_id"] == "reward_frame" for row in rows):
            owned.add("frame_reward")
        if any(item not in owned for item in changes.values()):
            raise ApiError(403, "NOT_ELIGIBLE", "Ten element wyglądu nie należy do konta.")
        appearance.update(changes)
    updates = {
        "display_name": body.displayName.strip() if body.displayName is not None else user["display_name"],
        "appearance": appearance,
    }
    async with await connect() as conn:
        updated = await (
            await conn.execute(
                """UPDATE users SET display_name=%s,appearance=%s
                WHERE id=%s RETURNING *""",
                (updates["display_name"], Jsonb(appearance), user["id"]),
            )
        ).fetchone()
        return await me_view(conn, updated)


@router.get("/me/cosmetics")
async def cosmetics(
    cursor: str | None = None, limit: int = Query(20, ge=1, le=100),
    user: dict = Depends(current_user),
) -> dict:
    items = [
        {"id": "avatar_default", "kind": "avatar", "label": "Domyślny awatar", "imageUrl": None},
        {"id": "frame_default", "kind": "frame", "label": "Domyślna ramka", "imageUrl": None},
        {"id": "title_default", "kind": "title", "label": "Domyślny tytuł", "imageUrl": None},
    ]
    async with await connect() as conn:
        row = await (
            await conn.execute(
                """SELECT 1 FROM redemptions WHERE user_id=%s AND reward_id='reward_frame'
                AND status IN ('ready','fulfilled') LIMIT 1""",
                (user["id"],),
            )
        ).fetchone()
    if row:
        items.append({"id": "frame_reward", "kind": "frame", "label": "Ramka nagrody", "imageUrl": None})
    key = fingerprint({"resource": "cosmetics", "user": user["id"]})
    offset = parse_cursor(cursor, key)
    return page(items[offset:offset + limit + 1], offset=offset, limit=limit, fingerprint=key)


@router.put("/me/preferences")
async def put_preferences(body: Preferences, user: dict = Depends(current_user)) -> dict:
    if any(need not in NEED_LABELS for need in body.needIds):
        raise ApiError(422, "VALIDATION_ERROR", "Nieznana potrzeba.")
    if any(preset not in {item["id"] for item in PRESETS} for preset in body.presetIds):
        raise ApiError(422, "VALIDATION_ERROR", "Nieznany zestaw filtrów.")
    for rule in [*body.rules, *(rule for named in body.namedFilters for rule in named.rules)]:
        feature = FEATURE_BY_ID.get(rule.featureId)
        if not feature or (rule.minRating is not None and not feature["supportsRating"]):
            raise ApiError(422, "VALIDATION_ERROR", "Niepoprawna reguła filtrowania.")
    preferences = body.model_dump(mode="json")
    async with await connect() as conn:
        await conn.execute("UPDATE users SET preferences=%s WHERE id=%s", (Jsonb(preferences), user["id"]))
    return {**preferences, "effectiveRules": effective_rules(preferences)}


@router.patch("/me/privacy")
async def patch_privacy(body: PrivacyPatch, user: dict = Depends(current_user)) -> dict:
    privacy = body.model_dump()
    async with await connect() as conn:
        await conn.execute("UPDATE users SET privacy=%s WHERE id=%s", (Jsonb(privacy), user["id"]))
    return privacy


@router.put("/me/ui-settings")
async def put_ui_settings(body: UiSettings, user: dict = Depends(current_user)) -> dict:
    settings = body.model_dump()
    if settings["colorThemeId"] not in CONFIGURATION["uiOptions"]["themeIds"] or settings["textScale"] not in CONFIGURATION["uiOptions"]["textScales"]:
        raise ApiError(422, "VALIDATION_ERROR", "Niepoprawne ustawienia wyglądu.")
    async with await connect() as conn:
        await conn.execute("UPDATE users SET ui_settings=%s WHERE id=%s", (Jsonb(settings), user["id"]))
    return settings


@router.post("/me/card-verifications", status_code=202)
async def create_card_verification(body: CardVerificationCreate, user: dict = Depends(current_user)) -> dict:
    if not any(card["id"] == body.cardTypeId and card["cityId"] == body.cityId for card in CARD_TYPES):
        raise ApiError(422, "CARD_INVALID", "Nieobsługiwany typ karty.")
    verification_id = new_id("card")
    async with await connect() as conn:
        entitlement = await (
            await conn.execute(
                """SELECT valid_until FROM demo_card_entitlements WHERE user_id=%s AND city_id=%s
                AND card_type_id=%s AND (valid_until IS NULL OR valid_until>=current_date)""",
                (user["id"], body.cityId, body.cardTypeId),
            )
        ).fetchone()
        result = "verified" if entitlement else "rejected"
        await conn.execute(
            """INSERT INTO card_verifications(id,user_id,city_id,card_type_id,status,card_masked,valid_until,demo_result)
            VALUES (%s,%s,%s,%s,'pending',%s,%s,%s)""",
            (verification_id, user["id"], body.cityId, body.cardTypeId, None, entitlement["valid_until"] if entitlement else None, result),
        )
    return {"id": verification_id, "cityId": body.cityId, "status": "pending", "demonstrational": True}


@router.get("/me/card-verifications/{verification_id}")
async def get_card_verification(verification_id: str, user: dict = Depends(current_user)) -> dict:
    async with await connect() as conn:
        row = await (
            await conn.execute(
                "SELECT * FROM card_verifications WHERE id=%s AND user_id=%s",
                (verification_id, user["id"]),
            )
        ).fetchone()
        if row is None:
            raise ApiError(404, "REVIEW_NOT_AVAILABLE", "Nie znaleziono sprawdzenia karty.")
        if row["status"] == "pending":
            row = await (
                await conn.execute(
                    """UPDATE card_verifications SET status=demo_result,
                    reason_code=CASE WHEN demo_result='rejected' THEN 'CARD_INVALID' ELSE NULL END
                    WHERE id=%s RETURNING *""",
                    (verification_id,),
                )
            ).fetchone()
    return {"id": row["id"], "cityId": row["city_id"], "status": row["status"], "validUntil": row["valid_until"].isoformat() if row["valid_until"] else None, "reasonCode": row["reason_code"], "demonstrational": True}


@router.post("/places/search")
async def search_places(body: PlaceSearch) -> dict:
    query = body.model_dump(mode="json", exclude={"cursor", "limit"})
    key = fingerprint(query)
    offset = parse_cursor(body.cursor, key)
    clauses = []
    params: list = []
    if body.cityId:
        clauses.append("city_id=%s")
        params.append(body.cityId)
    if body.q:
        clauses.append("(name ILIKE %s OR address ILIKE %s)")
        params.extend([f"%{body.q}%", f"%{body.q}%"])
    if body.bbox:
        clauses.append("lon BETWEEN %s AND %s AND lat BETWEEN %s AND %s")
        params.extend([body.bbox.west, body.bbox.east, body.bbox.south, body.bbox.north])
    sql = "SELECT * FROM places" + (" WHERE " + " AND ".join(clauses) if clauses else "") + " ORDER BY name,id LIMIT 501"
    async with await connect() as conn:
        rows = await (await conn.execute(sql, params)).fetchall()
        if len(rows) > 500:
            raise ApiError(422, "SEARCH_TOO_BROAD", "Zawęź wyszukiwanie do mniejszego obszaru.")
        rules = [rule.model_dump() for rule in body.rules]
        results = []
        for row in rows:
            item = await place_view(conn, row)
            from uspace_api.views import match_place
            item["match"] = match_place({"features": await current_features(conn, row)}, rules)
            if item["match"]["status"] == "does_not_match":
                continue
            if item["match"]["status"] == "insufficient_data" and not body.includeUnknownRequired:
                continue
            results.append(item)
    if body.sort == "recommended":
        rank = {"matches": 0, "not_evaluated": 0, "insufficient_data": 1}
        results.sort(key=lambda item: (rank[item["match"]["status"]], item["name"]))
    sort_places(results, body.sort)
    return page(results[offset:offset + body.limit + 1], offset=offset, limit=body.limit, fingerprint=key)


@router.get("/places/{place_id}")
async def get_place(place_id: str) -> dict:
    async with await connect() as conn:
        row = await (await conn.execute("SELECT * FROM places WHERE id=%s", (place_id,))).fetchone()
        if row is None:
            raise ApiError(404, "PLACE_NOT_AVAILABLE", "Nie znaleziono miejsca.")
        return await place_view(conn, row, detail=True)


@router.get("/users/{user_id}/public-profile")
async def public_profile(user_id: str) -> dict:
    async with await connect() as conn:
        row = await (await conn.execute("SELECT * FROM users WHERE id=%s", (user_id,))).fetchone()
        if row is None:
            raise ApiError(404, "USER_NOT_AVAILABLE", "Nie znaleziono profilu.")
        return await public_profile_view(conn, row)


@router.get("/places/{place_id}/reviews")
async def list_place_reviews(
    place_id: str, sort: str = "newest", cursor: str | None = None,
    limit: int = Query(20, ge=1, le=100), viewer: dict | None = Depends(optional_user),
) -> dict:
    if sort not in {"newest", "community"}:
        raise ApiError(422, "VALIDATION_ERROR", "Nieznany sposób sortowania.")
    key = fingerprint({"resource": "place_reviews", "place": place_id, "sort": sort, "viewer": viewer["id"] if viewer else None})
    offset = parse_cursor(cursor, key)
    async with await connect() as conn:
        place = await (await conn.execute("SELECT 1 FROM places WHERE id=%s", (place_id,))).fetchone()
        if place is None:
            raise ApiError(404, "PLACE_NOT_AVAILABLE", "Nie znaleziono miejsca.")
        order = "r.created_at DESC" if sort == "newest" else "coalesce(v.score,0) DESC,r.created_at DESC"
        rows = await (
            await conn.execute(
                f"""SELECT r.* FROM reviews r LEFT JOIN (
                    SELECT review_id, count(*) FILTER (WHERE verdict='confirm')-
                    count(*) FILTER (WHERE verdict='dispute') AS score
                    FROM votes GROUP BY review_id
                ) v ON v.review_id=r.id
                WHERE r.place_id=%s AND (r.publication_status='visible' OR r.author_id=%s)
                ORDER BY {order} OFFSET %s LIMIT %s""",
                (place_id, viewer["id"] if viewer else "", offset, limit + 1),
            )
        ).fetchall()
        items = [await review_view(conn, row, viewer["id"] if viewer else None) for row in rows]
    return page(items, offset=offset, limit=limit, fingerprint=key)


@router.post("/places/{place_id}/reviews", status_code=201)
async def create_review(
    place_id: str, body: ReviewCreate,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    user: dict = Depends(current_user),
) -> dict:
    key = _check_key(idempotency_key)
    payload = body.model_dump(mode="json")
    scope = f"review:{place_id}"
    async with await connect() as conn:
        previous = await _claim(conn, user["id"], scope, key, payload)
        if previous is not None:
            return previous
        place = await (await conn.execute("SELECT * FROM places WHERE id=%s", (place_id,))).fetchone()
        if place is None:
            raise ApiError(404, "PLACE_NOT_AVAILABLE", "Nie znaleziono miejsca.")
        review_id = new_id("rev")
        await conn.execute(
            """INSERT INTO reviews(id,place_id,author_id,visited_on,visited_at_local_time,time_zone,mode,recommendation)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
            (review_id, place_id, user["id"], body.visitedOn, body.visitedAtLocalTime, body.timeZone, body.mode, body.recommendation),
        )
        parts = {}
        for part in body.newParts:
            part_id = new_id("part")
            row = await (
                await conn.execute(
                    """INSERT INTO place_parts(id,place_id,kind,name,description,origin_review_id)
                    VALUES (%s,%s,%s,%s,%s,%s)
                    ON CONFLICT (place_id,name) DO NOTHING RETURNING id""",
                    (part_id, place_id, part.kind, part.name.strip(), part.description, review_id),
                )
            ).fetchone()
            if row is None:
                row = await (
                    await conn.execute(
                        """SELECT p.id,p.origin_review_id,r.verification_status,r.publication_status
                        FROM place_parts p LEFT JOIN reviews r ON r.id=p.origin_review_id
                        WHERE p.place_id=%s AND p.name=%s""",
                        (place_id, part.name.strip()),
                    )
                ).fetchone()
                if row["origin_review_id"] is not None and (
                    row["verification_status"] != "accepted" or row["publication_status"] != "visible"
                ):
                    raise ApiError(409, "PART_PENDING", "Ta część miejsca oczekuje na moderację.")
            parts[part.clientId] = row["id"]
        seen = set()
        for answer in body.answers:
            feature = FEATURE_BY_ID.get(answer.featureId)
            if feature is None:
                raise ApiError(422, "VALIDATION_ERROR", "Nieznana cecha.")
            if answer.rating and not feature["supportsRating"]:
                raise ApiError(422, "VALIDATION_ERROR", "Tej cechy nie można ocenić gwiazdkami.")
            if answer.operationalState and not feature["supportsOperationalState"]:
                raise ApiError(422, "VALIDATION_ERROR", "Ta cecha nie ma stanu działania.")
            target_id = parts.get(answer.targetClientId) if answer.targetClientId else answer.targetId
            if target_id:
                if not feature["supportsMultipleTargets"]:
                    raise ApiError(422, "VALIDATION_ERROR", "Ta cecha nie dotyczy części obiektu.")
                part = await (
                    await conn.execute("SELECT 1 FROM place_parts WHERE id=%s AND place_id=%s", (target_id, place_id))
                ).fetchone()
                if part is None:
                    raise ApiError(422, "VALIDATION_ERROR", "Nieznana część obiektu.")
            pair = (answer.featureId, target_id)
            if pair in seen:
                raise ApiError(422, "VALIDATION_ERROR", "Powtórzona obserwacja tej cechy.")
            seen.add(pair)
            await conn.execute(
                """INSERT INTO review_answers(
                    id,review_id,feature_id,target_id,presence,operational_state,rating,comment,embedding
                ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s::vector)""",
                (
                    new_id("ans"), review_id, answer.featureId, target_id, answer.presence,
                    answer.operationalState,
                    Jsonb(answer.rating.model_dump(exclude_none=True) if answer.rating else None),
                    answer.comment, review_vector(answer.featureId, answer.presence, answer.comment),
                ),
            )
        for issue in body.temporaryIssues:
            if issue.featureId not in FEATURE_BY_ID:
                raise ApiError(422, "VALIDATION_ERROR", "Nieznana cecha utrudnienia.")
            target_id = parts.get(issue.targetClientId) if issue.targetClientId else issue.targetId
            if target_id:
                part = await (
                    await conn.execute("SELECT 1 FROM place_parts WHERE id=%s AND place_id=%s", (target_id, place_id))
                ).fetchone()
                if part is None:
                    raise ApiError(422, "VALIDATION_ERROR", "Nieznana część obiektu.")
            await conn.execute(
                """INSERT INTO temporary_issues(id,review_id,place_id,feature_id,target_id,kind,description)
                VALUES (%s,%s,%s,%s,%s,%s,%s)""",
                (new_id("issue"), review_id, place_id, issue.featureId, target_id, issue.kind, issue.description),
            )
        row = await (await conn.execute("SELECT * FROM reviews WHERE id=%s", (review_id,))).fetchone()
        result = await review_view(conn, row, user["id"])
        await _complete(conn, user["id"], scope, key, result, 201)
        return result


@router.post("/review-assistance")
async def review_assistance(
    body: AssistanceRequest, user: dict = Depends(current_user),
) -> dict:
    async with await connect() as conn:
        place = await (await conn.execute("SELECT 1 FROM places WHERE id=%s", (body.placeId,))).fetchone()
    if place is None:
        raise ApiError(404, "PLACE_NOT_AVAILABLE", "Nie znaleziono miejsca.")
    return {"suggestions": await questions_for_draft(body.draft)}


@router.get("/reviews/{review_id}")
async def get_review(review_id: str, viewer: dict | None = Depends(optional_user)) -> dict:
    async with await connect() as conn:
        review = await (await conn.execute("SELECT * FROM reviews WHERE id=%s", (review_id,))).fetchone()
        if review is None or (review["publication_status"] != "visible" and (viewer is None or viewer["id"] != review["author_id"])):
            raise ApiError(404, "REVIEW_NOT_AVAILABLE", "Recenzja nie jest dostępna.")
        return await review_view(conn, review, viewer["id"] if viewer else None)


def _visit_restriction_enabled() -> bool:
    value = os.environ.get("USPACE_REQUIRE_VISIT_FOR_VOTE", "false").lower()
    if value not in {"true", "false", "1", "0"}:
        raise RuntimeError("USPACE_REQUIRE_VISIT_FOR_VOTE must be true or false")
    return value in {"true", "1"}


@router.get("/me/verification-tasks")
async def verification_tasks(
    cursor: str | None = None, limit: int = Query(20, ge=1, le=100),
    user: dict = Depends(current_user),
) -> dict:
    restricted = _visit_restriction_enabled()
    key = fingerprint({"resource": "verification_tasks", "user": user["id"], "restricted": restricted})
    offset = parse_cursor(cursor, key)
    visit_sql = """AND EXISTS (SELECT 1 FROM visit_attestations va
        WHERE va.user_id=%s AND va.place_id=r.place_id)""" if restricted else ""
    params = [user["id"], user["id"]]
    if restricted:
        params.append(user["id"])
    params.extend([offset, limit + 1])
    async with await connect() as conn:
        rows = await (
            await conn.execute(
                f"""SELECT a.id AS answer_id,r.id AS review_id,r.place_id,a.feature_id
                FROM review_answers a JOIN reviews r ON r.id=a.review_id
                WHERE r.publication_status='visible' AND r.verification_status='accepted'
                AND r.author_id<>%s
                AND NOT EXISTS (SELECT 1 FROM votes v WHERE v.answer_id=a.id AND v.voter_id=%s)
                {visit_sql} ORDER BY r.created_at DESC,a.id OFFSET %s LIMIT %s""",
                params,
            )
        ).fetchall()
    items = [{"id": row["answer_id"], "review": {"id": row["review_id"], "placeId": row["place_id"]}, "answerId": row["answer_id"], "featureId": row["feature_id"], "allowedActions": ["confirm", "dispute"]} for row in rows]
    return page(items, offset=offset, limit=limit, fingerprint=key)


@router.post("/reviews/{review_id}/answers/{answer_id}/votes", status_code=201)
async def create_vote(
    review_id: str, answer_id: str, body: VoteCreate,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    user: dict = Depends(current_user),
) -> dict:
    key = _check_key(idempotency_key)
    scope = f"vote:{review_id}:{answer_id}"
    payload = body.model_dump()
    async with await connect() as conn:
        previous = await _claim(conn, user["id"], scope, key, payload)
        if previous is not None:
            return previous
        row = await (
            await conn.execute(
                """SELECT r.author_id,r.place_id,r.publication_status,r.verification_status,a.id AS answer_id
                FROM reviews r JOIN review_answers a ON a.review_id=r.id
                WHERE r.id=%s AND a.id=%s""",
                (review_id, answer_id),
            )
        ).fetchone()
        if row is None or row["publication_status"] != "visible":
            raise ApiError(404, "REVIEW_NOT_AVAILABLE", "Recenzja nie jest dostępna.")
        if row["author_id"] == user["id"]:
            raise ApiError(403, "SELF_VERIFICATION_NOT_ALLOWED", "Nie można głosować na własną recenzję.")
        if row["verification_status"] != "accepted":
            raise ApiError(409, "REVIEW_PENDING", "Obserwacja oczekuje na moderację.")
        if _visit_restriction_enabled():
            attested = await (
                await conn.execute(
                    "SELECT 1 FROM visit_attestations WHERE user_id=%s AND place_id=%s LIMIT 1",
                    (user["id"], row["place_id"]),
                )
            ).fetchone()
            if attested is None:
                raise ApiError(403, "NOT_ELIGIBLE", "Brak potwierdzonej wizyty w tym miejscu.")
        existing = await (
            await conn.execute("SELECT 1 FROM votes WHERE answer_id=%s AND voter_id=%s", (answer_id, user["id"]))
        ).fetchone()
        if existing:
            raise ApiError(409, "ALREADY_VERIFIED", "Głos na tę obserwację został już oddany.")
        recent_votes = await (
            await conn.execute(
                "SELECT count(*) AS n FROM votes WHERE voter_id=%s AND created_at>now()-interval '24 hours'",
                (user["id"],),
            )
        ).fetchone()
        if recent_votes["n"] >= 100:
            raise ApiError(429, "RATE_LIMITED", "Osiągnięto dzienny limit głosów.", retryable=True, headers={"Retry-After": "86400"})
        await conn.execute("SELECT id FROM users WHERE id=%s FOR UPDATE", (row["author_id"],))
        vote_id = new_id("vote")
        await conn.execute(
            """INSERT INTO votes(id,review_id,answer_id,voter_id,verdict,reason)
            VALUES (%s,%s,%s,%s,%s,%s)""",
            (vote_id, review_id, answer_id, user["id"], body.verdict, body.reason),
        )
        delta = 1 if body.verdict == "confirm" else -1
        await conn.execute(
            """INSERT INTO points_entries(id,user_id,delta,reason_code,related_review_id,related_verification_id)
            VALUES (%s,%s,%s,%s,%s,%s)""",
            (new_id("pts"), row["author_id"], delta, "observation_confirmed" if delta > 0 else "observation_disputed", review_id, vote_id),
        )
        counts = await (
            await conn.execute(
                """SELECT count(*) FILTER (WHERE verdict='confirm') AS confirmed,
                count(*) FILTER (WHERE verdict='dispute') AS disputed FROM votes WHERE answer_id=%s""",
                (answer_id,),
            )
        ).fetchone()
        result = {
            "id": vote_id, "reviewId": review_id, "answerId": answer_id,
            "verdict": body.verdict,
            "communitySummary": {"confirmedCount": counts["confirmed"], "disputedCount": counts["disputed"]},
            "pointAward": {"status": "not_granted", "amount": 0, "reasonCode": "AUTHOR_RECEIVES_VOTE_POINTS"},
        }
        await _complete(conn, user["id"], scope, key, result, 201)
        return result


@router.post("/reviews/{review_id}/reports", status_code=201)
async def report_review(
    review_id: str, body: ReportCreate, user: dict = Depends(current_user),
) -> dict:
    async with await connect() as conn:
        row = await (
            await conn.execute("SELECT publication_status FROM reviews WHERE id=%s", (review_id,))
        ).fetchone()
        if row is None or row["publication_status"] != "visible":
            raise ApiError(404, "REVIEW_NOT_AVAILABLE", "Recenzja nie jest dostępna.")
        report_id = new_id("report")
        await conn.execute(
            """INSERT INTO reports(id,review_id,reporter_id,reason_code,description)
            VALUES (%s,%s,%s,%s,%s)""",
            (report_id, review_id, user["id"], body.reasonCode, body.description),
        )
    return {"reportId": report_id, "status": "received"}


@router.get("/me/points")
async def get_points(user: dict = Depends(current_user)) -> dict:
    async with await connect() as conn:
        pending = await (
            await conn.execute(
                "SELECT count(*) AS n FROM reviews WHERE author_id=%s AND point_status='pending'",
                (user["id"],),
            )
        ).fetchone()
        return {"balance": await balance(conn, user["id"]), "pendingAmount": None if pending["n"] else 0}


@router.get("/me/points/history")
async def points_history(
    cursor: str | None = None, limit: int = Query(20, ge=1, le=100),
    user: dict = Depends(current_user),
) -> dict:
    key = fingerprint({"resource": "points_history", "user": user["id"]})
    offset = parse_cursor(cursor, key)
    async with await connect() as conn:
        rows = await (
            await conn.execute(
                """SELECT * FROM points_entries WHERE user_id=%s
                ORDER BY created_at DESC,id OFFSET %s LIMIT %s""",
                (user["id"], offset, limit + 1),
            )
        ).fetchall()
    items = [{
        "id": row["id"], "delta": row["delta"], "reasonCode": row["reason_code"],
        "relatedReviewId": row["related_review_id"],
        "relatedVerificationId": row["related_verification_id"],
        "relatedRedemptionId": row["related_redemption_id"],
        "createdAt": row["created_at"].isoformat(),
    } for row in rows]
    return page(items, offset=offset, limit=limit, fingerprint=key)


@router.get("/rewards")
async def list_rewards(
    cityId: str | None = None, cursor: str | None = None,
    limit: int = Query(20, ge=1, le=100), viewer: dict | None = Depends(optional_user),
) -> dict:
    key = fingerprint({"resource": "rewards", "cityId": cityId, "viewer": viewer["id"] if viewer else None})
    offset = parse_cursor(cursor, key)
    async with await connect() as conn:
        rows = await (
            await conn.execute(
                """SELECT * FROM rewards WHERE (%s::text IS NULL OR city_id=%s OR city_id IS NULL)
                ORDER BY id OFFSET %s LIMIT %s""",
                (cityId, cityId, offset, limit + 1),
            )
        ).fetchall()
        items = [await reward_view(conn, row, viewer["id"] if viewer else None) for row in rows]
    return page(items, offset=offset, limit=limit, fingerprint=key)


@router.get("/rewards/{reward_id}")
async def get_reward(reward_id: str, viewer: dict | None = Depends(optional_user)) -> dict:
    async with await connect() as conn:
        row = await (await conn.execute("SELECT * FROM rewards WHERE id=%s", (reward_id,))).fetchone()
        if row is None:
            raise ApiError(404, "REWARD_UNAVAILABLE", "Nagroda nie jest dostępna.")
        return await reward_view(conn, row, viewer["id"] if viewer else None)


@router.post("/me/redemptions", status_code=201)
async def create_redemption(
    body: RedemptionCreate,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    user: dict = Depends(current_user),
) -> dict:
    key = _check_key(idempotency_key)
    payload = body.model_dump()
    async with await connect() as conn:
        previous = await _claim(conn, user["id"], "redemption", key, payload)
        if previous is not None:
            return previous
        await conn.execute("SELECT id FROM users WHERE id=%s FOR UPDATE", (user["id"],))
        reward = await (
            await conn.execute("SELECT * FROM rewards WHERE id=%s", (body.rewardId,))
        ).fetchone()
        if reward is None or reward["availability"] != "available":
            raise ApiError(422, "REWARD_UNAVAILABLE", "Nagroda nie jest dostępna.")
        if reward["cost_points"] != body.expectedCostPoints:
            raise ApiError(409, "PRICE_CHANGED", "Koszt nagrody uległ zmianie.")
        if body.deliveryMethod not in reward["delivery_methods"]:
            raise ApiError(422, "NOT_ELIGIBLE", "Nieobsługiwany sposób odbioru.")
        viewed = await reward_view(conn, reward, user["id"])
        if not viewed["eligibility"]["eligible"]:
            raise ApiError(403, "NOT_ELIGIBLE", "Brak uprawnień do tej nagrody.")
        current_balance = await balance(conn, user["id"])
        if current_balance < reward["cost_points"]:
            raise ApiError(422, "INSUFFICIENT_POINTS", "Za mało punktów.")
        redemption_id = new_id("redemption")
        row = await (
            await conn.execute(
                """INSERT INTO redemptions(id,user_id,reward_id,reward_name,cost_points,
                delivery_method,status,points_status)
                VALUES (%s,%s,%s,%s,%s,%s,'processing','reserved') RETURNING *""",
                (redemption_id, user["id"], reward["id"], reward["name"], reward["cost_points"], body.deliveryMethod),
            )
        ).fetchone()
        await conn.execute(
            """INSERT INTO points_entries(id,user_id,delta,reason_code,related_redemption_id)
            VALUES (%s,%s,%s,'reward_reserved',%s)""",
            (new_id("pts"), user["id"], -reward["cost_points"], redemption_id),
        )
        result = redemption_view(row, points_balance=current_balance - reward["cost_points"])
        await _complete(conn, user["id"], "redemption", key, result, 201)
        return result


@router.get("/me/redemptions")
async def list_redemptions(
    cursor: str | None = None, limit: int = Query(20, ge=1, le=100),
    user: dict = Depends(current_user),
) -> dict:
    key = fingerprint({"resource": "redemptions", "user": user["id"]})
    offset = parse_cursor(cursor, key)
    async with await connect() as conn:
        rows = await (
            await conn.execute(
                """SELECT * FROM redemptions WHERE user_id=%s
                ORDER BY created_at DESC,id OFFSET %s LIMIT %s""",
                (user["id"], offset, limit + 1),
            )
        ).fetchall()
    return page([redemption_view(row) for row in rows], offset=offset, limit=limit, fingerprint=key)


@router.get("/me/redemptions/{redemption_id}")
async def get_redemption(redemption_id: str, user: dict = Depends(current_user)) -> dict:
    async with await connect() as conn:
        row = await (
            await conn.execute(
                "SELECT * FROM redemptions WHERE id=%s AND user_id=%s", (redemption_id, user["id"]),)
        ).fetchone()
        if row is None:
            raise ApiError(404, "REWARD_UNAVAILABLE", "Nie znaleziono realizacji nagrody.")
        return redemption_view(row, points_balance=await balance(conn, user["id"]))



@router.get("/me/saved-places")
async def list_saved_places(
    cursor: str | None = None, limit: int = Query(20, ge=1, le=100),
    user: dict = Depends(current_user),
) -> dict:
    key = fingerprint({"resource": "saved_places", "user": user["id"]})
    offset = parse_cursor(cursor, key)
    async with await connect() as conn:
        rows = await (await conn.execute(
            """SELECT p.* FROM saved_places s JOIN places p ON p.id=s.place_id
            WHERE s.user_id=%s ORDER BY s.saved_at DESC,p.id OFFSET %s LIMIT %s""",
            (user["id"], offset, limit + 1),
        )).fetchall()
        result = [await place_view(conn, row) for row in rows]
    return page(result, offset=offset, limit=limit, fingerprint=key)


@router.put("/me/saved-places/{place_id}", status_code=204)
async def save_place(place_id: str, user: dict = Depends(current_user)) -> None:
    async with await connect() as conn:
        place = await (await conn.execute("SELECT 1 FROM places WHERE id=%s", (place_id,))).fetchone()
        if place is None:
            raise ApiError(404, "PLACE_NOT_AVAILABLE", "Nie znaleziono miejsca.")
        await conn.execute(
            "INSERT INTO saved_places(user_id,place_id) VALUES (%s,%s) ON CONFLICT DO NOTHING",
            (user["id"], place_id),
        )


@router.delete("/me/saved-places/{place_id}", status_code=204)
async def unsave_place(place_id: str, user: dict = Depends(current_user)) -> None:
    async with await connect() as conn:
        await conn.execute("DELETE FROM saved_places WHERE user_id=%s AND place_id=%s", (user["id"], place_id))
