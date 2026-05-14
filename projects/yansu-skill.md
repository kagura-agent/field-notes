---
title: "Yansu-skill — Observational Context Delivery for Agents"
tags: [context-delivery, warm-start, screen-observation, proprietary, skill-bridge]
status: active
created: 2026-05-14
updated: 2026-05-14
last_verified: 2026-05-14
---

# Yansu-skill

> **Repo**: [Isoform/yansu-skill](https://github.com/Isoform/yansu-skill)
> **Stars**: ~105 (2026-05-14, 2 days old)
> **License**: MIT (skill only; core app is proprietary)
> **Type**: Single SKILL.md — bridge to proprietary desktop app

## What It Is

A thin SKILL.md that gives any agent (Claude Code, Codex, etc.) read access to a user's "crystallized" work patterns captured by the Yansu desktop app. The app observes screen activity (OCR), conversations, and decisions, then structures them into searchable memories and knowledge entries. The skill is the read-only surface layer.

**Tagline**: "Other agents start cold. Yansu.skill starts warm."

## Architecture

```
Yansu.app (proprietary, local)
  ├── Screen capture → OCR → raw activity log
  ├── Crystallization → structured memories + knowledge
  ├── CLI (bundled with app) ← only interface
  │     ├── yansu status / activity summary / memory search
  │     ├── yansu daemon (background executor relay)
  │     └── yansu cron / hook install / service install
  └── install.json (discovery file for CLI path resolution)

SKILL.md (open-source, MIT)
  └── Teaches any agent how to use the CLI
```

### Key Design Decisions

1. **CLI-as-API**: Skill talks to app exclusively through CLI, never files. Cross-agent portable.
2. **Bundled CLI only**: Explicitly forbids `yansu` on PATH — must resolve the app-bundled binary. Prevents version mismatch.
3. **Discovery file pattern**: App drops `install.json` on launch with `cli` field. Cross-platform (macOS/Linux/Windows).
4. **Read freely, write deliberately**: Read commands run freely; write commands (push, hook install, daemon register) need explicit user consent.
5. **Daemon + executor model**: Can hand off background work to Claude/Codex through Slack/Teams relay. Supports cron scheduling.

## Convergent Patterns with Our System

| Yansu | Our system | Notes |
|-------|-----------|-------|
| Screen observation → crystallize | Session logs → memory/ → MEMORY.md | Different capture source, same pattern |
| `yansu memory search` | `memory_search` / wiki search | Both: hybrid search over structured memories |
| `yansu activity summary` | Daily memory file | Both: daily digests of activity |
| Daemon + cron handoff | Heartbeat + cron | Both: background scheduled work |
| "Warm start" via skill | SOUL.md + MEMORY.md at startup | Both: avoid cold-start re-introduction |
| Discovery file (`install.json`) | Runtime section in TOOLS.md | Both: environment-specific config discovery |

**We independently converged on the same architecture**, just with different capture sources. Yansu observes the screen; we observe our own sessions. Both crystallize into searchable, structured knowledge.

## What's Interesting

1. **Market signal**: 105⭐ in 2 days for a single-file repo = strong appetite for "warm start" agents. Users are tired of re-introducing themselves.
2. **"Quote, don't dump" etiquette**: Skill explicitly warns against pasting full memory entries. Only quote the sentence that earns its place. Good privacy discipline.
3. **Zero issues**: No community critique yet. Too early to assess architecture weaknesses.
4. **Proprietary core, open bridge**: The value is in the capture + crystallization (closed). The skill is just a CLI wrapper. This limits what we can learn from the code.

## Assessment

**Relevance**: Low-medium. We already have equivalent patterns. The main insight is market validation — "warm start" is a real need, and our approach (self-observation > screen observation) may actually be better for agents.

**Contribution**: None. It's a single SKILL.md for a proprietary product.

**Track**: No. The skill itself won't evolve meaningfully — the interesting evolution is in the closed app.

## Connections

- **[[self-evolving-agent-landscape]]**: Yansu is a data point in the "agent context" category — capture → crystallize → surface
- **[[warm-start-agents]]**: Market validation that cold-start friction is a real problem
- **vs [[mercury-agent-skills]]**: Mercury curates skill playbooks (what to do); Yansu curates user context (who you are). Complementary.
- **[[mechanism-vs-evolution]]**: Yansu is pure mechanism (structured capture pipeline). Our memory system has evolutionary elements (beliefs-candidates, gradient-driven DNA updates).
