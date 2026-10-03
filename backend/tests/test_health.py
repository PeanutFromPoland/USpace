import os

from fastapi.testclient import TestClient
import psycopg

from uspace_api.main import app


def test_health_and_pgvector() -> None:
    # CI supplies a PostgreSQL service; this checks the actual vector extension.
    with psycopg.connect(
        host=os.environ["POSTGRES_HOST"],
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        dbname=os.environ["POSTGRES_DB"],
    ) as connection:
        connection.execute("CREATE EXTENSION IF NOT EXISTS vector")
    with TestClient(app) as client:
        assert client.get("/health/live").status_code == 200
        response = client.get("/health/ready")
        assert response.status_code == 200
        assert response.json()["pgvector"] == "ready"
