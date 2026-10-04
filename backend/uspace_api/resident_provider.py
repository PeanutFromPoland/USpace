"""Asynchronous HTTP boundary for the synthetic resident-status operator."""

from __future__ import annotations

import os
import re
from datetime import UTC, date, datetime
from typing import Literal

import httpx
from pydantic import BaseModel, ConfigDict, ValidationError


class ResidentProviderUnavailable(Exception):
    """Transport or response failed; it does not mean the user is not a resident."""


class StartedVerification(BaseModel):
    model_config = ConfigDict(extra="forbid")

    verificationId: str
    userId: str
    cityId: str
    cardTypeId: str
    demonstrational: Literal[True]


class VerificationResult(BaseModel):
    model_config = ConfigDict(extra="forbid")

    userId: str
    cityId: str
    cardTypeId: str
    status: Literal["verified", "expired", "rejected"]
    validUntil: date | None
    reasonCode: Literal["CARD_OWNERSHIP_NOT_CONFIRMED", "CARD_EXPIRED"] | None
    demonstrational: Literal[True]


def _client() -> httpx.AsyncClient:
    return httpx.AsyncClient(timeout=5, trust_env=False)


def _settings() -> tuple[str, dict[str, str]]:
    url = os.environ.get("KINDSPOT_RESIDENT_API_URL", "").rstrip("/")
    token = os.environ.get("KINDSPOT_RESIDENT_API_TOKEN", "")
    try:
        parsed = httpx.URL(url) if url else None
    except httpx.InvalidURL as exc:
        raise ResidentProviderUnavailable("Synthetic operator URL is invalid") from exc
    if (
        parsed is None or parsed.scheme not in {"http", "https"} or not parsed.host
        or parsed.userinfo or parsed.query or parsed.fragment
        or len(token) < 32 or token.startswith("replace-")
    ):
        raise ResidentProviderUnavailable("Synthetic operator is not configured")
    return url, {"Authorization": f"Bearer {token}"}


async def start_resident_verification(
    user_id: str, city_id: str, card_type_id: str, card_number: str,
) -> str:
    url, headers = _settings()
    try:
        async with _client() as client:
            response = await client.post(
                url, headers=headers,
                json={"userId": user_id, "cityId": city_id,
                      "cardTypeId": card_type_id, "cardNumber": card_number},
            )
            response.raise_for_status()
            started = StartedVerification.model_validate(response.json())
    except (httpx.HTTPError, ValidationError, ValueError, KeyError, TypeError) as exc:
        raise ResidentProviderUnavailable("Synthetic operator did not accept verification") from exc
    if (started.userId, started.cityId, started.cardTypeId) != (user_id, city_id, card_type_id):
        raise ResidentProviderUnavailable("Synthetic operator returned a mismatched identity")
    if not re.fullmatch(r"[A-Za-z0-9_-]{24,128}", started.verificationId):
        raise ResidentProviderUnavailable("Synthetic operator returned an invalid reference")
    return started.verificationId


async def get_resident_verification(
    verification_id: str, user_id: str, city_id: str, card_type_id: str,
) -> VerificationResult:
    if not re.fullmatch(r"[A-Za-z0-9_-]{24,128}", verification_id):
        raise ResidentProviderUnavailable("Synthetic operator reference is invalid")
    url, headers = _settings()
    try:
        async with _client() as client:
            response = await client.get(f"{url}/{verification_id}", headers=headers)
            response.raise_for_status()
            result = VerificationResult.model_validate(response.json())
    except (httpx.HTTPError, ValidationError, ValueError, KeyError, TypeError) as exc:
        raise ResidentProviderUnavailable("Synthetic operator did not return a valid result") from exc
    if (result.userId, result.cityId, result.cardTypeId) != (user_id, city_id, card_type_id):
        raise ResidentProviderUnavailable("Synthetic operator returned a mismatched identity")
    if result.status == "verified" and result.validUntil is None:
        raise ResidentProviderUnavailable("Synthetic operator omitted verification expiry")
    if result.status == "verified" and result.validUntil < datetime.now(UTC).date():
        return result.model_copy(update={"status": "expired", "reasonCode": "CARD_EXPIRED"})
    return result
