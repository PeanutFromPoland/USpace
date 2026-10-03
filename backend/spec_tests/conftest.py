"""HTTP-level specification fixtures, deliberately outside the current CI test path."""

from collections.abc import Iterator
from uuid import uuid4

from fastapi.testclient import TestClient
import pytest

from uspace_api.main import app


@pytest.fixture
def client(monkeypatch: pytest.MonkeyPatch) -> Iterator[TestClient]:
    monkeypatch.setenv("OLLAMA_MODEL", "test-only-model")
    monkeypatch.setenv("USE_CHATGPT_API", "false")
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def credentials() -> dict[str, str]:
    return {
        "email": f"contract-{uuid4().hex}@example.invalid",
        "password": "Test-pass-12345!",
        "displayName": "Osoba testowa",
    }
