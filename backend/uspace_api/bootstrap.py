"""Explicit database setup: python -m uspace_api.bootstrap."""

import asyncio

from uspace_api.db import grant_app_role, install_schema, seed_demo


async def main() -> None:
    await install_schema()
    await seed_demo()
    await grant_app_role()


if __name__ == "__main__":
    asyncio.run(main())
