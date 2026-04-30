---
title: "brain — Git-backed Agent Memory"
repo: codejunkie99/brain
stars: 26
created: 2026-04-27
last_checked: 2026-04-30
status: new-project
tags: [memory, git, rust, mcp, cli]
---

# brain — Git-backed Long-term Memory for AI Coding Agents

## What It Is

A Rust CLI + MCP server that gives Claude Code, Cursor, Codex, OpenClaw, and Hermes a **shared local memory** stored as git commits in `~/.brain`. Each memory event = one JSON blob = one commit. SQLite FTS5 index for search.

**Repo:** <https://github.com/codejunkie99/brain>  
**Language:** Rust (workspace: 6 crates)  
**License:** Apache-2.0  

## Architecture

```
brain-cli (CLI)  ←→  brain-app (LocalBrain)  ←→  brain-store (BrainRepo: git2)
brain-mcp (MCP)  ↗                              ↘  brain-index (SQLite FTS5)
brain-tui (TUI)  ↗                                  brain-types (shared types)
```

### Storage Model: Git as Event Log

The core insight: **each memory event is a git commit** in `~/.brain/events/`. Not files-in-git (like our `memory/*.md`), but **commits-as-events** — the commit itself IS the record.

- Events stored as JSON blobs under `events/` tree
- One commit per `append_event` — no batching (v0.1 simplicity)
- UUID v7 event IDs (time-sortable)
- `git2` (libgit2) for all git ops — no shell `git` dependency
- Dir perms tightened to 0o700 on Unix

### Typed Event System

Strong typing via Rust enums (not freeform JSON):

| EventType | Purpose |
|---|---|
| Observe | Raw observation/note |
| Claim | Durable belief (supersession chains via `chain_id`) |
| Lesson | Learned insight |
| Pref | User preference |
| SkillEdit | Skill modification |
| Verify / Archive / Redact | Lifecycle management |
| Import / Audit | Maintenance |

### Memory Layers (à la cognitive science)

```rust
enum Layer { Working, Episodic, Semantic, Personal, Skill, Protocol }
```

Maps to a [[memory-architecture]] model where different types of memory have different durability and retrieval patterns. Compare with [[hermes-memory-skills]] 4-dimensional scoring.

### Bitemporal Queries

Two time axes:
- **Event-time** (`time_observed`): when the fact happened
- **Transaction-time** (`time_recorded`): when it was written down

This lets you ask "what did I know at time T?" — though v0.1 doesn't do full point-in-time reads (archive/redact evaluated at current state, not at T).

### Search

SQLite FTS5 with BM25 ranking. `unicode61` tokenizer + prefix indexing (2/3/4 chars). Auto-appends `*` to bare words. Power-user syntax passthrough (`"exact phrase"`, AND/OR/NOT).

### Multi-Agent Integration

**Adapter per agent** via onboarding:
- Claude Code → `mcp_servers.json` + `CLAUDE.md`
- Cursor → `.cursor/mcp.json` + `rules/brain.mdc`
- Codex → `config.toml` + `AGENTS.md`
- OpenClaw → `BRAIN.md` (CLI shelling, no MCP)
- Hermes → `AGENTS.md`

Uses `BRAIN:START` / `BRAIN:END` markers for managed prompt blocks — re-runs don't duplicate.

### Sync

Explicit: `brain remote add origin <url>` + `brain push/pull`. No auto-sync, no cloud. Pure local-first.

## Key Design Decisions

1. **Git as source of truth, SQLite as read index** — events survive index corruption. `brain doctor --deep` rebuilds from git.
2. **Idempotency keys on all writes** — retries collapse into single events. Critical for agent tool calls that may retry.
3. **Actor + Authority model** — each event records WHO wrote it (agent/human/system) and with what authority level (0-100 score). Enables trust-weighted retrieval.
4. **Classification** — events can be Private. Enables future access control.
5. **No network requirement** — works entirely offline. Git remote is opt-in.

## Comparison with Our Memory System

| Aspect | brain | Our system (OpenClaw) |
|---|---|---|
| Storage | Git commits (structured JSON) | Markdown files in git |
| Schema | Strongly typed Rust enums | Freeform markdown |
| Search | SQLite FTS5 + BM25 | memex semantic search / grep |
| Multi-agent | MCP server + CLI adapters | Single agent (OpenClaw only) |
| Event model | Typed events with layers | Daily logs + curated MEMORY.md |
| Sync | Git push/pull (explicit) | Git push (semi-automated) |
| Bitemporal | Yes (event-time + record-time) | No (file modification time only) |
| Idempotency | Built-in (keys) | None |

## Relevance to Our Direction

### Worth Borrowing
- **Idempotency keys** — our memory writes can duplicate on retry/re-run. A dedup mechanism would help.
- **Actor tagging** — when subagents write memory, we don't track WHO wrote it. Useful for trust scoring.
- **Typed event layers** (Episodic/Semantic/Skill) — our flat `memory/*.md` + `MEMORY.md` is a 2-tier approximation. The layer model is more principled.
- **Bitemporal queries** — "what did I know at time T?" is genuinely useful for debugging and reflection.

### Not Worth Adopting
- **Git-as-event-log** architecture — overkill for our volume. One commit per note means thousands of commits. Our markdown-in-git is simpler and human-readable.
- **Full MCP server** — OpenClaw's tool system is already richer than MCP tool calls. No need to add another protocol layer.
- **Rust complexity** — 6 crates for what we do with a few markdown files + grep. The engineering is solid but the problem doesn't demand it.

### Strategic Assessment
brain targets the "cross-agent memory" problem — one memory shared by Claude Code, Cursor, Codex, etc. This is a real pain point for multi-tool users. For us (single-agent OpenClaw), the cross-agent value is limited, but the architecture patterns (especially typed events + actor authority + bitemporal) are good reference designs.

**Watch or Adopt?** Watch. The project is 3 days old, 26 stars, single author. Architecture is thoughtful but unproven at scale. Revisit if it gains traction or if we decide to support cross-agent memory.

## See Also
- [[memory-architecture]] — general agent memory design patterns
- [[hermes-memory-skills]] — 4-dim scoring (Novelty/Durability/Specificity/Reduction)
- [[stash]] — competing approach (Postgres-backed, episode/fact/context model)
- [[agent-session-resume]] — cross-agent session continuity (complementary problem)
