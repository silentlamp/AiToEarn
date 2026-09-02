#!/usr/bin/env bash
# Validate backend config.yaml mounts before docker compose recreate.
set -euo pipefail

APP_DIR="${APP_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
IMAGE_PREFIX="${DOCKER_IMAGE_PREFIX:-lain4504}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

check_yaml() {
  local path="$1"
  local label="$2"
  if [[ ! -s "$path" ]]; then
    echo "ERROR: missing or empty $label: $path" >&2
    return 1
  fi
  grep -q '^port:' "$path" || { echo "ERROR: $path missing port" >&2; return 1; }
  echo "==> $label OK: $path"
}

main() {
  check_yaml "${APP_DIR}/project/aitoearn-backend/apps/aitoearn-ai/config/config.yaml" "aitoearn-ai config"
  check_yaml "${APP_DIR}/project/aitoearn-backend/apps/aitoearn-server/config/config.yaml" "aitoearn-server config"

  for app in aitoearn-ai aitoearn-server; do
    image="${IMAGE_PREFIX}/${app}:${IMAGE_TAG}"
    if docker image inspect "$image" >/dev/null 2>&1; then
      echo "==> Image present: $image"
    else
      echo "WARN: $image not pulled yet — skipping image inspect"
    fi
  done

  echo "==> Backend config preflight passed"
}

main "$@"
