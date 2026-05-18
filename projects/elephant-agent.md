---
title: Elephant Agent (agentic-in)
created: 2026-05-17
status: active
tags: [self-evolution, personal-model, memory, agent-infrastructure, curiosity]
stars: 287
repo: agentic-in/elephant-agent
last_verified: 2026-05-18
---

# Elephant Agent

> "Elephants never forget." — Personal-Model-first self-evolving AI agent.

**Repo**: [agentic-in/elephant-agent](https://github.com/agentic-in/elephant-agent) | 287⭐ (2026-05-18, created 05-15) | Python | No license yet

## What It Is

A personal AI companion framework built around a **Personal Model** — a structured, correctable understanding of the user that evolves through conversation, curiosity, and background reflection. Key thesis: memory that becomes **care, context, and better judgment**, not just transcript storage.

## Architecture

**Monorepo structure** (~910 files):
- `apps/cli/` — Interactive shell with voice, snapshot, sub-agents, growth metrics
- `apps/api/` — HTTP API runtime with cron, recall, provider methods
- `packages/` — Core packages (25+ packages)

**Key packages:**
| Package | Purpose |
|---------|---------|
| `understanding` | Personal Model governance, semantic search, temporal freshness, auto-retire |
| `curiosity` | Proactive question generation, ask policy (idle threshold, daily max, quiet hours) |
| `evidence` | Unified recall, episode summary indexing, recall planning/reranking, time-range queries |
| `continuity` | Cross-session projection |
| `experience` | Experience capture and runtime |
| `growth` | Self-evolution metrics, rollout, projection |
| `semantic_index` | Embedding-based search |
| `skills` | Builtin skill packages (MLOps, telephony, security) |
| `kernel` | Core runtime |
| `state` | State management |

## Personal Model — Four Lenses

| Lens | What it carries |
|------|----------------|
| **Identity** | Values, decision style, boundaries, durable preferences |
| **World** | Projects, people, tools, places, vocabulary, relationships |
| **Pulse** | Current focus, pressure, constraints, mood, temporary priorities |
| **Journey** | Past experiences, lessons, failures, recovery patterns, growth |

**Learning sources:**
1. **Grounded** — explicit remembers, corrections, dashboard edits
2. **Curiosity-driven** — proactive questions at natural pauses
3. **Reflect-driven** — background agents reading episode steps after close/idle
4. **Skill fit** — learning from capability use

## Curiosity System (Unique Differentiator)

Configurable curiosity levels: Quiet → Balanced → Active

**Proactive ask policy** (`proactive_ask_policy.py`):
- Numeric parameters: `idle_threshold_minutes`, `daily_max`, `quiet_hours`
- Question lifecycle: open → asked → answered/dismissed
- Each question tied to a Personal Model lens with a reason (gap, conflict, stale pulse, adaptation)
- `max_asked_count` prevents repetitive asking

## Evidence & Recall

- **Unified recall** — single entry point for memory retrieval across all evidence types
- **Episode summary indexing** — compressed episode representations
- **Recall reranking** — multi-signal reranking (semantic + temporal freshness)
- **Temporal policy** — freshness scoring by volatility (situational vs durable)
- **Auto-retire** — stale claims automatically retired

## Relevance to Us ([[OpenClaw]])

**Direct parallels:**
- Their Personal Model ≈ our MEMORY.md + beliefs-candidates (but more structured)
- Their curiosity system = something we lack entirely — proactive learning about the user
- Their evidence trail ≈ our memory/*.md daily logs (but with recall reranking)
- Their growth package ≈ our DNA self-governance (but metrics-driven)

**What they do better:**
- **Structured user model** with four lenses vs our flat MEMORY.md
- **Proactive curiosity** — asks questions instead of passively accumulating
- **Temporal freshness** — automatic decay of stale understanding
- **Auto-retire** — claims that haven't been accessed get cleaned up

**What we do differently:**
- **Skill ecosystem** — ClawHub, skill distribution, multi-agent
- **External integrations** — Discord, Feishu, WhatsApp channels
- **Open-source contribution workflow** — GoGetAJob, FlowForge
- **DNA self-governance** — beliefs → verification → DNA updates

**Potential borrowing:**
1. ~~Four-lens Personal Model structure for MEMORY.md organization~~
2. Curiosity system — proactive question generation during conversations
3. ~~Temporal freshness scoring for beliefs-candidates~~ (already have temporal decay in search.sh)
4. Auto-retire for stale memory entries

**Applied:**
- **Intent-aware recall reranking** (2026-05-18): Ported `plan_recall_query()` concept to `wiki/search.sh`. Classifies query intent (recent/historical/current/neutral) and adjusts decay rate (δ=0.05–0.50). Benchmark: 100% precision maintained. See [[temporal-decay-retrieval]].

## Assessment

**Why this matters:** 247⭐ in 2 days, Product Hunt featured, well-architected Python codebase. The "Personal Model" approach is a sophisticated answer to the same problem we solve with MEMORY.md — but with more structure, proactive learning, and governance.

**Growth signal:** Very strong launch trajectory. Created 05-15, already 247⭐. Active development (pushed 05-16).

## Issues & Community (05-17)

19 issues, all by maintainer (Xunzhuo) — pure roadmap, no external critique yet. Solo project. Key roadmap items:
- P0: Personal Model export/import (portability!), daemon process isolation, E2E regression suite, memory eval pipeline (LoCoMo), context compression alignment, prefix-cache reuse
- P1: ADP agent-to-agent communication, vLLM Semantic Router, reflect skill optimization, hot-reload config
- P2: Expand skill/provider ecosystem

201 test files — well-tested for a 2-day-old project. Tests reveal intent-aware recall reranking: queries like "最近聊了啥" get recency boost, "当初为什么" gets historical boost, "现在X是多少" gets strong freshness boost. This is more sophisticated than simple recency bias.

## Deep Read Insights

**Intent-aware recall reranking** — their `plan_recall_query()` classifies user intent (recent/historical/current/neutral) and applies different time-score weights. This directly addresses the problem of "all memories are equal" that plagues flat retrieval.

**Temporal freshness policy** — claims have volatility levels (situational vs durable), and freshness scoring penalizes stale claims without overriding semantic relevance. The penalty is capped at 0.49 to prevent freshness from dominating relevance.

**Single maintainer risk** — Initial concern about solo project **alleviated** (05-18). Now 4+ contributors: Xunzhuo (maintainer), haowu1234 (lifecycle/tests), minimAluminiumalism (uv migration, provider caps), BokwaiHo (docs). 10 external PRs in first week. Community health upgraded from SOLO → THRIVING.

**Watch for:** License (none yet), whether the structured model actually works better than flat notes in practice, episode lifecycle stability (3 refactors in 2 days suggests churn).

## Update 2026-05-18: Unified Daemon + Episode Lifecycle Maturation

**Key changes since last review (05-17 → 05-18):**

1. **Unified ServiceDaemon** (PR #29, +2752 lines): All services (IM gateways, cron, supervisor, learning worker) run in a single asyncio process with fault isolation via `DaemonTaskGuard`, health heartbeats, and graceful shutdown with configurable timeouts. Replaces per-adapter detached processes. Pattern worth studying — OpenClaw uses similar but less structured approach.

2. **Episode session boundary unification** (PR #30, 763+/784-): Major refactor across 44 files. All episode close paths now go through a single `close_episode()` function with guaranteed side-effects (semantic indexing + learning job enqueue). Clean state machine: `open → closed` with idempotent close.

3. **Episode status normalization** (PR #32): Daemon lock (`fcntl.flock`) prevents TOCTOU races on concurrent `daemon start`. Gateway adapter dedup for hot-start.

4. **uv migration** (PR #26): Replaced pip with uv for dependency management. Modern Python tooling.

5. **Provider capability alignment** (PR #28): Model provider capabilities mapped to official API specs.

**Architectural insight — single close path pattern:**
```python
def close_episode(storage, episode_id, *, reason, summary, ...):
    """ONLY path through which an episode should be closed."""
    # 1. Load + idempotent guard
    # 2. Update status
    # 3. Side-effect: index exit summary for recall
    # 4. Side-effect: enqueue learning job
```
This "single gateway with guaranteed side-effects" is a pattern we should consider for our own state transitions (e.g., memory writes, DNA updates).

**Community health:** 287⭐ (up from 285 on 05-17). Growth slowing from initial burst but still healthy. 4+ contributors now active. Issue #18 (provider capability registry) shows thoughtful roadmap evolution.

Links: [[self-evolving-agent-landscape]], [[hermes-agent]], [[genericagent]], [[gbrain]], [[agent-brain-portability]]
