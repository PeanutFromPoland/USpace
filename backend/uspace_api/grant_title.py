"""Explicit operator award, using the migration role. No automatic earning rules.

Only run after the operator has confirmed an achievement. Credentials stay in env.
"""
import argparse
import asyncio
import re

from uspace_api.db import connect


async def grant(user_id: str, title_id: str, label: str) -> None:
    if not re.fullmatch(r"title_[a-z0-9_]{1,54}", title_id) or title_id == "title_default":
        raise ValueError("Use a title_ identifier other than title_default")
    label = label.strip()
    if not 1 <= len(label) <= 60:
        raise ValueError("Title label must contain 1-60 characters")
    async with await connect(migration=True) as conn:
        user = await (await conn.execute("SELECT id FROM users WHERE id=%s FOR UPDATE", (user_id,))).fetchone()
        if user is None:
            raise ValueError("Account not found")
        await conn.execute("""INSERT INTO earned_titles(user_id,title_id,label)
            VALUES (%s,%s,%s) ON CONFLICT(user_id,title_id) DO NOTHING""", (user_id, title_id, label))
    print("Confirmed title stored. No points were granted.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--user-id", required=True)
    parser.add_argument("--title-id", required=True)
    parser.add_argument("--label", required=True)
    args = parser.parse_args()
    asyncio.run(grant(args.user_id, args.title_id, args.label))
