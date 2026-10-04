"""Unit tests for the existing provider-neutral chat adapter."""

import asyncio
from unittest.mock import patch

import httpx
import pytest

from uspace_api import config, llm


def _assert_chatgpt_branch_is_selected() -> None:
    selected = config.llm_config(
        {
            "USE_CHATGPT_API": "true",
            "OPENAI_API_KEY": "test-only-key",
            "OPENAI_MODEL": "test-model",
            "OLLAMA_MODEL": "local-model",
        }
    )
    assert selected.provider == "chatgpt_api"
    assert selected.base_url == "https://api.openai.com/v1"


def test_small_provider_selection_mutation_is_caught() -> None:
    """A one-branch regression makes the normal assertion fail without editing source."""
    _assert_chatgpt_branch_is_selected()
    with patch.object(config, "_flag", return_value=False), pytest.raises(AssertionError):
        _assert_chatgpt_branch_is_selected()


def test_chat_adapter_sends_selected_model_and_returns_text(monkeypatch: pytest.MonkeyPatch) -> None:
    seen: list[httpx.Request] = []

    def respond(request: httpx.Request) -> httpx.Response:
        seen.append(request)
        return httpx.Response(200, json={"choices": [{"message": {"content": "Odpowiedź"}}]})

    transport = httpx.MockTransport(respond)
    original_client = httpx.AsyncClient
    monkeypatch.setattr(
        llm.httpx,
        "AsyncClient",
        lambda **kwargs: original_client(transport=transport, **kwargs),
    )
    monkeypatch.setattr(
        llm,
        "llm_config",
        lambda: config.llm_config(
            {
                "USE_CHATGPT_API": "true",
                "OPENAI_API_KEY": "test-only-key",
                "OPENAI_MODEL": "test-model",
            }
        ),
    )

    result = asyncio.run(llm.chat_completion([{"role": "user", "content": "Test"}]))

    assert result == "Odpowiedź"
    assert len(seen) == 1
    assert str(seen[0].url) == "https://api.openai.com/v1/chat/completions"
    assert seen[0].headers["Authorization"] == "Bearer test-only-key"
    assert seen[0].read().decode() == (
        '{"model":"test-model","messages":[{"role":"user","content":"Test"}],'
        '"stream":false}'
    )


def test_chat_adapter_propagates_provider_failure(monkeypatch: pytest.MonkeyPatch) -> None:
    transport = httpx.MockTransport(lambda _: httpx.Response(503))
    original_client = httpx.AsyncClient
    monkeypatch.setattr(
        llm.httpx,
        "AsyncClient",
        lambda **kwargs: original_client(transport=transport, **kwargs),
    )
    monkeypatch.setattr(
        llm,
        "llm_config",
        lambda: config.llm_config({"OLLAMA_MODEL": "local-model"}),
    )

    with pytest.raises(httpx.HTTPStatusError):
        asyncio.run(llm.chat_completion([{"role": "user", "content": "Test"}]))
