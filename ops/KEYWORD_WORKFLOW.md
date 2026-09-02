# Keyword Research Workflow

Weekly routine (~2 hours per niche). Import [`keyword-bank.csv`](./keyword-bank.csv) into Google Sheets or use as-is.

## Tools (free)

| Tool | Action | Output |
|------|--------|--------|
| YouTube Autocomplete | Incognito search, type seed keyword | 25+ long-tail queries |
| TikTok Search | Type seed, capture suggestions | Trend angles (`...hack`, `...for beginners`) |
| Google Trends | Compare 2–3 candidates | Seasonal timing |
| TikTok Creative Center | Trending hashtags & sounds | Hashtag bank |

## Weekly steps (per niche)

1. **Seed** — use niche name from Account Group (`life_hacks`, etc.)
2. **Collect** — 50 autocomplete queries (YouTube + TikTok)
3. **Classify intent** — Learn / Watch / Compare / How-to
4. **Pick top 10** — map each to a video idea
5. **Update** `keyword-bank.csv` columns: `keyword`, `intent`, `source_platform`, `priority`
6. **Match CN source** — find 5–10 candidate videos on Bilibili/Douyin for top keywords
7. **Queue** — add to KrillinAI dub pipeline → AiToEarn draft

## Intent tags

- `learn` — how-to, tutorial
- `watch` — entertainment, satisfying
- `compare` — vs, best X for Y
- `how-to` — step-by-step

## Mix target

- 70% evergreen (how-to)
- 20% seasonal (Google Trends rising)
- 10% trend-driven (TikTok Creative Center)

## Optional paid tools (when scaling)

- [YoTrends](https://yotrends.ai) — Shorts + TikTok trend feed by country/niche
- [Virlo](https://virlo.ai) — niche analyzer, hashtag performance
- [Kurrently](https://kurrently.io) — real-time viral velocity

## Google Sheets setup

1. File → Import → Upload `keyword-bank.csv`
2. Add filter views per `niche` column
3. Add column `video_idea` and `cn_source_url` for production tracking
