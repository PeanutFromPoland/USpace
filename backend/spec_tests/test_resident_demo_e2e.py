"""HTTP journeys for the synthetic resident operator and login-capable demo users."""

import asyncio
import os

import httpx
import pytest
from fastapi.testclient import TestClient

from uspace_api import mock_resident_api, resident_provider
from uspace_api.db import connect
from uspace_api.demo_residents import DEMO_ACCOUNTS, DEMO_CARD_NUMBERS

API = "/api/v1"
CARD = {"cityId": "city_krakow", "cardTypeId": "demo_city_card"}


def _login(client: TestClient, email: str) -> tuple[str, dict[str, str]]:
    result = client.post(
        f"{API}/auth/login",
        json={"email": email, "password": os.environ["USPACE_E2E_DEMO_ACCOUNT_PASSWORD"]},
    )
    assert result.status_code == 200, result.text
    return result.json()["me"]["id"], {"Authorization": f"Bearer {result.json()['accessToken']}"}


def _verification(client: TestClient, headers: dict[str, str], user_id: str) -> dict:
    created = client.post(f"{API}/me/card-verifications", headers=headers,
                          json={**CARD, "cardNumber": DEMO_CARD_NUMBERS[user_id]})
    assert created.status_code == 202, created.text
    assert created.json()["status"] == "pending"
    result = client.get(f"{API}/me/card-verifications/{created.json()['id']}", headers=headers)
    assert result.status_code == 200, result.text
    return result.json()


def test_demo_resident_can_log_in_and_verify_city_status(client: TestClient) -> None:
    user_id, headers = _login(client, DEMO_ACCOUNTS[0][1])
    assert user_id == DEMO_ACCOUNTS[0][0]
    result = _verification(client, headers, user_id)
    assert result["status"] == "verified"
    assert result["cityId"] == "city_krakow"
    assert result["demonstrational"] is True
    assert result["validUntil"] is not None
    assert "cardNumber" not in result
    me = client.get(f"{API}/me", headers=headers).json()
    assert me["memberships"][0]["status"] == "verified"
    assert me["memberships"][0]["cardMasked"] == "••••0001"
    assert DEMO_CARD_NUMBERS[user_id] not in str(me)

    async def stored_card() -> dict:
        async with await connect(migration=True) as conn:
            return await (await conn.execute(
                "SELECT card_masked,provider_verification_id FROM card_verifications WHERE id=%s",
                (result["id"],),
            )).fetchone()

    stored = asyncio.run(stored_card())
    assert stored["card_masked"] == "••••0001"
    assert stored["provider_verification_id"]
    assert DEMO_CARD_NUMBERS[user_id] not in str(stored)
    reward = client.get(f"{API}/rewards/reward_code", headers=headers).json()
    assert reward["eligibility"]["eligible"] is True
    other_city = client.post(
        f"{API}/me/card-verifications", headers=headers,
        json={"cityId": "city_other", "cardTypeId": "demo_city_card",
              "cardNumber": DEMO_CARD_NUMBERS[user_id]},
    )
    assert other_city.status_code == 422
    missing_number = client.post(f"{API}/me/card-verifications", headers=headers, json=CARD)
    assert missing_number.status_code == 422
    wrong_number = client.post(
        f"{API}/me/card-verifications", headers=headers,
        json={**CARD, "cardNumber": DEMO_CARD_NUMBERS[DEMO_ACCOUNTS[1][0]]},
    )
    assert wrong_number.status_code == 202
    wrong_status = client.get(f"{API}/me/card-verifications/{wrong_number.json()['id']}", headers=headers)
    assert wrong_status.json()["status"] == "rejected"
    assert client.get(f"{API}/me", headers=headers).json()["memberships"][0]["status"] == "verified"


def test_expired_card_and_tourist_do_not_gain_resident_benefit(client: TestClient) -> None:
    expired_id, expired_headers = _login(client, DEMO_ACCOUNTS[2][1])
    expired = _verification(client, expired_headers, expired_id)
    assert expired["status"] == "expired"
    assert expired["reasonCode"] == "CARD_EXPIRED"
    assert client.get(f"{API}/rewards/reward_code", headers=expired_headers).json()["eligibility"]["eligible"] is False

    tourist_id, tourist_headers = _login(client, DEMO_ACCOUNTS[3][1])
    tourist = _verification(client, tourist_headers, tourist_id)
    assert tourist["status"] == "rejected"
    assert tourist["reasonCode"] == "CARD_OWNERSHIP_NOT_CONFIRMED"
    assert client.get(f"{API}/rewards/reward_code", headers=tourist_headers).json()["eligibility"]["eligible"] is False


def test_operator_outage_keeps_pending_request_and_prior_valid_status(
    client: TestClient, monkeypatch: pytest.MonkeyPatch,
) -> None:
    user_id, headers = _login(client, DEMO_ACCOUNTS[1][1])
    assert _verification(client, headers, user_id)["status"] == "verified"
    body = {**CARD, "cardNumber": DEMO_CARD_NUMBERS[user_id]}
    created = client.post(f"{API}/me/card-verifications", headers=headers, json=body).json()
    original_client = resident_provider._client
    monkeypatch.setattr(
        resident_provider, "_client",
        lambda: httpx.AsyncClient(transport=httpx.MockTransport(lambda _: httpx.Response(503))),
    )
    unavailable = client.get(f"{API}/me/card-verifications/{created['id']}", headers=headers)
    assert unavailable.status_code == 503
    assert unavailable.json()["error"]["code"] == "CARD_PROVIDER_UNAVAILABLE"
    assert unavailable.json()["error"]["retryable"] is True
    repeated = client.post(f"{API}/me/card-verifications", headers=headers, json=body)
    assert repeated.status_code == 503
    monkeypatch.setattr(resident_provider, "_client", original_client)
    repeated = client.post(f"{API}/me/card-verifications", headers=headers, json=body)
    assert repeated.json()["id"] == created["id"]
    assert client.get(f"{API}/me", headers=headers).json()["memberships"][0]["status"] == "verified"
    recovered = client.get(f"{API}/me/card-verifications/{created['id']}", headers=headers)
    assert recovered.json()["status"] == "verified"


def test_operator_requires_service_token_and_ignores_claimed_status(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("KINDSPOT_RESIDENT_API_TOKEN", "test-only-resident-service-token-32-chars")
    with TestClient(mock_resident_api.app) as operator:
        unauthenticated = operator.post("/verifications", json={
            "userId": DEMO_ACCOUNTS[0][0], **CARD,
            "cardNumber": DEMO_CARD_NUMBERS[DEMO_ACCOUNTS[0][0]],
        })
        assert unauthenticated.status_code == 401
        assert operator.get("/verifications/unknown").status_code == 401
        claimed = operator.post(
            "/verifications",
            headers={"Authorization": "Bearer test-only-resident-service-token-32-chars"},
            json={"userId": DEMO_ACCOUNTS[3][0], **CARD,
                  "cardNumber": DEMO_CARD_NUMBERS[DEMO_ACCOUNTS[3][0]], "status": "verified"},
        )
        assert claimed.status_code == 422
