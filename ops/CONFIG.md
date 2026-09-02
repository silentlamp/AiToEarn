# Configuration Guide — OAuth & AI Keys

Base URL after deploy: **http://localhost:8080**

## 1. Server Relay (YouTube + TikTok OAuth)

Recommended for quick start — no per-platform developer registration.

1. Open http://localhost:8080 → **Configuration** (sidebar)
2. Go to **Server → Relay**
3. Set:
   - `serverUrl`: `https://aitoearn.ai/api` (international) or `https://aitoearn.cn/api` (China)
   - `apiKey`: your API key from aitoearn.ai Settings → API Key
4. Click **Save and restart** for `aitoearn-server`

Alternative (self-hosted OAuth): edit [`project/aitoearn-backend/apps/aitoearn-server/config/config.yaml`](../project/aitoearn-backend/apps/aitoearn-server/config/config.yaml) — fill `clientId` / `clientSecret` for `youtube` and `tiktok`.

## 2. AI Model Providers

1. Configuration → **AI → Model providers**
2. Minimum required for repurposed content pipeline:
   - **Gemini** — `generateDraftFromVideoUrl`, chat, metadata generation
3. Optional for AI-generated video:
   - **Volcengine / ByteDance** — Seedance 2 models
   - **xAI** — Grok Imagine Video (native voiceover in prompts)

Config file: [`project/aitoearn-backend/apps/aitoearn-ai/config/config.yaml`](../project/aitoearn-backend/apps/aitoearn-ai/config/config.yaml)

## 3. AI Relay (optional)

If you prefer platform-hosted AI instead of your own keys:

1. Configuration → **AI → Relay**
2. Same `serverUrl` + `apiKey` as Server Relay

## 4. Verify

```powershell
cd AIToEarn
docker compose ps          # all services healthy
curl http://localhost:8080 # should redirect (308) or return 200
```

## 5. Connect channel accounts (per niche)

After Relay is configured:

1. Go to **Publish** (`/accounts`)
2. For each Account Group (`life_hacks`, `ai_tools`, `cooking_60s`):
   - Click **Add account** → YouTube → authorize as `yt_{niche}`
   - Click **Add account** → TikTok → authorize as `tt_{niche}`

OAuth URLs: `GET /api/v2/channels/accounts/auth/{platform}`
