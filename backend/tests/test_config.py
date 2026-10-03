import pytest

from uspace_api.config import llm_config


def test_ollama_is_default() -> None:
    config = llm_config({"OLLAMA_MODEL": "demo-model"})
    assert config.provider == "ollama"
    assert config.base_url == "http://ollama:11434/v1"


def test_chatgpt_requires_flag_and_secret() -> None:
    with pytest.raises(ValueError):
        llm_config({"USE_CHATGPT_API": "true", "OPENAI_MODEL": "gpt-demo"})
    config = llm_config(
        {"USE_CHATGPT_API": "true", "OPENAI_MODEL": "gpt-demo", "OPENAI_API_KEY": "secret"}
    )
    assert config.provider == "chatgpt_api"
    assert config.model == "gpt-demo"
    assert llm_config({"USE_CHATGPT_API": "true", "OPENAI_API_KEY": "secret"}).model == "gpt-4.1-mini"


def test_invalid_flag_fails_closed() -> None:
    with pytest.raises(ValueError):
        llm_config({"USE_CHATGPT_API": "sometimes", "OLLAMA_MODEL": "demo-model"})
