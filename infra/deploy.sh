#!/usr/bin/env bash
set -euo pipefail

cd /opt/uspace

compose() {
  docker compose --env-file .env --env-file release.env -f compose.demo.yaml "$@"
}

rollback() {
  if [[ -f release.previous.env ]]; then
    cp release.previous.env release.env
    compose up -d --wait --wait-timeout 180
  else
    rm -f release.env
    echo 'No previous release is available for rollback' >&2
    return 1
  fi
}

if [[ "${1:-}" == '--rollback' ]]; then
  rollback
  exit
fi

api_image="${1:?API image required}"
web_image="${2:?web image required}"

if [[ ! -f .env ]]; then
  echo 'Missing /opt/uspace/.env' >&2
  exit 1
fi

# Image references are generated from the repository name and commit SHA.
if [[ ! "$api_image" =~ ^ghcr\.io/[a-z0-9._/-]+:[a-f0-9]{40}$ ]] ||
   [[ ! "$web_image" =~ ^ghcr\.io/[a-z0-9._/-]+:[a-f0-9]{40}$ ]]; then
  echo 'Invalid image reference' >&2
  exit 1
fi

if [[ -f release.env ]]; then
  cp release.env release.previous.env
fi
printf 'API_IMAGE=%s\nWEB_IMAGE=%s\n' "$api_image" "$web_image" > release.next.env
chmod 600 release.next.env
mv release.next.env release.env

if ! compose pull api web; then
  echo 'Image pull failed' >&2
  rollback || true
  exit 1
fi

if ! compose up -d --wait --wait-timeout 180; then
  echo 'Deployment failed; restoring previous release' >&2
  rollback || true
  exit 1
fi

if ! compose exec -T api python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health/ready', timeout=5)"; then
  rollback || true
  exit 1
fi
echo "Deployed $api_image and $web_image"
