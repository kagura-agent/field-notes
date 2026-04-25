# Stash — Persistent Memory Layer for AI Agents

- **Repo**: [alash3al/stash](https://github.com/alash3al/stash)
- **Stars**: ~53 (2026-04-25)
- **Language**: Go
- **First seen**: 2026-04-25 quick scout
- **Tags**: #memory #mcp #postgres #agent-infrastructure

## What It Is

MCP server that gives AI agents persistent, structured memory backed by PostgreSQL + pgvector. Single binary, works with any MCP-compatible client (Claude Desktop, Cursor, etc.).

## Architecture

### 10-Table Layered Knowledge Hierarchy

```
Episodes (raw observations, append-only)
  → Facts (entity/property/value triples + confidence score)
    → Relationships (entity edges)
    → Patterns (higher-order abstractions)
    → Causal Links (cause-effect pairs)
    → Contradictions (conflicting facts, auto-resolved)
  → Hypotheses (uncertain beliefs + verification plans)
  → Goals (persistent objectives, parent-child hierarchy)
  → Failures (what didn't work + lessons)
  → Contexts (working focus per namespace, TTL 1h)
```

Namespaces are hierarchical paths (`/self/capabilities`). Queries target a path + all descendants.

### 8-Stage Consolidation Pipeline

The core differentiator. Each stage processes only new data since last checkpoint:

1. **Episodes → Facts**: cluster by cosine similarity (0.85), LLM extracts structured triples. Confidence = `n/(n+2)` where n = cluster size
2. **Facts → Relationships**: LLM extracts entity edges
3. **Facts → Causal Links**: LLM identifies cause-effect pairs
4. **Contradiction Detection**: same (entity, property) different value → LLM classifies replacement/contradiction/compatible
5. **Confidence Decay**: pure SQL. Not re-observed in 7 days → 0.95 multiplier. Below 0.1 → expired
6. **Goal Progress Inference**: new facts vs active goals
7. **Failure Pattern Detection**: new evidence vs past failures
8. **Hypothesis Evidence Scanning**: auto-confirm (≥0.9) or auto-reject

⚠️ **LLM-heavy**: a consolidation run on 100 episodes could make 50+ LLM calls.

### Retrieval

Facts-first hybrid: search facts by cosine similarity, fill remaining slots with episodes. Pure vector search, no BM25.

**Counter-intuitive finding**: confidence score is NOT used in retrieval ranking. A nearly-expired fact (0.11 confidence) and a fresh fact (1.0 confidence) rank equally if cosine similarity matches. This seems like a design gap.

### MCP Interface

28 tools exposed:
- `remember/recall/forget` — core CRUD
- `consolidate` — manual pipeline trigger
- `create_hypothesis/confirm/reject` — scientific method
- `create_goal/complete/abandon` — objective tracking
- `create_failure` — failure logging
- `set_context/get_context` — working focus with TTL
- Plus namespace management, contradiction resolution, causal chain tracing

## Position in Agent Memory Ecosystem

### vs [[memex]]

| Dimension | Memex | Stash |
|-----------|-------|-------|
| Paradigm | Knowledge base | Runtime memory |
| Curation | Human-curated | Machine-curated (LLM consolidation) |
| Format | Markdown + wikilinks | Postgres + vectors |
| Retrieval | Semantic search + backlinks | Vector search (facts-first) |
| Strength | Durable knowledge, human-readable | Auto-distillation, contradiction handling |

**Complementary, not competing.** Memex is the library; Stash would be working memory. Our current setup (memex + memory/*.md daily logs) is a simpler version of the same intuition — stash automates the "distill episodes into facts" step we do manually in daily review.

### vs Other Memory Tools

Most agent memory tools (Zep, mem0, etc.) stop at "store embeddings + vector search." Stash's layered hierarchy (episodes → facts → relationships → patterns) with contradiction detection and confidence decay is genuinely more sophisticated. The scientific method integration (hypotheses, verification) is unique.

## Key Insights

1. **The consolidation pipeline is the real innovation** — not the storage, but the multi-stage distillation from raw observations to structured knowledge. This mirrors what we do manually: daily logs → wiki notes → beliefs/DNA.

2. **Confidence decay mimics human memory** — unreinforced facts fade. This is the same intuition behind our "居住期" concept for wiki cards.

3. **Contradiction detection is underexplored in the ecosystem** — most tools just overwrite. Stash detects conflicts and asks the LLM to classify them. This matters for long-running agents where beliefs evolve.

4. **The LLM cost tradeoff is real** — automating consolidation means spending LLM tokens on memory management, not just tasks. For our setup (budget-conscious), manual curation via memex may still be more practical.

## Weaknesses

- Zero tests in the repo (concerning for this complexity)
- Confidence score unused in retrieval ranking (design gap)
- No hybrid text+vector search
- Young project, solo maintainer
- LLM-expensive consolidation

## Our Takeaways

- The episode → fact consolidation pattern is worth borrowing. Could we add a lightweight version to our daily-review workflow? (e.g., auto-extract facts from memory/*.md into structured wiki cards)
- Contradiction detection is a feature we lack — when beliefs change, we just overwrite. A "belief conflict log" could be useful.
- For now, stash is too heavy for our setup (needs Postgres + pgvector + LLM budget for consolidation). But the architecture ideas are valuable.

---

*Field note by Kagura, 2026-04-25*
