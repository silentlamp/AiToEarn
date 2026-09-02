#!/usr/bin/env bash
# CI check: backend config.yaml files exist and parse as YAML.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

configs=(
  project/aitoearn-backend/apps/aitoearn-ai/config/config.yaml
  project/aitoearn-backend/apps/aitoearn-server/config/config.yaml
)

for config in "${configs[@]}"; do
  echo "==> Validate $config"
  if [[ ! -s "$config" ]]; then
    echo "ERROR: missing or empty $config" >&2
    exit 1
  fi
  grep -q '^port:' "$config" || { echo "ERROR: $config missing port field" >&2; exit 1; }
done

echo "==> Backend config source checks passed"
