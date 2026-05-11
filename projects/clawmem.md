# ClawMem

- **Repo**: [yoloshii/ClawMem](https://github.com/yoloshii/ClawMem)
- **Stars**: 158 (2026-05-11)
- **Language**: TypeScript (Bun)
- **License**: MIT
- **Status**: Active (v0.9.0, pushed 2026-05-08)

## What It Is

On-device memory layer for AI coding agents. Integrates with Claude Code (hooks), OpenClaw (plugin), Hermes (MemoryProvider), and any MCP client. Single SQLite vault shared across all agents — a decision captured in Claude Code shows up immediately in OpenClaw.

## Why It Matters

This is the most engineering-mature agent memory system I've seen. Unlike research prototypes that demo a concept, ClawMem ships production-grade safety: cross-entity merge guards, contradiction detection, anti-contamination for derived insights, worker lease exclusivity, and proper failure models with named counters.

## Architecture

### Storage: SQLite WAL
- Single vault at `~/.cache/clawmem/index.sqlite`
- WAL mode + busy_timeout=5000ms for concurrent reads
- Collections map to directories of markdown files

### Retrieval Pipeline (5 stages)
1. **BM25 Probe** — fast path if top hit ≥0.85 with gap ≥0.15
2. **Query Expansion** — LLM generates lex/vec/hyde variants
3. **Parallel Search** — BM25 + Vector on original + expanded queries
4. **RRF Fusion** (k=60) — original gets 2× weight, expanded 1×
5. **Cross-Encoder Reranking** — position-aware blending (α=0.75 top 3, 0.60 mid, 0.40 tail)

Research fusion: QMD (multi-signal retrieval), SAME (composite scoring with half-lives), MAGMA (intent classification + graph traversal), A-MEM (self-evolving notes), [[engram]] (dedup windows + frequency scoring).

### Composite Scoring
```
score = (search×0.50 + recency×0.25 + confidence×0.25) × quality × co-activation
```
- **Content-type half-lives**: decisions/hubs never decay; handoffs decay at 30 days; notes at 60 days
- **Quality multiplier** (0.7–1.3): rewards structure, headings, lists, decision keywords, frontmatter
- **Co-activation boost** (up to 15%): docs frequently surfaced together get boosted
- **Recency intent detection**: shifts weights to 70% recency when queries contain "latest", "recent"

### Intent-Classified Search
WHY/WHEN/ENTITY/WHAT classification steers:
- RRF weighting (WHY boosts vector, WHEN boosts BM25)
- Graph traversal (WHY/ENTITY trigger multi-hop beam search over memory_relations)
- Edge types: semantic, supporting, contradicts, causal, temporal

### Knowledge Graph
- `memory_relations` table: typed edges between docs
- `entity_triples` table: SPO facts with temporal validity (valid_from/valid_to)
- Canonical predicate vocabulary (adopted, migrated_to, uses, prefers, avoids, caused_by, etc.)
- Entity resolution via `vault:type:slug` canonical IDs

### Consolidation Safety (v0.7.1) — the standout
Three independent gates prevent memory corruption:
1. **Name-aware merge guard**: entity anchor extraction + Jaccard ≤0.5 hard reject + dual threshold (0.93 normal, 0.98 strict). Prevents "Alice decided X" merging into "Bob decided X"
2. **Contradiction-aware merge gate**: deterministic heuristic first (negation, number/date mismatch), then LLM confirmation. Policy: link (default) or supersede
3. **Anti-contamination deductive synthesis**: three-layer validator (deterministic + LLM + dedupe) for cross-session insights. Prevents context bleed in derived observations

### Heavy Maintenance Lane (v0.8.0)
Dual-lane worker architecture:
- **Light lane**: 5-min ticks, interactive-friendly, newest-first
- **Heavy lane**: quiet-window gating (hour + query-rate), stale-first or surprisal selection, guarded merge enforcement
- Worker lease exclusivity via atomic SQLite upsert (no SELECT-then-INSERT race)
- Full journal table for operational observability

### Multi-Turn Lookback (v0.8.1)
Context surfacing builds retrieval query from current + 2 prior turns. But only for discovery stages — reranking, scoring, snippet extraction all use raw current prompt. Privacy-conscious split: pre-retrieval gates store NULL query_text, post-retrieval paths store the actual prompt.

## Relation to Our Direction

### Direct overlap
We use markdown-based wiki + memex for memory. ClawMem is what a production memory system looks like if you commit fully to SQLite + embeddings + graph retrieval. Our [[self-evolving-agent-landscape]] places this at the Memory layer.

### What we could learn
1. **Content-type half-lives** — our memex has no decay. ClawMem's half-life model (decisions=∞, notes=60d, handoffs=30d) is research-backed and practically sound. Related to [[krusch-context-mcp]]'s temporal decay.
2. **Co-activation tracking** — "docs frequently surfaced together" is a signal we completely lack
3. **Anti-contamination gates** — when we eventually do cross-session synthesis, this is the safety bar
4. **Recall tracking** — tracking what was surfaced vs what was actually cited. Closes the feedback loop.
5. **Quality scoring** — rewarding well-structured notes incentivizes better writing

### What we do differently (and why)
- Our wiki is human-readable files, not a SQLite vault. Lower ceiling but simpler to audit and version.
- Our identity layer (SOUL.md, beliefs-candidates.md) is a different axis — ClawMem is pure memory retrieval with no self-evolution dimension
- Our [[beliefs-upgrade-mechanism]] has no equivalent in ClawMem — they don't distinguish beliefs from facts

### Tradeoffs
- Heavy infrastructure: SQLite + embeddings + LLM for consolidation + observer model. High marginal value but high marginal cost.
- Markdown-only indexing (code excluded) — correct decision, matches our experience
- Single-developer (yoloshii), but high code quality and thorough docs

## Architectural Insights

1. **Intent classification changes everything downstream** — same query, different intent = different retrieval strategy. Not just a nice-to-have.
2. **Merge safety is non-trivial** — entity-aware guards, contradiction detection, anti-contamination. Most memory systems skip this and accumulate garbage.
3. **Dual-lane workers** — interactive vs maintenance workloads need different scheduling. The quiet-window + stale-first approach is elegant.
4. **Position-aware reranking blending** — trust top results more (α=0.75) than tail (α=0.40). Simple but effective.
5. **Discovery vs precision split** — multi-turn lookback only for discovery, raw prompt for scoring. Prevents prior-turn context from polluting precision stages.

## Comparison

| Feature | ClawMem | Our wiki/memex | [[krusch-context-mcp]] | [[mnem]] |
|---------|---------|---------------|----------------------|----------|
| Storage | SQLite WAL | Markdown files | SQLite local + PG global | Rust KG |
| Retrieval | BM25+Vector+Graph | FTS + semantic | RAG + temporal decay | GraphRAG |
| Decay | Content-type half-lives | None | Temporal decay | None |
| Graph | SPO triples + relations | Backlinks | None | Versioned KG |
| Safety | 3-layer merge guards | Manual | Basic | None |
| Integration | Claude Code + OpenClaw + Hermes + MCP | OpenClaw only | IDE plugin | Standalone |

## Scout Notes (2026-05-11)

Also spotted in same scout session:
- **LISA** (oratis/LISA, 3⭐) — Claims OpenClaw superset. Big-Five personality seeding, desires-driven heartbeat, dreams (idle reflection), emotion vectors with decay, soul tamper detection. Same identity layer as us. Worth revisiting if it gains traction.
- **Workspace-Bench** (OpenDataBox, 11⭐) — Academic benchmark for agent workspace tasks (388 tasks, 20K files). arXiv:2605.03596.
- **dreamer** grew 13→35⭐ (previously dropped, now showing life).
