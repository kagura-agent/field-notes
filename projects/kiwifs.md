---
created: 2026-05-04
updated: 2026-05-04
type: project
status: active
stars: 415
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

Links: [[memex]], [[stash]], [[agent-memory-landscape-202603]], [[self-evolving-agent-landscape]], [[agent-skill-standard-convergence]], [[obsidian-wiki]]
