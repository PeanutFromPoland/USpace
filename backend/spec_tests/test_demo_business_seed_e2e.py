"""The opt-in demo database presents coherent product data without touching operations."""

import asyncio

from uspace_api.db import connect
from uspace_api.demo_business import seed_demo_business_data
from uspace_api.demo_residents import DEMO_ACCOUNTS
from uspace_api.views import me_view, place_view, reward_view

BUSINESS_TABLES = (
    "users", "places", "place_parts", "reviews", "review_answers",
    "moderation_events", "temporary_issues", "visit_attestations", "votes",
    "reports", "points_entries", "rewards", "redemptions",
    "card_verifications", "saved_places", "earned_titles",
)
TECHNICAL_TABLES = ("sessions", "login_attempts", "idempotency_records")


def test_demo_business_seed_is_complete_repeatable_and_private(synthetic_database: None) -> None:
    async def check() -> None:
        async with await connect(migration=True) as conn:
            async def counts(tables: tuple[str, ...]) -> dict[str, int]:
                return {
                    table: (await (await conn.execute(f"SELECT count(*) AS n FROM {table}")).fetchone())["n"]
                    for table in tables
                }

            await conn.execute("SAVEPOINT business_seed_check")
            try:
                technical_before = await counts(TECHNICAL_TABLES)
                await seed_demo_business_data(conn)
                first_counts = await counts(BUSINESS_TABLES)
                assert all(count > 0 for count in first_counts.values()), first_counts
                assert first_counts["reviews"] >= 6
                assert first_counts["votes"] >= 4
                assert first_counts["redemptions"] >= 3

                anna = await (await conn.execute(
                    "SELECT * FROM users WHERE id=%s", (DEMO_ACCOUNTS[0][0],)
                )).fetchone()
                profile = await me_view(conn, anna)
                assert profile["pointsBalance"] == 46
                assert profile["memberships"][0]["status"] == "verified"
                assert profile["stats"]["reviewCount"] >= 1
                assert profile["privacy"]["needsVisibility"] == "private"
                assert profile["achievements"]

                library = await (await conn.execute(
                    "SELECT * FROM places WHERE id='place_krakow_library'"
                )).fetchone()
                detail = await place_view(conn, library, detail=True)
                assert any(
                    feature["featureId"] == "ramp" and feature["targetId"] == "part_library_main"
                    and feature["presence"] == "disputed"
                    for feature in detail["features"]
                )
                reward = await (await conn.execute(
                    "SELECT * FROM rewards WHERE id='reward_code'"
                )).fetchone()
                assert (await reward_view(conn, reward, anna["id"]))["eligibility"]["eligible"] is True

                await seed_demo_business_data(conn)
                assert await counts(BUSINESS_TABLES) == first_counts
                assert await counts(TECHNICAL_TABLES) == technical_before
            finally:
                await conn.execute("ROLLBACK TO SAVEPOINT business_seed_check")

    asyncio.run(check())
