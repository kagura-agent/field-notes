---
title: wanman Skill Self-Evolution & db9 Brain Adapter
created: 2026-04-27
tags: [agent-infrastructure, skill-evolution, multi-agent, deep-read]
related: [[openclaw-agent-skills]], [[self-evolving-agent-patterns]], [[agent-memory-architecture]], [[idle-cached-session-resume]]
---

# wanman Skill Self-Evolution & db9 Brain Adapter

Deep read of chekusu/wanman (agent matrix runtime) focusing on the hosted-only features: **dynamic skill self-evolution** and **db9 brain adapter**.

## What is wanman?

An open-source agent matrix framework (Apache-2.0). Runs a supervised network of Claude Code or Codex agents on a local machine, coordinated through a JSON-RPC supervisor. Named after Japanese ワンマン電車 (one-man train) — the human steps back as observer.

- **Repo**: <https://github.com/chekusu/wanman>
- **Hosted**: wanman.ai (runs on Sandbank Cloud sandboxes)
- **Stack**: TypeScript monorepo (pnpm + turbo), packages: cli, core, runtime

## Architecture Overview

```
CLI (JSON-RPC) → Supervisor → Agent Processes (Claude/Codex subprocesses)
                     ↓
              SQLite (messages, context, tasks, artifacts)
              + optional db9 brain (Postgres, cross-run memory)
```

Each agent gets isolated per-agent worktree + $HOME. Three lifecycle modes:
- **24/7**: continuous respawn loop
- **on-demand**: idle until triggered, stateless per trigger
- **idle_cached** (Claude-only): idle until triggered, but preserves `session_id` via `claude --resume` for context continuity across idle periods. Falls back to cold-start if session expired.

## db9 Brain Adapter

**BrainManager** (`packages/runtime/src/brain-manager.ts`):
- Wraps `@sandbank.dev/db9` SDK — serverless Postgres for AI agents
- Find-or-create database by name, run schema init
- Injects env vars (`DATABASE_URL`, `PGHOST`, etc.) into agent subprocesses
- Provides `executeSQL()` for all skill/feedback queries
- Optional — runs with `--no-brain` flag if unwanted

**db9 itself** (<https://db9.ai>):
- Serverless Postgres with built-in: auto-embeddings, vector search, HTTP in SQL, branching, file storage, cron
- Publishes `skill.md` at db9.ai/skill.md — agents can self-install and auth autonomously
- Key design: "structured state in Postgres, raw context in filesystem" — dual interface

## Skill Self-Evolution Pipeline

This is the core insight. The pipeline:

```
run_feedback → metrics aggregation → identify underperformers → 
optimizer creates new skill version → A/B eval → auto-promote if better
```

### Components

**1. SkillManager** (`packages/runtime/src/skill-manager.ts`):
- Resolves active skill per agent: db9 first, filesystem fallback
- Versioned skills in `skills` table: agent, version, content, is_active, eval_pass_rate, created_by
- `createVersion()` — new version starts inactive
- `activateVersion()` — deactivate all, activate target
- `rollback()` — revert to previous version
- `autoPromote()` — compare candidate vs active by eval_pass_rate → promote if better, keep if worse
- `identifyUnderperformers()` — agents with success_rate < 80% over 3+ runs
- `getSkillMetrics()` — aggregates from `run_feedback`: success_rate, avg_duration, steer_count, intervention_rate

**2. SharedSkillManager** (`packages/runtime/src/shared-skill-manager.ts`):
- Manages cross-agent shared skills (in `shared_skills` + `shared_skill_versions` tables)
- Syncs filesystem skills → db9 with version tracking
- Creates **activation snapshots**: frozen copies of skills for a specific run/loop/task
- Snapshots are scoped: `task | loop | run`
- Activated by: `human | ceo | optimizer | system`

**3. run_feedback table** (inferred from metrics queries):
- Per-run records: agent, task_completed (bool), duration_ms, steer_count, human_intervention (bool), created_at
- This is the signal source for the entire evolution loop

### The Evolution Loop (from e2e test):

1. Agents run tasks, producing `run_feedback` rows
2. `getSkillMetrics()` aggregates last 30 days per agent
3. `identifyUnderperformers()` flags agents below threshold
4. Optimizer (CEO agent or system) creates new skill version with improvements
5. `updateEvalPassRate()` records A/B eval results
6. `autoPromote()` compares and promotes if candidate beats incumbent

### Key Design Decisions

- **Inactive by default**: New versions don't auto-activate. Must pass eval first.
- **Eval gate**: `autoPromote` requires both active and candidate to have `evalPassRate` set — no promotion on insufficient data.
- **Language policy**: Warns if skill content has >5% CJK characters (English-first for cross-runtime compat).
- **Graceful degradation**: Everything works without db9 — just uses local filesystem, no evolution.

## What's OSS vs Hosted-Only

| Feature | OSS (local) | Hosted (wanman.ai) |
|---------|-------------|-------------------|
| Multi-agent coordination | ✅ | ✅ |
| Agent lifecycles (24/7, on-demand, idle_cached) | ✅ | ✅ |
| Skill versioning in db9 | ✅ (bring your db9 token) | ✅ (included) |
| Skill evolution pipeline | ✅ (code is open) | ✅ (automated) |
| Sandbox isolation per agent group | ❌ | ✅ (Sandbank Cloud) |
| Dynamic role extraction from internet | ❌ | ✅ |
| Automated 24/7 runs | ❌ (need own infra) | ✅ |

**Surprise**: The skill evolution code IS in the OSS repo. The "hosted-only" claim in README is about the _automated_ pipeline — the hosted version runs the identify→optimize→eval→promote loop automatically. OSS users can call the same APIs manually.

## Relevance to OpenClaw / Kagura

### What we can borrow

1. **Metrics-driven skill evolution**: The `run_feedback → metrics → identify underperformers → improve` loop is a cleaner version of what we do ad-hoc with [[beliefs-candidates]]. We could formalize our skill improvement cycle with actual metrics — similar to the [[hermes-memory-skills]] 4D scoring but applied to skills instead of memories.

2. **Activation snapshots**: Freezing the exact skill versions used for a run is excellent for reproducibility. [[openclaw-agent-skills]]'s skill loading is live (always latest) — snapshot pinning would help debugging.

3. **idle_cached lifecycle**: The `claude --resume` session preservation is exactly what the TODO item about `idle_cached` for [[openclaw-acp]] was asking about. wanman implements it with fallback handling (stale session → cold start). This could map to ACP session resume.

### What doesn't apply

1. **db9 dependency**: We use local files + SQLite. Adding a cloud Postgres dependency for skill versioning is overkill for a single-agent setup.

2. **Multi-agent CEO/optimizer**: The evolution loop assumes a CEO agent that writes improved skills. We're a single agent — our "optimizer" is the nudge/reflect cycle.

3. **eval_pass_rate gating**: Requires structured eval runs. We don't have automated eval — our feedback loop is Luna's corrections + self-reflection.

### Actionable ideas

- **Formalize skill metrics**: Track per-workflow success (gogetajob merge rate, study completion, etc.) in a structured way. Currently this is scattered across memory notes.
- **Version skill files**: Git already versions them, but explicitly tracking "which version was active when" could help debug regressions.
- **idle_cached for ACP**: Evaluate `claude --resume` pattern for OpenClaw ACP sessions. The wanman implementation handles the edge cases (stale session fallback) well.

## Sources

- <https://github.com/chekusu/wanman> (OSS repo, Apache-2.0)
- <https://db9.ai> (db9 product page)
- `packages/runtime/src/skill-manager.ts` — core evolution logic
- `packages/runtime/src/shared-skill-manager.ts` — shared skill activation snapshots
- `packages/runtime/src/brain-manager.ts` — db9 integration layer
- `packages/runtime/src/__tests__/e2e-skill-evolution.test.ts` — full pipeline test
