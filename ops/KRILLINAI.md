# KrillinAI — CN to EN Repurpose Pipeline

End-to-end: download CN video → ASR → translate → English TTS dub → vertical MP4 → import to AiToEarn.

Repo: https://github.com/krillinai/KrillinAI

## Install (Windows)

1. Download latest release from [KrillinAI Releases](https://github.com/krillinai/KrillinAI/releases)
2. Extract to `ops/krillinai/` (or any path outside repo)
3. Copy `config.example.toml` → `config.toml`
4. Configure:
   - LLM provider (OpenAI-compatible or Gemini) for translation
   - TTS: **Edge TTS** (free, good for Shorts bulk) or ElevenLabs API key
   - Whisper for ASR (local or API)

## Pipeline commands

```bash
# Subtitle from Bilibili/YouTube/local file
krillinai subtitle --url "https://www.bilibili.com/video/BVxxxx"

# Dub to English
krillinai tts --lang en

# Render vertical (TikTok / YouTube Shorts)
krillinai render-vertical

# Full pipeline
krillinai pipeline --url "https://www.bilibili.com/video/BVxxxx" --target-lang en --format vertical
```

## Source platforms (CN ecosystem)

| Platform | Content type | Download |
|----------|-------------|----------|
| Douyin | Viral shorts | Manual browse + download tool |
| Bilibili | Tutorials, explainers | yt-dlp / KrillinAI URL input |
| Kuaishou | Life/rural content | Similar to Douyin |
| Xiaohongshu | Lifestyle tips | Manual + screen record fallback |

## Import to AiToEarn

1. Upload dubbed MP4 to **Agent Assets** or material library
2. Use **Draft Box → Create from video URL** (or API `POST ai/draft-generation/video-url`)
3. Gemini generates EN title, description, 3–5 hashtags
4. Schedule publish in **Publish** calendar for the matching Account Group

## Legal note

Transform content significantly (dub, re-edit, commentary). Do not re-upload raw CN videos without transformation.

## Voice stack recommendation

| Use case | Tool |
|----------|------|
| Bulk Shorts/TikTok | Edge TTS via KrillinAI (free) |
| Premium YouTube | ElevenLabs Multilingual v2 |
| AI-generated originals | Grok Imagine Video in AiToEarn Draft Box |
