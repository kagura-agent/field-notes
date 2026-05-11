---
created: 2026-05-04
updated: 2026-05-11
type: project
status: active
stars: 419
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

## v0.5.0: Rules System + Multi-Space (2026-05-07)

Two significant features landed post-v0.5.0 release (05-06/07):

### Rules System (`.kiwi/rules.md`)

A persistent rules file that agents read to understand workspace conventions. Key design:

- **Format-agnostic storage**: rules are plain markdown in `.kiwi/rules.md`
- **Multi-format export engine**: `GET /api/kiwi/rules?format=cursor|claude|agents|openclaw`
  - Cursor → frontmatter with `alwaysApply: true` + tool list
  - Claude → `### Rules` section with tool summary
  - OpenClaw → JSON with `type: "mcp"`, tools array, rules string
- **CLI**: `kiwifs rules show`, `kiwifs rules edit` (opens `$EDITOR`), `kiwifs rules export --format X`, `kiwifs rules sync --format cursor --output .cursor/rules/kiwi.md`
- **Git-versioned**: every PUT auto-commits with actor attribution
- **256KB limit**: sensible cap prevents abuse

**Insight**: This is the "write once, deploy everywhere" pattern for agent instructions. One `.kiwi/rules.md` file syncs to Cursor rules, CLAUDE.md, AGENTS.md, and OpenClaw config. Eliminates the N-file drift problem where each harness has its own stale instructions.

**Relevance to us**: We already have this pattern (AGENTS.md is our rules file), but KiwiFS's multi-format export is interesting — if our wiki were served via MCP, we could auto-generate per-harness instructions from a single source.

### Multi-Space Architecture

`internal/spaces/` introduces isolated knowledge spaces served from one binary:

- **Space = full stack**: each space gets its own storage, versioner, searcher, pipeline (via `bootstrap.Build`)
- **Three dispatch strategies**: `X-Kiwi-Space` header (subdomain routing via reverse proxy), URL path prefix (`/api/kiwi/{space}/...`), or default (first registered)
- **CRUD API**: `POST /api/spaces` (create with auto-init `.kiwi/config.toml`), `DELETE /api/spaces/:name` (soft-delete with `.deleted-{timestamp}` rename), `GET /api/spaces` (list with metadata)
- **Per-space auth**: `FilterKeysForSpace()` restricts API keys to their declared space — multi-tenant isolation
- **Ownership semantics**: `ownStack` flag distinguishes manager-built stacks (Close on shutdown) from externally-registered stacks (lifecycle managed by serve.go)

**Design quality**: Graceful degradation — `RemoveSpace` does soft-delete (rename, not rm), `Close` logs but continues on per-space errors so one broken space doesn't leak others' handles.

**Relevance to us**: Multi-space maps to our workspace/repos split. If we ever wanted to expose different knowledge domains (personal wiki vs project docs vs public knowledge) with different access controls, this is the architecture. The per-space auth is particularly clean — one server, multiple tenants, key-scoped isolation.

### Growth Update

420⭐ (was 426 at last check — possible star fluctuation or measurement noise). Still actively developed: 9 commits in 24h, v0.5.0 release, external contributor PR merged (Mermaid rendering). Moving from "knowledge filesystem" to "agent operating environment" — rules + spaces + task orchestration positions it as a full workspace server.

### Ecosystem Position

KiwiFS is converging on "the Obsidian for agents" — a complete workspace that handles knowledge, tasks, rules, and multi-agent coordination. The rules export engine is a smart move: it positions KiwiFS as the single source of truth even when agents use different harnesses (Cursor, Claude Code, OpenClaw).

Comparison with competitors:
- [[stash]] — memory-only (episodes/facts), no task orchestration, no rules
- [[memex]] — search-only, no server, no multi-tenant
- Obsidian — human-only, no agent access layer
- KiwiFS — trying to be all three + task board + rules engine

Risk: BSL-1.1 license + feature bloat. Adding rules + spaces + claims + webhooks + Mermaid in 2 weeks signals aggressive scope expansion. Whether this holds together architecturally long-term is the question.

## Agent Self-Modification of Rules (2026-05-07, PR #41)

Small but philosophically significant change: agents can now read/write `.kiwi/rules.md` and `.kiwi/playbook.md` through standard `kiwi_write`/`kiwi_read` MCP tools.

### Design: GuardPath Allowlist

- Previously: blanket hidden-directory guard blocked ALL `.kiwi/*` writes
- Now: `userEditableKiwiFiles` allowlist for `rules.md` and `playbook.md` specifically
- Everything else in `.kiwi/` (config.toml, state/, templates/) and `.git/` remains blocked
- Traversal attack protection tested: `../.kiwi/config.toml` still blocked
- 82 additions / 3 deletions, 2 files changed — surgical fix

### Why This Matters

This completes the agent governance loop:
1. Agent reads rules → understands workspace conventions
2. Agent works within rules → knowledge/task operations
3. Agent **writes rules** → adapts conventions based on experience

Before PR#41, rules were human-only-writable — agents could read but not evolve them. Now agents can propose and apply rule changes through the same API they use for everything else. This is [[mechanism-vs-evolution]] in action: the mechanism (GuardPath) gates which files are mutable, but within that gate, evolution is unconstrained.

**Contrast with our approach**: Our AGENTS.md/SOUL.md are self-modifiable by design (DNA Self-Governance section). KiwiFS had to explicitly punch a hole in its security model to enable this. Different starting assumptions — we trusted the agent from day one; they're cautiously expanding trust.

**Open question**: No approval/review layer for agent-authored rule changes. Git history provides auditability but not pre-commit validation. In a multi-agent workspace, one agent could overwrite another's rules. The claim system (PR#38) could gate this, but it's not wired up yet.

### Mermaid Rendering (PR#39, merged 05-06)

External contributor PR adding Mermaid diagram rendering in markdown pages. Minor feature but signals community contribution — first non-maintainer code merged. Healthy sign for a 3-week-old project.

## Followup Summary (2026-05-07)

- **Stars**: 421 (plateau after initial 415→426 burst; growth decelerating)
- **Dev velocity**: Still high — 5 PRs merged in 48h, but smaller scope (fixes, rendering, allowlist). The big architectural pushes (claims, workflows, spaces) were last week.
- **Trajectory**: Transitioning from feature explosion to stabilization. Rules self-modification closes the last obvious gap in the agent autonomy story.
- **Next revisit**: 05-14 as scheduled. Watch for: multi-agent coordination patterns using claims+rules, community growth (external PRs), and whether the feature scope stabilizes or keeps expanding.

## v0.10.0: Security + Quality Pipeline (2026-05-11 followup)

Explosive development burst: v0.5.0 → v0.10.0 in 3 days (05-08 to 05-10). 9 PRs merged. Two significant architectural additions:

### Security & Publish Primitives (PR#55, +950/-38)

- **Space visibility**: `private` / `unlisted` / `public` modes via `PUT /space/visibility`. Public = all reads open; unlisted = direct file access but no tree/search; writes always require auth.
- **Scoped tokens**: `scope=read` (rejects mutations) and `scope=write` with optional path prefix restrictions. CLI: `kiwifs token create/list/revoke`.
- **Audit logging**: Append-only JSONL at `.kiwi/audit/YYYY-MM-DD.jsonl` with daily rotation. Captures every API request (method, path, actor, token hash, IP, status, duration). Query via `GET /audit?since=&limit=`.
- **Rate limiting**: Per-token rate limiting (token hash key, IP fallback). Opt-in only when `requests_per_minute > 0` — won't break dev/test.
- **Config-driven webhooks**: `[[webhook_entries]]` in config.toml auto-registers at startup (idempotent).
- **CORS hardening**: `[server.cors]` with explicit allowed_origins, backward-compatible with legacy `cors_origins`.

This transforms kiwifs from a single-user dev tool to a **multi-user publishable platform**. The visibility + scoped tokens + audit combo is production-grade access control.

### Markdown Quality Pipeline (PR#53, +2024/-30)

Two-layer quality system for agent-written content:

1. **Auto-format on write** (`FormatWrite` pipeline hook): Normalizes markdown before commit — fixes table alignment, closes unclosed fences, normalizes list markers, strips trailing whitespace. Runs silently, zero agent effort.
2. **`kiwi_lint` MCP tool** + `POST /api/kiwi/lint`: 10 lint rules with structured output (line numbers, severity). Error-severity issues reject writes with HTTP 422.

Lint rules: frontmatter-yaml-invalid, frontmatter-missing-required, frontmatter-date-invalid, table-column-mismatch, table-no-separator, fence-unclosed, fence-mermaid-invalid, heading-duplicate-slug, heading-skip-level, link-image-broken.

Pipeline: Format runs before validate. Both configurable via `[lint]` in config.toml.

**Tested extensively**: CJK/emoji in tables, nested fences, escaped pipes, BOM, null bytes, 10K-char lines, 200-row tables, adversarial/fuzz inputs. Also validated against React, Kubernetes, Rust, VS Code READMEs + CommonMark spec (206KB) + GFM spec (216KB).

### Other v0.7-0.10 additions

- **Graph search tools** (PR#47): `peek`, `section`, `graph_walk`, `ingest` MCP tools for knowledge graph navigation
- **Comprehensive markdown rendering v2** (PR#50): Major UI upgrade
- **Batch UI fixes** (PR#51): Theme editor, search, wiki links, graph, nav

### Ecosystem Position Update

🟢 THRIVING (6/6 community health): 8 unique issue authors, 29 external PRs in 30 days, 4 merged PR authors, 27/30 PRs merged.

kiwifs is executing the "everything server" strategy at extraordinary velocity. Each release adds a new infrastructure layer:
- v0.5: Rules + multi-space → governance
- v0.7: Graph search → navigation
- v0.8-0.9: Rendering + UI polish → UX
- v0.10: Security + quality → multi-user production

**Risk**: Scope explosion continues. 6 major capability layers in 3 weeks. BSL-1.1 license unchanged. Whether this architectural breadth is sustainable with a small team is the key question.

**Relevance to us**:
1. **Lint-on-write pattern** — Our wiki-lint.py runs as post-hoc audit. kiwifs's approach (reject invalid writes at pipeline level) is more ergonomic. Consider: should memex or our commit hooks reject broken markdown before it enters the wiki?
2. **Scoped tokens** — If we ever expose wiki via MCP server, their read/write scope + path prefix model is the right granularity.
3. **Audit logging** — Append-only JSONL with daily rotation is simple and effective. We have session logs but no wiki-level audit trail.

Links: [[memex]], [[stash]], [[agent-memory-landscape-202603]], [[self-evolving-agent-landscape]], [[agent-skill-standard-convergence]], [[obsidian-wiki]], [[pulse-todo]], [[taskflow]], [[mechanism-vs-evolution]], [[agent-commerce]], [[context-is-software]], [[wiki-lint]]
