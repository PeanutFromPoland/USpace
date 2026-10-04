from uspace_api.views import place_statistics, sort_places


def test_place_average_pools_subordinate_dimensions_not_averages_of_reviews() -> None:
    result = place_statistics([
        {"review_id": "r1", "presence": "present", "rating": {"asd": 1, "blinds": 5, "average_rating": 3}},
        {"review_id": "r2", "presence": "present", "rating": {"overall": 5, "average_rating": 5}},
        {"review_id": "r2", "presence": "absent", "rating": {"overall": 0}},
        {"review_id": "r3", "presence": "unknown", "rating": None},
    ])
    assert result["aggregateRating"] == 11 / 3
    assert result["reviewCount"] == 3


def test_unknown_or_absent_are_never_an_average_and_count_reviews_only_once() -> None:
    result = place_statistics([
        {"review_id": "r1", "presence": "absent", "rating": None},
        {"review_id": "r1", "presence": "unknown", "rating": None},
    ])
    assert result == {"aggregateRating": None, "reviewCount": 1}
    assert place_statistics([]) == {"aggregateRating": None, "reviewCount": 0}


def test_average_has_priority_over_review_count_and_count_breaks_ties() -> None:
    places = [
        {"id": "a", "name": "A", "aggregateRating": 4, "reviewCount": 100},
        {"id": "b", "name": "B", "aggregateRating": 5, "reviewCount": 1},
        {"id": "c", "name": "C", "aggregateRating": 5, "reviewCount": 2},
        {"id": "d", "name": "D", "aggregateRating": None, "reviewCount": 1000},
    ]
    sort_places(places, "best_rated")
    assert [p["id"] for p in places] == ["c", "b", "a", "d"]
    sort_places(places, "review_count")
    assert [p["id"] for p in places] == ["d", "a", "c", "b"]
