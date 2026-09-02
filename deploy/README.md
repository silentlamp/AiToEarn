# AiToEarn production VPS

Internal multi-channel ops stack on shared Mirai infrastructure.

## Topology

| Host | Role | Upstream |
|------|------|----------|
| `yt.mirailabs.space` | App (web + API + OSS) | web `:3004`, server `:3006`, ai `:3012` |
| `yt.mirailabs.space/oss` | Object CDN | `127.0.0.1:19000/aitoearn/` (shared RustFS) |

Shared RustFS: `mirai-rustfs` on `tako-network` (`rustfs.local:9000`).

## VPS paths

| Path | Purpose |
|------|---------|
| `/home/lain4504/aitoearn` | Git checkout + compose |
| `/home/lain4504/aitoearn/.env.prod` | Image prefix, RustFS keys (**not in git**) |
| `/opt/mirai/rustfs` | Shared object storage (do not destroy) |

## CI/CD

Workflow: [`.github/workflows/deploy-vps.yml`](../.github/workflows/deploy-vps.yml)

1. Push to `main` (backend/web/compose/deploy paths) → build images → SSH deploy
2. Images: `{DOCKER_HUB_USERNAME}/aitoearn-{web,server,ai}:latest`
3. Remote: `scripts/vps-deploy.sh`

### GitHub configuration

**Variable:** `DOCKER_HUB_USERNAME` = `lain4504`

**Secrets:** `DOCKER_HUB_TOKEN`, `GH_DEPLOY_TOKEN`, `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`

## Bootstrap (once)

```bash
# On VPS as root — or run scripts/bootstrap_vps_cicd.py locally
cd /home/lain4504/aitoearn
cp deploy/env.prod.example .env.prod   # fill RUSTFS_* from tako .env.prod
docker login -u lain4504
bash scripts/vps-deploy.sh
```

## DNS required

Add `yt.mirailabs.space` A record → VPS IP before certbot SSL succeeds.
