---
title: Query Dilution
created: 2026-04-17
source: Memory search eval 04-17 — systematic failure analysis
modified: 2026-04-17
---

# Query Dilution

Adding generic/common words to a semantically precise query can kill retrieval by pushing the query embedding away from target document embeddings.

## Pattern

| Query | Score | Hit? |
|-------|-------|------|
| "credential security" | 0.573 | ✅ |
| "agent credential security pool" | — | ❌ |
| "chat first product" | 0.573 | ✅ |
| "chat first product design" | — | ❌ |
| "llm wiki karpathy" | ✅ hit | ✅ |
| "llm wiki karpathy document knowledge base" | — | ❌ |

Common diluters: "design", "pool", "document", "knowledge", "base" — high-frequency words that shift the centroid of the query embedding.

## Why It Happens

Embedding models average token representations. Adding generic words moves the embedding toward a "generic" region of the space, reducing cosine similarity with specific document embeddings. Combined with a minScore threshold, this drops the result below cutoff.

## Mitigation Options

1. **Lower minScore** — more results but more noise
2. **Query decomposition** — split "A B C D E" into sub-queries, union results
3. **Hybrid retrieval** — keyword (BM25) + semantic, then re-rank
4. **Query expansion** — add synonyms from the document corpus
5. **User-side** — use precise queries, fewer generic words

## Related

- [[intent-aware-retrieval]] — query understanding before search
- [[progressive-disclosure-memory]] — layered retrieval design
