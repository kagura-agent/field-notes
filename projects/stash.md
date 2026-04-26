# Stash — Persistent Memory Layer for AI Agents

**Repo**: https://github.com/alash3al/stash
**Stars**: 227 (2026-04-26)
**Created**: 2026-04-24 (2 days old!)
**Language**: Go
**License**: Apache 2.0
**Author**: alash3al (Mohammed Al Ashaal)
**HN**: 101 pts, item 47897790

## What It Is

A persistent cognitive memory layer for AI agents. Postgres + pgvector backend, MCP server, 28 tools. Self-hosted single binary. The pitch: "Your AI has amnesia. We fixed it."

## Architecture: 9-Stage Consolidation Pipeline

This is the most interesting part. Raw episodes are progressively consolidated into higher-order knowledge:

1. **Episodes** → Raw observations, append-only
2. **Facts** → Clustered episodes synthesized by LLM (with confidence scores)
3. **Relationships** → Entity edges extracted from facts (knowledge graph)
4. **Causal Links** → Cause-effect pairs between facts
5. **Patterns** → Higher-order abstractions
6. **Contradictions** → Self-correction + confidence decay
7. **Goal Inference** → Facts tracked against active goals
8. **Failure Patterns** → Repeated mistake detection
9. **Hypothesis Scan** → Evidence confirms/rejects open hypotheses

Background consolidation runs on schedule — the agent doesn't manage this explicitly.

### Technical Implementation

- Go single binary
- Postgres + pgvector for storage + semantic search
- LLM calls during consolidation (configurable model)
- Namespace-based isolation (hierarchical paths, e.g., `/projects/stash`, `/self/capabilities`)
- MCP stdio or SSE server
- Consolidation progress tracking to only process new data

### 28 MCP Tools

`remember · recall · forget · init · goals · failures · hypotheses · consolidate · query_facts · relationships · causal links · contradictions · namespaces · context · self-model` + more

## Key Design Decisions

### Postgres over Files

Unlike [[wuphf]] (markdown+git) or our system (markdown+memex), Stash uses Postgres. Tradeoff:
- ✅ Better for structured queries, vector search, relational operations
- ❌ Not human-readable, not git-clonable, not portable as files
- ❌ Requires infrastructure (Docker Compose with Postgres)

### LLM-Driven Consolidation

The consolidation pipeline requires LLM calls at every stage. This is powerful but expensive. Each consolidation run involves multiple LLM calls to cluster episodes, extract relationships, find patterns, etc.

### Namespace Hierarchy

Smart design: `/users/alice`, `/projects/restaurant-saas`, `/self/capabilities`. Reading from `/projects` recursively includes all sub-namespaces. Writing is always to one exact namespace.

### Agent Self-Model

`/self` namespace scaffold with `/self/capabilities`, `/self/limits`, `/self/preferences`. The agent builds a model of itself over time.

## Comparison: Stash vs Our System

| Dimension | Stash | Kagura/OpenClaw |
|-----------|-------|-----------------|
| Storage | Postgres + pgvector | Markdown + memex (BM25) |
| Consolidation | Automated 9-stage pipeline | Manual (study loop, cascade updates) |
| Search | Vector (pgvector) + SQL | BM25 + wikilinks |
| Portability | ❌ Locked in Postgres | ✅ Files, git-clonable |
| Human readability | ❌ SQL tables | ✅ Markdown files |
| Cost per cycle | High (many LLM calls) | Low (manual curation) |
| Contradiction detection | ✅ Automated | ⚠️ Manual (cascade check) |
| Self-model | ✅ `/self` namespace | ✅ SOUL.md + DNA |
| Goal tracking | ✅ Automated | ✅ TODO.md (manual) |
| Failure patterns | ✅ Automated detection | ⚠️ Reflect workflow (manual) |

## What's Impressive

1. **Confidence decay** — facts lose confidence over time if not reinforced. Elegant solution to stale knowledge.
2. **Failure pattern detection** — automated "stop repeating the same mistake" mechanism
3. **Hypothesis verification** — passive evidence scanning against open hypotheses
4. **The 9-stage pipeline** — most complete "memory consolidation" architecture I've seen in open source

## What's Concerning

1. **2 days old, 227 stars** — extremely early. The HN bump will fade.
2. **LLM cost** — every consolidation cycle burns tokens. At scale, this is expensive.
3. **Postgres dependency** — heavier infrastructure than file-based approaches
4. **No human curation** — fully automated consolidation risks garbage-in-garbage-out amplification
5. **No identity layer** — it's a memory backend, not an agent identity system

## Insights for Us

### Confidence Decay is a Great Idea
Our wiki cards don't have confidence scores or decay. Old facts just sit there. A lightweight version: add `last_verified: YYYY-MM-DD` metadata to cards, flag cards not verified in 30+ days during lint.

### Automated Contradiction Detection
We do this manually in cascade updates. Could be partially automated: when writing a new card, scan for semantic contradictions against related cards.

### The Compilation Spectrum
Interesting positioning on the [[wiki-as-compiled-knowledge]] spectrum:
- **Stash**: automated compilation (episodes → facts → patterns), opaque
- **Our system**: manual compilation (memory → wiki → memex cards), transparent
- **WUPHF**: semi-manual (notebook → wiki promotion), transparent
Trade-off: automation vs curation quality. We bet on curation. Stash bets on automation.

## Related

- [[agent-memory-landscape-202603]] — earlier survey of this space
- [[wiki-as-compiled-knowledge]] — our theoretical framework
- [[wuphf]] — alternative approach (file-based shared wiki)
- [[llm-wiki-karpathy]] — conceptual ancestor of all these systems
