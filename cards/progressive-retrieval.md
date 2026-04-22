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

## Related
- [[claude-context]] — code search (different domain, same ecosystem)
- [[GBrain]] — PGLite embedded approach (no cloud dependency)
- [[dreaming]] — our memory consolidation system

---
*Created: 2026-04-22*
