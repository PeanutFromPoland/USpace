"""Stable, Polish JSON errors for the mobile client."""

from __future__ import annotations

from uuid import uuid4

from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


class ApiError(Exception):
    def __init__(
        self, status: int, code: str, message: str,
        *, field_errors: list[dict] | None = None, retryable: bool = False,
        headers: dict[str, str] | None = None,
    ) -> None:
        self.status = status
        self.code = code
        self.message = message
        self.field_errors = field_errors or []
        self.retryable = retryable
        self.headers = headers or {}


def response(request: Request, exc: ApiError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status,
        headers=exc.headers,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message,
                "fieldErrors": exc.field_errors,
                "retryable": exc.retryable,
                "requestId": getattr(request.state, "request_id", f"req_{uuid4().hex}"),
            }
        },
    )


async def api_error_handler(request: Request, exc: ApiError) -> JSONResponse:
    return response(request, exc)


async def validation_error_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    fields = [
        {"path": ".".join(str(part) for part in error["loc"] if part != "body"), "code": "INVALID_VALUE"}
        for error in exc.errors()
    ]
    return response(
        request,
        ApiError(422, "VALIDATION_ERROR", "Sprawdź zaznaczone pola.", field_errors=fields),
    )
