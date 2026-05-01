---
title: oh-my-kimichan — Multi-Agent Orchestration for Kimi Code CLI
created: 2026-05-01
updated: 2026-05-01
status: active
stars: 12
url: https://github.com/dmae97/oh-my-kimichan
---

# oh-my-kimichan

**Worktree-based multi-agent orchestration harness for Kimi Code CLI (K2.6).** Turns a single coding agent CLI into a coordinated team with roles, DAG scheduling, ensemble voting, quality gates, and local graph memory.

Korean author (dmae97), heavy anime/mascot branding ("Kimichan"), TypeScript, Apache-2.0. Very new (created 2026-04-30).

## What It Solves

The same problem our [[team-lead]] skill tackles: **how to coordinate multiple coding agent instances on a shared codebase without conflicts.** Their answer: git worktrees for isolation + DAG for dependency ordering + ensemble for quality.

## Architecture

```
omk team → tmux session
  ├── coordinator (planner window)
  ├── worker-1..N (each in isolated git worktree)
  └── reviewer (code review window)
```

**Orchestration stack:**
- `task-graph.ts` — Kahn's algorithm topological sort, cycle detection, stable ordering
- `dag.ts` — Node state machine (pending→running→done/failed), retry tracking with attempts history
- `scheduler.ts` — Thin wrapper: runnable nodes = pending + all deps done
- `executor.ts` — Worker pool with configurable concurrency, state persistence, ETA estimation
- `ensemble.ts` — Role-aware candidate voting (see below)

**Worktree isolation** (`worktree.ts`):
- Each DAG node gets its own git worktree at `.omk/worktrees/{runId}/{nodeId}`
- Branch naming: `work/{runId}/{nodeId}`
- Cleanup via `git worktree remove --force`
- Simple but effective — avoids the merge-conflict-during-parallel-edit problem entirely

## Key Insight: Ensemble Voting

The most interesting pattern. Instead of running a task once, run it N times with different **perspectives** and aggregate:

```typescript
// For role "coder":
[
  { id: "implement", perspective: "minimal correct implementation" },
  { id: "edge-cases", perspective: "edge cases, error handling, backward compat" },
  { id: "simplicity", perspective: "delete/reuse-first simplification" },
]
```

Each candidate gets the perspective injected via env vars (`OMK_ENSEMBLE_PERSPECTIVE`). Results are scored by weight × confidence (parsed from stdout). Quorum ratio (default 50%) determines pass/fail.

**Tradeoff:** 2-3x LLM cost per node, but catches errors that a single perspective misses. Default `maxParallel = 1` serializes candidates (saves memory, no worktree conflicts between ensemble runs).

This is conceptually similar to [[self-consistency]] / majority voting in reasoning, but applied at the task level with role-specific perspectives.

## Local Graph Memory

JSON-file-backed graph store (`.omk/memory/graph-state.json`) with:
- **Ontology**: 16 node types (Project, Session, Memory, Goal, Topic, Decision, Task, Risk, Command, File, Evidence, Constraint, Question, Answer, Concept)
- **22 relation types** (HAS_SESSION, WROTE, UPDATES, DEPENDS_ON, BLOCKED_BY, TOUCHES_FILE, etc.)
- **Auto-extraction**: Parses markdown content into typed concepts via keyword matching (headings→Topic, bullets with "TODO"→Task, "?"→Question, etc.)
- **GraphQL-lite query API**: `omk_graph_query` supports `ontology`, `memory(path:)`, `memories(query:)`, `mindmap(query:)`, `nodes(type:)`
- **Mindmap tree**: BFS neighborhood expansion from project root, configurable depth

**vs our approach**: We use flat markdown files (wiki/projects/, wiki/cards/) with [[wikilinks]] and full-text search (memex). Their graph is richer structurally but the auto-extraction is keyword-based (fragile). Our manual curation produces higher-quality links. The mindmap visualization is novel though.

Optional Neo4j backend for production scale.

## Approval Policy

Four levels: `interactive` (ask for destructive), `auto` (safe tools auto-allow), `yolo` (allow all), `block` (deny all). Comparable to [[cadis]] policy gates but simpler.

Tool classification:
- Safe: ReadFile, Glob, Grep, SearchWeb, FetchURL
- Destructive: Shell, WriteFile, StrReplaceFile, applyDiff

## Kimi-Specific: Okabe + D-Mail

Leverages Kimi Code's built-in `SendDMail` tool for checkpointing (inspired by Steins;Gate's D-Mail concept). Each agent extends `okabe.yaml` base which includes Kimi's native tools + plan mode + background tasks.

## What We Can Learn

1. **Worktree isolation is the simplest correct solution** for multi-agent parallel coding. Our team-lead skill should mandate this.
2. **Ensemble voting per-role** is an interesting quality improvement. Could apply to our PR review workflow — run review from correctness + security + maintainability perspectives separately, then aggregate.
3. **ETA estimation** (`eta.ts`) — tracks completed node durations, averages them, divides remaining by worker count. Simple but useful for long orchestration runs. Our FlowForge could add this.
4. **State persistence** during execution — if the process dies, resume from last persisted state. Our FlowForge has instance state but not mid-workflow DAG checkpointing.

## What They Don't Have (That We Do)

- No contribution/PR workflow (no `gogetajob` equivalent)
- No cross-session memory continuity (their graph is per-project, not per-agent identity)
- No cron/heartbeat system
- No skill marketplace integration
- Kimi-only (we're model-agnostic via ACP)

## Position in Ecosystem

Part of the "coding agent harness" wave alongside [[cadis]], [[codex-plusplus]], [[stash]], and our own [[openclaw]]. Each wraps a coding agent CLI with orchestration. The differentiator here is the ensemble voting pattern — most others focus on worktree isolation + DAG but don't do multi-perspective aggregation.

12⭐ is very early. Worth watching if the ensemble pattern catches on. The Korean/Japanese community overlap with Kimi Code might give it a niche.

## Related

- [[cadis]] — Similar vision (multi-agent runtime), different execution (Rust daemon vs Node.js CLI wrapper)
- [[team-lead]] — Our skill for multi-agent coordination
- [[stash]] — Another coding agent harness (Claude Code focused)
- [[dirac]] — Hash-anchored edits, AST-native tools (complementary approach to edit safety)
