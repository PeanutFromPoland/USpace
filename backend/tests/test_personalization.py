import asyncio

import pytest
from pydantic import ValidationError

from uspace_api import api
from uspace_api.errors import ApiError
from uspace_api.models import ProfilePatch, UiSettings
from uspace_api.personalization import inventory, reward_category, validate_appearance
from uspace_api.views import reward_view


def test_inventory_has_only_completed_purchases_and_explicit_titles():
    empty = inventory(set(), [])
    assert {row['id'] for row in empty} == {'avatar_default', 'frame_default', 'title_default'}
    assert not any(row['id'] in {'avatar_lemur', 'avatar_cat'} for row in empty)
    earned = inventory({'reward_avatar_cat', 'reward_frame', 'reward_theme_gardener'}, [
        {'title_id': 'title_confirmed', 'label': 'Potwierdzony tytuł'}])
    assert {row['id'] for row in earned} == {
        'avatar_default', 'frame_default', 'title_default', 'avatar_cat', 'frame_bow', 'gardener', 'title_confirmed'}


def test_equip_checks_ownership_and_slot_not_just_id():
    owned = inventory({'reward_avatar_cat', 'reward_frame'}, [])
    validate_appearance({'avatarId': 'avatar_cat', 'frameId': 'frame_bow'}, owned)
    validate_appearance({'frameId': 'frame_reward'}, owned)  # Legacy compatibility.
    for invalid in [{'avatarId': 'frame_bow'}, {'frameId': 'avatar_cat'},
                    {'avatarId': 'avatar_lemur'}, {'titleId': 'title_unearned'}]:
        with pytest.raises(ApiError) as error:
            validate_appearance(invalid, owned)
        assert error.value.status == 403


class Cursor:
    def __init__(self, rows):
        self.rows = rows
    async def fetchall(self):
        return self.rows
    async def fetchone(self):
        return self.rows[0] if self.rows else None


class Connection:
    def __init__(self, purchases=None):
        self.purchases = purchases or []
        self.writes = []
    async def __aenter__(self):
        return self
    async def __aexit__(self, *_):
        return False
    async def execute(self, query, params=None):
        if query.startswith('UPDATE'):
            self.writes.append((query, params))
        if 'earned_titles' in query:
            return Cursor([])
        if 'redemptions' in query:
            assert params[0] == 'usr_test'
            return Cursor(self.purchases)
        return Cursor([{'id': 'usr_test'}])


def test_paid_theme_cannot_bypass_inventory_through_accessibility(monkeypatch):
    conn = Connection()
    async def connect():
        return conn
    monkeypatch.setattr(api, 'connect', connect)
    with pytest.raises(ApiError):
        asyncio.run(api.put_ui_settings(UiSettings(colorThemeId='explorer'), {'id': 'usr_test'}))
    assert conn.writes == []
    conn.purchases = [{'reward_id': 'reward_theme_explorer'}]
    result = asyncio.run(api.put_ui_settings(UiSettings(colorThemeId='explorer', highContrast=True), {'id': 'usr_test'}))
    assert result['colorThemeId'] == 'explorer' and result['highContrast']
    assert len(conn.writes) == 1


@pytest.mark.parametrize('existing,reason', [
    ({'status': 'fulfilled', 'points_status': 'charged'}, 'ALREADY_OWNED'),
    ({'status': 'processing', 'points_status': 'reserved'}, 'PURCHASE_PENDING'),
])
def test_owned_or_inflight_cosmetic_disallows_a_second_purchase(existing, reason):
    row = {'id': 'reward_avatar_cat', 'name': 'Kot', 'description': '', 'kind': 'cosmetic',
           'cost_points': 100, 'city_id': None, 'availability': 'available', 'delivery_methods': ['account_item'], 'image_url': None}
    result = asyncio.run(reward_view(Connection([existing]), row, 'usr_test'))
    assert result['eligibility'] == {'eligible': False, 'reasonCode': reason}
    assert result['categoryId'] == 'avatar'


def test_category_and_profile_model_accept_no_new_client_award_fields():
    assert reward_category({'id': 'reward_theme_explorer', 'kind': 'cosmetic'}) == 'theme'
    assert reward_category({'id': 'reward_frame', 'kind': 'cosmetic'}) == 'frame'
    assert reward_category({'id': 'other', 'kind': 'city_benefit'}) == 'city'
    assert ProfilePatch(appearance={'titleId': 'title_confirmed'}).appearance.titleId == 'title_confirmed'


def test_client_cannot_award_a_title_or_reveal_an_unearned_title():
    from uspace_api.personalization import public_title
    with pytest.raises(ValidationError):
        ProfilePatch(achievements=[{"id": "title_forged"}])
    assert asyncio.run(public_title(Connection(), {"id": "usr_test", "appearance": {"titleId": "title_forged"}})) is None
