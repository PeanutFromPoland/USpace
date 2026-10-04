from inspect import iscoroutinefunction

import pytest
from fastapi.routing import APIRoute
from fastapi.testclient import TestClient
from pydantic import ValidationError

from uspace_api.api import router
from uspace_api.main import app
from uspace_api.models import Preferences, ReviewCreate, UiSettings


def test_router_is_mounted_and_configuration_is_reachable() -> None:
    paths = app.openapi()["paths"]
    routes = [route for route in router.routes if isinstance(route, APIRoute)]
    assert routes and all(iscoroutinefunction(route.endpoint) for route in routes)
    assert all(route.path in paths for route in routes)
    response = TestClient(app).get("/api/v1/configuration")
    assert response.status_code == 200
    assert response.json()["features"]
    assert "green" in response.json()["uiOptions"]["themeIds"]


def test_private_routes_reject_missing_session_without_accessing_database() -> None:
    client = TestClient(app)
    for method, path, body in [
        ("GET", "/api/v1/me", None),
        ("GET", "/api/v1/me/saved-places", None),
        ("PUT", "/api/v1/me/saved-places/place_demo", None),
        ("DELETE", "/api/v1/me/saved-places/place_demo", None),
        ("POST", "/api/v1/me/redemptions", {"rewardId": "reward_frame", "expectedCostPoints": 5, "deliveryMethod": "account_item"}),
    ]:
        response = client.request(method, path, json=body)
        assert response.status_code == 401
        assert response.json()["error"]["code"]


def test_survey_payload_keeps_recommendation_and_absent_distinct_from_unknown() -> None:
    body = ReviewCreate.model_validate({
        "mode": "quick", "visitedOn": "2026-10-03", "timeZone": "Europe/Warsaw",
        "recommendation": 5,
        "answers": [
            {"clientId": "a", "featureId": "ramp", "presence": "present", "rating": {"overall": 4, "average_rating": 4}},
            {"clientId": "b", "featureId": "elevator", "presence": "absent", "rating": None},
            {"clientId": "c", "featureId": "quiet_environment", "presence": "unknown", "rating": None},
        ],
    })
    assert body.recommendation == 5
    assert body.answers[0].rating.model_dump()["overall"] == 4
    assert body.answers[1].presence != body.answers[2].presence
    with pytest.raises(ValidationError):
        ReviewCreate.model_validate({**body.model_dump(), "recommendation": 6})


def test_named_filters_and_accessibility_validate_without_resetting_account() -> None:
    body = {"needIds": ["wheelchair"], "namedFilters": [{"name": "  Spokojne  ", "rules": [], "includeUnknownRequired": True}]}
    parsed = Preferences.model_validate(body)
    assert parsed.namedFilters[0].name == "Spokojne"
    with pytest.raises(ValidationError):
        Preferences.model_validate({**body, "namedFilters": [*body["namedFilters"], {"name": "spokojne", "rules": []}]})
    settings = UiSettings.model_validate({"colorThemeId": "green", "darkMode": True, "highContrast": True})
    assert settings.darkMode and settings.highContrast


def test_configuration_contains_all_existing_survey_questions_and_need_links() -> None:
    response = TestClient(app).get("/api/v1/configuration").json()
    features = response["features"]
    assert len(features) == 12
    assert all(feature.get("questionText") for feature in features)
    assert next(f for f in features if f["id"] == "quiet_environment")["isEnvironmental"]
    assert "lift" not in {feature["id"] for feature in features}
    assert "elevator" in {feature["id"] for feature in features}
    assert next(n for n in response["needs"] if n["id"] == "wheelchair")["featureIds"] == ["step_free_entrance", "accessible_toilet"]
