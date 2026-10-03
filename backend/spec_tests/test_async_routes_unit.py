"""The product API is specified as asynchronous FastAPI handlers."""

from inspect import iscoroutinefunction

from fastapi.routing import APIRoute

from uspace_api.main import app


def test_product_routes_are_async() -> None:
    product_routes = [
        route
        for route in app.routes
        if isinstance(route, APIRoute) and route.path.startswith("/api/v1/")
    ]
    assert product_routes, "Product routes under /api/v1 are not implemented yet."
    assert all(iscoroutinefunction(route.endpoint) for route in product_routes)
