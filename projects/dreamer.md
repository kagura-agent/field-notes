---
title: Dreamer — Team-Wide Self-Evolving Context Server
created: 2026-05-06
source: scout session #1431, deep read of luml-ai/dreamer
tags: [self-evolving, memory, context, mcp, team, agent-infrastructure]
stars: 13
status: brand-new (2026-05-05)
---

# Dreamer

**Repo:** [luml-ai/dreamer](https://github.com/luml-ai/dreamer)
**What:** Self-hosted MCP server that collects agent memories and periodically "dreams" — regenerating AGENTS.md and context bundles from accumulated observations.

## Core Concept

Dreamer solves the **team-wide agent memory problem**: when multiple agents (Claude Code, Cursor, Codex) work in the same codebase, their individual learnings stay siloed. Dreamer pools memories into a shared store, then uses an LLM to distill them into a single context bundle that all agents read.

## Architecture

Two-phase "dream" pipeline:

1. **LTM Phase** — fold new short-term memories (STM batch) into long-term memory (markdown files in `memory/`). The LLM is given the inbox + existing LTM and asked to evolve, not replace.
2. **Context Phase** — update agent-facing context (`AGENTS.md`, skills) from the LTM diff. Only touches what changed, doesn't re-derive from scratch.

### Component Graph (Protocol-based)

Every slot is a Python Protocol in `dreamer.api`:
- `STMStore` — short-term memory (SQLite default). submit/claim_batch/mark_consumed
- `LTMStore` — long-term memory (markdown workspace). open/commit/discard workspace
- `ContextStore` — agent-facing context (also markdown workspace). Same interface as LTM
- `DreamEngine` — LTM + Context phase runners (Claude Agent SDK default)
- `DreamGate` — decides whether to dream (budget gate, empty gate)
- `DreamLeaseStore` — distributed locking for dream exclusivity
- `PostDreamHook` — git commit, GitHub PR opening
- `STMSerializer` — materializes memory batch for the dream engine
- `Triggers` — cron (default every 6h), external, webhook

### Key Design Decisions

1. **Workspace-as-interface**: Both LTM and Context stores expose `FileViewable` — the dream engine gets a local directory to edit, mutations are mirrored back. This means the "AI" part is just editing files in a sandbox.

2. **Two stores, not one**: LTM (raw knowledge) is separate from Context (curated agent-facing). This is the same pattern we use (memory/ vs AGENTS.md + skills/) but formalized.

3. **Lease-based concurrency**: DreamLeaseStore prevents simultaneous dreams. One dream at a time per tenant.

4. **FanoutContextStore**: Can replicate context to multiple backends (e.g., git + S3) with rollback on failure.

5. **Git + PR hook**: Post-dream commits to a `dreamer` branch and opens/updates a rolling PR. Human review of automated evolution.

## Memory Types

Agents submit memories via MCP `submit_memory` tool:
- `observation` — something learned while working
- `failure` — what went wrong and why
- `code_snippet` — reusable patterns discovered

Custom types can be declared in config with JSON Schema validation.

## Comparison to Our Approach

| Aspect | Dreamer | Kagura/OpenClaw |
|--------|---------|-----------------|
| Memory collection | MCP tool (explicit submit) | Nudge hook (implicit, agent_end) |
| STM → LTM | LLM dream (batch, async) | Manual beliefs-candidates pipeline |
| LTM → Context | LLM dream (diff-scoped) | Manual DNA updates |
| Trigger | Cron (every 6h) | agent_end hook (every 5 sessions) |
| Multi-agent | Yes (team-wide) | No (single agent) |
| Human review | PR hook | Feishu notification |
| Concurrency | Lease-based | N/A (single agent) |

## Key Insights

1. **The "dream" metaphor is apt** — consolidation happens offline, not in-line. This matches sleep research: episodic → semantic happens during downtime. We do something similar with daily-review cron.

2. **Explicit submit > implicit capture**: Their `submit_memory` tool forces agents to be intentional about what's worth remembering. Our nudge approach is more automatic but noisier.

3. **Two-phase separation is important**: LTM Phase doesn't need to know about context format. Context Phase only sees the diff. This prevents the "rewrite everything" failure mode.

4. **PR-as-guardrail**: Human reviews the rolling PR before context changes land on main. Elegant lightweight governance.

5. **Protocol-based extensibility**: Every component is swappable via YAML config. No plugin system needed — just point at a class that satisfies the Protocol.

## Relevance to Us

- We already have the two-store pattern (memory/ + AGENTS.md/skills)
- We already have the periodic consolidation (daily-review)
- We DON'T have: formalized STM submission types, dream lease concurrency, PR-based governance for DNA changes
- **Actionable**: The "context phase only touches what changed" principle is something we could adopt — our daily-review currently re-reads everything

## Ecosystem Position

Sits in the [[self-evolving-agent-landscape]] Memory+Prompt/Skill layers. Competes with [[brain-git-memory]] (simpler, git-only) and [[stash]] (episode-based, Postgres). Differentiated by the two-phase dream + MCP interface + team-wide design.

Links: [[self-evolving-agent-landscape]], [[mechanism-vs-evolution]], [[brain-git-memory]], [[stash]], [[agent-skill-standard-convergence]]
