---
title: "Dreaming (OpenClaw Memory Consolidation)"
created: 2026-04-16
tags: [memory, openclaw, consolidation]
---

# Dreaming

OpenClaw's offline memory consolidation system. Runs during low-activity periods (cron 3:30 AM) to strengthen important memories and surface patterns.

## Phases
- **Light Sleep**: Short-term recall scoring — which memories were accessed recently?
- **REM**: Deep consolidation — cross-reference, find themes, promote to long-term

## Reference: GBrain runCycle (v0.17.0)
[[gbrain]] unified all maintenance into `runCycle()` — one primitive, 6 phases in fixed order (lint → backlinks → sync → extract → embed → orphans). Three callers converge. Key insight: **fix files first, then index** — phase order matters. Lock coordination via DB rows with TTL (not session-scoped advisory locks, which break under connection pooling). This is the target architecture for our dreaming.

## Our Setup
- Enabled 04-13, first successful run 04-15
- Config: `openclaw.json → plugins.entries.memory-core.config.dreaming`
- Light: 3-day lookback; REM: 7-day lookback
- Storage: both inline + separate reports

## Status (04-16)
- 197 memory chunks tracked, 194 light hits, 3 REM hits
- 113 events accumulated
- Workaround for quiet-hours skip: triggered via daily-review cron ✅

Related: [[dreaming-vs-beliefs-candidates]], [[openclaw-architecture]]
