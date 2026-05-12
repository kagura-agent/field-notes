---
title: "Beads — Distributed Graph Issue Tracker for AI Agents"
created: 2026-05-12
source: https://github.com/gastownhall/beads
stars: 23555
language: Go
license: Apache-2.0
status: active
last_verified: 2026-05-12
---

# Beads (bd)

> Distributed graph issue tracker for AI agents, powered by Dolt. By Steve Yegge (ex-Google/Amazon/Grab). 23K⭐, v1.0.4 (2026-05-09).

## What It Does

Replaces markdown plans and TODO files with a **dependency-aware graph database** backed by [Dolt](https://github.com/dolthub/dolt) (version-controlled SQL). Core primitive: issues with typed links (`relates_to`, `duplicates`, `supersedes`, `replies_to`) forming a knowledge graph.

Key workflow:
- `bd ready` — surfaces tasks with no open blockers (auto-scheduling)
- `bd prime` — injects workflow context + persistent memories into agent session start
- `bd remember "insight"` — stores persistent project memory (replaces MEMORY.md files)
- `bd compact` — AI-driven summarization of old closed issues ("memory decay")

## Architecture

```
CLI (bd) → Dolt Database (.beads/dolt/) → Dolt Remote (push/pull)
```

**Why Dolt?** Version-controlled SQL with cell-level merge. Every write auto-committed to Dolt history = complete audit trail. Native push/pull to remotes (DoltHub, S3, GCS). Offline work just works.

**Hash-based IDs** (`bd-a1b2`): Random UUID → short hash. No sequential ID collisions in multi-agent/multi-branch workflows. Progressive scaling (4→6 chars as DB grows).

**Two storage modes:**
1. **Embedded** (default) — Dolt in-process, single-writer, `.beads/embeddeddolt/`
2. **Server** — `dolt sql-server`, multi-writer capable

## Key Design Decisions

### Compaction = Semantic Memory Decay
Uses Claude Haiku to summarize old closed issues. Tier-based: Tier 1 = 7+ days closed, includes 2 levels of dependency context. Preserves audit trail while reducing context window cost. Configurable per-repo.

### Agent Integration Model
`bd setup <agent>` injects workflow instructions into agent config files (AGENTS.md for Codex/Factory, hooks for Claude Code). `bd prime` provides session-start context injection. MCP server available via `beads-mcp` PyPI package.

### Contributor vs Maintainer Mode
`bd init --contributor` routes planning to `~/.beads-planning` (separate from fork). `bd init --stealth` uses locally without repo commits. Smart role detection via SSH/HTTPS credentials.

## Relevance to Us

**Direct overlap with our architecture:**
- We use `MEMORY.md` + `memory/*.md` + `TODO.md` for task tracking and memory → Beads replaces all three with structured SQL graph
- We use `wiki/` with `[[wikilinks]]` for knowledge → Beads' graph links (`relates_to`, `supersedes`) serve similar purpose but with typed edges
- Our `bd prime` equivalent is AGENTS.md + SOUL.md session startup sequence
- Our FlowForge workflows ~ Beads' dependency-aware `bd ready` (auto-scheduling based on blockers)

**What Beads does better:**
- **Collision-free multi-agent**: Hash IDs prevent conflicts when multiple agents create tasks concurrently. Our sequential TODO items would collide.
- **Structured memory decay**: Tier-based compaction with AI summarization. We just manually clean MEMORY.md.
- **Audit trail**: Every change committed to Dolt history. We lose edit history in markdown files.
- **Dependency graph**: Typed links between issues. Our TODO is flat list.

**What we do differently (and arguably better):**
- **Simplicity**: Our markdown files are human-readable, zero tooling required. Beads needs Go binary + Dolt.
- **Portability**: Our wiki travels as plain git. Beads' Dolt DB is opaque.
- **Flexibility**: Our wiki supports freeform notes, concept cards, narrative. Beads is issue-focused.
- **Integration depth**: Our memory/DNA system is deeply integrated with agent identity. Beads is project-scoped.

**Verdict**: Not a replacement for us — our memory system serves identity continuity, not just task tracking. But Beads' specific innovations worth borrowing:
1. **Hash-based IDs** — for any multi-agent task creation scenario
2. **Tiered compaction with AI summarization** — could apply to our memory/*.md files
3. **`bd prime` pattern** — structured session-start injection (we already do this but less formally)
4. **Typed graph links** — our wikilinks are untyped; adding `supersedes:`, `contradicts:` types could improve knowledge navigation

## Issues / Weaknesses (from GitHub issues)

- `bd close` silently no-ops status update on specific rows (data integrity concern)
- `bd export` is lossy — JSONL doesn't round-trip wisps/events/comments (51GB→53MB data loss)
- Server mode ignores TLS config
- v1.0.4 was a breaking change marketed as patch (semver violation)
- `--dry-run` ignored by some subcommands

## Ecosystem Position

Beads occupies a unique niche: **structured task memory for coding agents**. Not a general agent framework, not a memory system — specifically a dependency-aware issue tracker designed for AI agent workflows.

Competitors: GitHub Issues (not agent-optimized), Linear (SaaS, not embeddable), our markdown TODO (unstructured). Most "agent memory" projects ([[agent-memory-taxonomy]]) focus on conversational or knowledge memory, not task/planning memory.

Links: [[self-evolving-agent-landscape]], [[agent-memory-taxonomy]], [[claude-code-memory-architecture]], [[git-backed-agent-memory]]
