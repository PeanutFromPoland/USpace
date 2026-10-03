"""Minimal API entry point; product routes will follow the approved contract."""

import os
from contextlib import asynccontextmanager

import psycopg
from fastapi import FastAPI, HTTPException

from uspace_api.config import llm_config


@asynccontextmanager
async def lifespan(_: FastAPI):
    llm_config()
    yield


app = FastAPI(title="USpace API", version="0.1.0", lifespan=lifespan)


@app.get("/health/live")
def live() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/health/ready")
def ready() -> dict[str, str]:
    try:
        with psycopg.connect(
            host=os.environ.get("POSTGRES_HOST", "db"),
            port=int(os.environ.get("POSTGRES_PORT", "5432")),
            user=os.environ["POSTGRES_USER"],
            password=os.environ["POSTGRES_PASSWORD"],
            dbname=os.environ["POSTGRES_DB"],
            connect_timeout=3,
        ) as connection, connection.cursor() as cursor:
            cursor.execute("SELECT extversion FROM pg_extension WHERE extname = 'vector'")
            row = cursor.fetchone()
        if row is None:
            raise RuntimeError("pgvector extension is unavailable")
    except (KeyError, ValueError, psycopg.Error, RuntimeError) as exc:
        raise HTTPException(status_code=503, detail="Database not ready") from exc
    return {"status": "ok", "database": "ready", "pgvector": "ready"}
