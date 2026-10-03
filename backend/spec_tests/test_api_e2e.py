"""Contract-first API journeys. These tests are RED until product routes exist.

They exercise the full ASGI request path and will use the configured test
PostgreSQL database once product storage is implemented. The test database
must contain the sample places and rewards required by contract section 8.
"""

import os
from uuid import uuid4

from fastapi.testclient import TestClient

from rating_template import FeatureSummaryTemplate, ReviewAnswerTemplate


API = "/api/v1"
RATING = {"blinds": 4, "asd": 2, "adhd": 4, "average_rating": 3.33}


def _register(client: TestClient, credentials: dict[str, str]) -> str:
    response = client.post(f"{API}/auth/register", json=credentials)
    assert response.status_code == 201, response.text
    return response.json()["userId"]


def _login(client: TestClient, credentials: dict[str, str]) -> dict[str, str]:
    response = client.post(
        f"{API}/auth/login",
        json={"email": credentials["email"], "password": credentials["password"]},
    )
    assert response.status_code == 200, response.text
    return {"Authorization": f"Bearer {response.json()['accessToken']}"}


def _new_authenticated_user(
    client: TestClient, credentials: dict[str, str]
) -> tuple[str, dict[str, str]]:
    user_id = _register(client, credentials)
    return user_id, _login(client, credentials)


def _first_place(client: TestClient) -> tuple[str, str, str]:
    configuration = client.get(f"{API}/configuration")
    assert configuration.status_code == 200, configuration.text
    body = configuration.json()
    assert body["cities"], "PoC needs a seeded city (contract section 8)."
    assert body["features"], "PoC needs a seeded feature catalogue."
    city_id = body["cities"][0]["id"]
    rated_features = [feature for feature in body["features"] if feature["supportsRating"]]
    assert rated_features, "PoC needs a rated feature in the catalogue."
    feature_id = rated_features[0]["id"]
    search = client.post(
        f"{API}/places/search",
        json={"cityId": city_id, "rules": [], "sort": "recommended", "limit": 20},
    )
    assert search.status_code == 200, search.text
    assert search.json()["items"], "PoC needs a seeded place (contract section 8)."
    return search.json()["items"][0]["id"], feature_id, city_id


def _review_body(feature_id: str, *, detailed: bool = False) -> dict:
    return {
        "mode": "detailed" if detailed else "quick",
        "visitedOn": "2026-01-01",
        "visitedAtLocalTime": None,
        "timeZone": "Europe/Warsaw",
        "newParts": [],
        "answers": [
            {
                "clientId": "answer_1",
                "featureId": feature_id,
                "targetId": None,
                "targetClientId": None,
                "presence": "present",
                "operationalState": None,
                "rating": None,
                "comment": None,
            }
        ],
        "temporaryIssues": [],
    }


def test_uc01_registration_starts_with_private_needs_and_no_tourist_label(
    client: TestClient, credentials: dict[str, str]
) -> None:
    user_id, headers = _new_authenticated_user(client, credentials)
    me = client.get(f"{API}/me", headers=headers)
    assert me.status_code == 200, me.text
    assert me.json()["id"] == user_id
    assert me.json()["privacy"]["needsVisibility"] == "private"
    assert me.json()["preferences"]["needIds"] == []
    assert "tourist" not in str(me.json()).lower()


def test_uc01_duplicate_email_returns_structured_field_error(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _register(client, credentials)
    duplicate = client.post(f"{API}/auth/register", json=credentials)
    assert duplicate.status_code == 409, duplicate.text
    assert duplicate.json()["error"]["code"] == "EMAIL_TAKEN"
    assert duplicate.json()["error"]["fieldErrors"]


def test_uc17_login_rejects_wrong_password_without_creating_session(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _register(client, credentials)
    failed = client.post(
        f"{API}/auth/login",
        json={"email": credentials["email"], "password": "incorrect"},
    )
    assert failed.status_code == 401, failed.text
    assert failed.json()["error"]["code"] == "INVALID_CREDENTIALS"


def test_uc17_private_profile_requires_authentication(client: TestClient) -> None:
    response = client.get(f"{API}/me")
    assert response.status_code == 401, response.text
    assert "error" in response.json()


def test_uc17_logout_ends_access_to_private_profile(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    ended = client.post(f"{API}/auth/logout", headers=headers)
    assert ended.status_code == 204, ended.text
    after = client.get(f"{API}/me", headers=headers)
    assert after.status_code == 401, after.text


def test_uc01_profile_rejects_an_unowned_cosmetic(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    unowned_avatar = f"unowned-{uuid4().hex}"
    response = client.patch(
        f"{API}/me/profile",
        headers=headers,
        json={"appearance": {"avatarId": unowned_avatar}},
    )
    assert response.status_code in {403, 422}, response.text
    me = client.get(f"{API}/me", headers=headers)
    assert me.status_code == 200, me.text
    assert me.json()["appearance"]["avatarId"] != unowned_avatar


def test_uc03_preferences_round_trip_and_private_default(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    config = client.get(f"{API}/configuration")
    assert config.status_code == 200, config.text
    need_id = config.json()["needs"][0]["id"]
    body = {"needIds": [need_id], "presetIds": [], "rules": []}
    stored = client.put(f"{API}/me/preferences", headers=headers, json=body)
    assert stored.status_code == 200, stored.text
    assert stored.json()["needIds"] == [need_id]
    me = client.get(f"{API}/me", headers=headers)
    assert me.json()["preferences"]["needIds"] == [need_id]
    assert me.json()["privacy"]["needsVisibility"] == "private"


def test_uc02_card_check_is_city_scoped_and_starts_as_pending(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    configuration = client.get(f"{API}/configuration")
    assert configuration.status_code == 200, configuration.text
    card_types = configuration.json()["cardTypes"]
    assert card_types, "PoC needs a demonstrational card type."
    card_type = card_types[0]
    card_number = os.environ.get("USPACE_E2E_VALID_CARD_NUMBER")
    assert card_number, "Set USPACE_E2E_VALID_CARD_NUMBER to a synthetic valid demo card."
    response = client.post(
        f"{API}/me/card-verifications",
        headers=headers,
        json={
            "cityId": card_type["cityId"],
            "cardTypeId": card_type["id"],
            "cardNumber": card_number,
        },
    )
    assert response.status_code == 202, response.text
    assert response.json()["status"] == "pending"
    current = client.get(
        f"{API}/me/card-verifications/{response.json()['id']}", headers=headers
    )
    assert current.status_code == 200, current.text
    assert current.json()["cityId"] == card_type["cityId"]
    assert "cardNumber" not in current.json()


def test_uc04_empty_search_is_a_success_not_an_outage(client: TestClient) -> None:
    response = client.post(
        f"{API}/places/search",
        json={"q": f"no-place-{uuid4().hex}", "rules": [], "limit": 20},
    )
    assert response.status_code == 200, response.text
    assert response.json()["items"] == []
    assert response.json()["nextCursor"] is None


def test_uc04_unknown_required_data_is_opt_in_and_never_claimed_as_matching(
    client: TestClient,
) -> None:
    config = client.get(f"{API}/configuration")
    assert config.status_code == 200, config.text
    city_id = config.json()["cities"][0]["id"]
    feature_ids = {item["id"] for item in config.json()["features"]}
    assert "step_free_entrance" in feature_ids
    query = {
        "cityId": city_id,
        "rules": [
            {"featureId": "step_free_entrance", "importance": "required", "minRating": None}
        ],
        "sort": "recommended",
        "limit": 100,
    }
    strict = client.post(f"{API}/places/search", json={**query, "includeUnknownRequired": False})
    inclusive = client.post(f"{API}/places/search", json={**query, "includeUnknownRequired": True})
    assert strict.status_code == inclusive.status_code == 200
    assert all(item["match"]["status"] == "matches" for item in strict.json()["items"])
    statuses = [item["match"]["status"] for item in inclusive.json()["items"]]
    assert "matches" in statuses
    assert "insufficient_data" in statuses, "PoC needs a place with missing data."
    assert "does_not_match" not in statuses
    assert statuses == sorted(statuses, key=lambda status: status != "matches")


def test_uc04_place_detail_distinguishes_unknown_from_absent(client: TestClient) -> None:
    place_id, _, _ = _first_place(client)
    response = client.get(f"{API}/places/{place_id}")
    assert response.status_code == 200, response.text
    assert response.json()["id"] == place_id
    for feature in response.json()["features"]:
        assert feature["presence"] in {"present", "absent", "unknown", "disputed"}
        FeatureSummaryTemplate.model_validate(feature)


def test_uc05_review_requires_a_substantive_answer(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    place_id, feature_id, _ = _first_place(client)
    body = _review_body(feature_id)
    body["answers"][0]["presence"] = "unknown"
    response = client.post(
        f"{API}/places/{place_id}/reviews",
        headers={**headers, "Idempotency-Key": uuid4().hex},
        json=body,
    )
    assert response.status_code == 422, response.text
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


def test_uc05_quick_review_is_visible_pending_and_has_separate_points_status(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    place_id, feature_id, _ = _first_place(client)
    response = client.post(
        f"{API}/places/{place_id}/reviews",
        headers={**headers, "Idempotency-Key": uuid4().hex},
        json=_review_body(feature_id),
    )
    assert response.status_code == 201, response.text
    review = response.json()
    assert review["publicationStatus"] == "visible"
    assert review["verificationStatus"] == "pending"
    assert review["pointAward"]["status"] == "pending"
    assert review["answers"][0]["rating"] is None


def test_uc06_detailed_review_returns_object_rating_for_its_answer(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    place_id, feature_id, _ = _first_place(client)
    body = _review_body(feature_id, detailed=True)
    body["newParts"] = [
        {"clientId": "new_entrance", "kind": "entrance", "name": "Wejście testowe"}
    ]
    body["answers"][0].update(
        {"targetClientId": "new_entrance", "rating": RATING, "comment": "Opis wejścia"}
    )
    response = client.post(
        f"{API}/places/{place_id}/reviews",
        headers={**headers, "Idempotency-Key": uuid4().hex},
        json=body,
    )
    assert response.status_code == 201, response.text
    answer = response.json()["answers"][0]
    ReviewAnswerTemplate.model_validate(answer)
    assert isinstance(answer["rating"]["average_rating"], int | float)
    assert answer["targetId"] is not None


def test_uc05_retry_same_key_does_not_duplicate_review(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    place_id, feature_id, _ = _first_place(client)
    headers = {**headers, "Idempotency-Key": uuid4().hex}
    body = _review_body(feature_id)
    first = client.post(f"{API}/places/{place_id}/reviews", headers=headers, json=body)
    second = client.post(f"{API}/places/{place_id}/reviews", headers=headers, json=body)
    assert first.status_code == second.status_code == 201
    assert first.json()["id"] == second.json()["id"]
    changed = _review_body(feature_id)
    changed["answers"][0]["presence"] = "absent"
    conflict = client.post(f"{API}/places/{place_id}/reviews", headers=headers, json=changed)
    assert conflict.status_code == 409, conflict.text
    assert conflict.json()["error"]["code"] == "IDEMPOTENCY_CONFLICT"


def test_uc07_assistance_is_optional_and_does_not_publish(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    place_id, feature_id, _ = _first_place(client)
    response = client.post(
        f"{API}/review-assistance",
        headers=headers,
        json={"placeId": place_id, "draft": _review_body(feature_id)},
    )
    assert response.status_code == 200, response.text
    assert isinstance(response.json()["suggestions"], list)
    assert "reviewId" not in response.json()


def test_uc09_author_cannot_vote_on_own_observation(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, author_headers = _new_authenticated_user(client, credentials)
    place_id, feature_id, _ = _first_place(client)
    created = client.post(
        f"{API}/places/{place_id}/reviews",
        headers={**author_headers, "Idempotency-Key": uuid4().hex},
        json=_review_body(feature_id),
    )
    assert created.status_code == 201, created.text
    review_id = created.json()["id"]
    answer_id = created.json()["answers"][0]["id"]
    path = f"{API}/reviews/{review_id}/answers/{answer_id}/votes"
    own_vote = client.post(
        path,
        headers={**author_headers, "Idempotency-Key": uuid4().hex},
        json={"verdict": "confirm"},
    )
    assert own_vote.status_code == 403, own_vote.text
    assert own_vote.json()["error"]["code"] == "SELF_VERIFICATION_NOT_ALLOWED"


def test_uc09_qualified_voter_confirms_one_observation_idempotently(
    client: TestClient,
) -> None:
    qualified_email = os.environ.get("USPACE_E2E_QUALIFIED_EMAIL")
    qualified_password = os.environ.get("USPACE_E2E_QUALIFIED_PASSWORD")
    assert qualified_email and qualified_password, "Seed a synthetic backend-qualified voter."
    voter_headers = _login(
        client, {"email": qualified_email, "password": qualified_password}
    )
    tasks = client.get(f"{API}/me/verification-tasks", headers=voter_headers)
    assert tasks.status_code == 200, tasks.text
    assert tasks.json()["items"], "The seeded voter needs an eligible observation task."
    task = tasks.json()["items"][0]
    review_id = task["review"]["id"]
    answer_id = task["answerId"]
    path = f"{API}/reviews/{review_id}/answers/{answer_id}/votes"
    before = client.get(f"{API}/reviews/{review_id}", headers=voter_headers)
    assert before.status_code == 200, before.text
    old_answer = next(item for item in before.json()["answers"] if item["id"] == answer_id)
    old_confirmed = old_answer["communitySummary"]["confirmedCount"]
    old_disputed = old_answer["communitySummary"]["disputedCount"]
    headers = {**voter_headers, "Idempotency-Key": uuid4().hex}
    first = client.post(path, headers=headers, json={"verdict": "confirm"})
    repeated = client.post(path, headers=headers, json={"verdict": "confirm"})
    assert first.status_code == repeated.status_code == 201
    assert first.json()["id"] == repeated.json()["id"]
    current = client.get(f"{API}/reviews/{review_id}", headers=voter_headers)
    assert current.status_code == 200, current.text
    answer = next(item for item in current.json()["answers"] if item["id"] == answer_id)
    assert answer["communitySummary"]["confirmedCount"] == old_confirmed + 1
    assert answer["communitySummary"]["disputedCount"] == old_disputed


def test_uc13_report_does_not_remove_review_or_cast_feature_vote(
    client: TestClient, credentials: dict[str, str]
) -> None:
    author_id, author_headers = _new_authenticated_user(client, credentials)
    place_id, feature_id, _ = _first_place(client)
    review = client.post(
        f"{API}/places/{place_id}/reviews",
        headers={**author_headers, "Idempotency-Key": uuid4().hex},
        json=_review_body(feature_id),
    )
    assert review.status_code == 201, review.text
    reviewer = {**credentials, "email": f"report-{uuid4().hex}@example.invalid"}
    reviewer_id, reviewer_headers = _new_authenticated_user(client, reviewer)
    assert reviewer_id != author_id
    report = client.post(
        f"{API}/reviews/{review.json()['id']}/reports",
        headers=reviewer_headers,
        json={"reasonCode": "suspected_false"},
    )
    assert report.status_code == 201, report.text
    assert report.json()["status"] == "received"
    current = client.get(f"{API}/reviews/{review.json()['id']}", headers=author_headers)
    assert current.json()["publicationStatus"] == "visible"


def test_uc14_pending_points_are_not_spendable_balance(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    before = client.get(f"{API}/me/points", headers=headers)
    assert before.status_code == 200, before.text
    place_id, feature_id, _ = _first_place(client)
    review = client.post(
        f"{API}/places/{place_id}/reviews",
        headers={**headers, "Idempotency-Key": uuid4().hex},
        json=_review_body(feature_id),
    )
    assert review.status_code == 201, review.text
    after = client.get(f"{API}/me/points", headers=headers)
    assert after.status_code == 200, after.text
    assert after.json()["balance"] == before.json()["balance"]


def test_uc10_points_history_is_empty_for_new_account(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    response = client.get(f"{API}/me/points/history", headers=headers)
    assert response.status_code == 200, response.text
    assert response.json()["items"] == []
    assert response.json()["nextCursor"] is None


def test_uc11_insufficient_points_cannot_create_redemption(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    catalogue = client.get(f"{API}/rewards")
    assert catalogue.status_code == 200, catalogue.text
    rewards = [
        item
        for item in catalogue.json()["items"]
        if item["costPoints"] > 0
        and item["availability"] == "available"
        and item["eligibility"]["eligible"]
    ]
    assert rewards, "PoC needs a seeded nonzero-cost reward (contract section 8)."
    reward = rewards[0]
    response = client.post(
        f"{API}/me/redemptions",
        headers={**headers, "Idempotency-Key": uuid4().hex},
        json={
            "rewardId": reward["id"],
            "expectedCostPoints": reward["costPoints"],
            "deliveryMethod": reward["deliveryMethods"][0],
        },
    )
    assert response.status_code == 422, response.text
    assert response.json()["error"]["code"] == "INSUFFICIENT_POINTS"


def test_uc15_new_account_has_no_owned_rewards(
    client: TestClient, credentials: dict[str, str]
) -> None:
    _, headers = _new_authenticated_user(client, credentials)
    response = client.get(f"{API}/me/redemptions", headers=headers)
    assert response.status_code == 200, response.text
    assert response.json()["items"] == []


def test_uc12_backend_configuration_provides_labels_and_structured_limits(
    client: TestClient,
) -> None:
    response = client.get(f"{API}/configuration")
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["needs"] and all(item["label"] for item in body["needs"])
    assert body["features"] and all(item["label"] for item in body["features"])
    assert body["limits"]["maxReviewAnswers"] > 0


def test_uc16_public_profile_keeps_private_fields_out(
    client: TestClient, credentials: dict[str, str]
) -> None:
    user_id, headers = _new_authenticated_user(client, credentials)
    private = client.get(f"{API}/users/{user_id}/public-profile")
    assert private.status_code == 200, private.text
    assert "needs" not in private.json()
    for forbidden in ("pointsBalance", "memberships", "cardMasked", "reputation"):
        assert forbidden not in private.json()
    changed = client.patch(
        f"{API}/me/privacy", headers=headers, json={"needsVisibility": "public"}
    )
    assert changed.status_code == 200, changed.text
    public = client.get(f"{API}/users/{user_id}/public-profile")
    assert public.status_code == 200, public.text
    assert "needs" in public.json()
    restored = client.patch(
        f"{API}/me/privacy", headers=headers, json={"needsVisibility": "private"}
    )
    assert restored.status_code == 200, restored.text
    again = client.get(f"{API}/users/{user_id}/public-profile")
    assert again.status_code == 200, again.text
    assert "needs" not in again.json()
