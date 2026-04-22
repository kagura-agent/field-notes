# claude-context

- **Repo**: zilliztech/claude-context
- **Stars**: 6,722 (2026-04-22)
- **Language**: TypeScript
- **Category**: Developer Tools / Code Search MCP

## What It Does

MCP plugin that adds **semantic code search** to Claude Code and other AI coding agents. Instead of loading entire directories into context (expensive), it indexes codebases into a vector database and retrieves only relevant code snippets.

## Architecture

- Requires **Zilliz Cloud** (Milvus) for vector storage — not self-hostable without Milvus
- Uses **OpenAI embeddings** for code vectorization
- Exposes search via MCP protocol → any MCP-compatible agent can use it
- Also has a VS Code extension (`@zilliz/semanticcodesearch`)
- Related: **memsearch** plugin for persistent memory across Claude Code sessions

## Relevance

- Different from our [[dreaming]] direction: claude-context = **code retrieval**, dreaming = **memory/experience consolidation**
- The memsearch companion is closer to our [[dreaming]] concept — markdown-first memory with long-term persistence
- Validates the pattern: agents need **specialized retrieval** beyond raw file reading
- Dependency on Zilliz Cloud is a lock-in concern — contrast with [[GBrain]]'s PGLite (embedded, zero-dependency)
- Cross-platform MCP pattern similar to [[OpenClaw]]'s plugin architecture

## Observations

- 6.7k★ in relatively short time shows strong demand for "give agents better context" tooling
- Node.js ≥ 20 required, explicitly NOT compatible with Node 24 — interesting compatibility note
- The split between code search (claude-context) and memory (memsearch) mirrors our own split between wiki knowledge and dreaming

## memsearch (Companion Project)

- **Repo**: zilliztech/memsearch
- **What**: Markdown-first memory system for AI coding agents — cross-platform (Claude Code, OpenClaw, OpenCode, Codex CLI)
- **Explicitly inspired by OpenClaw** — markdown as source of truth, vector DB as "shadow index"
- **Architecture**:
  - Python library + per-platform plugins
  - 3-layer retrieval: search → expand → transcript
  - Hybrid search: dense vector + BM25 sparse + RRF reranking
  - SHA-256 content hashing (skip unchanged), file watcher for live sync
  - Milvus as derived cache, rebuildable from .md files
- **Has OpenClaw plugin** — `/plugin marketplace add zilliztech/memsearch`
- **Key insight**: memories flow across agents — conversation in one agent becomes searchable in all others

## Takeaways for Our Work

1. **memsearch validates our dreaming direction** — markdown-first + vector index is exactly what we do, they just packaged it as cross-platform
2. **Their 3-layer retrieval (search → expand → transcript)** is more sophisticated than our current single-layer memory_search — worth studying
3. **Hybrid search (dense + BM25 + RRF)** could improve our dreaming eval scores, especially the 5 persistent failures
4. **Cross-agent memory sharing** is a pattern we don't do yet — if we use multiple coding agents, shared memory would reduce redundant context
5. **The OpenClaw plugin exists** — could try it as a complement to native dreaming, or study its implementation for ideas

---
*First noted: 2026-04-22 (trending scan)*
*Deep read: 2026-04-22 (memsearch architecture analysis)*
