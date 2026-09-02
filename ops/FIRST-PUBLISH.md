# First Publish Batch — Checklist

Goal: **5–10 videos per niche** (15–30 total) via Calendar scheduler.

## Prerequisites

- [ ] Docker stack healthy (`docker compose ps`)
- [ ] Relay OAuth configured — [CONFIG.md](./CONFIG.md)
- [ ] Gemini API key configured (draft metadata)
- [ ] 3 Account Groups seeded — [SETUP-NICHES.md](./SETUP-NICHES.md)
- [ ] YouTube + TikTok connected per niche in **Publish** UI
- [ ] KrillinAI pipeline tested — [KRILLINAI.md](./KRILLINAI.md)

## Content prep (per video)

1. Pick keyword from `keyword-bank.csv` (priority = high)
2. Source CN video → KrillinAI dub EN → vertical MP4
3. Upload to AiToEarn → generate draft metadata (title, description, hashtags)
4. Review hook in first 3 seconds (pattern interrupt / bold claim)

## Scheduling (EN market — US/EU)

| Platform | Frequency | Best windows (EST) |
|----------|-----------|-------------------|
| TikTok | 1–3/day per niche | 7–9am, 12–1pm, 7–9pm |
| YouTube Shorts | 1–2/day per niche | Stagger 2–4h after TikTok |

Use **Publish → Calendar** in AiToEarn:

1. Drag draft to calendar slot
2. Select accounts: `yt_{niche}` + `tt_{niche}`
3. Confirm platform-specific params (Shorts format, hashtags)

## Batch plan (week 1)

| Niche | Videos | Mix |
|-------|--------|-----|
| life_hacks | 5–10 | 70% CN repurpose + 30% AI gen |
| ai_tools | 5–10 | 50% AI gen + 50% repurpose |
| cooking_60s | 5–10 | 80% CN repurpose + 20% AI gen |

## Analytics loop (start week 2)

Weekly 30 min per niche:

| Metric | TikTok target | YouTube Shorts target |
|--------|--------------|----------------------|
| Completion rate | >50% | >70% |
| Rewatch rate | >10% | — |
| Shares/saves | Top 10% in niche | Top 10% in niche |

Actions:

1. Top 3 videos → analyze hook/topic → double down
2. Bottom 3 → kill pattern
3. Refresh `keyword-bank.csv`
4. Check Google Trends for rising topics

## API: create draft from video URL

After upload, metadata generation:

```http
POST /api/ai/draft-generation/video-url
Authorization: Bearer {token}
Content-Type: application/json

{
  "videoUrl": "https://your-rustfs-or-cdn-url/video.mp4",
  "groupId": "{draft_group_id}"
}
```

Then schedule via Publish UI or `POST /api/v2/channels/publish/flows`.
