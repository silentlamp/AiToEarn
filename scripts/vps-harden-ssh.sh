#!/usr/bin/env bash
# Harden VPS SSH for GitHub Actions deploys (fail2ban ignoreip + ufw).
# Root-owned copy on VPS: /usr/local/sbin/aitoearn-harden-ssh.sh
set -euo pipefail

echo "==> SSH service status"
if systemctl list-unit-files | grep -q '^ssh\.service'; then
  systemctl is-active --quiet ssh || systemctl start ssh || true
elif systemctl list-unit-files | grep -q '^sshd\.service'; then
  systemctl is-active --quiet sshd || systemctl start sshd || true
fi

echo "==> UFW (allow SSH)"
if command -v ufw >/dev/null 2>&1; then
  ufw allow 22/tcp || true
fi

echo "==> fail2ban (whitelist GitHub Actions + unban)"
if ! command -v fail2ban-client >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq fail2ban
  else
    exit 0
  fi
fi

META_JSON="$(curl -fsSL --max-time 30 https://api.github.com/meta || true)"
if [ -n "$META_JSON" ]; then
  GH_ACTIONS_IPS="$(printf '%s' "$META_JSON" | python3 -c 'import json,sys; m=json.load(sys.stdin); print(" ".join(m.get("actions") or []))')"
else
  GH_ACTIONS_IPS=""
fi

install -d -m 755 /etc/fail2ban
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1 ${GH_ACTIONS_IPS}

[sshd]
enabled = true
maxretry = 10
findtime = 10m
bantime = 30m
EOF

systemctl enable fail2ban
systemctl reload fail2ban 2>/dev/null || systemctl restart fail2ban
fail2ban-client unban --all 2>/dev/null || true
echo "==> SSH hardening done"
