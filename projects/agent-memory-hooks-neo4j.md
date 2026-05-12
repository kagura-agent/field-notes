---
title: "Agent Memory Hooks — Graph-Backed Dream Memory for Coding Agents"
created: 2026-05-12
source: https://github.com/tomasonjo/agent-memory-hooks-neo4j
stars: 71
star_history: "71 (05-12, day 7)"
status: noted
tags: [agent-memory, graph-database, dream-consolidation, neo4j, hooks, claude-code, codex, cursor]
last_verified: 2026-05-12
---

# Agent Memory Hooks (Neo4j)

> Two-stage memory system for Claude Code + Codex + Cursor: online capture via hooks → offline consolidation via "dream phase."

By **Tomaz Bratanic** (tomasonjo) — Graph ML author, Manning books on Graph Algorithms and Essential GraphRAG. 944 GitHub followers. Credible domain expert.

## Architecture

### Stage 1: Online Capture (Hooks)

Every session event → Neo4j graph as a linked list per session.

```
(Session {session_id, client})
  -[:FIRST_EVENT]-> (Event) -[:NEXT]-> (Event) -> ...
  -[:LATEST_EVENT]-> (last Event)
```

Events captured: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`.

Key design decisions:
- **Linked list, not flat log**: Events form a chain, enabling traversal and temporal queries
- **Multi-client**: Same Neo4j instance for Claude Code, Codex, Cursor — `client` tag differentiates
- **Truncation**: Tool responses capped at 4000 chars — practical for graph storage
- **Transcript capture**: SessionStart hook reads full transcript file (if available) into the event node

### Stage 2: Offline Consolidation (Dream Phase)

`dream.py` — standalone script that:
1. Finds sessions with events newer than their `last_dreamed_at` watermark
2. Renders events as a text log (truncated tool I/O)
3. Passes event log + ALL existing memories to Claude
4. Claude returns JSON: `{memories: [{path, content}]}` 
5. Upserts `:Memory` nodes, creates `DERIVED_FROM` provenance edges
6. Advances watermark

**Memory schema**: Markdown files stored as graph nodes.
```
(:Memory {path, content, updated_at})  — path is unique
(:Memory)-[:DERIVED_FROM]->(:Session)   — provenance
(:Session)-[:DREAMED]->(:Memory)        — reverse link
```

Paths are semantic: `profile/role.md`, `tools/bash/common-flags.md`, `project/<slug>.md`.

### Stage 3: Retrieval (Inject Memory)

`inject_memory.py` — hook that runs on every prompt:
- **SessionStart**: Loads up to 5 `profile/*` memories as context
- **UserPromptSubmit**: Fulltext search against memory content, with OR-term fallback
- Lucene fulltext index on `:Memory` (content + path)
- Minimum score threshold 0.5, max 5 results

## Key Insights

### 1. Watermark-Based Incremental Processing
`last_dreamed_at` on each Session node = high-water mark. Only events newer than this are sent to the LLM. But ALL existing memories are still passed for context (so the model can merge, not just append). This is efficient for frequent runs.

**Comparison to our light sleep**: Our light sleep runs per-session too, but uses confidence scoring (0.0-1.0) rather than a binary watermark. Their approach is simpler — process or skip, no scoring.

### 2. Graph Provenance
The `DERIVED_FROM` relationship means you can answer "which sessions created this memory?" — a query our flat file system can't do. If a memory seems wrong, you can trace its origin.

**Potential for our system**: We could add `source:` frontmatter to wiki cards (session ID or memory date), similar to what [[dream-consolidation-pattern]] (thClaws) does with `sources:` frontmatter.

### 3. Fulltext Search with Stopword Fallback
inject_memory.py uses Lucene fulltext first, then falls back to OR-terms extraction (removing common stopwords). This is a pragmatic approach — no embeddings, no vector DB, just text search. For tool/project memories, this probably works well enough.

**Comparison to our approach**: We use memex (semantic + keyword hybrid). Their approach is simpler but less capable for semantic matching.

### 4. Memory as Markdown Files in a Graph
Each `:Memory` node contains a full markdown file (with YAML frontmatter). The graph adds relationships (provenance, fulltext index) that flat files don't have. But the content format is identical to what we store in wiki/.

## Strengths

- Clean separation: capture (hooks) vs. consolidation (dream) vs. retrieval (inject)
- Provenance tracking via graph relationships
- Watermark prevents redundant processing
- Multi-client support (Claude Code + Codex + Cursor share one memory)
- Tests exist and cover the linked-list structure + memory injection

## Weaknesses

- **Neo4j dependency**: Requires running Neo4j instance — heavy for personal use
- **No memory deletion**: Model can't delete or rename memories — only upsert
- **Fulltext only**: No semantic/embedding search — misses conceptual matches
- **Single model call per session**: All events compressed into one LLM call — large sessions might hit context limits
- **No memory categories/hierarchy**: All memories are flat (just paths), no concept of importance or decay
- **Zero issues**: No community engagement at all — solo project

## Relevance to Our Direction

1. **Provenance tracking** is the key takeaway. We should consider adding `source_session:` or `derived_from:` metadata to wiki cards/memories.
2. **Dream phase pattern** confirms [[dream-consolidation-pattern]] as an emerging standard — this is the third independent implementation (thClaws, buddyme decay, this).
3. **Graph vs. flat files**: For us, the graph overhead isn't worth it (Neo4j is heavy). But the *relationships* (provenance, fulltext) could be replicated with frontmatter metadata + memex search.
4. **Multi-agent memory sharing**: Their multi-client support (one Neo4j for Claude Code + Codex + Cursor) is interesting — we could explore shared memory across agents if we ever run multiple.

## Connection to Existing Knowledge

- [[dream-consolidation-pattern]]: This is a concrete implementation
- [[claude-code-memory-architecture]]: Their hook system extends Claude Code's built-in memory
- [[git-backed-agent-memory]]: Alternative approach — git as memory backend vs. graph DB
- [[self-evolving-agent-landscape]]: Fits in the Memory (Layer 1) tier
