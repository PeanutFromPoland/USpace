"""OpenAI-compatible client shared by Ollama and the optional ChatGPT API."""

import httpx

from uspace_api.config import llm_config


async def chat_completion(messages: list[dict[str, str]]) -> str:
    config = llm_config()
    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(
            f"{config.base_url}/chat/completions",
            headers={"Authorization": f"Bearer {config.api_key}"},
            json={"model": config.model, "messages": messages, "stream": False},
        )
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]
