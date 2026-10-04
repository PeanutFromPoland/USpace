"""Explicit database setup: python -m uspace_api.bootstrap."""

import asyncio
import os

from uspace_api.db import grant_app_role, install_schema, seed_demo
from uspace_api.demo_residents import seed_demo_accounts


async def main() -> None:
    await install_schema()
    await seed_demo()
    if os.environ.get("KINDSPOT_ENABLE_DEMO_RESIDENTS", "false").lower() in {"true", "1"}:
        password = os.environ.get("KINDSPOT_DEMO_ACCOUNT_PASSWORD", "")
        await seed_demo_accounts(password)
    await grant_app_role()


if __name__ == "__main__":
    asyncio.run(main())
