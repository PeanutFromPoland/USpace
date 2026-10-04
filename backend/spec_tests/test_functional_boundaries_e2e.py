"""UC-04/08/09/11: API outcomes on both sides of close decision boundaries.

The shared conftest guards and resets a disposable PostgreSQL database whose
name ends in ``_test``. No production database or external reward provider is
used by these journeys.
"""

import asyncio
from uuid import uuid4

from fastapi.testclient import TestClient

from uspace_api.db import connect
from uspace_api.worker import process_one_review


API = "/api/v1"
PLACE = "place_krakow_library"


def _new_user(client: TestClient) -> tuple[str, dict[str, str]]:
    email = f"boundary-{uuid4().hex}@example.invalid"
    password = "Test-only-boundary-pass-123!"
    created = client.post(
        f"{API}/auth/register",
        json={"email": email, "password": password, "displayName": "Osoba testowa"},
    )
    assert created.status_code == 201, created.text
    logged_in = client.post(
        f"{API}/auth/login", json={"email": email, "password": password}
    )
    assert logged_in.status_code == 200, logged_in.text
    return created.json()["userId"], {
        "Authorization": f"Bearer {logged_in.json()['accessToken']}"
    }


def _create_review(
    client: TestClient, headers: dict[str, str], answers: list[dict]
) -> dict:
    response = client.post(
        f"{API}/places/{PLACE}/reviews",
        headers={**headers, "Idempotency-Key": uuid4().hex},
        json={
            "mode": "quick",
            "visitedOn": "2026-01-01",
            "visitedAtLocalTime": None,
            "timeZone": "Europe/Warsaw",
            "newParts": [],
            "answers": answers,
            "temporaryIssues": [],
        },
    )
    assert response.status_code == 201, response.text
    return response.json()


def _answer(client_id: str, feature_id: str, rating: int | None = None) -> dict:
    return {
        "clientId": client_id,
        "featureId": feature_id,
        "targetId": None,
        "targetClientId": None,
        "presence": "present",
        "operationalState": None,
        "rating": None if rating is None else {"overall": rating, "average_rating": rating},
        "comment": None,
    }


def _place_average(client: TestClient) -> float | None:
    response = client.get(f"{API}/places/{PLACE}")
    assert response.status_code == 200, response.text
    return response.json()["aggregateRating"]


def test_only_accepted_visible_review_changes_place_average(
    client: TestClient,
) -> None:
    _, author = _new_user(client)
    before = _place_average(client)
    score = 1 if before is not None and before > 3 else 5
    review = _create_review(client, author, [_answer("a", "ramp", score)])
    review_id = review["id"]

    assert review["verificationStatus"] == "pending"
    assert _place_average(client) == before

    assert asyncio.run(process_one_review(review_id)) is True
    accepted = client.get(f"{API}/reviews/{review_id}", headers=author)
    assert accepted.status_code == 200, accepted.text
    assert accepted.json()["verificationStatus"] == "accepted"
    assert accepted.json()["publicationStatus"] == "visible"
    assert _place_average(client) != before

    async def hide_for_fixture() -> None:
        async with await connect(migration=True) as conn:
            await conn.execute(
                "UPDATE reviews SET publication_status='hidden_pending_moderation' WHERE id=%s",
                (review_id,),
            )

    asyncio.run(hide_for_fixture())
    assert _place_average(client) == before


def test_votes_change_only_the_selected_answer_in_the_same_review(
    client: TestClient, monkeypatch
) -> None:
    _, author = _new_user(client)
    voter_id, voter = _new_user(client)
    review = _create_review(
        client,
        author,
        [_answer("ramp_answer", "ramp"), _answer("lift_answer", "elevator")],
    )
    assert asyncio.run(process_one_review(review["id"])) is True
    answer_ids = {answer["featureId"]: answer["id"] for answer in review["answers"]}

    async def qualify_voter() -> None:
        async with await connect(migration=True) as conn:
            await conn.execute(
                "INSERT INTO visit_attestations(user_id,place_id,visited_on,source) "
                "VALUES (%s,%s,'2026-01-01','synthetic_fixture')",
                (voter_id, PLACE),
            )

    asyncio.run(qualify_voter())
    monkeypatch.setenv("USPACE_REQUIRE_VISIT_FOR_VOTE", "true")
    tasks = client.get(f"{API}/me/verification-tasks", headers=voter)
    assert tasks.status_code == 200, tasks.text
    eligible = {task["answerId"] for task in tasks.json()["items"]}
    assert set(answer_ids.values()) <= eligible

    def counters() -> dict[str, dict]:
        response = client.get(f"{API}/reviews/{review['id']}", headers=author)
        assert response.status_code == 200, response.text
        return {
            answer["id"]: answer["communitySummary"] for answer in response.json()["answers"]
        }

    baseline = counters()
    ramp_path = f"{API}/reviews/{review['id']}/answers/{answer_ids['ramp']}/votes"
    ramp_headers = {**voter, "Idempotency-Key": uuid4().hex}
    first = client.post(ramp_path, headers=ramp_headers, json={"verdict": "confirm"})
    repeated = client.post(ramp_path, headers=ramp_headers, json={"verdict": "confirm"})
    assert first.status_code == repeated.status_code == 201
    assert first.json()["id"] == repeated.json()["id"]
    after_ramp = counters()
    assert after_ramp[answer_ids["ramp"]]["confirmedCount"] == (
        baseline[answer_ids["ramp"]]["confirmedCount"] + 1
    )
    assert after_ramp[answer_ids["elevator"]] == baseline[answer_ids["elevator"]]

    lift_path = f"{API}/reviews/{review['id']}/answers/{answer_ids['elevator']}/votes"
    disputed = client.post(
        lift_path,
        headers={**voter, "Idempotency-Key": uuid4().hex},
        json={"verdict": "dispute"},
    )
    assert disputed.status_code == 201, disputed.text
    after_lift = counters()
    assert after_lift[answer_ids["ramp"]] == after_ramp[answer_ids["ramp"]]
    assert after_lift[answer_ids["elevator"]]["disputedCount"] == (
        baseline[answer_ids["elevator"]]["disputedCount"] + 1
    )
    assert client.get(f"{API}/me/points", headers=voter).json()["balance"] == 0


def test_cosmetic_purchase_succeeds_at_exact_price_and_fails_one_point_below(
    client: TestClient,
) -> None:
    reward_response = client.get(f"{API}/rewards/reward_frame")
    assert reward_response.status_code == 200, reward_response.text
    price = reward_response.json()["costPoints"]
    assert price > 1

    async def fund(user_id: str, amount: int) -> None:
        async with await connect(migration=True) as conn:
            await conn.execute(
                "INSERT INTO points_entries(id,user_id,delta,reason_code) "
                "VALUES (%s,%s,%s,'synthetic_boundary_fixture')",
                (uuid4().hex, user_id, amount),
            )

    exact_id, exact_headers = _new_user(client)
    short_id, short_headers = _new_user(client)
    asyncio.run(fund(exact_id, price))
    asyncio.run(fund(short_id, price - 1))
    payload = {
        "rewardId": "reward_frame",
        "expectedCostPoints": price,
        "deliveryMethod": "account_item",
    }

    exact_request = {**exact_headers, "Idempotency-Key": uuid4().hex}
    bought = client.post(f"{API}/me/redemptions", headers=exact_request, json=payload)
    repeated = client.post(f"{API}/me/redemptions", headers=exact_request, json=payload)
    assert bought.status_code == repeated.status_code == 201
    assert bought.json()["id"] == repeated.json()["id"]
    assert bought.json()["status"] == "fulfilled"
    assert bought.json()["pointsStatus"] == "charged"
    assert client.get(f"{API}/me/points", headers=exact_headers).json()["balance"] == 0

    short = client.post(
        f"{API}/me/redemptions",
        headers={**short_headers, "Idempotency-Key": uuid4().hex},
        json=payload,
    )
    assert short.status_code == 422, short.text
    assert short.json()["error"]["code"] == "INSUFFICIENT_POINTS"
    assert client.get(f"{API}/me/points", headers=short_headers).json()["balance"] == price - 1
    owned = client.get(f"{API}/me/redemptions", headers=short_headers)
    assert owned.status_code == 200, owned.text
    assert owned.json()["items"] == []
