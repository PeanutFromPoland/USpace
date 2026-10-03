"""Runtime configuration for the demo infrastructure."""

from dataclasses import dataclass
import os


def _flag(value: str) -> bool:
    normalized = value.strip().lower()
    if normalized in {"true", "1", "yes"}:
        return True
    if normalized in {"false", "0", "no"}:
        return False
    raise ValueError("USE_CHATGPT_API must be true or false")


@dataclass(frozen=True)
class LlmConfig:
    provider: str
    base_url: str
    model: str
    api_key: str


def llm_config(environ: dict[str, str] | None = None) -> LlmConfig:
    env = os.environ if environ is None else environ
    if _flag(env.get("USE_CHATGPT_API", "false")):
        key = env.get("OPENAI_API_KEY", "").strip()
        model = env.get("OPENAI_MODEL", "gpt-4.1-mini").strip()
        if not key or not model:
            raise ValueError("OPENAI_API_KEY and a non-empty OPENAI_MODEL are required")
        return LlmConfig("chatgpt_api", "https://api.openai.com/v1", model, key)

    model = env.get("OLLAMA_MODEL", "").strip()
    if not model:
        raise ValueError("OLLAMA_MODEL is required when USE_CHATGPT_API=false")
    return LlmConfig("ollama", "http://ollama:11434/v1", model, "ollama")
