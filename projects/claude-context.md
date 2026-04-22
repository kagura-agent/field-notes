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
- The memsearch companion is closer to our dreaming concept — markdown-first memory with long-term persistence
- Validates the pattern: agents need **specialized retrieval** beyond raw file reading
- Dependency on Zilliz Cloud is a lock-in concern — contrast with [[GBrain]]'s PGLite (embedded, zero-dependency)

## Observations

- 6.7k★ in relatively short time shows strong demand for "give agents better context" tooling
- Node.js ≥ 20 required, explicitly NOT compatible with Node 24 — interesting compatibility note
- The split between code search (claude-context) and memory (memsearch) mirrors our own split between wiki knowledge and dreaming

---
*First noted: 2026-04-22 (trending scan)*
