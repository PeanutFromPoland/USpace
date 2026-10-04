"""Private HTTP mock of a city-card operator; synthetic accounts and cards only."""

from __future__ import annotations

import hmac
import os
import secrets
import time
from collections import OrderedDict
from datetime import UTC, datetime, timedelta
from typing import Literal

from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel, ConfigDict

from uspace_api.demo_residents import DEMO_CARD_NUMBERS, EXPIRED_RESIDENT_ID, VERIFIED_RESIDENT_IDS

app = FastAPI(
    title="KindSpot synthetic resident operator", docs_url=None, redoc_url=None, openapi_url=None
)

# Ephemeral operator state. Restarting the mock requires submitting the demo card again.
_checks: OrderedDict[str, tuple[float, dict]] = OrderedDict()
_MAX_CHECKS = 1000
_CHECK_LIFETIME_SECONDS = 24 * 60 * 60


class VerifyRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    userId: str
    cityId: str
    cardTypeId: str
    cardNumber: str


def _authorize(authorization: str | None) -> None:
    secret = os.environ.get("KINDSPOT_RESIDENT_API_TOKEN", "")
    supplied = authorization.removeprefix("Bearer ") if authorization else ""
    if len(secret) < 32 or secret.startswith("replace-") or not hmac.compare_digest(supplied, secret):
        raise HTTPException(status_code=401, detail="Unauthorized")


@app.get("/health/live")
async def live() -> dict[str, str]:
    secret = os.environ.get("KINDSPOT_RESIDENT_API_TOKEN", "")
    if len(secret) < 32 or secret.startswith("replace-"):
        raise HTTPException(status_code=503, detail="Mock operator is not configured")
    return {"status": "ok"}


@app.post("/verifications", status_code=201)
async def verify(body: VerifyRequest, authorization: str | None = Header(default=None)) -> dict:
    _authorize(authorization)
    if body.cityId != "city_krakow" or body.cardTypeId != "demo_city_card":
        raise HTTPException(status_code=422, detail="Unsupported synthetic card")

    status: Literal["verified", "expired", "rejected"] = "rejected"
    valid_until = None
    reason = "CARD_OWNERSHIP_NOT_CONFIRMED"
    expected = DEMO_CARD_NUMBERS.get(body.userId, "")
    if expected and hmac.compare_digest(body.cardNumber, expected):
        if body.userId in VERIFIED_RESIDENT_IDS:
            status = "verified"
            valid_until = (datetime.now(UTC).date() + timedelta(days=365 * 3)).isoformat()
            reason = None
        elif body.userId == EXPIRED_RESIDENT_ID:
            status = "expired"
            valid_until = "2020-01-01"
            reason = "CARD_EXPIRED"

    now = time.monotonic()
    for key, (created, _) in list(_checks.items()):
        if now - created > _CHECK_LIFETIME_SECONDS:
            del _checks[key]
    verification_id = secrets.token_urlsafe(24)
    _checks[verification_id] = (now, {
        "userId": body.userId, "cityId": body.cityId, "cardTypeId": body.cardTypeId,
        "status": status, "validUntil": valid_until, "reasonCode": reason,
        "demonstrational": True,
    })
    if len(_checks) > _MAX_CHECKS:
        _checks.popitem(last=False)
    return {
        "verificationId": verification_id, "userId": body.userId,
        "cityId": body.cityId, "cardTypeId": body.cardTypeId,
        "demonstrational": True,
    }


@app.get("/verifications/{verification_id}")
async def verification_result(
    verification_id: str, authorization: str | None = Header(default=None),
) -> dict:
    _authorize(authorization)
    record = _checks.get(verification_id)
    if record is None or time.monotonic() - record[0] > _CHECK_LIFETIME_SECONDS:
        _checks.pop(verification_id, None)
        raise HTTPException(status_code=404, detail="Verification unavailable")
    return record[1]
