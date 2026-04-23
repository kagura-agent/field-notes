# Memory Reconsolidation in Agent Systems

Neuroscience concept (Nader 2000) applied to AI agent memory: memories become labile on retrieval and can update.

## Key Insight
Traditional agent memory is append-only or latest-wins. Reconsolidation treats every retrieval as an opportunity to evaluate whether the memory is still accurate given current context.

## Implementation Pattern ([[mneme]])
1. On retrieval, compute cosine drift between stored embedding and current context embedding
2. If drift exceeds threshold (e.g., 0.3), trigger LLM evaluation: keep / update / conflict
3. On update: create new versioned engram, mark old as superseded (preserves history)
4. On conflict: reduce confidence, flag for resolution

## Relevance to [[openclaw]]
Our current memory model (MEMORY.md + daily logs) is fully manual curation. No mechanism detects when a stored fact becomes stale. Reconsolidation could be implemented as:
- During memex search, flag results with high context drift
- In heartbeat/daily-review, scan for contradicting entries
- On explicit recall, auto-evolve outdated facts

## Related
- [[write-time-vs-read-time-arbitration]] — Orb's write-time approach vs mneme's read-time evolution
- [[frozen-trust-vs-time-decay]] — confidence decay models

Links: [[mneme]], [[openclaw]], [[orb]]
