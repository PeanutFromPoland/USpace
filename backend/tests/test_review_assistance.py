"""Model-generated questions remain optional and tied to the current draft."""

import asyncio
import json

import httpx
import pytest

from uspace_api import assistance
from uspace_api.models import ReviewCreate


def _draft(count: int = 1, comment: str | None = None) -> ReviewCreate:
    return ReviewCreate.model_validate({
        "mode": "quick", "visitedOn": "2026-01-01", "timeZone": "Europe/Warsaw",
        "answers": [
            {"clientId": f"answer_{index}", "featureId": "ramp", "presence": "present",
             "comment": comment if index == 0 else None}
            for index in range(count)
        ],
    })


def test_local_model_questions_are_validated_and_private_text_is_redacted(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("USE_CHATGPT_API", "false")
    monkeypatch.setenv("OLLAMA_MODEL", "test-model")

    async def reply(messages: list[dict[str, str]]) -> str:
        assert "Ollama" not in messages[1]["content"]
        assert "ala@example.org" not in messages[1]["content"]
        assert "[email]" in messages[1]["content"]
        items = [
            {"answerClientId": "unknown", "field": "comment", "question": "Gdzie jest wejście?"},
            {"answerClientId": "answer_0", "field": "rating", "question": "Dlaczego ocena jest niska?"},
        ] + [
            {"answerClientId": f"answer_{index}", "field": "comment", "question": "Gdzie jest podjazd?"}
            for index in range(6)
        ]
        return json.dumps({"suggestions": items})

    monkeypatch.setattr(assistance, "chat_completion", reply)
    result = asyncio.run(assistance.questions_for_draft(_draft(6, "Kontakt ala@example.org")))
    assert len(result) == 5
    assert [item["answerClientId"] for item in result] == [f"answer_{i}" for i in range(5)]
    assert all(item["field"] == "comment" and item["required"] is False for item in result)


def test_unavailable_or_invalid_model_keeps_assistance_optional(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("USE_CHATGPT_API", "false")
    monkeypatch.setenv("OLLAMA_MODEL", "test-model")

    async def unavailable(_: list[dict[str, str]]) -> str:
        raise httpx.ConnectError("local model unavailable")

    monkeypatch.setattr(assistance, "chat_completion", unavailable)
    assert asyncio.run(assistance.questions_for_draft(_draft())) == []

    async def invalid(_: list[dict[str, str]]) -> str:
        return "not JSON"

    monkeypatch.setattr(assistance, "chat_completion", invalid)
    assert asyncio.run(assistance.questions_for_draft(_draft())) == []

    async def fenced(_: list[dict[str, str]]) -> str:
        return '```json\n{"suggestions":[{"answerClientId":"answer_0","field":"comment","question":"Gdzie jest podjazd?"}]}\n```'

    monkeypatch.setattr(assistance, "chat_completion", fenced)
    assert len(asyncio.run(assistance.questions_for_draft(_draft()))) == 1


def test_external_provider_needs_separate_content_flag(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("USE_CHATGPT_API", "true")
    monkeypatch.setenv("OPENAI_API_KEY", "test-only-key")
    monkeypatch.setenv("USPACE_ALLOW_EXTERNAL_REVIEW_CONTENT", "false")

    async def forbidden(_: list[dict[str, str]]) -> str:
        raise AssertionError("Draft must not leave the local host")

    monkeypatch.setattr(assistance, "chat_completion", forbidden)
    assert asyncio.run(assistance.questions_for_draft(_draft())) == []
