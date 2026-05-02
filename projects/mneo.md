---
title: mneo — Git Refs as Memory Scopes
created: 2026-05-02
updated: 2026-05-02
status: new
stars: 1
url: https://github.com/HugoLopes45/mneo
---

# mneo

**Persistent memory for AI agents using git refs.** MCP server + Claude Code skill. No vector database, no embeddings, no daemon — branches are scopes, push/fetch is sync.

- **Author**: HugoLopes45
- **Language**: TypeScript
- **Stars**: 1 (extremely early)

## Novel Insight

Uses **git refs (branches)** as the namespace/scope mechanism for agent memory:
- Each memory scope = a git branch
- Sync between agents = git push/fetch
- No server, no DB, no embeddings
- Version history = git log
- Collaboration = standard git workflows

## Why This Matters

This is the most minimal possible memory infrastructure:
- **Zero dependencies** beyond git (already present in any dev environment)
- **Naturally distributed** (push to remote = share with team)
- **Built-in versioning** (every memory mutation is a commit)
- **Human-inspectable** (just read the branch)

## Comparison to Other Approaches

| Approach | Infrastructure | Sync | Human-readable |
|----------|---------------|------|----------------|
| [[stash]] | Postgres + pgvector | ❌ local only | ❌ SQL tables |
| OpenClaw/memex | Markdown + BM25 | ✅ git push | ✅ files |
| mneo | Git refs only | ✅ git push/fetch | ✅ files on branch |
| [[auto-memory]] | SQLite | ❌ local only | ❌ DB |

mneo is essentially **our approach (markdown + git) taken to its logical extreme** — even the namespace/scope mechanism IS git, not just the storage.

## Limitations (Why 1⭐)

- No semantic search (BM25 or vector)
- No consolidation pipeline
- Branch proliferation risk at scale
- Still very early/proof-of-concept

## Relevance

Validates our bet on git + files as the memory substrate. The next step would be combining mneo's git-native namespacing with memex's BM25 search.

## Related

- [[stash]] — Postgres-based alternative
- [[brain-git-memory]] — similar git-backed concept
- [[wiki-as-compiled-knowledge]] — our theoretical framework
