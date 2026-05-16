# OpenHuman

**Repo:** [tinyhumansai/openhuman](https://github.com/tinyhumansai/openhuman)
**Created:** 2026-02-18 | **Stars:** ~9,000 (as of 2026-05-16) | **Forks:** 756
**License:** GPL-3.0 | **Status:** Early Beta
**Creator:** @senamakel (TinyHumans AI)
**Website:** tinyhumans.ai/openhuman

## What It Is

Open-source "Personal AI super intelligence" — a desktop agentic assistant that integrates with your daily life through 118+ third-party OAuth integrations. Positions itself as the **UI-first, privacy-forward** alternative to terminal-based agent harnesses (OpenClaw, Hermes, etc.).

Key selling point: **context in minutes, not weeks** — connect your accounts, auto-fetch syncs data every 20 minutes, Memory Tree compresses everything into a local knowledge base. No training period.

## Tech Stack & Architecture

```
React Frontend (Vite + Tailwind) → JSON-RPC → Rust Core → Tauri v2 Shell
```

- **Core:** Rust binary (`src/`) — all business logic lives here
  - Memory Tree pipeline (chunk → score → summarize → retrieve)
  - Integration adapters + auto-fetch scheduler
  - Model routing (sends tasks to right LLM: reasoning/fast/vision)
  - TokenJuice token compression (up to 80% reduction)
  - Native tools: web search, scraper, filesystem, git, voice
  - Voice: STT in, ElevenLabs TTS out, lip-sync, Google Meet agent
- **Desktop Shell:** Tauri v2 + CEF child webviews for integration providers
- **Frontend:** React — presentation only, no business logic
- **Data:** SQLite (Memory Tree chunks), Obsidian-compatible Markdown vault
- **Build:** Node 24+, pnpm 10.10, Rust 1.93, CMake
- **Distribution:** DMG, EXE, curl install script, Homebrew, npm, deb

### Memory Tree (核心差异化)

Inspired by Karpathy's Obsidian-wiki workflow. Data flow:
1. OAuth connect → auto-fetch every 20min → normalize to Markdown
2. Split into ≤3k-token chunks → store in SQLite + `.md` files
3. Embeddings + entity extraction + hotness scoring
4. Hierarchical summary trees (source/topic/global)
5. Agent queries Memory Tree at runtime

All memory stays local on device. The Obsidian vault is human-browsable and editable.

### Privacy Model

**On device:** Memory Tree DB, Obsidian vault, audio buffers, local model state
**Through backend:** LLM calls (proxied under one subscription), web search proxy, OAuth token storage, integration request brokering

OAuth tokens held server-side (never plaintext on device). OS keychain for sensitive local tokens. No training on user data. Optional local AI via Ollama for fully on-device operation.

## Growth Trajectory

- Created 2026-02-18, ~9K stars in ~3 months
- ~100 stars/day average (with spikes much higher — reportedly 1,272/day peak)
- Product Hunt featured, TrendShift trending
- 756 forks, 129 open issues — active contributor community
- Has AGENTS.md, CLAUDE.md, CODEX_WORKPAD.md — designed for AI-assisted contribution

### Why It's Blowing Up

1. **UI-first in a terminal-first world** — clean desktop app, mascot with face/voice, no config-first setup
2. **118+ integrations with one-click OAuth** — massive moat vs. BYO-connector approaches
3. **Memory Tree narrative** — "knows you in minutes" is compelling marketing vs. weeks of training
4. **Karpathy endorsement/inspiration** — citing his Obsidian workflow gives instant credibility
5. **TokenJuice** — practical cost/latency reduction that users feel
6. **Meeting agent** — joins Google Meet as a real participant, very demo-friendly

## Overlap & Divergence with Our Direction

### Where We Overlap
| Area | OpenHuman | OpenClaw/Kagura |
|---|---|---|
| Open source agent harness | ✅ GPL-3 | ✅ MIT |
| Privacy-first positioning | ✅ Local memory | ✅ Local-first |
| Agent-as-companion | ✅ Mascot with personality | ✅ Soul/identity system |
| Memory/context system | ✅ Memory Tree + Obsidian | ✅ Memory files + wiki |
| Voice support | ✅ STT/TTS/lip-sync | ✅ ElevenLabs TTS |
| Multi-model routing | ✅ Built-in router | ✅ Provider config |

### Where They Diverge
| Dimension | OpenHuman | OpenClaw/Kagura |
|---|---|---|
| **Target user** | Non-technical, desktop | Technical, server/CLI |
| **Delivery** | Desktop app (Tauri) | CLI + gateway daemon |
| **Integration model** | 118+ OAuth connectors | Channel adapters (Discord, Feishu, etc.) |
| **Memory architecture** | Auto-fetch → chunk → embed → tree | File-based (MEMORY.md, wiki/, daily logs) |
| **Business model** | One subscription (proxied LLM) | BYO API keys |
| **Agent identity** | Desktop mascot, face, lip-sync | Text-based soul (SOUL.md, DNA) |
| **Philosophy** | "Minutes to context" via auto-ingest | "Earn context" through interaction |
| **License** | GPL-3 (copyleft) | MIT (permissive) |
| **Privacy trade-off** | OAuth tokens on their server | Fully self-hosted, no intermediary |

### Key Differences in Privacy Approach
OpenHuman says "privacy-first" but routes all LLM calls, search, and OAuth through their backend. They hold your integration tokens server-side. OpenClaw is truly self-hosted — you bring your own keys, no intermediary. OpenHuman's privacy is "local memory, proxied compute"; OpenClaw's is "local everything."

## Key Takeaways

1. **UI matters** — OpenHuman's explosive growth proves there's massive demand for agent harnesses that don't require terminal comfort. OpenClaw's terminal-first approach limits addressable market.

2. **Auto-fetch is a killer feature** — Proactive data ingestion (vs. waiting for the user to provide context) is the biggest UX win. Our heartbeat/cron system is the closest analog but doesn't auto-ingest from connected services.

3. **Memory Tree vs. flat files** — Their hierarchical chunk→embed→summarize pipeline is more sophisticated than our MEMORY.md + wiki approach. The Obsidian-compatible output is genius — users can browse/edit their agent's memory.

4. **Integration moat** — 118+ OAuth integrations is a massive effort. OpenClaw's channel adapter model is narrower but deeper (Discord bot, Feishu app, etc. with full bidirectional messaging).

5. **"One subscription" model** — Proxying LLM calls through their backend simplifies onboarding but creates vendor lock-in and a privacy choke point. OpenClaw's BYO-key model is more aligned with true self-sovereignty.

6. **Desktop mascot/meeting agent** — The anthropomorphic UI (face, voice, lip-sync, Google Meet participant) makes the "companion" feeling tangible. Our identity system (SOUL.md, stories, memes) achieves this through text/voice but lacks the visual presence.

7. **Potential inspiration:** Memory Tree architecture (hierarchical summarization of ingested data) could improve our wiki/memory system. Auto-fetch concept could be adapted for our heartbeat system.

## Verdict

OpenHuman is optimizing for a different user: someone who wants a polished desktop experience with minimal setup. We're building for power users who want full control. Their growth validates the "personal AI companion" thesis we share, but their approach trades self-sovereignty for convenience. The Memory Tree and auto-fetch patterns are worth studying; the subscription-proxy model is not our path.

---
*Card created: 2026-05-16 | Source: GitHub repo + GitBook docs*
