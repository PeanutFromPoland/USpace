"""Unit tests for the temporary, test-local rating response model."""

import pytest
from pydantic import ValidationError
from rating_template import FeatureSummaryTemplate, ReviewAnswerTemplate

RATING_EXAMPLE = {"blinds": 4, "asd": 2, "adhd": 4, "average_rating": 3.33}


@pytest.mark.parametrize("model", [ReviewAnswerTemplate, FeatureSummaryTemplate])
def test_rating_is_an_object_in_both_response_types(model: type) -> None:
    parsed = model.model_validate({"featureId": "ramp", "rating": RATING_EXAMPLE})
    assert parsed.rating is not None
    assert parsed.rating.model_dump() == RATING_EXAMPLE


@pytest.mark.parametrize("model", [ReviewAnswerTemplate, FeatureSummaryTemplate])
def test_rating_dimension_names_are_not_hard_coded(model: type) -> None:
    parsed = model.model_validate(
        {"featureId": "ramp", "rating": {"another_need": 5, "average_rating": 5.0}}
    )
    assert parsed.rating is not None
    assert parsed.rating.model_dump()["another_need"] == 5


@pytest.mark.parametrize("model", [ReviewAnswerTemplate, FeatureSummaryTemplate])
def test_rating_may_be_null_when_no_quality_can_be_assessed(model: type) -> None:
    parsed = model.model_validate({"featureId": "ramp", "rating": None})
    assert parsed.rating is None


@pytest.mark.parametrize("model", [ReviewAnswerTemplate, FeatureSummaryTemplate])
def test_legacy_scalar_rating_is_rejected(model: type) -> None:
    with pytest.raises(ValidationError):
        model.model_validate({"featureId": "ramp", "rating": 3})
