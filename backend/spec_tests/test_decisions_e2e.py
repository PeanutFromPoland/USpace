"""E2E coverage for the decisions made after the v0.1 contract draft."""

import asyncio
import json
import os
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient

from uspace_api import worker
from uspace_api.db import connect
from uspace_api.worker import process_one_redemption, process_one_review

API = "/api/v1"
PLACE = "place_krakow_library"


def _user(client: TestClient) -> tuple[str, dict[str, str]]:
    email = f"decision-{uuid4().hex}@example.invalid"
    password = "Test-pass-decision-123!"
    created = client.post(
        f"{API}/auth/register",
        json={"email": email, "password": password, "displayName": "Osoba testowa"},
    )
    assert created.status_code == 201, created.text
    login = client.post(f"{API}/auth/login", json={"email": email, "password": password})
    assert login.status_code == 200, login.text
    return created.json()["userId"], {"Authorization": f"Bearer {login.json()['accessToken']}"}


def _review(
    client: TestClient, headers: dict[str, str], presence: str = "present",
    comment: str | None = None,
) -> dict:
    body = {
        "mode": "quick", "visitedOn": "2026-01-01", "visitedAtLocalTime": None,
        "timeZone": "Europe/Warsaw", "newParts": [],
        "answers": [{
            "clientId": "a", "featureId": "ramp", "targetId": None,
            "targetClientId": None, "presence": presence,
            "operationalState": None, "rating": None, "comment": comment,
        }],
        "temporaryIssues": [],
    }
    response = client.post(
        f"{API}/places/{PLACE}/reviews",
        headers={**headers, "Idempotency-Key": uuid4().hex}, json=body,
    )
    assert response.status_code == 201, response.text
    return response.json()


def test_dispute_debits_author_and_balance_may_be_negative(client: TestClient) -> None:
    _, author = _user(client)
    _, voter = _user(client)
    _, second_voter = _user(client)
    review = _review(client, author)
    assert asyncio.run(process_one_review(review["id"])) is True
    answer_id = review["answers"][0]["id"]
    vote = client.post(
        f"{API}/reviews/{review['id']}/answers/{answer_id}/votes",
        headers={**voter, "Idempotency-Key": uuid4().hex},
        json={"verdict": "dispute"},
    )
    assert vote.status_code == 201, vote.text
    second_vote = client.post(
        f"{API}/reviews/{review['id']}/answers/{answer_id}/votes",
        headers={**second_voter, "Idempotency-Key": uuid4().hex},
        json={"verdict": "dispute"},
    )
    assert second_vote.status_code == 201, second_vote.text
    assert client.get(f"{API}/me/points", headers=author).json()["balance"] == -1
    assert client.get(f"{API}/me/points", headers=voter).json()["balance"] == 0


def test_visit_flag_uses_server_attestation(client: TestClient, monkeypatch) -> None:
    _, author = _user(client)
    voter_id, voter = _user(client)
    review = _review(client, author)
    assert asyncio.run(process_one_review(review["id"])) is True
    answer_id = review["answers"][0]["id"]
    monkeypatch.setenv("USPACE_REQUIRE_VISIT_FOR_VOTE", "true")
    path = f"{API}/reviews/{review['id']}/answers/{answer_id}/votes"
    headers = {**voter, "Idempotency-Key": uuid4().hex}
    denied = client.post(path, headers=headers, json={"verdict": "confirm"})
    assert denied.status_code == 403
    assert denied.json()["error"]["code"] == "NOT_ELIGIBLE"

    async def attest() -> None:
        async with await connect(migration=True) as conn:
            await conn.execute(
                """INSERT INTO visit_attestations(user_id,place_id,visited_on,source)
                VALUES (%s,%s,'2026-01-01','synthetic_fixture')""",
                (voter_id, PLACE),
            )

    asyncio.run(attest())
    accepted = client.post(path, headers=headers, json={"verdict": "confirm"})
    assert accepted.status_code == 201, accepted.text


def test_pending_review_cannot_receive_vote_points(client: TestClient) -> None:
    _, author = _user(client)
    _, voter = _user(client)
    review = _review(client, author)
    answer_id = review["answers"][0]["id"]
    response = client.post(
        f"{API}/reviews/{review['id']}/answers/{answer_id}/votes",
        headers={**voter, "Idempotency-Key": uuid4().hex}, json={"verdict": "confirm"},
    )
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "REVIEW_PENDING"
    assert client.get(f"{API}/me/points", headers=author).json()["balance"] == 0


def test_conflicting_accepted_observations_are_disputed(client: TestClient) -> None:
    _, first_author = _user(client)
    _, second_author = _user(client)
    first = _review(client, first_author, "present")
    second = _review(client, second_author, "absent")

    async def accept_both() -> None:
        async with await connect(migration=True) as conn:
            await conn.execute(
                "UPDATE reviews SET verification_status='accepted' WHERE id IN (%s,%s)",
                (first["id"], second["id"]),
            )

    asyncio.run(accept_both())
    detail = client.get(f"{API}/places/{PLACE}")
    assert detail.status_code == 200, detail.text
    ramp = next(
        feature for feature in detail.json()["features"]
        if feature["featureId"] == "ramp" and feature["targetId"] is None
    )
    assert ramp["presence"] == "disputed"
    search = client.post(
        f"{API}/places/search",
        json={"cityId": "city_krakow", "rules": [{"featureId": "ramp", "importance": "required", "minRating": None}], "includeUnknownRequired": True},
    )
    library = next(item for item in search.json()["items"] if item["id"] == PLACE)
    assert library["match"]["status"] == "insufficient_data"


def test_bot_awards_one_base_point_only_once(client: TestClient) -> None:
    _, author = _user(client)
    review = _review(client, author)
    assert asyncio.run(process_one_review(review["id"])) is True
    assert asyncio.run(process_one_review(review["id"])) is False
    current = client.get(f"{API}/reviews/{review['id']}", headers=author).json()
    assert current["verificationStatus"] == "accepted"
    assert current["pointAward"] == {"status": "granted", "amount": 1, "reasonCode": "REVIEW_ACCEPTED"}
    history = client.get(f"{API}/me/points/history", headers=author).json()["items"]
    assert len([entry for entry in history if entry["relatedReviewId"] == review["id"]]) == 1


def test_repeated_structured_review_is_hidden_without_second_award(client: TestClient) -> None:
    _, author = _user(client)
    first = _review(client, author)
    assert asyncio.run(process_one_review(first["id"])) is True
    second = _review(client, author)
    assert asyncio.run(process_one_review(second["id"])) is True
    own = client.get(f"{API}/reviews/{second['id']}", headers=author).json()
    assert own["publicationStatus"] == "hidden_pending_moderation"
    assert own["pointAward"]["status"] == "pending"
    assert client.get(f"{API}/reviews/{second['id']}").status_code == 404
    assert client.get(f"{API}/me/points", headers=author).json()["balance"] == 1


def test_pending_user_text_stays_private_until_acceptance(client: TestClient, monkeypatch) -> None:
    _, author = _user(client)
    body = {
        "mode": "detailed", "visitedOn": "2026-01-01", "timeZone": "Europe/Warsaw",
        "newParts": [{"clientId": "side", "kind": "entrance", "name": "Wejście użytkownika", "description": "Opis prywatny"}],
        "answers": [{
            "clientId": "a", "featureId": "ramp", "targetClientId": "side",
            "presence": "present", "comment": "Tekst oczekujący na moderację",
        }],
        "temporaryIssues": [{
            "featureId": "ramp", "targetClientId": "side", "kind": "outage",
            "description": "Opis utrudnienia oczekujący na moderację",
        }],
    }
    created = client.post(
        f"{API}/places/{PLACE}/reviews",
        headers={**author, "Idempotency-Key": uuid4().hex}, json=body,
    )
    assert created.status_code == 201, created.text
    review_id = created.json()["id"]
    pending = client.get(f"{API}/reviews/{review_id}").json()
    assert pending["answers"][0]["comment"] is None
    assert pending["temporaryIssues"] == []
    place = client.get(f"{API}/places/{PLACE}").json()
    assert all(part["name"] != "Wejście użytkownika" for part in place["parts"])
    assert place["activeIssueCount"] == 0
    assert place["temporaryIssues"] == []

    async def classify(_: list[dict[str, str]]) -> str:
        assert "Wejście użytkownika" in str(_)
        return json.dumps({"decision": "accept"})

    monkeypatch.setattr(worker, "chat_completion", classify)
    assert asyncio.run(process_one_review(review_id)) is True
    accepted = client.get(f"{API}/places/{PLACE}").json()
    assert any(part["name"] == "Wejście użytkownika" for part in accepted["parts"])
    assert accepted["activeIssueCount"] == 1
    assert accepted["temporaryIssues"][0]["description"] == body["temporaryIssues"][0]["description"]


def test_expired_city_entitlement_does_not_unlock_reward(client: TestClient) -> None:
    user_id, headers = _user(client)

    async def expired_card() -> None:
        async with await connect(migration=True) as conn:
            await conn.execute(
                """INSERT INTO card_verifications(
                id,user_id,city_id,card_type_id,status,valid_until,demo_result)
                VALUES (%s,%s,'city_krakow','card_krakow','verified','2020-01-01','verified')""",
                (f"card_{uuid4().hex}", user_id),
            )

    asyncio.run(expired_card())
    reward = client.get(f"{API}/rewards/reward_code", headers=headers)
    assert reward.status_code == 200
    assert reward.json()["eligibility"]["eligible"] is False


def test_demo_reward_settles_without_second_debit(client: TestClient) -> None:
    user_id, headers = _user(client)
    async def fund():
        async with await connect(migration=True) as conn:
            await conn.execute("INSERT INTO points_entries(id,user_id,delta,reason_code) VALUES (%s,%s,100,'test_funding')",
                               (uuid4().hex, user_id))
    asyncio.run(fund())
    before = client.get(f"{API}/me/points", headers=headers).json()["balance"]
    created = client.post(
        f"{API}/me/redemptions",
        headers={**headers, "Idempotency-Key": uuid4().hex},
        json={"rewardId": "reward_frame", "expectedCostPoints": 5, "deliveryMethod": "account_item"},
    )
    assert created.status_code == 201, created.text
    redemption_id = created.json()["id"]
    assert created.json()["status"] == "fulfilled"
    assert asyncio.run(process_one_redemption(redemption_id)) is False
    assert asyncio.run(process_one_redemption(redemption_id)) is False
    result = client.get(f"{API}/me/redemptions/{redemption_id}", headers=headers).json()
    assert result["status"] == "fulfilled"
    assert client.get(f"{API}/me/points", headers=headers).json()["balance"] == before - 5


def test_harmful_text_is_hidden_without_points(client: TestClient, monkeypatch) -> None:
    _, author = _user(client)
    review = _review(client, author, comment="Syntetyczna treść do moderacji")

    async def classify(_: list[dict[str, str]]) -> str:
        return json.dumps({"decision": "moderate"})

    monkeypatch.setattr(worker, "chat_completion", classify)
    assert asyncio.run(process_one_review(review["id"])) is True
    own = client.get(f"{API}/reviews/{review['id']}", headers=author)
    assert own.status_code == 200
    assert own.json()["publicationStatus"] == "hidden_pending_moderation"
    assert own.json()["pointAward"]["status"] == "not_granted"
    assert client.get(f"{API}/reviews/{review['id']}").status_code == 404
    assert client.get(f"{API}/me/points", headers=author).json()["balance"] == 0


def test_external_model_requires_separate_content_flag(client: TestClient, monkeypatch) -> None:
    _, author = _user(client)
    review = _review(client, author, comment="Syntetyczna treść prywatna")
    monkeypatch.setenv("USE_CHATGPT_API", "true")
    monkeypatch.setenv("OPENAI_API_KEY", "test-only-key")
    monkeypatch.setenv("USPACE_ALLOW_EXTERNAL_REVIEW_CONTENT", "false")

    async def unexpected_call(_: list[dict[str, str]]) -> str:
        raise AssertionError("External API must not be called")

    monkeypatch.setattr(worker, "chat_completion", unexpected_call)
    assert asyncio.run(process_one_review(review["id"])) is False
    current = client.get(f"{API}/reviews/{review['id']}", headers=author)
    assert current.json()["verificationStatus"] == "pending"


def test_api_role_cannot_read_migration_history(client: TestClient) -> None:
    if not os.environ.get("APP_DB_USER"):
        pytest.skip("Separate API role is not configured for this run")

    async def privileges() -> dict:
        async with await connect() as conn:
            return await (
                await conn.execute(
                    """SELECT current_user AS role_name,
                    has_table_privilege(current_user,'schema_versions','SELECT') AS can_read_migrations"""
                )
            ).fetchone()

    row = asyncio.run(privileges())
    assert row["role_name"] == os.environ["APP_DB_USER"]
    assert row["can_read_migrations"] is False
