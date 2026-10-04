"""Synthetic identities shared by demo account seeding and the mock operator."""

from __future__ import annotations

from psycopg.types.json import Jsonb

from uspace_api.auth import hash_password
from uspace_api.db import connect

DEMO_ACCOUNTS = (
    ("usr_demo_resident_anna", "anna.mieszkanka@kindspot.invalid", "Mieszkanka Demo Anna"),
    ("usr_demo_resident_jan", "jan.mieszkaniec@kindspot.invalid", "Mieszkaniec Demo Jan"),
    ("usr_demo_resident_expired", "wygasla.karta@kindspot.invalid", "Mieszkaniec Demo — karta wygasła"),
    ("usr_demo_tourist", "turysta@kindspot.invalid", "Turysta Demo"),
)

VERIFIED_RESIDENT_IDS = {DEMO_ACCOUNTS[0][0], DEMO_ACCOUNTS[1][0]}
EXPIRED_RESIDENT_ID = DEMO_ACCOUNTS[2][0]
DEMO_CARD_NUMBERS = {
    DEMO_ACCOUNTS[0][0]: "DEMO-KRK-ANNA-0001",
    DEMO_ACCOUNTS[1][0]: "DEMO-KRK-JAN-0002",
    DEMO_ACCOUNTS[2][0]: "DEMO-KRK-EXPIRED-0003",
    DEMO_ACCOUNTS[3][0]: "DEMO-KRK-TOURIST-0004",
}


async def seed_demo_accounts(password: str) -> None:
    """Create login-capable synthetic accounts; rotating the configured password is safe."""
    if len(password) < 12 or len(password) > 256 or password.startswith("replace-"):
        raise ValueError("KINDSPOT_DEMO_ACCOUNT_PASSWORD must contain 12–256 characters")
    appearance = Jsonb({"avatarId": "avatar_default", "frameId": "frame_default", "titleId": "title_default"})
    async with await connect(migration=True) as conn:
        for user_id, email, display_name in DEMO_ACCOUNTS:
            await conn.execute(
                """INSERT INTO users(id,email,password_hash,display_name,appearance)
                VALUES (%s,%s,%s,%s,%s)
                ON CONFLICT (id) DO UPDATE SET password_hash=EXCLUDED.password_hash""",
                (user_id, email, hash_password(password), display_name, appearance),
            )
