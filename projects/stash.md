# Stash — Persistent Memory Layer for AI Agents

**Repo**: https://github.com/alash3al/stash
**Stars**: 227 → 514 (2026-04-29, +127% in 3 days)
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

1. **5 days old, 514 stars** — growth sustained past HN bump, but still very early. Last push 04-26, no commits in 3 days.
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

## Deep Read Update (2026-04-29)

Second pass on the codebase after initial scout. 514⭐ now, doubling in 3 days — sustained growth beyond HN spike.

### Recall Strategy: Facts-First

The `Recall()` function searches consolidated **facts first** (higher quality), then backfills remaining slots with raw **episodes**. Results merged by similarity score. This is smart — it prioritizes distilled knowledge over raw observations, only falling back to episodes when facts don't cover the query.

Our approach: memex BM25 search treats all cards equally. We could benefit from a similar priority scheme — e.g., wiki cards ranked higher than daily memory entries in `memory_search`.

### Hypothesis Lifecycle

FSM with valid transitions:
```
proposed → testing → confirmed/rejected
         → rejected
testing  → proposed (rollback)
```

Each hypothesis has: `content`, `confidence`, `verification_plan`, `method`, `source_fact_ids`. Auto-confirmation during consolidation scans new facts for evidence.

Our equivalent: `beliefs-candidates.md` entries with `triggers:` and `validation:` fields. But we lack the FSM — entries are either graduated or not. The `proposed → testing → confirmed` lifecycle is more rigorous.

### Failure Tracking: Content + Reason + Lesson

The `CreateFailure()` API requires all three fields — you can't record a failure without explaining *why* it happened and *what you learned*. Linked to goals optionally.

Our equivalent: `beliefs-candidates.md` failure entries. We also capture reason + lesson but less consistently. The required fields approach is worth adopting.

### Decay: Elegant SQL-Only

```sql
UPDATE facts SET confidence = confidence * decay_factor
WHERE updated_at < now() - window
```

Facts below `expiry_threshold` get soft-deleted (`valid_until = now()`). No LLM needed — pure time-based decay. Our [[confidence-decay-design]] card was directly inspired by this.

### Consolidation Checkpoint Safety

New since last read: checkpoints only advance on success. If consolidation fails mid-pipeline, it re-processes from where it left off. This is the kind of production detail that separates toy projects from real tools.

### Embedding Model Flexibility

Also new: configurable embedding dimensions with validation on model switch. Practical concern — users switching from OpenAI to Ollama embeddings need different vector sizes.

### Growth Stall?

Last push 04-26 despite growing stars. 6 commits total since creation, all on 04-26. This could mean:
- Author busy with other things (alash3al has many repos)
- Project is "complete enough" for the concept
- Or losing momentum after the HN spike

Revisit 05-06 to check if development resumes.

### Architectural Comparison: Pipeline vs Curation

| Approach | Stash | Kagura |
|----------|-------|--------|
| Consolidation | LLM-automated pipeline | Human-curated (study loop + cascade) |
| Recall priority | Facts > Episodes (code-enforced) | All cards equal (memex BM25) |
| Failure tracking | Structured (content/reason/lesson required) | Semi-structured (beliefs-candidates) |
| Hypothesis | FSM lifecycle + auto-scan | No formal mechanism |
| Decay | SQL-based confidence * factor | File-based `last_verified` (proposed, not implemented) |
| Cost | High (LLM calls per consolidation) | Low (manual labor) |
| Quality floor | Depends on LLM quality | Depends on curator diligence |

Stash automates what we do manually. The tradeoff: automation scales but can amplify garbage. Curation is high-quality but doesn't scale. Our system is better for a single agent with a human partner; Stash is better for fleet deployment.

## Related

- [[agent-memory-landscape-202603]] — earlier survey of this space
- [[wiki-as-compiled-knowledge]] — our theoretical framework
- [[wuphf]] — alternative approach (file-based shared wiki)
- [[llm-wiki-karpathy]] — conceptual ancestor of all these systems
- [[confidence-decay-design]] — our decay design inspired by Stash
- [[reasonix]] — another project with multi-tier cache architecture
