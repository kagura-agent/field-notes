# brain (codejunkie99/brain) — Deep Read Notes

> codejunkie99/brain | 37★ (2026-05-03) | Rust | Apache 2.0 | v0.1.0
> Spin-off from [[agentic-stack]]. Same creator (@codejunkie99/Av1dlive).

## What It Is

Git-backed long-term memory for AI coding agents, rewritten from scratch in Rust. Each note = one git commit = one JSON blob in `events/`. MCP server + CLI + TUI. Adapters for Claude Code, Cursor, Codex, OpenClaw, Hermes.

**The thesis**: your agent's memory should be (1) durable (git), (2) portable across harnesses, (3) searchable (FTS5 + BM25), (4) secure (secret scanning at write time, not after).

## Why This Matters

This is [[agentic-stack]]'s memory layer extracted and rebuilt as a proper systems-level tool. agentic-stack was Python + markdown files + Jaccard clustering. brain is Rust + git + SQLite FTS5 + typed events. The leap from "scripted file management" to "structured event store" is significant.

**Timing signal**: The creator had 1,800★ on agentic-stack and chose to split memory into its own project. This suggests memory-as-infrastructure is becoming its own product category, not just a feature of agent frameworks.

## Architecture

### Crate Structure (7 crates, ~6k LOC Rust)
```
brain-types    — Event, EventDraft, EventPayload (10 variants), SubjectRef, Actor
brain-store    — BrainRepo: git-backed event log via libgit2
brain-index    — SQLite FTS5 index, BM25 ranking, materialized projections
brain-app      — LocalBrain: orchestration, two-phase write (git first, index best-effort)
brain-mcp      — rmcp stdio server (5 tools: ping/note/log/ask/doctor)
brain-tui      — ratatui dashboard
brain-cli      — CLI binary
```

### Event Model — 10 Typed Variants

```
Observe   — raw observations (the "note" command)
Claim     — typed structured claims with supersession chains
Lesson    — semantic-layer lessons (added/modified/retired/promoted/decayed)
Pref      — user preferences (category/key/value with previous_value audit trail)
SkillEdit — skill file changes with edit_kind tracking
Verify    — attestations on entities (confirmed/refuted/uncertain)
Archive   — soft-delete with restore
Redact    — content removal with span tracking
Import    — bulk import from external sources (agentic-stack, Notion, Obsidian, Claude Code)
Audit     — operational records (manual edit, schema migration, dream cycle, daemon lifecycle)
```

This is far more structured than agentic-stack's JSONL or our markdown files. Every event has: UUIDv7 ID, idempotency key, actor (agent/human/system), layer (episodic/semantic/personal), authority (source + score), classification (private/internal/public), time_observed vs time_recorded.

### Write Path — Security-First

```
EventDraft → shallow_validate → serialize JSON → secret scan (18 patterns + NFKC + zero-width strip)
  → size cap (1MB) → detached-HEAD check → TOCTOU brain-tree revalidation
    → git blob + tree + commit → index catch-up (best effort)
```

**Key design decision**: scan the FULLY SERIALIZED JSON, not individual fields. This covers every string field on every payload variant (present and future) automatically. Our wiki-lint scans files; brain scans events at write time.

### Multi-Writer Safety

- Directory-based append lock (`brain-append.lock.d`) for cross-process serialization
- libgit2 HEAD CAS retry loop for concurrent writes (Locked/Modified error codes)
- Exponential backoff with 2s deadline

### Forgery Defenses (impressive)

Three-layer commit integrity checking:
1. **Trailer-block parsing**: `event_id:` only parsed from the git trailer block (after last blank line), preventing trailer injection via commit subject
2. **Blob/trailer cross-check**: blob's internal `event_id` must match the trailer's claimed ID
3. **Filename-in-parent skip**: if `events/<id>.json` existed in any parent tree, the commit didn't introduce it (catches both same-blob reuse and blob-content-swap attacks)

### FTS5 Index

- Three-column FTS (`title`, `body`, `tags`) with different BM25 weights (10x/5x/1x)
- `unicode61 remove_diacritics 2` tokenizer with prefix indexing (2/3/4 chars)
- Materialized projections: `pref_current` and `claim_current` tables for latest-value lookups
- Redact rolls back projections to most recent non-redacted predecessor

### MCP Server

5 tools: `ping`, `note`, `log`, `ask`, `doctor`. Tool descriptions are prescriptive — they tell the agent WHEN to call (not just what the tool does). Example: `ask` says "CALL THIS PROACTIVELY at the start of non-trivial tasks."

OpenClaw adapter doesn't use MCP (shell-out to `brain` CLI instead) because OpenClaw doesn't speak MCP natively. Other harnesses (Claude Code, Cursor, Codex) use the MCP server.

## Comparison: brain vs Our Memory System

| Dimension | brain | Kagura (wiki + memory/ + MEMORY.md) |
|---|---|---|
| **Storage** | Git commits (one per event) | Markdown files (daily logs + wiki notes) |
| **Schema** | 10 typed event variants | Unstructured markdown |
| **Search** | FTS5 + BM25 (ranked) | memex (FTS5 + semantic) |
| **Secret protection** | Write-time scanning (18 patterns) | wiki-lint (25 patterns, batch scan) |
| **Idempotency** | Built-in (key per event) | None |
| **Redaction** | First-class event type with rollback | Manual file editing |
| **Integrity** | 3-layer forgery defense | git history (no extra checks) |
| **Cross-harness** | 5 adapters (MCP + CLI) | OpenClaw only |
| **Knowledge graph** | None | memex wikilinks + backlinks ✅ |
| **Semantic search** | None (pure lexical) | memex embedding search ✅ |
| **Dream cycle** | Not in v0.1 (was in agentic-stack) | nudge gradient (LLM-based) |

**Our advantages**: semantic search (embedding-based), knowledge graph (wikilinks + backlinks), richer interconnection between concepts. brain has no equivalent of `[[double-bracket]]` linking.

**Their advantages**: typed events, write-time security, idempotency, formal redaction with rollback, multi-writer safety, cross-harness portability.

## Key Insights

### 1. Memory as Infrastructure, Not Feature
brain treats memory as a systems problem: typed events, idempotency, integrity checks, multi-writer safety. Our memory is "files + convention." This is the git-vs-Dropbox split for agent memory. Both work, but one has stronger guarantees.

### 2. Write-Time Secret Scanning Is Better Than Batch Scanning
We run wiki-lint as a batch check. brain rejects secrets at write time — they never enter the git history. The normalized scan (NFKC + zero-width strip) catches Unicode evasion that simple regex misses. Our wiki-lint could adopt the same approach.

### 3. Prescriptive Tool Descriptions Are Underrated
brain's MCP `ask` tool description says "CALL THIS PROACTIVELY at the start of non-trivial tasks" with specific scenarios. This is more effective than "Search the database" — it drives agent behavior. Our skill descriptions could be more prescriptive.

### 4. The Import Payload Is Strategic
`ImportSource` has variants for AgentStackFolder, NotionExport, ObsidianVault, ClaudeCodeProject, OpaqueArchive. This positions brain as a migration target — "bring your existing memory here." We don't have import tooling.

### 5. Dream Cycle Was Left Behind (Intentionally?)
agentic-stack's dream cycle (Jaccard clustering → pattern extraction → review queue) is not in brain v0.1. Either it's coming later, or the creator decided typed events + FTS5 search is enough without automated pattern extraction. Worth watching.

## In the Agent Ecosystem

- **Layer**: Agent infrastructure (memory runtime)
- **Relation to [[agentic-stack]]**: extraction/rewrite of the memory layer, replacing Python JSONL with Rust git+SQLite
- **Competitors**: [[gbrain]] (PostgreSQL-based), [[reflexio]] (cloud service), our wiki/memex (file-based)
- **Signal**: memory is becoming its own product category. The split from agentic-stack mirrors how databases split from application frameworks

## Borrowable Ideas

1. **Write-time secret scanning**: integrate into our memory write path (not just batch wiki-lint)
2. **Prescriptive skill/tool descriptions**: tell agents WHEN to use tools, not just WHAT they do
3. **Typed events with idempotency**: if we ever formalize our memory model beyond markdown
4. **Import tooling**: a `brain import --obsidian ~/.openclaw/workspace/wiki` equivalent for our system

## Links

[[agentic-stack]], [[agent-memory-taxonomy]], [[brain-git-memory]], [[self-evolving-agent-landscape]], [[skill-ecosystem]]

*Deep read: 2026-05-03. Source: GitHub clone + code reading of all 7 crates.*
