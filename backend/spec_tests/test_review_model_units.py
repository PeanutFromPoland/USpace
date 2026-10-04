"""RED unit specification for the not-yet-implemented ReviewCreate model.

Only this helper knows where the future production model lives. Move the
import if the module layout changes; keep the behavioral assertions intact.
"""

import pytest
from pydantic import BaseModel, ValidationError


def _review_create_model() -> type[BaseModel]:
    try:
        from uspace_api.models import ReviewCreate
    except ModuleNotFoundError as exc:
        if exc.name != "uspace_api.models":
            raise
        pytest.fail("ReviewCreate model is not implemented yet (UC-05/UC-06).")
    except ImportError:
        pytest.fail("ReviewCreate model is not implemented yet (UC-05/UC-06).")
    return ReviewCreate


def _draft(*, presence: str = "present", rating: object = None) -> dict:
    return {
        "mode": "quick",
        "visitedOn": "2026-01-01",
        "visitedAtLocalTime": None,
        "timeZone": "Europe/Warsaw",
        "newParts": [],
        "answers": [
            {
                "clientId": "answer_1",
                "featureId": "ramp",
                "targetId": None,
                "targetClientId": None,
                "presence": presence,
                "operationalState": None,
                "rating": rating,
                "comment": None,
            }
        ],
        "temporaryIssues": [],
    }


def test_uc05_short_answer_without_text_or_visit_hour_is_valid() -> None:
    review_create_model = _review_create_model()
    parsed = review_create_model.model_validate(_draft())
    assert parsed.visitedAtLocalTime is None
    assert len(parsed.answers) == 1


def test_uc05_only_unknown_answers_are_not_substantive() -> None:
    review_create_model = _review_create_model()
    with pytest.raises(ValidationError):
        review_create_model.model_validate(_draft(presence="unknown"))


def test_uc05_absent_feature_cannot_have_a_rating() -> None:
    review_create_model = _review_create_model()
    with pytest.raises(ValidationError):
        review_create_model.model_validate(
            _draft(presence="absent", rating={"blinds": 4, "average_rating": 4})
        )


def test_uc06_rating_object_accepts_dynamic_dimension_keys() -> None:
    review_create_model = _review_create_model()
    parsed = review_create_model.model_validate(
        _draft(rating={"blinds": 4, "asd": 2, "adhd": 4, "average_rating": 3.33})
    )
    assert parsed.model_dump()["answers"][0]["rating"]["average_rating"] == 3.33


def test_uc06_legacy_scalar_rating_is_rejected() -> None:
    review_create_model = _review_create_model()
    with pytest.raises(ValidationError):
        review_create_model.model_validate(_draft(rating=3))


def test_uc06_one_answer_cannot_target_two_parts() -> None:
    review_create_model = _review_create_model()
    draft = _draft()
    draft["answers"][0]["targetId"] = "existing_entrance"
    draft["answers"][0]["targetClientId"] = "new_entrance"
    with pytest.raises(ValidationError):
        review_create_model.model_validate(draft)
