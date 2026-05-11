# krusch-context-mcp

**Repo**: [kruschdev/krusch-context-mcp](https://github.com/kruschdev/krusch-context-mcp)
**Stars**: 61 (2026-05-10, 3 days old)
**License**: MIT | **Language**: JavaScript (Node.js 22+)
**Depth**: 🔬 deep-dive | **Last Updated**: 2026-05-10

## What

Unified MCP server giving IDE agents persistent episodic memory + semantic codebase search + lightweight steering nudges + external doc RAG. 18 tools exposed via MCP stdio. Local-first, all embeddings via Ollama (bge-large), no API costs for context retrieval.

## Lakebase Architecture (Key Pattern)

The most interesting architectural decision. Two-tier memory inspired by Neon's decoupled storage:

- **Compute Cache** (SQLite, per-project `.agent/memory.db`) — zero-latency reads, WAL mode
- **Object Storage** (PostgreSQL + pgvector) — durable fleet-wide persistence
- **Async sync**: Pull on project open (PG → SQLite), push on write (SQLite → PG, async)
- **Local bias**: +0.3 cosine similarity boost for project-local results — simple hierarchical routing

**Why this matters**: Decouples read latency from write durability. Agent gets fast local reads while maintaining cross-project memory fleet. Pattern is generalizable beyond this project.

Compare: Our flat-file memory (MEMORY.md + daily logs + wiki/) is single-tier. We have no local-cache / global-store split or async sync.

## Memory Types

| Type | Storage | Purpose | Our Equivalent |
|---|---|---|---|
| Episodic (5 categories) | SQLite + PG | bugs, priorities, outcomes, lessons, activity | memory/*.md (daily logs) |
| Nuggets (3 kinds) | SQLite + PG | lightweight steering facts (key-value) | beliefs-candidates.md |
| Codebase search | PG-Git | semantic over indexed repos | grep / memex search |
| External docs | PG-Git | ingested manuals for hallucination-free RAG | wiki/ (manual) |

## RAG Failure Mode Awareness

References [Sentra Technical Report](https://github.com/niashwin/sentra-rag-failure-modes) for failure taxonomy:

| Failure Mode | Countermeasure | Effectiveness |
|---|---|---|
| F1 Negation | LLM auto-tagging (hybrid retrieval) | ✅ Real |
| F2 Numeric | Same (keyword tags supplement cosine) | ✅ Real |
| F3 Role-Swap | Same | ✅ Real |
| F4 Hubness | Local bias only | ⚠️ Weak |
| F6 Ebbinghaus Forgetting | Temporal decay: `exp(-0.01 * ageDays)` | ✅ Real (~26% drop/30d) |

**Insight**: Pure cosine similarity has known failure modes. Hybrid retrieval (cosine + keyword tags) is a practical countermeasure. Most agent memory systems (including ours) use pure cosine or text match — this is a gap.

## Consolidation

L2-normalized centroid averaging for semantic dedup:
- No re-embedding needed (compute centroid of two existing vectors, normalize)
- O(n²) pairwise comparison, capped at 500 memories per project-category
- Threshold-based (default 0.15 cosine distance) with dry-run preview

## Weaknesses

1. SQLite cosine = full-table scan with in-JS computation. No vector index. Caps at ~500/category.
2. Minimal tests (1 file, 4 integration tests). No unit tests.
3. Tight coupling to `pg-git-mcp` (imports pool, embedding, git-engine directly).
4. "Zero-Trust" is marketing — it's cross-reference search (codebase + memory), not security isolation.
5. No retention policy / automated GC. Memory grows forever until manual consolidation.
6. No conflict resolution for bidirectional sync (last-write-wins implicit).

## Connections

- [[mnem]] — versioned KG approach vs. Krusch's flat episodic + nuggets approach. mnem is more sophisticated (content-addressed CIDs, GraphRAG), Krusch is more pragmatic (SQL, flat categories).
- [[retrieval-is-the-bottleneck]] — Krusch's failure-mode taxonomy confirms this. The bottleneck isn't storage, it's finding the right memory at the right time.
- [[caveman]] — Krusch stores full content; caveman compresses. Different bets on the storage/retrieval tradeoff.
- [[taco-context-compression]] — TACO compresses output, Krusch enriches input context. Complementary strategies.

## Applicable to Us

1. **Temporal decay** for wiki/memory retrieval — we have zero relevance decay right now
2. **Nuggets pattern** — vectorized beliefs-candidates would be more retrievable than flat markdown
3. **Hybrid retrieval** (cosine + keyword tags) — our memex search is pure semantic, known F1-F3 failure modes apply
4. **Lakebase pattern** — if we ever move beyond flat files, local SQLite cache + remote durable store is the architecture to follow
5. **Sentra failure mode taxonomy** — worth studying independently as a framework for evaluating any RAG system

## Applied: Hybrid Search Wrapper (2026-05-11)

Created `wiki/search.sh` — a hybrid search that combines memex (cosine similarity) with grep (keyword matching). Applied to all 5 search points in study.yaml.

**Verified failure modes:**
- F2 (numeric): `memex search "repos with more than 1000 stars"` → 0 results. Hybrid → 2 results (hermes-agent, phantom)
- F1 (negation): `memex search "projects NOT about memory"` → 1 irrelevant result. Hybrid → keyword supplements
- General: `memex search "projects that were dropped"` → 0 results. Hybrid → 5 results (orb, bux, multica, etc.)

**Outcome:** Searches that previously appeared empty now surface relevant notes. This prevents the false signal "nothing in wiki about this" which led to duplicate research.

**Next steps:**
- Monitor: does hybrid search change study decisions? (Should reduce "already known" re-discoveries)
- Consider: temporal decay weighting (Sentra's `exp(-0.01 * ageDays)`) as future enhancement
- Consider: integrating into other workflows (workloop, reflect) that also search wiki
