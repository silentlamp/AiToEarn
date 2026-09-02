# Internal Use — Multi-Channel Creator Ops

This fork of [silentlamp/AiToEarn](https://github.com/silentlamp/AiToEarn) is configured for **personal/internal use only**.

## Removed features

- Subscription billing (Paddle/Stripe)
- Wallet, income, and membership UI
- Task marketplace / earning / affiliate routes
- Credits balance gates before AI generation

## What remains

- Draft Box + AI batch video/image generation
- Multi-account publishing (YouTube, TikTok, 10+ platforms)
- Account Groups (Spaces) for niche-based channel management
- Calendar scheduler
- AI Agent + MCP integration
- `generateDraftFromVideoUrl` for repurposed content metadata

## Target workflow

See **[ops/QUY-TRINH-CHUAN.md](ops/QUY-TRINH-CHUAN.md)** for the full 5-phase standard operating procedure.

Summary:

1. Research keywords (external tools / `ops/keyword-bank.csv`)
2. Source CN videos → dub to English (KrillinAI — see `ops/KRILLINAI.md`)
3. Import into AiToEarn → generate draft metadata
4. Schedule publish to YouTube + TikTok per Account Group
5. Weekly analytics loop → back to step 1

## API costs

AI usage is billed by your own provider keys (Gemini, Seedance, Grok, etc.), not by AiToEarn. Configure via **Config Manager** in the app UI after deploy.

## Do not use

The sibling repo at `E:\production\aitoearn` (`silentlamp/Tako`) still contains full Paddle billing — it is a different project.
