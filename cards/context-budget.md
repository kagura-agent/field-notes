---
title: "Context Budget Optimization"
created: 2026-04-16
tags: [optimization, tokens, openclaw]
---

# Context Budget

Strategy for reducing token consumption in OpenClaw workspace files injected into every session.

## Tiers
- **Tier A**: SOUL.md/IDENTITY.md compression — done
- **Tier B**: AGENTS.md dedup/compression — done (saved 1,319 tokens, 17.6%)
- **Tier C**: Workspace files selective injection — pending OpenClaw #66576

## Tracking
- Baseline measured 04-14: ~7,494 tokens (original), ~6,175 tokens (post Tier A+B)
- Re-measured 04-19: ~5,861 tokens (381 lines / 20,514 chars). Total savings: ~1,633 tokens (21.8%)
- Next re-measure: 05-03

Related: [[openclaw-architecture]]
