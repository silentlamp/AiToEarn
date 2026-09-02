# Seed Niche Account Groups

Creates three Account Groups (Spaces) for multi-channel ops:

| Group | Seed keyword | YouTube alias | TikTok alias |
|-------|-------------|---------------|--------------|
| `life_hacks` | life hacks 2026 | yt_life_hacks | tt_life_hacks |
| `ai_tools` | AI tools for... | yt_ai_tools | tt_ai_tools |
| `cooking_60s` | 60 second recipes | yt_cooking | tt_cooking |

## Run

```powershell
cd AIToEarn
.\ops\scripts\seed-niches.ps1
```

Requires Docker stack running (`aitoearn-web` container healthy).

## After seeding

Connect YouTube and TikTok accounts manually in the UI — OAuth requires browser authorization per platform account. See [CONFIG.md](./CONFIG.md).

## API reference

- `POST /api/v2/channels/account-groups` — body: `{ "name": "life_hacks", "location": "EN market" }`
- Auth: `Bearer {token}` from `docker exec aitoearn-web cat /data/init/token.txt`
