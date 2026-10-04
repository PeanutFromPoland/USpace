"""Explicit synthetic test account setup; never run during application startup.

Usage: KINDSPOT_TEST_EMAIL / KINDSPOT_TEST_PASSWORD environment, then
python -m uspace_api.test_account [--reset]. Only touches this synthetic account.
"""
import argparse
import asyncio
import os

from psycopg.types.json import Jsonb

from uspace_api.auth import hash_password
from uspace_api.db import connect
from uspace_api.models import Register
from uspace_api.views import new_id


async def prepare(reset: bool = False) -> None:
    # .invalid ensures the setup cannot be used accidentally on a real address.
    email = os.environ.get("KINDSPOT_TEST_EMAIL", "hackaton@example.invalid").strip().lower()
    if not email.endswith("@example.invalid"):
        raise ValueError("Use a synthetic @example.invalid test address")
    data = Register(email=email, password=os.environ["KINDSPOT_TEST_PASSWORD"], displayName="Test Hackaton")
    async with await connect(migration=True) as conn:
        user = await (await conn.execute("SELECT id,preferences,ui_settings FROM users WHERE email=%s FOR UPDATE", (email,))).fetchone()
        if user is not None and reset:
            # Reviews and community votes remain; this resets the test wallet and purchases.
            for table in ("idempotency_records", "sessions", "saved_places", "points_entries", "redemptions", "visit_attestations", "demo_card_entitlements", "card_verifications"):
                await conn.execute(f"DELETE FROM {table} WHERE user_id=%s", (user["id"],))
            preferences = {"needIds": [], "presetIds": [], "rules": [], "namedFilters": user["preferences"].get("namedFilters", [])}
            ui = dict(user["ui_settings"])
            # Purchased colour themes are cosmetics, not accessibility grants.
            if ui.get("colorThemeId") in {"explorer", "gardener"}:
                ui["colorThemeId"] = "green"
            appearance = {"avatarId": "avatar_default", "frameId": "frame_default", "titleId": "title_default"}
            await conn.execute("UPDATE users SET display_name='Test Hackaton',helper_opt_in=false,privacy=%s,preferences=%s,appearance=%s,ui_settings=%s WHERE id=%s",
                (Jsonb({"needsVisibility": "private"}), Jsonb(preferences), Jsonb(appearance), Jsonb(ui), user["id"]))
            await conn.execute("INSERT INTO points_entries(id,user_id,delta,reason_code) VALUES (%s,%s,1000,'test_account_initial')",
                (new_id("pts"), user["id"]))
        if user is None:
            uid = new_id("usr")
            await conn.execute("""INSERT INTO users(id,email,password_hash,display_name,appearance)
                VALUES (%s,%s,%s,%s,%s)""", (uid, email, hash_password(data.password), data.displayName,
                Jsonb({"avatarId": "avatar_default", "frameId": "frame_default", "titleId": "title_default"})))
            await conn.execute("""INSERT INTO points_entries(id,user_id,delta,reason_code)
                VALUES (%s,%s,1000,'test_account_initial')""", (new_id("pts"), uid))
        if user is None or reset:
            uid = uid if user is None else user["id"]
            await conn.execute("""INSERT INTO places(id,name,category_id,city_id,address,lat,lon,features)
                VALUES ('place_test_garden','Ogród ciszy (konto testowe)','park','city_krakow',
                'Miejsce syntetyczne, Kraków',50.06,19.94,'[]'::jsonb) ON CONFLICT DO NOTHING""")
            garden = await (await conn.execute("SELECT id FROM places WHERE id=%s", ("place_test_garden",))).fetchone()
            if garden:
                await conn.execute("INSERT INTO saved_places(user_id,place_id) VALUES (%s,%s)", (uid, garden["id"]))
    print("Test account ready. Credentials are not printed. Existing balance is kept unless --reset is used.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--reset", action="store_true")
    asyncio.run(prepare(parser.parse_args().reset))
