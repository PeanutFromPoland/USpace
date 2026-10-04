"""Isolated PostgreSQL fixtures for the contract-level journeys."""

import asyncio
import os
from collections.abc import Iterator
from uuid import uuid4

import httpx
import pytest
from fastapi.testclient import TestClient
from psycopg.types.json import Jsonb

from uspace_api import mock_resident_api, resident_provider
from uspace_api.auth import hash_password
from uspace_api.db import connect, install_schema, seed_demo
from uspace_api.demo_residents import seed_demo_accounts
from uspace_api.main import app
from uspace_api.views import new_id


async def _prepare_test_database() -> dict[str, str]:
    if not os.environ.get("POSTGRES_DB", "").endswith("_test"):
        pytest.fail("E2E reset requires a dedicated database ending in _test.")
    await install_schema()
    async with await connect(migration=True) as conn:
        await conn.execute(
            """TRUNCATE idempotency_records,sessions,login_attempts,moderation_events,points_entries,reports,votes,
            visit_attestations,temporary_issues,review_answers,reviews,redemptions,
            card_verifications,demo_card_entitlements,place_parts,places,rewards,users CASCADE"""
        )
    await seed_demo()
    await seed_demo_accounts("Test-only-resident-pass-123!")
    identities = {
        "ACCEPTED_AUTHOR": ("accepted@example.invalid", "Test-pass-accepted-123!"),
        "HIDDEN_AUTHOR": ("hidden@example.invalid", "Test-pass-hidden-123!"),
        "FUNDED_USER": ("funded@example.invalid", "Test-pass-funded-123!"),
        "QUALIFIED": ("qualified@example.invalid", "Test-pass-qualified-123!"),
    }
    ids = {key: new_id("usr") for key in identities}
    accepted_id = new_id("rev")
    hidden_id = new_id("rev")
    answer_id = new_id("ans")
    ready_id = new_id("redemption")
    failed_id = new_id("redemption")
    async with await connect(migration=True) as conn:
        for key, (email, password) in identities.items():
            await conn.execute(
                """INSERT INTO users(id,email,password_hash,display_name,appearance)
                VALUES (%s,%s,%s,%s,%s)""",
                (ids[key], email, hash_password(password), key, Jsonb({"avatarId": "avatar_default", "frameId": "frame_default", "titleId": "title_default"})),
            )
        await conn.execute(
            """INSERT INTO reviews(id,place_id,author_id,visited_on,time_zone,mode,
            publication_status,verification_status,point_status,point_amount)
            VALUES (%s,'place_krakow_library',%s,'2026-01-01','Europe/Warsaw','quick',
            'visible','accepted','granted',1),
            (%s,'place_krakow_library',%s,'2026-01-01','Europe/Warsaw','detailed',
            'hidden_pending_moderation','under_moderation','not_granted',0)""",
            (accepted_id, ids["ACCEPTED_AUTHOR"], hidden_id, ids["HIDDEN_AUTHOR"]),
        )
        await conn.execute(
            """INSERT INTO review_answers(id,review_id,feature_id,presence)
            VALUES (%s,%s,'ramp','present')""",
            (answer_id, accepted_id),
        )
        await conn.execute(
            """INSERT INTO points_entries(id,user_id,delta,reason_code,related_review_id)
            VALUES (%s,%s,1,'review_accepted',%s)""",
            (new_id("pts"), ids["ACCEPTED_AUTHOR"], accepted_id),
        )
        await conn.execute(
            """INSERT INTO points_entries(id,user_id,delta,reason_code)
            VALUES (%s,%s,100,'demo_funding')""",
            (new_id("pts"), ids["FUNDED_USER"]),
        )
        await conn.execute(
            """INSERT INTO redemptions(id,user_id,reward_id,reward_name,cost_points,
            delivery_method,status,points_status,code,instructions)
            VALUES (%s,%s,'reward_code','Kod demonstracyjny',10,'pickup_code',
            'ready','charged','DEMO-READY','Pokaż kod demonstracyjny.'),
            (%s,%s,'reward_code','Kod demonstracyjny',10,'pickup_code',
            'failed','released',NULL,NULL)""",
            (ready_id, ids["FUNDED_USER"], failed_id, ids["FUNDED_USER"]),
        )
        await conn.execute(
            """INSERT INTO visit_attestations(user_id,place_id,visited_on,source)
            VALUES (%s,'place_krakow_library','2026-01-01','synthetic_fixture')""",
            (ids["QUALIFIED"],),
        )
    values = {}
    for key, (email, password) in identities.items():
        values[f"USPACE_E2E_{key}_EMAIL"] = email
        values[f"USPACE_E2E_{key}_PASSWORD"] = password
    values.update({
        "USPACE_E2E_DEMO_ACCOUNT_PASSWORD": "Test-only-resident-pass-123!",
        "USPACE_E2E_ACCEPTED_REVIEW_ID": accepted_id,
        "USPACE_E2E_HIDDEN_REVIEW_ID": hidden_id,
        "USPACE_E2E_READY_REDEMPTION_ID": ready_id,
        "USPACE_E2E_FAILED_REDEMPTION_ID": failed_id,
    })
    return values


@pytest.fixture(scope="session")
def synthetic_database() -> Iterator[None]:
    previous = {key: os.environ.get(key) for key in [
        "USPACE_RUN_WORKERS", "USPACE_REQUIRE_VISIT_FOR_VOTE", "OLLAMA_MODEL", "USE_CHATGPT_API",
    ]}
    os.environ.update({"USPACE_RUN_WORKERS": "false", "USPACE_REQUIRE_VISIT_FOR_VOTE": "false", "OLLAMA_MODEL": "test-only-model", "USE_CHATGPT_API": "false"})
    seeded = asyncio.run(_prepare_test_database())
    old_seeded = {key: os.environ.get(key) for key in seeded}
    os.environ.update(seeded)
    yield
    for key, value in {**previous, **old_seeded}.items():
        if value is None:
            os.environ.pop(key, None)
        else:
            os.environ[key] = value


@pytest.fixture
def client(monkeypatch: pytest.MonkeyPatch, synthetic_database: None) -> Iterator[TestClient]:
    monkeypatch.setenv("OLLAMA_MODEL", "test-only-model")
    monkeypatch.setenv("USE_CHATGPT_API", "false")
    monkeypatch.setenv("KINDSPOT_RESIDENT_API_TOKEN", "test-only-resident-service-token-32-chars")
    monkeypatch.setenv("KINDSPOT_RESIDENT_API_URL", "http://resident-mock/verifications")
    monkeypatch.setattr(
        resident_provider, "_client",
        lambda: httpx.AsyncClient(transport=httpx.ASGITransport(app=mock_resident_api.app), timeout=5),
    )
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def credentials() -> dict[str, str]:
    return {
        "email": f"contract-{uuid4().hex}@example.invalid",
        "password": "Test-pass-12345!",
        "displayName": "Osoba testowa",
    }
