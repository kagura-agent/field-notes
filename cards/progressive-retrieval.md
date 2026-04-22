# Progressive Retrieval (渐进式检索)

**Pattern**: Multi-layer recall that expands context progressively rather than dumping everything at once.

## memsearch's 3-Layer Model
1. **Search** — vector similarity + BM25 sparse → initial candidates
2. **Expand** — follow links/references from candidates → related context
3. **Transcript** — pull full conversation history when needed → deep context

## Why It Matters

Single-layer search (our current [[dreaming]]) returns isolated chunks. Progressive retrieval builds a **context graph** — each layer adds connected knowledge, not random hits.

This maps to how humans recall: a keyword triggers a memory → that memory reminds you of related events → you reconstruct the full story.

## Hybrid Search Components
- **Dense vectors** — semantic similarity (catches paraphrases)
- **BM25 sparse** — exact term matching (catches specific names, IDs)
- **RRF reranking** — Reciprocal Rank Fusion combines both signals

Our [[dreaming]] eval's 5 persistent failures might benefit from adding BM25 — some failures are likely exact-match queries that semantic search misses.

## Application to Our Stack

| Layer | memsearch | Our equivalent |
|-------|-----------|----------------|
| Search | Milvus vector + BM25 | memory_search (vector only) |
| Expand | Link following | ❌ missing |
| Transcript | Full history | session-logs (manual) |

Gap: we lack the **expand** layer. Adding [[双链]] traversal after initial search could improve recall.

## Feasibility Assessment (2026-04-22)

**Key discovery: OpenClaw already has hybrid search!**

`src/agents/memory-search.ts` shows:
- `DEFAULT_HYBRID_ENABLED = true` (vector 0.7 + FTS 0.3)
- FTS5 with query expansion (`query-expansion.ts`) — stop word removal, CJK bigram tokenization
- MMR (Maximal Marginal Relevance) — configurable, we have it enabled
- Temporal decay — configurable, we have it enabled
- Multi-language support: EN/ZH/JA/KO/ES/PT/AR stop words

Our config (`openclaw.json`) already enables MMR + temporal decay on top of defaults.

**Implication**: The TODO item "research BM25 feasibility" was based on outdated assumptions. We already have hybrid (dense + sparse) search. The 5 persistent eval failures break down as:
- 3 query dilution → fixed by adjusting qrels (queries were unrealistic)
- 2 genuinely unfixable by search: temporal ("yesterday") and operational ("PR stats") — need query preprocessing or structured metadata, not better retrieval

**What memsearch adds that we still lack:**
1. **Expand layer** — link following after initial search (our [[双链]] are not traversed)
2. **Transcript layer** — full conversation history pull (we have session-logs but it's manual)
3. **Progressive expansion** — search → expand → deepen, not dump everything

**Next step**: The expand layer is the real gap. Consider adding wiki `[[link]]` traversal as a post-search enrichment step.

## Related
- [[claude-context]] — code search (different domain, same ecosystem)
- [[GBrain]] — PGLite embedded approach (no cloud dependency)
- [[dreaming]] — our memory consolidation system

---
*Created: 2026-04-22*
