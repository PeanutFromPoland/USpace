"""Password hashing and revocable, short-lived bearer sessions."""

from __future__ import annotations

import hashlib
import hmac
import secrets
from datetime import UTC, datetime, timedelta

from fastapi import Header

from uspace_api.db import connect
from uspace_api.errors import ApiError

SESSION_HOURS = 12
PBKDF2_ITERATIONS = 600_000


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(32)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, PBKDF2_ITERATIONS)
    return f"pbkdf2_sha256${PBKDF2_ITERATIONS}${salt.hex()}${digest.hex()}"


def verify_password(password: str, encoded: str) -> bool:
    try:
        algorithm, iterations, salt, expected = encoded.split("$")
        if algorithm != "pbkdf2_sha256":
            return False
        actual = hashlib.pbkdf2_hmac(
            "sha256", password.encode("utf-8"), bytes.fromhex(salt), int(iterations)
        )
        return hmac.compare_digest(actual, bytes.fromhex(expected))
    except (ValueError, TypeError):
        return False


def token_hash(token: str) -> str:
    return hashlib.sha256(token.encode("ascii")).hexdigest()


async def issue_session(user_id: str) -> tuple[str, datetime]:
    token = secrets.token_urlsafe(48)
    expires = datetime.now(UTC) + timedelta(hours=SESSION_HOURS)
    async with await connect() as conn:
        await conn.execute(
            "INSERT INTO sessions(token_hash,user_id,expires_at) VALUES (%s,%s,%s)",
            (token_hash(token), user_id, expires),
        )
    return token, expires


async def current_user(authorization: str | None = Header(default=None)) -> dict:
    if not authorization or not authorization.startswith("Bearer "):
        raise ApiError(401, "SESSION_EXPIRED", "Zaloguj się ponownie.")
    token = authorization[7:]
    if not token or len(token) > 256:
        raise ApiError(401, "SESSION_EXPIRED", "Zaloguj się ponownie.")
    async with await connect() as conn:
        row = await (
            await conn.execute(
                """SELECT u.* FROM sessions s JOIN users u ON u.id=s.user_id
                WHERE s.token_hash=%s AND s.revoked_at IS NULL AND s.expires_at>now()""",
                (token_hash(token),),
            )
        ).fetchone()
    if row is None:
        raise ApiError(401, "SESSION_EXPIRED", "Zaloguj się ponownie.")
    return row


async def optional_user(authorization: str | None = Header(default=None)) -> dict | None:
    if not authorization:
        return None
    return await current_user(authorization)


async def revoke_session(authorization: str) -> None:
    token = authorization.removeprefix("Bearer ")
    async with await connect() as conn:
        await conn.execute(
            "UPDATE sessions SET revoked_at=now() WHERE token_hash=%s", (token_hash(token),)
        )
