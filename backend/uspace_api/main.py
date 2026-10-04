"""Minimal API entry point; product routes will follow the approved contract."""

import asyncio
import os
from contextlib import asynccontextmanager
from uuid import uuid4

import psycopg
from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware

from uspace_api.api import router
from uspace_api.config import llm_config
from uspace_api.db import connect
from uspace_api.errors import ApiError, api_error_handler, validation_error_handler
from uspace_api.worker import worker_loop


@asynccontextmanager
async def lifespan(_: FastAPI):
    llm_config()
    worker = None
    if os.environ.get("USPACE_RUN_WORKERS", "false").lower() in {"true", "1"}:
        worker = asyncio.create_task(worker_loop())
    try:
        yield
    finally:
        if worker is not None:
            worker.cancel()
            try:
                await worker
            except asyncio.CancelledError:
                pass


app = FastAPI(title="KindSpot API", version="0.1.0", lifespan=lifespan, docs_url="/api/docs", redoc_url="/api/redoc", openapi_url="/api/openapi.json")
# Explicit origins for browser development; production reverse proxy is same-origin.
origins = [value.strip() for value in os.environ.get("KINDSPOT_CORS_ORIGINS", "").split(",") if value.strip()]
if origins:
    app.add_middleware(CORSMiddleware, allow_origins=origins, allow_credentials=False,
        allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
        allow_headers=["Authorization", "Content-Type", "Idempotency-Key"],
        expose_headers=["X-Request-ID"])
app.include_router(router)
app.add_exception_handler(ApiError, api_error_handler)
app.add_exception_handler(RequestValidationError, validation_error_handler)


@app.middleware("http")
async def request_id_middleware(request: Request, call_next):
    request.state.request_id = f"req_{uuid4().hex}"
    response = await call_next(request)
    response.headers["X-Request-ID"] = request.state.request_id
    return response


@app.get("/health/live")
def live() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/health/ready")
async def ready() -> dict[str, str]:
    try:
        async with await connect() as connection:
            row = await (
                await connection.execute("SELECT extversion FROM pg_extension WHERE extname = 'vector'")
            ).fetchone()
        if row is None:
            raise RuntimeError("pgvector extension is unavailable")
    except (KeyError, ValueError, RuntimeError, psycopg.Error) as exc:
        raise HTTPException(status_code=503, detail="Database not ready") from exc
    return {"status": "ok", "database": "ready", "pgvector": "ready"}
