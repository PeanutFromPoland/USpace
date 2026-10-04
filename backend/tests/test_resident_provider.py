"""The operator response is untrusted even on the private network."""

import asyncio
import sys

import httpx
import pytest

from uspace_api import resident_provider

if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())


def _configure(monkeypatch: pytest.MonkeyPatch, response: dict) -> None:
    monkeypatch.setenv("KINDSPOT_RESIDENT_API_URL", "http://resident-mock/verifications")
    monkeypatch.setenv("KINDSPOT_RESIDENT_API_TOKEN", "test-only-resident-service-token-32-chars")
    monkeypatch.setattr(
        resident_provider, "_client",
        lambda: httpx.AsyncClient(transport=httpx.MockTransport(
            lambda _: httpx.Response(200, json=response)
        )),
    )


def test_provider_rejects_mismatched_identity(monkeypatch: pytest.MonkeyPatch) -> None:
    _configure(monkeypatch, {
        "userId": "another_user", "cityId": "city_krakow", "cardTypeId": "demo_city_card",
        "status": "verified", "validUntil": "2030-12-31", "reasonCode": None,
        "demonstrational": True,
    })
    with pytest.raises(resident_provider.ResidentProviderUnavailable):
        asyncio.run(resident_provider.get_resident_verification(
            "a" * 24, "usr_demo_resident_anna", "city_krakow", "demo_city_card"
        ))


def test_provider_normalizes_expired_confirmation(monkeypatch: pytest.MonkeyPatch) -> None:
    _configure(monkeypatch, {
        "userId": "usr_demo_resident_anna", "cityId": "city_krakow",
        "cardTypeId": "demo_city_card", "status": "verified",
        "validUntil": "2020-01-01", "reasonCode": None, "demonstrational": True,
    })
    result = asyncio.run(resident_provider.get_resident_verification(
        "a" * 24, "usr_demo_resident_anna", "city_krakow", "demo_city_card"
    ))
    assert result.status == "expired"
    assert result.reasonCode == "CARD_EXPIRED"


def test_provider_rejects_confirmation_without_expiry(monkeypatch: pytest.MonkeyPatch) -> None:
    _configure(monkeypatch, {
        "userId": "usr_demo_resident_anna", "cityId": "city_krakow",
        "cardTypeId": "demo_city_card", "status": "verified",
        "validUntil": None, "reasonCode": None, "demonstrational": True,
    })
    with pytest.raises(resident_provider.ResidentProviderUnavailable):
        asyncio.run(resident_provider.get_resident_verification(
            "a" * 24, "usr_demo_resident_anna", "city_krakow", "demo_city_card"
        ))


def test_provider_rejects_start_with_mismatched_identity(monkeypatch: pytest.MonkeyPatch) -> None:
    _configure(monkeypatch, {
        "verificationId": "a" * 24, "userId": "another_user", "cityId": "city_krakow",
        "cardTypeId": "demo_city_card", "demonstrational": True,
    })
    with pytest.raises(resident_provider.ResidentProviderUnavailable):
        asyncio.run(resident_provider.start_resident_verification(
            "usr_demo_resident_anna", "city_krakow", "demo_city_card", "DEMO-KRK-ANNA-0001"
        ))
