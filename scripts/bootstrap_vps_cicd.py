#!/usr/bin/env python3
"""One-shot VPS bootstrap for AiToEarn CI/CD."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = os.environ.get("VPS_HOST", "145.79.13.104")
USER = os.environ.get("VPS_USER", "root")
PASSWORD = os.environ["VPS_PASSWORD"]
GH_TOKEN = os.environ["GH_DEPLOY_TOKEN"]
DOCKER_USER = os.environ.get("DOCKER_HUB_USERNAME", "lain4504")
DOCKER_TOKEN = os.environ["DOCKER_HUB_TOKEN"]
PUBKEY = os.environ["VPS_SSH_PUBKEY"]
APP_DIR = "/home/lain4504/aitoearn"


def run(client: paramiko.SSHClient, cmd: str, timeout: int = 600) -> int:
    print(f"\n$ {cmd}")
    _, stdout, stderr = client.exec_command(cmd, timeout=timeout, get_pty=True)
    out = stdout.read().decode("utf-8", "replace")
    err = stderr.read().decode("utf-8", "replace")
    code = stdout.channel.recv_exit_status()
    if out.strip():
        sys.stdout.buffer.write(out[-6000:].encode("utf-8", "replace") + b"\n")
    if err.strip():
        sys.stderr.buffer.write(err[-2000:].encode("utf-8", "replace") + b"\n")
    return code


def main() -> int:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(HOST, username=USER, password=PASSWORD, timeout=30)

    escaped = PUBKEY.strip().replace("'", "'\"'\"'")
    run(
        client,
        f"mkdir -p /root/.ssh && chmod 700 /root/.ssh && "
        f"(grep -qxF '{escaped}' /root/.ssh/authorized_keys 2>/dev/null || "
        f"echo '{escaped}' >> /root/.ssh/authorized_keys) && chmod 600 /root/.ssh/authorized_keys",
    )

    clone_url = f"https://x-access-token:{GH_TOKEN}@github.com/silentlamp/AiToEarn.git"
    run(client, f"mkdir -p {APP_DIR} && chown lain4504:lain4504 {APP_DIR}")
    if run(client, f"test -d {APP_DIR}/.git") != 0:
        run(client, f"rm -rf {APP_DIR} && git clone --depth 1 {clone_url} {APP_DIR}", timeout=300)
    else:
        run(
            client,
            f"cd {APP_DIR} && git remote set-url origin {clone_url} && "
            f"git fetch --depth 1 origin main && git reset --hard origin/main",
            timeout=300,
        )
    run(client, f"chown -R lain4504:lain4504 {APP_DIR}")

    run(
        client,
        f"AK=$(grep '^RUSTFS_ACCESS_KEY=' /home/lain4504/tako/.env.prod | cut -d= -f2-); "
        f"SK=$(grep '^RUSTFS_SECRET_KEY=' /home/lain4504/tako/.env.prod | cut -d= -f2-); "
        f"printf '%s\\n' "
        f"'DOCKER_IMAGE_PREFIX={DOCKER_USER}' "
        f"'IMAGE_TAG=latest' "
        f"'APP_DOMAIN=yt.mirailabs.space' "
        f"\"RUSTFS_ACCESS_KEY=$AK\" "
        f"\"RUSTFS_SECRET_KEY=$SK\" "
        f"> {APP_DIR}/.env.prod && "
        f"chmod 600 {APP_DIR}/.env.prod && chown lain4504:lain4504 {APP_DIR}/.env.prod",
    )

    run(client, f"echo '{DOCKER_TOKEN}' | docker login -u '{DOCKER_USER}' --password-stdin")
    run(client, f"chmod +x {APP_DIR}/scripts/vps-deploy.sh {APP_DIR}/scripts/vps-harden-ssh.sh")
    run(
        client,
        f"cp {APP_DIR}/scripts/vps-harden-ssh.sh /usr/local/sbin/aitoearn-harden-ssh.sh && "
        f"chown root:root /usr/local/sbin/aitoearn-harden-ssh.sh && chmod 700 /usr/local/sbin/aitoearn-harden-ssh.sh",
    )

    run(
        client,
        f"set -a && . {APP_DIR}/.env.prod && set +a && "
        f"docker run --rm --network tako-network "
        f"-e RUSTFS_ACCESS_KEY -e RUSTFS_SECRET_KEY "
        f"minio/mc:latest /bin/sh -c "
        f"\"mc alias set rustfs http://rustfs.local:9000 \\$RUSTFS_ACCESS_KEY \\$RUSTFS_SECRET_KEY; "
        f"mc mb rustfs/aitoearn --ignore-existing; mc anonymous set download rustfs/aitoearn; mc ls rustfs\"",
    )

    print("\nBootstrap complete.")
    client.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
