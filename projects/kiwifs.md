---
created: 2026-05-04
updated: 2026-05-06
type: project
status: active
stars: 426
repo: kiwifs/kiwifs
language: Go
license: BSL-1.1
---

# KiwiFS — Knowledge Filesystem for Agents

> "Agents write with `cat`. Humans read in a wiki. Git versions everything."

## What It Is

Single Go binary that serves markdown files as a knowledge filesystem with:
- **Web UI** (React/BlockNote, wiki links, backlinks, graph view, themes)
- **Git versioning** (every write = atomic commit, immutable audit trail)
- **Multi-protocol access** — REST, NFS, S3, WebDAV, FUSE, MCP (21 tools + 3 resources)
- **3-tier search** — grep → SQLite FTS5/BM25 → semantic vector (via Ollama or API)
- **Dataview** — Obsidian-like computed views with hand-written Pratt parser for DQL

## Why It Matters (2026-05-04)

415⭐ in 12 days (created 04-22). This is the fastest-growing project in the "agent knowledge infrastructure" space right now. It's solving the same problem we solve with memex + wiki — but as a polished single-binary server.

## Core Design Decision: Files > Database

The central insight: **files are the only format that is simultaneously human-readable, agent-native, and tool-agnostic.** `cat file.md` works in every shell, container, sandbox. No SDK needed.

But raw files need database-like guarantees, so KiwiFS layers on top:
- **Versioning** via Git (crash recovery, blame, diff)
- **Concurrency** via ETags (optimistic locking, `If-Match` / `409 Conflict`)
- **Structured queries** via frontmatter → SQLite `file_meta` table
- **Real-time sync** via SSE broadcast on every write/delete

## Memory Model

Built-in episodic vs semantic memory distinction:
- `memory_kind` field: `episodic` / `semantic` / `consolidation` / `working`
- `merged-from` frontmatter: provenance tracking for consolidation (which episodes were incorporated)
- `derived-from` frontmatter: write-time provenance via `X-Provenance` header
- Default template includes `episodes/` directory

This directly mirrors our split: `memory/YYYY-MM-DD.md` (episodic) → `wiki/` (semantic).

## Architecture

```
internal/
├── api/          # REST endpoints
├── memory/       # episodic/semantic types, merge/consolidation
├── mcpserver/    # 21 MCP tools + 3 resources
├── search/       # grep + SQLite FTS5 + vector
├── storage/      # file I/O with atomic writes
├── versioning/   # Git integration
├── fuse/         # FUSE mount
├── nfs/          # NFS server
├── s3/           # S3-compatible API
├── webdav/       # WebDAV
├── pipeline/     # write pipeline (hooks)
├── spaces/       # multi-space support
├── links/        # wiki link resolution + backlinks
├── dataview/     # DQL Pratt parser
└── webui/        # embedded React SPA
```

Key deps: go-git, echo (HTTP), go-fuse, go-nfs, goldmark (markdown), mcp-go

## Relation to Our Stack

| Aspect | KiwiFS | Our setup (memex + wiki) |
|---|---|---|
| Storage | Markdown files | Markdown files |
| Search | FTS5 + vector | memex semantic search |
| Versioning | Built-in Git | External Git |
| UI | Web UI (React) | CLI + manual |
| Agent access | cat/MCP/REST/NFS/S3 | Direct filesystem |
| Memory model | episodic/semantic/consolidation | memory/ → wiki/ |
| Provenance | X-Provenance → frontmatter | Manual |
| License | BSL-1.1 ⚠️ | N/A (personal) |

**Lessons for us:**
1. **Provenance tracking** — their `merged-from` and `derived-from` fields are worth adopting. When we consolidate daily memory into wiki cards, we lose the trail.
2. **DQL queries over frontmatter** — we have memex search but no structured query. This would be useful for our wiki (e.g., "all projects with status=active and stars>100").
3. **Multi-protocol** is overkill for us, but the MCP server pattern is interesting — exposing wiki as MCP tools could help other agents access our knowledge.

**Why we won't switch:**
- BSL-1.1 (not OSS, commercial restrictions)
- We don't need a server — our wiki is local, single-user
- Our memex search is sufficient for current scale
- Adding a dependency contradicts our "files are enough" philosophy

## Also Scouted (2026-05-04)

**SKILL.mk** (Teaonly, 80⭐, created 05-02) — Makefile-format agent skills with DAG structure + on-demand loading. Key insight: skill instructions as dependency graph, load only the relevant recipe target → 85% token reduction in probe mode. Novel but early (PoC stage). See [[agent-skill-standard-convergence]].

**Skill ecosystem explosion** — Domain-specific skills proliferating: Swiss design (91⭐), Compose performance (295⭐), scientific plotting (36⭐), character animation (72⭐). We're in the "skill as content" phase — skills becoming the new blog posts.

**future-agi** (819⭐, created 04-20) — Open-source eval/observability platform for agents. Apache 2.0, self-hostable. Growing fast.

## Agent-Ready Infrastructure (2026-05-06, PR #38)

KiwiFS is no longer just a knowledge filesystem — it's becoming an **agent task orchestration layer**. PR #38 (merged 05-06, +1353/-58 lines, 32 files, 58 adversarial tests) adds:

### Claims System (Task Locking)
- SQLite-backed lease/claim store with expiry goroutine
- `kiwi_claim` / `kiwi_release` / `kiwi_eligible` MCP tools
- REST: `POST /claim`, `DELETE /claim`, `GET /claims`
- Conflict resolution: upsert-with-guard — claim succeeds only if expired or same holder
- Lease range: 1min–24h, configurable per claim

### Workflow State Machine
- `ValidateTransition(path, oldStatus, newStatus) error` hook in write pipeline
- Intercepts **both** `Write` and `Append` paths (and `BulkWrite`)
- `ErrTransitionDenied` → HTTP 409, `ErrValidationFailed` → HTTP 422 (clean error semantics)
- `OnTransition` callback fires after successful status change → webhook dispatch + dependency re-resolution

### Dependency Tracking (`_blocked`)
- `blocked-by` frontmatter field (array of paths)
- `_blocked` computed field via SQL post-pass: checks if any blocker has non-terminal status
- `ComputeBlockedStatus()` runs as `PostFlush` callback on async indexer → cross-row consistency
- `OnDelete` cascade: when a blocker file is deleted, dependents get re-indexed
- `kiwi_eligible` MCP tool returns `WHERE type = "task" AND status = "todo" AND _blocked = false`

### Webhooks
- HMAC-signed dispatch with standard-webhooks format
- Glob matching on paths (e.g. `tasks/**`)
- Retry with exponential backoff
- Fires on transitions, enabling external orchestrators

### Long-Polling
- `GET /changes?feed=longpoll&since=<seq>&timeout=30s`
- Enables polling-based agents without WebSocket complexity

### Design Pattern: Files as Task Board

The key insight: **markdown files with frontmatter ARE the task board**. No separate database for tasks — tasks are files, status is frontmatter, queries are DQL, concurrency is ETags + claims.

```yaml
# tasks/fix-login.md frontmatter
type: task
status: todo
priority: 1
blocked-by:
  - tasks/setup-auth.md
assignee: agent-kagura
```

This is essentially a **lightweight Linear/Jira built on markdown** — but native to agent workflows. The agent polls for eligible tasks, claims one, does the work, transitions status. No SDK, no API client, just `PUT` a file with new frontmatter.

### Relevance to Us

1. **Conceptual validation**: Our [[pulse-todo]] and [[taskflow]] solve similar problems but as standalone tools. KiwiFS proves the pattern of **task orchestration embedded in the knowledge layer** is viable.
2. **Claims as coordination primitive**: Multi-agent claim/lease is something we'd need if we ever run multiple agents on shared workspaces. Their SQLite+upsert pattern is clean and steal-worthy.
3. **`_blocked` computation**: Their SQL post-pass for dependency resolution is elegant — a computed field that auto-updates when dependencies change. This is better than manually tracking blockers.
4. **Workflow in the write pipeline**: Intercepting writes to enforce state transitions means agents can't skip steps. This is governance-by-infrastructure, not governance-by-prompt — aligns with our [[mechanism-vs-evolution]] thinking.

### Growth Signal

415⭐ → 426⭐ in 2 days. Active development: PR #37 (ML/analytics, 10 features) and PR #38 (agent orchestration) merged within 48 hours. This is the most architecturally ambitious project in the agent knowledge space right now.

Links: [[memex]], [[stash]], [[agent-memory-landscape-202603]], [[self-evolving-agent-landscape]], [[agent-skill-standard-convergence]], [[obsidian-wiki]], [[pulse-todo]], [[taskflow]], [[mechanism-vs-evolution]]
