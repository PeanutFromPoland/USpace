"""PostgreSQL storage and versioned schema bootstrap for the KindSpot demo."""

from __future__ import annotations

import asyncio
import os
import re
import sys

import psycopg
from psycopg import sql
from psycopg.rows import dict_row
from psycopg.types.json import Jsonb

if sys.platform == "win32":
    # psycopg async requires a selector loop on Windows (including local tests).
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())


def connection_kwargs(*, migration: bool = False) -> dict:
    db_name = os.environ["POSTGRES_DB"]
    if migration:
        user = os.environ["POSTGRES_USER"]
        password = os.environ["POSTGRES_PASSWORD"]
    elif os.environ.get("APP_DB_USER") and os.environ.get("APP_DB_PASSWORD"):
        user = os.environ["APP_DB_USER"]
        password = os.environ["APP_DB_PASSWORD"]
    elif db_name.endswith("_test"):
        # Dedicated test databases may use one throwaway role.
        user = os.environ["POSTGRES_USER"]
        password = os.environ["POSTGRES_PASSWORD"]
    else:
        raise RuntimeError("APP_DB_USER and APP_DB_PASSWORD are required for the API")
    return {
        "host": os.environ.get("POSTGRES_HOST", "db"),
        "port": int(os.environ.get("POSTGRES_PORT", "5432")),
        "user": user,
        "password": password,
        "dbname": db_name,
        "row_factory": dict_row,
        "connect_timeout": 5,
    }


async def connect(*, migration: bool = False) -> psycopg.AsyncConnection:
    return await psycopg.AsyncConnection.connect(**connection_kwargs(migration=migration))


SCHEMA = """
CREATE EXTENSION IF NOT EXISTS vector;
CREATE TABLE IF NOT EXISTS schema_versions (
    version integer PRIMARY KEY, installed_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS users (
    id text PRIMARY KEY, email text NOT NULL UNIQUE, password_hash text NOT NULL,
    display_name text NOT NULL, appearance jsonb NOT NULL DEFAULT '{}'::jsonb,
    helper_opt_in boolean NOT NULL DEFAULT false,
    preferences jsonb NOT NULL DEFAULT '{"needIds":[],"presetIds":[],"rules":[]}'::jsonb,
    privacy jsonb NOT NULL DEFAULT '{"needsVisibility":"private"}'::jsonb,
    ui_settings jsonb NOT NULL DEFAULT '{"colorThemeId":"default","highContrast":false,"reduceMotion":false,"textScale":1,"simpleLanguage":false}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS sessions (
    token_hash text PRIMARY KEY, user_id text NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at timestamptz NOT NULL, revoked_at timestamptz
);
CREATE INDEX IF NOT EXISTS sessions_user_idx ON sessions(user_id);
CREATE TABLE IF NOT EXISTS login_attempts (
    email_hash text NOT NULL, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS login_attempts_lookup_idx ON login_attempts(email_hash,created_at);
CREATE TABLE IF NOT EXISTS places (
    id text PRIMARY KEY, name text NOT NULL, category_id text NOT NULL,
    city_id text NOT NULL, address text NOT NULL, lat double precision NOT NULL,
    lon double precision NOT NULL, features jsonb NOT NULL DEFAULT '[]'::jsonb
);
CREATE TABLE IF NOT EXISTS place_parts (
    id text PRIMARY KEY, place_id text NOT NULL REFERENCES places(id),
    kind text NOT NULL, name text NOT NULL, description text,
    origin_review_id text,
    UNIQUE(place_id, name)
);
CREATE TABLE IF NOT EXISTS reviews (
    id text PRIMARY KEY, place_id text NOT NULL REFERENCES places(id),
    author_id text NOT NULL REFERENCES users(id), visited_on date NOT NULL,
    visited_at_local_time time, time_zone text NOT NULL, mode text NOT NULL,
    publication_status text NOT NULL DEFAULT 'visible',
    verification_status text NOT NULL DEFAULT 'pending',
    point_status text NOT NULL DEFAULT 'pending', point_amount integer,
    point_reason_code text, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS reviews_place_created_idx ON reviews(place_id, created_at DESC);
CREATE TABLE IF NOT EXISTS review_answers (
    id text PRIMARY KEY, review_id text NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    feature_id text NOT NULL, target_id text REFERENCES place_parts(id),
    presence text NOT NULL, operational_state text, rating jsonb, comment text,
    embedding vector(128), created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS answers_review_idx ON review_answers(review_id);
CREATE INDEX IF NOT EXISTS answers_embedding_idx ON review_answers USING hnsw (embedding vector_cosine_ops);
CREATE TABLE IF NOT EXISTS moderation_events (
    id text PRIMARY KEY, review_id text NOT NULL REFERENCES reviews(id),
    decision text NOT NULL, provider text NOT NULL,
    duplicate_signal boolean NOT NULL, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS temporary_issues (
    id text PRIMARY KEY, review_id text REFERENCES reviews(id),
    place_id text NOT NULL REFERENCES places(id), feature_id text NOT NULL,
    target_id text REFERENCES place_parts(id), kind text NOT NULL,
    description text NOT NULL, status text NOT NULL DEFAULT 'active',
    reported_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS visit_attestations (
    user_id text NOT NULL REFERENCES users(id), place_id text NOT NULL REFERENCES places(id),
    visited_on date NOT NULL, source text NOT NULL,
    PRIMARY KEY(user_id, place_id, visited_on)
);
CREATE TABLE IF NOT EXISTS votes (
    id text PRIMARY KEY, review_id text NOT NULL REFERENCES reviews(id),
    answer_id text NOT NULL REFERENCES review_answers(id),
    voter_id text NOT NULL REFERENCES users(id), verdict text NOT NULL,
    reason text, created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(answer_id, voter_id)
);
CREATE TABLE IF NOT EXISTS reports (
    id text PRIMARY KEY, review_id text NOT NULL REFERENCES reviews(id),
    reporter_id text NOT NULL REFERENCES users(id), reason_code text NOT NULL,
    description text, status text NOT NULL DEFAULT 'received',
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS points_entries (
    id text PRIMARY KEY, user_id text NOT NULL REFERENCES users(id),
    delta integer NOT NULL, reason_code text NOT NULL,
    related_review_id text REFERENCES reviews(id),
    related_verification_id text REFERENCES votes(id),
    related_redemption_id text, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS one_review_award_idx ON points_entries(related_review_id)
    WHERE reason_code = 'review_accepted';
CREATE UNIQUE INDEX IF NOT EXISTS one_vote_effect_idx ON points_entries(related_verification_id)
    WHERE related_verification_id IS NOT NULL;
CREATE TABLE IF NOT EXISTS rewards (
    id text PRIMARY KEY, name text NOT NULL, description text NOT NULL,
    kind text NOT NULL, cost_points integer NOT NULL, city_id text,
    availability text NOT NULL, delivery_methods jsonb NOT NULL,
    image_url text
);
CREATE TABLE IF NOT EXISTS redemptions (
    id text PRIMARY KEY, user_id text NOT NULL REFERENCES users(id),
    reward_id text NOT NULL REFERENCES rewards(id), reward_name text NOT NULL,
    cost_points integer NOT NULL, delivery_method text NOT NULL,
    status text NOT NULL, points_status text NOT NULL, code text,
    expires_at timestamptz, instructions text, failure_code text,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS card_verifications (
    id text PRIMARY KEY, user_id text NOT NULL REFERENCES users(id),
    city_id text NOT NULL, card_type_id text NOT NULL, status text NOT NULL,
    card_masked text, valid_until date, reason_code text,
    demo_result text NOT NULL, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS demo_card_entitlements (
    user_id text NOT NULL REFERENCES users(id), city_id text NOT NULL,
    card_type_id text NOT NULL, valid_until date,
    PRIMARY KEY(user_id,city_id,card_type_id)
);
CREATE TABLE IF NOT EXISTS idempotency_records (
    user_id text NOT NULL REFERENCES users(id), scope text NOT NULL,
    key text NOT NULL, request_hash text NOT NULL, status_code integer,
    response jsonb, created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY(user_id, scope, key)
);
"""

INITIAL_SCHEMA_VERSION = 1
CURRENT_SCHEMA_VERSION = 2


async def install_schema() -> None:
    """Explicit migration entry point; never called implicitly by an API request."""
    async with await connect(migration=True) as conn:
        await conn.execute(
            """CREATE TABLE IF NOT EXISTS schema_versions (
            version integer PRIMARY KEY, installed_at timestamptz NOT NULL DEFAULT now()
            )"""
        )
        row = await (
            await conn.execute("SELECT 1 FROM schema_versions WHERE version=%s", (INITIAL_SCHEMA_VERSION,))
        ).fetchone()
        if row is None:
            await conn.execute(SCHEMA)
            await conn.execute(
                "INSERT INTO schema_versions(version) VALUES (%s)", (INITIAL_SCHEMA_VERSION,)
            )
        row = await (
            await conn.execute("SELECT 1 FROM schema_versions WHERE version=%s", (CURRENT_SCHEMA_VERSION,))
        ).fetchone()
        if row is None:
            await conn.execute("ALTER TABLE place_parts ADD COLUMN IF NOT EXISTS origin_review_id text")
            await conn.execute(
                "INSERT INTO schema_versions(version) VALUES (%s)", (CURRENT_SCHEMA_VERSION,)
            )


async def seed_demo() -> None:
    """Only synthetic records. Safe to repeat without erasing user-created data."""
    places = [
        (
            "place_krakow_library", "Biblioteka demonstracyjna", "library", "city_krakow",
            "ul. Przykładowa 1, Kraków", 50.0647, 19.9450,
            [
                {"featureId": "step_free_entrance", "targetId": None, "presence": "present", "operationalState": "working", "rating": None},
                {"featureId": "ramp", "targetId": None, "presence": "present", "operationalState": "working", "rating": None},
                {"featureId": "quiet_environment", "targetId": None, "presence": "present", "operationalState": None, "rating": None},
            ],
        ),
        (
            "place_krakow_station", "Dworzec demonstracyjny", "transport", "city_krakow",
            "ul. Przykładowa 2, Kraków", 50.0680, 19.9470,
            [
                {"featureId": "step_free_entrance", "targetId": None, "presence": "unknown", "operationalState": None, "rating": None},
                {"featureId": "elevator", "targetId": None, "presence": "present", "operationalState": "not_working", "rating": None},
            ],
        ),
        (
            "place_krakow_cafe", "Kawiarnia demonstracyjna", "food", "city_krakow",
            "ul. Przykładowa 3, Kraków", 50.0610, 19.9420,
            [{"featureId": "step_free_entrance", "targetId": None, "presence": "absent", "operationalState": None, "rating": None}],
        ),
    ]
    rewards = [
        ("reward_frame", "Ramka profilu", "Element wyglądu profilu", "cosmetic", 5, None, "available", ["account_item"]),
        ("reward_code", "Kod demonstracyjny", "Syntetyczny kod odbioru", "city_benefit", 10, "city_krakow", "available", ["pickup_code"]),
        ("reward_sold_out", "Niedostępna nagroda", "Przykład wyczerpanej nagrody", "cosmetic", 5, None, "sold_out", ["account_item"]),
    ]
    async with await connect(migration=True) as conn:
        for place in places:
            await conn.execute(
                """INSERT INTO places(id,name,category_id,city_id,address,lat,lon,features)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT (id) DO NOTHING""",
                (*place[:-1], Jsonb(place[-1])),
            )
        await conn.execute(
            """INSERT INTO place_parts(id,place_id,kind,name,description)
            VALUES ('part_library_main','place_krakow_library','entrance','Wejście główne','Dane demonstracyjne')
            ON CONFLICT (id) DO NOTHING"""
        )
        for reward in rewards:
            await conn.execute(
                """INSERT INTO rewards(id,name,description,kind,cost_points,city_id,availability,delivery_methods)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s) ON CONFLICT (id) DO NOTHING""",
                (*reward[:-1], Jsonb(reward[-1])),
            )


async def grant_app_role() -> None:
    """Create/update a least-privilege API role after explicit migrations."""
    role = os.environ.get("APP_DB_USER")
    password = os.environ.get("APP_DB_PASSWORD")
    if not role or not password:
        if os.environ["POSTGRES_DB"].endswith("_test"):
            return
        raise RuntimeError("APP_DB_USER and APP_DB_PASSWORD are required")
    if not re.fullmatch(r"[a-z][a-z0-9_]{2,62}", role):
        raise ValueError("APP_DB_USER must be a simple PostgreSQL role name")
    if role == os.environ["POSTGRES_USER"]:
        raise ValueError("The API role must differ from the migration role")
    async with await connect(migration=True) as conn:
        exists = await (
            await conn.execute("SELECT rolsuper FROM pg_roles WHERE rolname=%s", (role,))
        ).fetchone()
        if exists and exists["rolsuper"]:
            raise RuntimeError("The API role must not be a superuser")
        if not exists:
            await conn.execute(
                sql.SQL("CREATE ROLE {} LOGIN PASSWORD {}").format(sql.Identifier(role), sql.Literal(password))
            )
        else:
            await conn.execute(
                sql.SQL("ALTER ROLE {} PASSWORD {}").format(sql.Identifier(role), sql.Literal(password))
            )
        identifier = sql.Identifier(role)
        await conn.execute(sql.SQL("GRANT USAGE ON SCHEMA public TO {}").format(identifier))
        await conn.execute(
            sql.SQL("REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM {}").format(identifier)
        )
        grants = {
            "SELECT": "places,rewards,visit_attestations,demo_card_entitlements",
            "SELECT,INSERT": "place_parts,review_answers,temporary_issues,votes,reports,points_entries,moderation_events",
            "SELECT,INSERT,UPDATE": "users,sessions,reviews,redemptions,card_verifications,idempotency_records",
            "SELECT,INSERT,DELETE": "login_attempts",
        }
        for privileges, table_names in grants.items():
            await conn.execute(
                sql.SQL("GRANT {} ON {} TO {}").format(
                    sql.SQL(privileges),
                    sql.SQL(",").join(sql.Identifier(name) for name in table_names.split(",")),
                    identifier,
                )
            )
