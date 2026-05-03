---
title: Git-Backed Agent Memory
created: 2026-05-03
updated: 2026-05-03
---

# Git-Backed Agent Memory

Using git as the storage backend for agent memory — each memory event becomes a commit, history provides audit trail, and standard git operations (push/pull/clone) enable memory portability.

## Key Implementations

### [[agentic-stack]] (Python, 2026-03)
- `.agent/memory/` directory with 4 layers (working/episodic/semantic/personal)
- JSONL files for episodic entries
- Jaccard clustering for dream cycle pattern extraction
- CLI tools: learn.py / recall.py / show.py

### brain (Rust, 2026-04, spin-off from agentic-stack)
- One JSON blob per event, one commit per event in `events/` subtree
- 10 typed event variants (Observe/Claim/Lesson/Pref/SkillEdit/Verify/Archive/Redact/Import/Audit)
- SQLite FTS5 derived index with BM25 ranking
- Write-time secret scanning (18 patterns + NFKC normalization)
- Three-layer commit integrity checking (trailer parsing, blob cross-check, filename-in-parent skip)
- MCP server for Claude Code/Cursor/Codex; CLI shell-out for OpenClaw/Hermes
- See wiki/projects/brain-rust.md for full deep-read

## Why Git?

1. **Durability**: every write is a commit — data survives process crashes
2. **Audit trail**: full history of what was learned, when, by which agent
3. **Portability**: `git push`/`git pull` moves memory between machines
4. **Integrity**: content-addressable storage makes tampering detectable
5. **Familiarity**: developers already have git tooling and workflows

## Tradeoffs vs File-Based Memory

| Dimension | Git-backed events | File-based (our wiki/memory/) |
|---|---|---|
| Atomicity | One commit = one event, atomic | File write, no transaction |
| Searchability | FTS5 derived index (rebuild from git) | memex FTS5 + embeddings |
| Knowledge graph | None (flat events) | Wikilinks + backlinks ✅ |
| Semantic search | None (lexical only) | Embedding-based ✅ |
| Write overhead | git commit per note (~5ms) | File write (~1ms) |
| History | Full git log | git log on files |
| Multi-writer | Append lock + CAS retry | Single writer (typical) |

## Pattern: Memory-as-Infrastructure

The emergence of standalone memory projects (brain, [[gbrain]], [[reflexio]]) signals that agent memory is becoming its own infrastructure layer, not just a feature of agent frameworks. The agentic-stack → brain split is the clearest evidence: memory is important enough to be its own product.

See also: [[agent-memory-taxonomy]], [[claude-code-memory-architecture]], [[self-evolving-agent-landscape]]
