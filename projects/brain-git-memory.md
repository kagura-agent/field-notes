# brain (codejunkie99/brain)

**Repo**: codejunkie99/brain
**Stars**: 32 (2026-05-01)
**Language**: Rust
**Created**: 2026-04-27, last push 04-28
**License**: Apache-2.0

## What It Does

Git-backed long-term memory for AI coding agents. CLI + TUI + MCP server. Notes stored as git commits in `~/.brain`, indexed in SQLite for search, available to Claude Code, Cursor, Codex, OpenClaw, Hermes via adapters.

## Architecture — Why It's Interesting

### 1. Event-Sourced, Not Document-Based

Memory is a stream of **typed events** (Note, Claim, Preference, Redact, Verify), not markdown files. Each event has:
- UUID v7 (time-sortable)
- `SubjectRef` (what entity/concept this is about)
- `Actor` (which agent or human wrote it)
- `EventPayload` (typed content)
- `Authority` (provenance: source_kind, score, attested_by)
- `Classification`, `SignatureState`
- `idempotency_key` (retries don't duplicate)
- `chain_id` / `parent_event_id` (supersession chains — Claim A → Claim B replaces A)
- Schema versioning

This is way more structured than typical "memory is a text file" approaches. Agents produce discrete facts, not documents — the event model is a better fit.

### 2. Git as Source of Truth, SQLite as Derived Index

Events stored as JSON blobs in git (`events/` subtree), one commit per append. SQLite is a **derived projection** rebuilt from git via `brain doctor --deep`.

Why this matters:
- Git gives you immutable audit trail, versioning, and sync (push/pull) for free
- SQLite gives you structured queries without being the source of truth
- If index corrupts → rebuild from git. If git corrupts → game over, but git is resilient

### 3. Bitemporal Queries

Two time axes:
- `time_observed` — when did the fact happen in reality?
- `time_recorded` — when was it recorded in brain?

Enables "what did I know at time T?" queries. Crucial for debugging stale beliefs and temporal reasoning. Not a full bitemporal implementation (no "as known at T" snapshot queries yet) but the foundation is there.

### 4. FTS5 Search (Agent-Optimized)

- 3 FTS columns: title / body / tags (weighted differently via BM25)
- `unicode61` tokenizer, no Porter stemming (would destroy recall on identifiers like `fastapi-users`)
- Prefix indexing on 2/3/4 chars — agents type fragments, not full words
- Auto-appends `*` to bare words at query time (`fast` → `fast*` → matches `fastapi`)
- Power-user syntax preserved: `"exact phrase"`, `AND/OR/NOT`, `title:foo`

### 5. Multi-Agent Adapters

Onboarding writes config files for each agent:
- Claude Code: `~/.claude/mcp_servers.json` + `CLAUDE.md`
- Cursor: `.cursor/mcp.json` + rules
- Codex: `~/.codex/config.toml` + `AGENTS.md`
- OpenClaw: `~/.openclaw/workspace/BRAIN.md`
- Hermes: `AGENTS.md`

Uses `BRAIN:START` / `BRAIN:END` markers so re-runs don't duplicate content.

### 6. Supersession Chains

Claims form chains via `chain_id`. When a fact is updated (e.g., "auth uses JWT" → "auth uses PKCE"), the new Claim supersedes the old one. `claim_current` materialized view shows only chain tips. Clean way to handle evolving knowledge.

## Rust Crate Structure

```
crates/
  brain-types/   — Event, EventDraft, SubjectRef, Actor, enums
  brain-store/   — BrainRepo (git2-based write/read)
  brain-index/   — SQLite FTS5 index + queries
  brain-mcp/     — MCP server
  brain-cli/     — CLI binary
  brain-tui/     — Terminal UI
  brain-app/     — App orchestration
```

## Comparison to OpenClaw Memory

| | OpenClaw | brain |
|---|---|---|
| Storage | Markdown files (MEMORY.md + memory/YYYY-MM-DD.md) | JSON events in git |
| Query | grep / memex search | SQLite FTS5 + structured SQL |
| Versioning | Git (manual) | Git (built-in per-event commits) |
| Multi-agent | Single agent reads/writes | Multi-agent via MCP + adapters |
| Temporal | Date-based files | Bitemporal (observed vs recorded) |
| Readability | Human-readable, editable | Machine-optimized, less readable |
| Overhead | Zero (plain files) | Rust binary + SQLite |

## Key Insights

1. **Event-sourced > document for agent memory** — agents produce facts, not documents. But document format (our approach) wins on human readability and editability.
2. **Bitemporal is right for beliefs** — "when did I learn X?" vs "when did X happen?" is exactly what beliefs-candidates needs. We could add observed/recorded timestamps to candidate entries.
3. **Supersession chains solve belief revision** — our beliefs-candidates uses manual "graduated" markers. brain's chain model automates it.
4. **Git + SQLite separation of concerns** — validates our approach of git-backed markdown + separate search index (memex). Same pattern, different granularity.

## Status Assessment

- 32⭐, 2 days of pushing then stopped. Could be a weekend project that's done, or could be abandoned.
- Architecture is overengineered for 32 stars but the design is solid
- Worth revisiting 05-07 to see if development resumes
- **Not a contribution target** (too early, unclear if maintained)

## Related

- [[agent-session-resume]] — another cross-agent memory approach (session-level vs event-level)
- [[hermes-memory-skills]] — memory hygiene (dreaming/consolidation) rather than storage
- [[skill-ecosystem]] — brain is memory infrastructure, complementary to skill distribution
