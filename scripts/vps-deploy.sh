#!/usr/bin/env bash
# Remote deploy — runs on VPS at /home/lain4504/aitoearn
set -euo pipefail

APP_DIR="${APP_DIR:-/home/lain4504/aitoearn}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
DOCKER_IMAGE_PREFIX="${DOCKER_IMAGE_PREFIX:-lain4504}"
COMPOSE="docker compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env.prod"

wait_for_http_health() {
  local name="$1"
  local port="$2"
  local attempts="${3:-45}"
  local ok=0

  echo "==> Wait for ${name} health on :${port}"
  for _ in $(seq 1 "$attempts"); do
    if curl -fsS -o /dev/null "http://127.0.0.1:${port}/health" 2>/dev/null; then
      ok=1
      break
    fi
    if ! docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null | grep -q true; then
      echo "${name} is not running — recent logs:"
      docker logs --tail 120 "$name" 2>&1 || true
      return 1
    fi
    sleep 2
  done

  if [[ "$ok" != "1" ]]; then
    echo "${name} health check timed out — recent logs:"
    docker logs --tail 120 "$name" 2>&1 || true
    $COMPOSE ps || true
    return 1
  fi
}

cd "$APP_DIR"

echo "==> Deploy AiToEarn @ $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "    APP_DIR=$APP_DIR IMAGE_TAG=$IMAGE_TAG PREFIX=$DOCKER_IMAGE_PREFIX"

if [[ -n "${DOCKER_HUB_TOKEN:-}" ]]; then
  echo "==> Docker Hub login"
  echo "$DOCKER_HUB_TOKEN" | docker login -u "$DOCKER_IMAGE_PREFIX" --password-stdin
fi

if [[ -d .git ]]; then
  echo "==> Sync repo"
  git fetch --depth=1 origin main
  git reset --hard origin/main
fi

export IMAGE_TAG DOCKER_IMAGE_PREFIX
if grep -q '^IMAGE_TAG=' .env.prod 2>/dev/null; then
  sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=${IMAGE_TAG}/" .env.prod
else
  echo "IMAGE_TAG=${IMAGE_TAG}" >> .env.prod
fi
if grep -q '^DOCKER_IMAGE_PREFIX=' .env.prod 2>/dev/null; then
  sed -i "s/^DOCKER_IMAGE_PREFIX=.*/DOCKER_IMAGE_PREFIX=${DOCKER_IMAGE_PREFIX}/" .env.prod
else
  echo "DOCKER_IMAGE_PREFIX=${DOCKER_IMAGE_PREFIX}" >> .env.prod
fi

echo "==> Ensure RustFS bucket aitoearn exists"
if docker ps --format '{{.Names}}' | grep -qx mirai-rustfs; then
  set -a
  # shellcheck disable=SC1091
  source .env.prod
  set +a
  docker run --rm --network tako-network \
    -e "RUSTFS_ACCESS_KEY=${RUSTFS_ACCESS_KEY:-}" \
    -e "RUSTFS_SECRET_KEY=${RUSTFS_SECRET_KEY:-}" \
    minio/mc:latest /bin/sh -c '
      mc alias set rustfs http://rustfs.local:9000 "$RUSTFS_ACCESS_KEY" "$RUSTFS_SECRET_KEY";
      mc mb rustfs/aitoearn --ignore-existing;
      mc anonymous set download rustfs/aitoearn;
    ' || echo "WARN: rustfs bucket init skipped"
fi

echo "==> Pull images"
$COMPOSE pull aitoearn-ai aitoearn-server aitoearn-web || true

echo "==> Preflight backend config"
bash scripts/validate-prod-config.sh

echo "==> Recreate stack"
$COMPOSE up -d --remove-orphans mongodb redis
$COMPOSE up -d mongodb-rs-init || true

$COMPOSE up -d --force-recreate --remove-orphans aitoearn-ai
wait_for_http_health aitoearn-ai 3012 60

$COMPOSE up -d --force-recreate aitoearn-server
wait_for_http_health aitoearn-server 3006 45

$COMPOSE up -d --force-recreate aitoearn-web

echo "==> Apply host nginx"
if [[ -f deploy/nginx/aitoearn-app.conf ]]; then
  CERT="/etc/letsencrypt/live/yt.mirailabs.space/fullchain.pem"
  if [[ ! -f "$CERT" ]] && command -v certbot >/dev/null 2>&1; then
    cat > /etc/nginx/sites-available/aitoearn-app <<'NGINX_HTTP'
server {
    listen 80;
    server_name yt.mirailabs.space;
    client_max_body_size 500M;
    location / { return 200 'aitoearn bootstrap\n'; add_header Content-Type text/plain; }
}
NGINX_HTTP
    ln -sf /etc/nginx/sites-available/aitoearn-app /etc/nginx/sites-enabled/aitoearn-app
    nginx -t && systemctl reload nginx
    certbot certonly --nginx --non-interactive --agree-tos \
      -m admin@mirailabs.space -d yt.mirailabs.space --cert-name yt.mirailabs.space || true
  fi
  cp deploy/nginx/aitoearn-app.conf /etc/nginx/sites-available/aitoearn-app
  ln -sf /etc/nginx/sites-available/aitoearn-app /etc/nginx/sites-enabled/aitoearn-app
  if [[ -f "$CERT" ]]; then
    nginx -t
    systemctl reload nginx
  else
    echo "WARN: SSL cert missing — serving HTTP-only until DNS/certbot ready"
    sed -i '/listen 443 ssl;/,/ssl_dhparam/d' /etc/nginx/sites-available/aitoearn-app || true
    nginx -t && systemctl reload nginx || true
  fi
fi

echo "==> Health checks"
sleep 8
curl -fsS -o /dev/null -w "web:%{http_code}\n" http://127.0.0.1:3004/ || true
curl -fsS -o /dev/null -w "server:%{http_code}\n" http://127.0.0.1:3006/health || true
curl -fsS -o /dev/null -w "ai:%{http_code}\n" http://127.0.0.1:3012/health || true
$COMPOSE ps

echo "==> Deploy done"
