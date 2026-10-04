"""Cross-module integration contracts; runs only in the isolated _test database fixture."""
from uuid import uuid4

from test_api_e2e import _new_authenticated_user


def test_flutter_survey_named_filter_and_saved_place_round_trip(client, credentials):
    _, headers = _new_authenticated_user(client, credentials)
    body = {"needIds": ["wheelchair"], "presetIds": [], "rules": [], "namedFilters": [
        {"name": "Bez schodów", "rules": [{"featureId": "step_free_entrance", "importance": "required", "minRating": None}],
         "includeUnknownRequired": True}]}
    assert client.put('/api/v1/me/preferences', headers=headers, json=body).status_code == 200
    assert client.get('/api/v1/me', headers=headers).json()['preferences']['namedFilters'] == body['namedFilters']
    place = 'place_krakow_library'
    assert client.put(f'/api/v1/me/saved-places/{place}', headers=headers).status_code == 204
    assert client.put(f'/api/v1/me/saved-places/{place}', headers=headers).status_code == 204
    saved = client.get('/api/v1/me/saved-places', headers=headers).json()['items']
    assert [item['id'] for item in saved].count(place) == 1
    review = {"mode": "quick", "visitedOn": "2026-10-03", "timeZone": "Europe/Warsaw", "recommendation": 5,
        "answers": [{"clientId": "answer_local_1", "featureId": "ramp", "presence": "present",
                     "rating": {"overall": 4, "average_rating": 4.0}}]}
    operation_headers = {**headers, 'Idempotency-Key': f'flutter-{uuid4().hex}'}
    response = client.post(f'/api/v1/places/{place}/reviews', json=review, headers=operation_headers)
    assert response.status_code == 201, response.text
    result = response.json()
    assert result['recommendation'] == 5
    assert result['answers'][0]['rating']['overall'] == 4
    repeat = client.post(f'/api/v1/places/{place}/reviews', json=review, headers=operation_headers)
    assert repeat.json()['id'] == result['id']
    assert client.delete(f'/api/v1/me/saved-places/{place}', headers=headers).status_code == 204
    assert client.get('/api/v1/me/saved-places', headers=headers).json()['items'] == []
    assert client.get('/api/v1/me', headers=headers).json()['pointsBalance'] == 0
