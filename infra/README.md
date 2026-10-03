# Demo infrastructure

## Layout

```text
Internet → Caddy (HTTPS) → Flutter web container
                         → FastAPI (/api/* and public /health/live)
FastAPI → PostgreSQL 17 + pgvector
        → Ollama (private Docker network)
        → OpenAI API only when USE_CHATGPT_API=true and a key is supplied
```

The Flutter source remains a mobile application. The web build gives reviewers a
public URL for this infrastructure demo. Product API routes are implemented;
the Flutter product screens are not connected yet. The public demo must use
synthetic accounts and reviews only.

Only Caddy publishes ports (80 and 443). PostgreSQL, Ollama, API and web stay on
the private Compose network. Caddy obtains and renews HTTPS certificates for
`DEMO_HOST` after DNS points to the VPS. A domain is required for reliable public
TLS; an IP-only deployment needs a separate certificate decision.

## One-time VPS preparation

1. Provide an Ubuntu VPS sized for the chosen Ollama model. CPU inference is
   possible but may be slow. Choose RAM, disk and optional GPU after selecting
   a model; do not promise model performance before measuring it.
2. Install Docker Engine and the Compose plugin, create a dedicated `deploy`
   account, and grant it access to Docker. Limit SSH to keys. The account's
   Docker access is effectively host administrator access, so protect its key.
3. Point a DNS A/AAAA record for the demo domain to the VPS. Allow inbound
   TCP 80 and 443, and restrict SSH to trusted addresses. Keep 5432 and 11434
   closed externally.
4. Create `/opt/uspace/initdb`, owned by `deploy`. Create `/opt/uspace/.env`
   from the variables below with mode `600`; do not commit it. Put a strong,
   unique passwords for the PostgreSQL administrator and API role there. The first deployment copies Compose and
   Caddy definitions into `/opt/uspace`.
5. If GHCR images are private, configure `docker login ghcr.io` on the VPS with
   a read-only package token. Otherwise make both packages public. The workflow
   uses its own `GITHUB_TOKEN` to publish images.
6. Select a local Ollama model and set `OLLAMA_MODEL` to its exact name. After
   the first deployment, run `docker compose --env-file .env --env-file
   release.env -f compose.demo.yaml exec ollama ollama pull <model>` in
   `/opt/uspace`. Model data persists in a volume.

Required `/opt/uspace/.env` values:

```dotenv
DEMO_HOST=demo.example.org
POSTGRES_USER=uspace
POSTGRES_DB=uspace
POSTGRES_PASSWORD=replace-with-a-random-secret
APP_DB_USER=uspace_app
APP_DB_PASSWORD=replace-with-a-different-random-secret
OLLAMA_MODEL=replace-with-a-pulled-model
USE_CHATGPT_API=false
OPENAI_MODEL=gpt-4.1-mini
OPENAI_API_KEY=
USPACE_REQUIRE_VISIT_FOR_VOTE=false
USPACE_ALLOW_EXTERNAL_REVIEW_CONTENT=false
```

When `USE_CHATGPT_API=true`, supply `OPENAI_API_KEY` on the VPS. The configured
default model is `gpt-4.1-mini`; `OPENAI_MODEL` can override it. FastAPI refuses
to start if the flag is enabled without a key. The key
is never included in a Flutter build or container image. Turn the flag back to
`false` to return to Ollama. The Ollama service remains private and can stay
running in either mode. Sending review text to OpenAI additionally requires
`USPACE_ALLOW_EXTERNAL_REVIEW_CONTENT=true`; keep it disabled until the
privacy decision is approved. Review assistance currently uses deterministic
optional prompts and does not send drafts to a model.

The `migrate` service uses the administrator credentials to create the schema,
synthetic catalogue, and restricted API role. The `api` service receives only
`APP_DB_USER` and `APP_DB_PASSWORD`. New schema versions must be additive until
rollback rules are defined. Do not point this demo at real user data.

## GitHub setup

The single workflow runs on PRs targeting `master` and on pushes to `master`
(including merges). CI tests Python and the pgvector extension, analyzes and
tests Flutter, builds a web artifact, validates Compose, and builds both images.
The push run publishes images tagged with the merge commit SHA. The `deploy`
job starts automatically when the repository variable
`DEMO_DEPLOY_ENABLED=true` is set.

Create the `demo` GitHub environment, restrict it to the `master` branch, and
add these environment secrets:

| Name | Value |
| --- | --- |
| `DEMO_SSH_HOST` | VPS hostname or IP for SSH |
| `DEMO_SSH_USER` | Deploy account name |
| `DEMO_SSH_PRIVATE_KEY` | Dedicated private key for this workflow |
| `DEMO_SSH_KNOWN_HOSTS` | Verified SSH host-key line; obtain and verify out of band |

Set environment variable `DEMO_URL=https://demo.example.org` and repository
variable `DEMO_DEPLOY_ENABLED=true` only after the VPS and domain are ready.
Protect `master`: require the `backend`, `frontend`, `compose`, and `images` checks
and require PR review. Do not require the deploy job for PRs; it only runs after
merge. A push outside the PR process would also trigger CD, so branch protection
must block direct pushes if PR-only deployment is required.

## Deployment behavior and recovery

`deploy.sh` pulls the two SHA-tagged images, updates `release.env`, runs the
one-shot migration service, then waits
for Compose health checks. It keeps the preceding image references in
`release.previous.env` and restores them if image pull, Compose startup, or
the internal readiness check fails. The workflow then checks public
`/health/live` and asks the server to restore the previous release if that
check fails. On a first deployment there is no prior release to restore.
To roll back manually, run:

```bash
bash /opt/uspace/deploy.sh --rollback
```

Database data and Ollama models live in named volumes and survive image
updates. The SQL file creates `vector` on a new database volume. For an
existing volume, the migration service also ensures `vector` exists using
the administrative database role. It creates the product schema before
restarting the API. Avoid irreversible schema changes until rollback behavior
is defined.

Before enabling real user data, schedule encrypted off-host PostgreSQL dumps,
test restoration to a separate database, and set a retention period. This repo
contains no backup credentials or target because no VPS or storage destination
exists yet. Demo accounts should use synthetic data until backups and privacy
controls are in place.
