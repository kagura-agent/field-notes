# Thoth — Dashboard-First Orchestration Runtime for Autoresearch

**Repo**: https://github.com/SeeleAI/Thoth
**Stars**: 39 (2026-05-02)
**Created**: 2026-04-24
**Pushed**: 2026-05-01
**Language**: Python
**License**: MIT
**Version**: 0.1.8

## What It Is

A "dashboard-first" orchestration runtime for autoresearch projects. Designed as a Claude Code plugin (and Codex plugin). The core idea: instead of treating agent work as a series of ad-hoc chat interactions, Thoth structures everything into durable, trackable, reviewable work units.

## Why It's Interesting

Thoth solves a problem we face daily: **agent work drifts**. When an agent works on something complex, it can lose track of goals, loop without progress, or produce unverifiable results. Thoth's answer is to impose structure through a planning authority + execution runtime split with a dashboard for observability.

## Architecture: Three-Layer Control Plane

### Layer 1: Host Surface
Commands exposed to the agent: `init`, `discuss`, `run`, `loop`, `review`, `auto`, `status`, `doctor`, `dashboard`.

### Layer 2: Planning Authority
- `discuss` → structured planning: interrogate goals, constraints, success criteria, risks. **No code allowed during discuss.**
- Decisions → Work Items → Ready Work (with `work_id@revision` binding)
- Object graph: Discussion → Decision → Work Item. Clean separation of planning and execution.

### Layer 3: Execution Runtime
- `run` → one durable execution packet, four-phase lifecycle: **plan → execute → validate → reflect**
- `loop` → bounded controller spawning child runs
- `auto` → priority-driven work queue, runs until queue empty or budget exhausted
- `review` → structured critique with role identification + first principles decomposition

## Key Design Decisions

### 1. Work-ID Binding
Every run is bound to `work_id@revision`. The agent **cannot invent work items** — if `--work-id` is missing, it must show candidates and stop. This prevents scope creep.

### 2. Plateau Detection
For metric-optimizing loops, Thoth tracks `iterations_since_best` with configurable patience (default 15). When plateaued → pause and ask user. Handles noisy metrics with median of 3 runs and min-delta thresholds.

### 3. Git-as-Memory
Before proposing changes, check `git log --oneline -20` + `git diff HEAD~1` + grep for reverts. Anti-repetition: avoid recently reverted approaches. This is a simple but effective way to prevent cyclic failures.

### 4. Atomic Commits
One logical change per iteration, focused staging (`git add <specific-files>`), never blanket staging.

### 5. Dual-Host Execution
Supports `--executor claude|codex` — can dispatch work to either Claude Code or Codex, with explicit guards against "silently doing Codex work as Claude."

### 6. Review Protocol
Structured first-principles review: role identification → axiom decomposition → critique (strengths/weaknesses/risks/blind spots) → recommendations → interactive discussion. Not a monologue — ends with probing questions.

## Comparison with FlowForge

| Aspect | Thoth | FlowForge |
|--------|-------|-----------|
| Focus | Autoresearch/engineering within a repo | General agent workflow orchestration |
| State | `.thoth/` directory (JSON objects) | SQLite database |
| Work binding | `work_id@revision` strict | Instance + node name |
| Planning | Dedicated `discuss` command, no-code zone | No separate planning phase |
| Dashboard | FastAPI + uvicorn local dashboard | CLI-only |
| Plateau detect | Built-in metric monitoring | Not present |
| Agent host | Claude Code / Codex plugin | Agent-agnostic |
| Durability | Git-backed, recoverable from files | DB-backed |

## Patterns Worth Borrowing

1. **Planning-Execution Separation**: `discuss` being explicitly no-code is clever. We could add a "plan" node type in FlowForge that prevents the agent from jumping to implementation.

2. **Plateau Detection**: For workloops that optimize something (contribution quality, wiki health metrics), detecting stalls and asking for strategy changes instead of blindly continuing. ~~Currently FlowForge just runs until done.~~ **Applied (2026-05-02)**: FlowForge v1.1.2+ now tracks node visit counts per instance and warns when a node is revisited ≥ max_visits (default: 5). Nodes can set custom `max_visits` in YAML. Warning is surfaced in CLI output.

3. **Work-ID Binding**: Strict task binding prevents scope creep. Our `flowforge start` with YAML-defined nodes is less strict — the agent interprets tasks flexibly, which can drift.

4. **Review Protocol**: The structured role-first review approach could improve our `reflect` workflows. Explicitly choosing a review persona before starting.

## Limitations

- **Young project**: 39 stars, 8 days old, no community yet
- **Claude Code-centric**: Deeply tied to Claude Code/Codex plugin system, not portable
- **No memory layer**: Uses git-as-memory, no persistent knowledge graph or embedding search
- **Autoresearch niche**: Designed for metric-optimization loops (ML experiments, benchmark tuning), not general agent orchestration

## Position in Agent Ecosystem

Sits in the **agent infrastructure** layer, between [[flowforge]] (workflow orchestration) and [[cadis]] (runtime with HUD). Closer to engineering project management than to memory/skill systems. Complements rather than competes with [[stash]] (memory) or [[agentic-stack]] (skill ecosystem).

## Related

- [[flowforge]] — our workflow engine, solves similar coordination problems differently
- [[cadis]] — Rust runtime with desktop HUD, also has worktree isolation
- [[worktree-convergence-2026-05]] — the multi-agent worktree pattern Thoth also uses
- [[mechanism-vs-evolution]] — Thoth is firmly on the "mechanism" side: structure prevents drift, rather than evolving past it
