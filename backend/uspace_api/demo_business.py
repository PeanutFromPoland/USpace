"""Idempotent synthetic business records for the opt-in demonstration database."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

from psycopg import AsyncConnection
from psycopg.types.json import Jsonb

from uspace_api.demo_residents import DEMO_ACCOUNTS, DEMO_CARD_NUMBERS


async def seed_demo_business_data(conn: AsyncConnection) -> None:
    """Fill product-facing tables without changing existing rows or technical tables."""
    anna, jan, expired, tourist = (account[0] for account in DEMO_ACCOUNTS)
    now = datetime.now(UTC)

    for part in (
        ("part_demo_library_side", "place_krakow_library", "entrance", "Wejście boczne", "Przykładowe wejście bez oznaczeń"),
        ("part_demo_station_lift", "place_krakow_station", "other", "Winda przy peronie", "Przykładowa winda"),
        ("part_demo_cafe_entrance", "place_krakow_cafe", "entrance", "Wejście od ulicy", "Przykładowe wejście"),
    ):
        await conn.execute(
            """INSERT INTO place_parts(id,place_id,kind,name,description)
            VALUES (%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING""", part,
        )

    reviews = (
        ("rev_demo_library_anna", "place_krakow_library", anna, "detailed", "visible", "accepted", "granted", 1, "REVIEW_ACCEPTED", 5, 5),
        ("rev_demo_library_jan", "place_krakow_library", jan, "quick", "visible", "accepted", "granted", 1, "REVIEW_ACCEPTED", 9, 3),
        ("rev_demo_station_jan", "place_krakow_station", jan, "detailed", "visible", "accepted", "granted", 1, "REVIEW_ACCEPTED", 7, 2),
        ("rev_demo_cafe_expired", "place_krakow_cafe", expired, "quick", "visible", "accepted", "granted", 1, "REVIEW_ACCEPTED", 12, 4),
        ("rev_demo_cafe_tourist", "place_krakow_cafe", tourist, "detailed", "visible", "accepted", "granted", 1, "REVIEW_ACCEPTED", 4, 3),
        ("rev_demo_hidden_tourist", "place_krakow_library", tourist, "quick", "hidden_pending_moderation", "under_moderation", "not_granted", 0, "CONTENT_MODERATION", 2, None),
    )
    for review_id, place_id, author_id, mode, publication, verification, points, amount, reason, days_ago, recommendation in reviews:
        await conn.execute(
            """INSERT INTO reviews(id,place_id,author_id,visited_on,time_zone,mode,
            publication_status,verification_status,point_status,point_amount,point_reason_code,
            created_at,recommendation)
            VALUES (%s,%s,%s,%s,'Europe/Warsaw',%s,%s,%s,%s,%s,%s,%s,%s)
            ON CONFLICT DO NOTHING""",
            (review_id, place_id, author_id, (now - timedelta(days=days_ago)).date(),
             mode, publication, verification, points, amount, reason,
             now - timedelta(days=days_ago), recommendation),
        )

    answers = (
        ("ans_demo_anna_ramp", "rev_demo_library_anna", "ramp", "part_library_main", "present", "working", 5, "Podjazd przy wejściu głównym był wygodny."),
        ("ans_demo_anna_quiet", "rev_demo_library_anna", "quiet_environment", None, "present", None, 4, "W czytelni było spokojnie."),
        ("ans_demo_anna_toilet", "rev_demo_library_anna", "accessible_toilet", None, "present", "working", 4, "Toaleta była dostępna podczas wizyty."),
        ("ans_demo_jan_ramp", "rev_demo_library_jan", "ramp", "part_library_main", "absent", None, None, "Podczas mojej wizyty nie widziałem podjazdu przy tym wejściu."),
        ("ans_demo_jan_orientation", "rev_demo_library_jan", "orientation", None, "present", None, 3, "Oznaczenia prowadziły do czytelni."),
        ("ans_demo_station_elevator", "rev_demo_station_jan", "elevator", "part_demo_station_lift", "present", "not_working", 2, "Winda była nieczynna w dniu wizyty."),
        ("ans_demo_station_rest", "rev_demo_station_jan", "rest", None, "present", None, 3, "W poczekalni były ławki."),
        ("ans_demo_cafe_quiet", "rev_demo_cafe_expired", "quiet_environment", None, "present", None, 4, "Po południu było dość spokojnie."),
        ("ans_demo_cafe_step", "rev_demo_cafe_tourist", "step_free_entrance", "part_demo_cafe_entrance", "absent", None, None, "Przy wejściu był stopień."),
        ("ans_demo_cafe_light", "rev_demo_cafe_tourist", "gentle_light", None, "present", None, 3, "Oświetlenie było umiarkowane."),
        ("ans_demo_hidden", "rev_demo_hidden_tourist", "ramp", None, "unknown", None, None, "Przykład recenzji wstrzymanej do sprawdzenia."),
    )
    for answer_id, review_id, feature_id, target_id, presence, state, rating, comment in answers:
        score = None if rating is None else Jsonb({"overall": rating, "average_rating": rating})
        await conn.execute(
            """INSERT INTO review_answers(id,review_id,feature_id,target_id,presence,
            operational_state,rating,comment)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING""",
            (answer_id, review_id, feature_id, target_id, presence, state, score, comment),
        )

    for review_id, *_ in reviews:
        accepted = review_id != "rev_demo_hidden_tourist"
        await conn.execute(
            """INSERT INTO moderation_events(id,review_id,decision,provider,duplicate_signal)
            VALUES (%s,%s,%s,'synthetic_fixture',false) ON CONFLICT DO NOTHING""",
            (f"mod_{review_id}", review_id, "accept" if accepted else "moderate"),
        )

    for issue in (
        ("issue_demo_station_lift", "rev_demo_station_jan", "place_krakow_station", "elevator", "part_demo_station_lift", "outage", "Przykład: winda czasowo nieczynna.", "active"),
        ("issue_demo_cafe_entrance", "rev_demo_cafe_tourist", "place_krakow_cafe", "step_free_entrance", "part_demo_cafe_entrance", "construction", "Przykład: prace przy wejściu zostały zakończone.", "resolved"),
    ):
        await conn.execute(
            """INSERT INTO temporary_issues(id,review_id,place_id,feature_id,target_id,
            kind,description,status) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            ON CONFLICT DO NOTHING""", issue,
        )

    for user_id, place_id, days_ago in (
        (jan, "place_krakow_library", 9),
        (expired, "place_krakow_library", 5),
        (anna, "place_krakow_station", 7),
        (tourist, "place_krakow_cafe", 4),
    ):
        await conn.execute(
            """INSERT INTO visit_attestations(user_id,place_id,visited_on,source)
            VALUES (%s,%s,%s,'synthetic_fixture') ON CONFLICT DO NOTHING""",
            (user_id, place_id, (now - timedelta(days=days_ago)).date()),
        )

    votes = (
        ("vote_demo_jan_anna_ramp", "rev_demo_library_anna", "ans_demo_anna_ramp", jan, "confirm", "Zgadzam się z opisem tego wejścia.", anna),
        ("vote_demo_expired_anna_ramp", "rev_demo_library_anna", "ans_demo_anna_ramp", expired, "dispute", "Podczas mojej wizyty wyglądało to inaczej.", anna),
        ("vote_demo_anna_station_lift", "rev_demo_station_jan", "ans_demo_station_elevator", anna, "confirm", "Winda również była nieczynna.", jan),
        ("vote_demo_tourist_cafe", "rev_demo_cafe_expired", "ans_demo_cafe_quiet", tourist, "confirm", None, expired),
    )
    for vote_id, review_id, answer_id, voter_id, verdict, reason, author_id in votes:
        await conn.execute(
            """INSERT INTO votes(id,review_id,answer_id,voter_id,verdict,reason)
            VALUES (%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING""",
            (vote_id, review_id, answer_id, voter_id, verdict, reason),
        )
        vote_exists = await (await conn.execute(
            "SELECT 1 FROM votes WHERE id=%s", (vote_id,),
        )).fetchone()
        if vote_exists is None:
            continue
        await conn.execute(
            """INSERT INTO points_entries(id,user_id,delta,reason_code,
            related_review_id,related_verification_id)
            VALUES (%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING""",
            (f"pts_{vote_id}", author_id, 1 if verdict == "confirm" else -1,
             "observation_confirmed" if verdict == "confirm" else "observation_disputed",
             review_id, vote_id),
        )

    for review_id, _, author_id, _, _, verification, *_ in reviews:
        if verification != "accepted":
            continue
        await conn.execute(
            """INSERT INTO points_entries(id,user_id,delta,reason_code,related_review_id)
            VALUES (%s,%s,1,'review_accepted',%s) ON CONFLICT DO NOTHING""",
            (f"pts_{review_id}", author_id, review_id),
        )

    for point_id, user_id, amount in (
        ("pts_demo_funding_anna", anna, 50),
        ("pts_demo_funding_jan", jan, 25),
        ("pts_demo_funding_expired", expired, 5),
    ):
        await conn.execute(
            """INSERT INTO points_entries(id,user_id,delta,reason_code)
            VALUES (%s,%s,%s,'synthetic_demo_funding') ON CONFLICT DO NOTHING""",
            (point_id, user_id, amount),
        )

    for report in (
        ("report_demo_ramp", "rev_demo_library_anna", tourist, "suspected_false", "Przykładowe zgłoszenie sprzecznej obserwacji."),
        ("report_demo_cafe", "rev_demo_cafe_tourist", anna, "other", "Przykładowe zgłoszenie do sprawdzenia."),
    ):
        await conn.execute(
            """INSERT INTO reports(id,review_id,reporter_id,reason_code,description)
            VALUES (%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING""", report,
        )

    redemptions = (
        ("redemption_demo_anna_frame", anna, "reward_frame", "Obręcz z kokardą", 5, "account_item", "fulfilled", "charged", None, "Element dostępny na koncie."),
        ("redemption_demo_jan_code", jan, "reward_code", "Kod demonstracyjny", 10, "pickup_code", "ready", "charged", "DEMO-JAN-CODE", "Pokaż fikcyjny kod przy odbiorze."),
        ("redemption_demo_jan_failed", jan, "reward_code", "Kod demonstracyjny", 10, "pickup_code", "failed", "released", None, None),
    )
    for redemption_id, user_id, reward_id, name, cost, method, status, points_status, code, instructions in redemptions:
        await conn.execute(
            """INSERT INTO redemptions(id,user_id,reward_id,reward_name,cost_points,
            delivery_method,status,points_status,code,instructions,failure_code)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING""",
            (redemption_id, user_id, reward_id, name, cost, method, status, points_status,
             code, instructions, "SYNTHETIC_FAILURE" if status == "failed" else None),
        )
        reason = "reward_purchased" if method == "account_item" else "reward_reserved"
        await conn.execute(
            """INSERT INTO points_entries(id,user_id,delta,reason_code,related_redemption_id)
            VALUES (%s,%s,%s,%s,%s) ON CONFLICT DO NOTHING""",
            (f"pts_{redemption_id}", user_id, -cost, reason, redemption_id),
        )
        if status == "failed":
            await conn.execute(
                """INSERT INTO points_entries(id,user_id,delta,reason_code,related_redemption_id)
                VALUES (%s,%s,%s,'reward_released',%s) ON CONFLICT DO NOTHING""",
                (f"pts_{redemption_id}_released", user_id, cost, redemption_id),
            )

    for user_id, status, valid_until, reason in (
        (anna, "verified", (now + timedelta(days=1095)).date(), None),
        (jan, "verified", (now + timedelta(days=1095)).date(), None),
        (expired, "expired", datetime(2020, 1, 1, tzinfo=UTC).date(), "CARD_EXPIRED"),
        (tourist, "rejected", None, "CARD_OWNERSHIP_NOT_CONFIRMED"),
    ):
        await conn.execute(
            """INSERT INTO card_verifications(id,user_id,city_id,card_type_id,status,
            card_masked,valid_until,reason_code,demo_result)
            VALUES (%s,%s,'city_krakow','demo_city_card',%s,%s,%s,%s,%s)
            ON CONFLICT DO NOTHING""",
            (f"card_seed_{user_id}", user_id, status,
             "••••" + DEMO_CARD_NUMBERS[user_id][-4:], valid_until, reason, status),
        )

    for user_id, place_id in (
        (anna, "place_krakow_station"),
        (jan, "place_krakow_library"),
        (tourist, "place_krakow_cafe"),
    ):
        await conn.execute(
            """INSERT INTO saved_places(user_id,place_id) VALUES (%s,%s)
            ON CONFLICT DO NOTHING""", (user_id, place_id),
        )

    for user_id, title_id, label in (
        (anna, "title_community_guide", "Przewodniczka społeczności — demo"),
        (jan, "title_city_explorer", "Odkrywca miasta — demo"),
    ):
        await conn.execute(
            """INSERT INTO earned_titles(user_id,title_id,label)
            VALUES (%s,%s,%s) ON CONFLICT DO NOTHING""", (user_id, title_id, label),
        )

    await conn.execute(
        """UPDATE users SET preferences=%s WHERE id=%s
        AND preferences='{"needIds":[],"presetIds":[],"rules":[]}'::jsonb""",
        (Jsonb({"needIds": ["wheelchair"], "presetIds": ["step_free"],
                "rules": [], "namedFilters": []}), anna),
    )
    await conn.execute(
        """UPDATE users SET preferences=%s WHERE id=%s
        AND preferences='{"needIds":[],"presetIds":[],"rules":[]}'::jsonb""",
        (Jsonb({"needIds": ["noise"], "presetIds": ["quiet"],
                "rules": [], "namedFilters": []}), jan),
    )
