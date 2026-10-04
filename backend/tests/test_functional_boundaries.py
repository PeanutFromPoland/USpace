"""UC-03/04/05: close boundaries with different product outcomes.

The expected results come from the current use cases and integration decisions.
This module treats models and place calculations as public behavior; it does
not mirror their implementation.
"""

import pytest
from pydantic import ValidationError

from uspace_api.models import Preferences, ReviewCreate
from uspace_api.views import place_statistics, sort_places


def _review_body(*, rating: dict[str, float] | None = None, recommendation: int | None = None) -> dict:
    return {
        "mode": "quick",
        "visitedOn": "2026-01-01",
        "timeZone": "Europe/Warsaw",
        "recommendation": recommendation,
        "answers": [
            {
                "clientId": "answer_1",
                "featureId": "ramp",
                "presence": "present",
                "rating": rating,
            }
        ],
    }


def test_place_average_uses_each_dimension_once_not_review_or_technical_averages() -> None:
    result = place_statistics(
        [
            {
                "review_id": "r1",
                "presence": "present",
                "rating": {"blinds": 1, "asd": 1, "average_rating": 5},
                "recommendation": 5,
            },
            {
                "review_id": "r2",
                "presence": "present",
                "rating": {"adhd": 5, "average_rating": 1},
                "recommendation": 1,
            },
        ]
    )
    assert result == {"aggregateRating": 7 / 3, "reviewCount": 2}


def test_absent_zero_and_unknown_do_not_turn_no_quality_data_into_zero_average() -> None:
    result = place_statistics(
        [
            {"review_id": "absent", "presence": "absent", "rating": {"overall": 0}},
            {"review_id": "unknown", "presence": "unknown", "rating": None},
        ]
    )
    assert result == {"aggregateRating": None, "reviewCount": 2}


def test_slightly_higher_average_beats_many_more_reviews_without_rounding() -> None:
    places = [
        {"id": "many", "name": "Wiele", "aggregateRating": 4.0, "reviewCount": 1000},
        {"id": "better", "name": "Lepsze", "aggregateRating": 4.001, "reviewCount": 1},
        {"id": "unknown", "name": "Nieznane", "aggregateRating": None, "reviewCount": 2000},
    ]
    sort_places(places, "best_rated")
    assert [place["id"] for place in places] == ["better", "many", "unknown"]


def test_review_count_sort_keeps_count_primary_and_rating_breaks_exact_tie() -> None:
    places = [
        {"id": "more", "name": "Więcej", "aggregateRating": 1.0, "reviewCount": 10},
        {"id": "high", "name": "Wyżej", "aggregateRating": 5.0, "reviewCount": 9},
        {"id": "tie", "name": "Remis", "aggregateRating": 4.0, "reviewCount": 10},
    ]
    sort_places(places, "review_count")
    assert [place["id"] for place in places] == ["tie", "more", "high"]


@pytest.mark.parametrize("score", [1, 5])
def test_endpoint_ratings_and_recommendation_preserve_both_valid_edges(score: int) -> None:
    parsed = ReviewCreate.model_validate(
        _review_body(rating={"overall": score, "average_rating": score}, recommendation=score)
    )
    assert parsed.answers[0].rating.model_dump()["overall"] == score
    assert parsed.recommendation == score


@pytest.mark.parametrize("score", [0, 6])
def test_existing_feature_quality_stops_just_outside_one_to_five(score: int) -> None:
    with pytest.raises(ValidationError):
        ReviewCreate.model_validate(
            _review_body(rating={"overall": score, "average_rating": score})
        )


@pytest.mark.parametrize("score", [0, 6])
def test_recommendation_stops_just_outside_one_to_five(score: int) -> None:
    with pytest.raises(ValidationError):
        ReviewCreate.model_validate(_review_body(recommendation=score))


def test_named_filter_accepts_exactly_sixty_characters_after_trimming() -> None:
    name = " " + "F" * 60 + " "
    parsed = Preferences.model_validate(
        {"namedFilters": [{"name": name, "rules": []}]}
    )
    assert parsed.namedFilters[0].name == "F" * 60


@pytest.mark.parametrize("name", [" ", "F" * 61])
def test_named_filter_rejects_empty_or_sixty_one_character_name(name: str) -> None:
    with pytest.raises(ValidationError):
        Preferences.model_validate({"namedFilters": [{"name": name, "rules": []}]})
