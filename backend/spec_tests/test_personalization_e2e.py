"""Needs the guarded, disposable PostgreSQL *_test fixture; never a real-user database."""
import asyncio
from uuid import uuid4

from test_api_e2e import _new_authenticated_user

from uspace_api.db import connect
from uspace_api.grant_title import grant


def test_purchase_equip_title_and_reload_are_server_owned(client, credentials):
    user_id, headers = _new_authenticated_user(client, credentials)

    async def fund():
        async with await connect(migration=True) as conn:
            await conn.execute("INSERT INTO points_entries(id,user_id,delta,reason_code) VALUES (%s,%s,1000,'test_fixture')",
                               (uuid4().hex, user_id))
    asyncio.run(fund())
    assert client.patch('/api/v1/me/profile', headers=headers, json={'appearance': {'avatarId': 'avatar_cat'}}).status_code == 403
    assert client.put('/api/v1/me/ui-settings', headers=headers, json={'colorThemeId': 'explorer'}).status_code == 403
    for reward, slot, equipped in [('reward_avatar_cat', 'avatarId', 'avatar_cat'), ('reward_frame', 'frameId', 'frame_bow'),
                                    ('reward_theme_explorer', None, 'explorer')]:
        price = client.get(f'/api/v1/rewards/{reward}', headers=headers).json()['costPoints']
        payload = {'rewardId': reward, 'expectedCostPoints': price, 'deliveryMethod': 'account_item'}
        operation = {**headers, 'Idempotency-Key': uuid4().hex}
        first = client.post('/api/v1/me/redemptions', headers=operation, json=payload)
        repeated = client.post('/api/v1/me/redemptions', headers=operation, json=payload)
        assert first.status_code == 201 and first.json()['status'] == 'fulfilled'
        assert first.json()['pointsStatus'] == 'charged' and repeated.json()['id'] == first.json()['id']
        duplicate = client.post('/api/v1/me/redemptions', headers={**headers, 'Idempotency-Key': uuid4().hex}, json=payload)
        assert duplicate.status_code == 403
        response = client.patch('/api/v1/me/profile', headers=headers, json={'appearance': {slot: equipped}}) if slot else client.put(
            '/api/v1/me/ui-settings', headers=headers, json={'colorThemeId': equipped, 'highContrast': True})
        assert response.status_code == 200
    assert client.patch('/api/v1/me/profile', headers=headers, json={'appearance': {'avatarId': 'frame_bow'}}).status_code == 403
    assert client.patch('/api/v1/me/profile', headers=headers, json={'appearance': {'titleId': 'title_confirmed'}}).status_code == 403
    asyncio.run(grant(user_id, 'title_confirmed', 'Potwierdzony tytuł testowy'))
    assert client.patch('/api/v1/me/profile', headers=headers, json={'appearance': {'titleId': 'title_confirmed'}}).status_code == 200
    restored = client.get('/api/v1/me', headers=headers).json()
    assert restored['appearance'] == {'avatarId': 'avatar_cat', 'frameId': 'frame_bow', 'titleId': 'title_confirmed'}
    assert restored['uiSettings']['colorThemeId'] == 'explorer' and restored['uiSettings']['highContrast']
    assert restored['pointsBalance'] == 795
    public = client.get(f'/api/v1/users/{user_id}/public-profile').json()
    assert public['title']['label'] == 'Potwierdzony tytuł testowy'
    assert 'needs' not in public and 'pointsBalance' not in public
