"""RED state-transition contracts requiring deterministic synthetic DB fixtures."""

import asyncio
import os
from uuid import uuid4

from fastapi.testclient import TestClient
from test_api_e2e import _new_authenticated_user

from uspace_api.db import connect

API = "/api/v1"


def _seeded_value(name: str) -> str:
    value = os.environ.get(name)
    assert value, f"Synthetic test fixture must provide {name}."
    return value


def _seeded_headers(client: TestClient, prefix: str) -> dict[str, str]:
    response = client.post(
        f"{API}/auth/login",
        json={
            "email": _seeded_value(f"{prefix}_EMAIL"),
            "password": _seeded_value(f"{prefix}_PASSWORD"),
        },
    )
    assert response.status_code == 200, response.text
    return {"Authorization": f"Bearer {response.json()['accessToken']}"}


def test_uc08_bot_accepted_review_has_one_confirmed_points_entry(client: TestClient) -> None:
    headers = _seeded_headers(client, "USPACE_E2E_ACCEPTED_AUTHOR")
    review_id = _seeded_value("USPACE_E2E_ACCEPTED_REVIEW_ID")
    review = client.get(f"{API}/reviews/{review_id}", headers=headers)
    assert review.status_code == 200, review.text
    assert review.json()["publicationStatus"] == "visible"
    assert review.json()["verificationStatus"] == "accepted"
    assert review.json()["pointAward"]["status"] == "granted"
    history = client.get(f"{API}/me/points/history", headers=headers)
    assert history.status_code == 200, history.text
    awards = [
        item
        for item in history.json()["items"]
        if item["relatedReviewId"] == review_id and item["reasonCode"] == "review_accepted"
    ]
    assert len(awards) == 1


def test_uc08_hidden_review_does_not_claim_successful_verification(client: TestClient) -> None:
    headers = _seeded_headers(client, "USPACE_E2E_HIDDEN_AUTHOR")
    review_id = _seeded_value("USPACE_E2E_HIDDEN_REVIEW_ID")
    review = client.get(f"{API}/reviews/{review_id}", headers=headers)
    assert review.status_code == 200, review.text
    assert review.json()["publicationStatus"] == "hidden_pending_moderation"
    assert review.json()["verificationStatus"] != "accepted"
    assert review.json()["pointAward"]["status"] != "granted"


def test_uc11_funded_purchase_is_charged_once_with_server_status(client: TestClient, credentials) -> None:
    user_id, headers = _new_authenticated_user(client, credentials)
    async def fund():
        async with await connect(migration=True) as conn:
            await conn.execute("INSERT INTO points_entries(id,user_id,delta,reason_code) VALUES (%s,%s,1000,'test_funding')",
                               (uuid4().hex, user_id))
    asyncio.run(fund())
    points = client.get(f"{API}/me/points", headers=headers)
    catalogue = client.get(f"{API}/rewards", headers=headers)
    assert points.status_code == catalogue.status_code == 200
    balance = points.json()["balance"]
    purchasable = [
        item
        for item in catalogue.json()["items"]
        if item["availability"] == "available"
        and item["eligibility"]["eligible"]
        and 0 < item["costPoints"] <= balance
    ]
    assert purchasable, "Seed a funded account and an eligible available reward."
    reward = purchasable[0]
    purchase_headers = {**headers, "Idempotency-Key": uuid4().hex}
    payload = {
        "rewardId": reward["id"],
        "expectedCostPoints": reward["costPoints"],
        "deliveryMethod": reward["deliveryMethods"][0],
    }
    first = client.post(f"{API}/me/redemptions", headers=purchase_headers, json=payload)
    repeated = client.post(f"{API}/me/redemptions", headers=purchase_headers, json=payload)
    assert first.status_code == repeated.status_code == 201
    assert first.json()["id"] == repeated.json()["id"]
    assert first.json()["status"] == ("fulfilled" if reward.get("cosmetic") else "processing")
    assert first.json()["pointsStatus"] in {"reserved", "charged"}
    assert first.json()["code"] is None


def test_uc15_ready_and_failed_rewards_show_delivery_and_release(client: TestClient) -> None:
    headers = _seeded_headers(client, "USPACE_E2E_FUNDED_USER")
    ready_id = _seeded_value("USPACE_E2E_READY_REDEMPTION_ID")
    failed_id = _seeded_value("USPACE_E2E_FAILED_REDEMPTION_ID")
    ready = client.get(f"{API}/me/redemptions/{ready_id}", headers=headers)
    failed = client.get(f"{API}/me/redemptions/{failed_id}", headers=headers)
    assert ready.status_code == failed.status_code == 200
    assert ready.json()["status"] == "ready"
    assert ready.json()["code"]
    assert ready.json()["instructions"]
    assert failed.json()["status"] == "failed"
    assert failed.json()["pointsStatus"] == "released"
