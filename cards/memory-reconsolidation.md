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

## OpenChronicle's Supersede Pattern (2026-04-28)

[[openchronicle]] implements a clean version of supersede-not-delete:
- Old facts get strikethrough + `#superseded-by` links to new version
- Full timeline preserved, never deleted
- Plain Markdown files — no special DB needed
- "Default is silence" classifier: new fact must pass 3-day durability test before being committed

This is closer to neuroscience reconsolidation than mneme's approach: OpenChronicle doesn't re-evaluate on retrieval, but it does version-control facts with explicit supersession chains. The durability test (requiring pattern confirmation over 3 days) acts as a natural filter against ephemeral observations.

Links: [[mneme]], [[openclaw]], [[orb]], [[openchronicle]]
