# cavemem — Cross-Agent Persistent Memory

> **Repo:** [JuliusBrussee/cavemem](https://github.com/JuliusBrussee/cavemem) ⭐126 (2026-04-24)
> **Language:** TypeScript (monorepo, turborepo)
> **License:** MIT
> **Part of:** Caveman ecosystem — caveman (talk less), cavemem (remember more), cavekit (build better)

## What It Does

Cross-agent persistent memory for coding assistants. Hooks fire at session boundaries, compress observations using a deterministic "caveman grammar" (~75% fewer prose tokens, code/paths preserved verbatim), and store in local SQLite. Agents query via MCP tools. No network, no cloud.

**Supports:** Claude Code, Cursor, Gemini CLI, OpenCode, Codex

## Architecture

```
session events → redact <private> → compress → SQLite + FTS5
                                                     ↑
                                         MCP queries on demand
```

### Key Components (monorepo)

| Package | Role |
|---|---|
| `packages/core` | `MemoryStore` facade — redact → compress → persist pipeline |
| `packages/compress` | Deterministic caveman grammar: remove articles/hedges/fillers, abbreviate, preserve code/paths/URLs |
| `packages/storage` | SQLite + FTS5 + vector embeddings |
| `packages/hooks` | IDE hook handlers: session-start, user-prompt-submit, post-tool-use, stop, session-end |
| `packages/embedding` | Local/Ollama/OpenAI embedding providers |
| `packages/config` | Settings resolution |
| `apps/cli` | CLI commands |
| `apps/mcp-server` | MCP server (stdio) with search/timeline/get_observations/list_sessions |
| `apps/worker` | Background daemon for embedding backfill + web viewer (:37777) |

### Design Decisions

1. **Deterministic compression, not LLM summarization.** Caveman grammar is regex-based: strip pleasantries, hedges, fillers, articles; abbreviate common words. Round-trip guaranteed (expand reverses compress). This means no LLM calls on the write path — hooks complete in <150ms.

2. **Hybrid search (BM25 + cosine).** FTS5 for keyword, local vector for semantic, blended via tunable alpha (default 0.5). Min-max normalization then weighted sum. Simple but effective.

3. **Progressive MCP retrieval.** `search` → snippets only, `get_observations` → full bodies on demand. Saves context tokens.

4. **Idempotent session creation.** `ensureSession()` is called before every observation insert because Claude Code doesn't guarantee SessionStart fires first (mid-session install, hook chain failures, session resume). Pragmatic defensive coding.

5. **Session-end rollup.** Turn summaries are concatenated into a session summary at session end. On next session start, last 3 session summaries are injected as "Prior-session context". Simple but gives the agent continuity.

6. **Privacy via tag stripping.** `<private>...</private>` tags stripped at write boundary. Path glob exclusions for directories.

## Comparison with Our Approach

| Aspect | cavemem | OpenClaw (us) |
|---|---|---|
| Memory model | Per-observation, compressed prose | Daily markdown logs + curated MEMORY.md |
| Compression | Deterministic grammar (~75% reduction) | None (raw text) |
| Search | FTS5 + vector hybrid | memex semantic search |
| Scope | Coding sessions only | Full agent lifecycle |
| Storage | SQLite (local) | Git-backed markdown files |
| Cross-agent | Yes (shared SQLite) | No (single agent) |
| Summarization | Concatenation rollup | Human-curated + dreaming |

### What We Can Learn

1. **Deterministic compression is underrated.** We could compress daily memory logs before they hit context. The caveman grammar approach (strip articles, hedges, abbreviate) is surprisingly effective and zero-cost at runtime.

2. **Progressive retrieval pattern.** Search → snippets → fetch full on demand. Our memex search returns full content always — a snippet-first API could save context tokens.

3. **Hybrid BM25 + vector search.** Our memex does semantic-only. Adding keyword search (even just grep) as a complement could improve recall for exact terms.

4. **Session boundary hooks.** The hook-based observation capture is elegant for coding tools. Not directly applicable to our always-on agent model, but the "capture → compress → index" pipeline is reusable.

## Interesting Patterns

- **Caveman grammar as a "lossy codec"**: Not LLM-generated summaries (which hallucinate), not raw logs (which waste tokens). A middle ground: deterministic, reversible, cheap. The tradeoff is it only removes syntactic fluff, not semantic redundancy.
- **Auto-spawning worker**: The embedding daemon auto-starts on first hook, self-exits when idle. <2ms hot-path check (stat pidfile + kill(0)). Good pattern for background services that shouldn't require manual management.

## Links

- Related: [[auto-memory]], [[agent-memory-landscape-202603]], [[opencode-compaction]]
- Concept: [[context-budget-constraint]] — compression directly addresses context budget
- Pattern: [[existence-encoding]] — different approach to the same "preserve signal, drop noise" problem
