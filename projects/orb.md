# Orb — Claude Code Wrapper Framework

**Repo:** https://github.com/KarryViber/Orb (⭐52, created 2026-04-16)
**Language:** JavaScript/Node.js

## What It Does
Multi-profile messaging shell around Claude Code CLI. Routes messages from Slack to per-profile Claude Code workers, with:
- Per-thread Claude Code sessions (reuses via inject IPC)
- Holographic long-term memory (SQLite, trust scoring, decay)
- DocStore FTS5 search with project slug inference
- Cron scheduling per profile
- MCP permission relay (surfaces Claude Code approvals in Slack)

## Architecture
User (Slack) → Orb (routing + memory + cron) → Claude Code CLI (one worker per thread) → Reply

Orb stays **outside** agent runtime — doesn't replace Claude Code's loop, just wraps it.

## Comparison to OpenClaw
- Similar concept: persistent agent shell wrapping coding CLI
- OpenClaw is more mature: multi-channel, multi-provider, skill system, heartbeat, ACP runtime
- Orb's "holographic memory" (trust scoring + decay) is interesting — OpenClaw uses flat markdown files
- Orb is Claude Code-only; OpenClaw is provider-agnostic

## Interesting Ideas
- **Trust-scored memory**: Facts get trust scores, decay over time. Could inform our memory evolution.
- **Per-thread session reuse via IPC inject**: Efficient approach to follow-up turns.

Links: [[openclaw]], [[coding-agent]]
