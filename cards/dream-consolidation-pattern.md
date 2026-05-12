---
title: Dream Consolidation Pattern
tags: [agent-memory, knowledge-management, architecture-pattern]
created: 2026-05-12
last_verified: 2026-05-12
---

# Dream Consolidation Pattern

An automated background process that mines agent session transcripts to extract, deduplicate, and consolidate knowledge into a structured knowledge base. Named after the metaphor of sleep → memory consolidation.

## Key Design Elements

1. **Two-surface invariant**: Strict separation between **knowledge vaults** (real project knowledge) and **audit log** (meta-information about what the consolidator did). Prevents mixing meta-content with actual knowledge.

2. **Skip-already-processed**: Uses previous run's summary table as a resume marker. Only processes sessions with new content since last consolidation. Efficient for frequent runs.

3. **Four-pass procedure**: Survey → Read sessions → Consolidate → Summarize. Each pass has clear constraints and target surfaces.

4. **Targeted reconciliation**: After writing new knowledge, re-read only the pages modified in this run to check for internal contradictions. Full-vault sweep is a separate operation.

5. **Provenance tracking**: Every insight traced to source session IDs via `sources:` frontmatter. Enables auditability.

6. **Conservative deletion**: Only delete when content is strictly subsumed or explicitly contradicted. Cost of redundancy < cost of knowledge loss.

## Implementations

- [[thclaws]] `/dream` command (v0.9.0, 2026-05-12) — first known implementation. Spawns side-channel agent with `KmsRead/Search/Write/Append/Delete` tools. Embedded AgentDef compiled into binary, overridable by user.

## Relevance to Our Stack

Our [[memex]] wiki maintenance is manual (doctor, lint, search). The dream pattern could automate:
- Mining daily memory logs → extracting reusable knowledge into wiki cards
- Deduplicating wiki cards that cover the same concept
- Detecting contradictions between cards written at different times
- Building audit trail of what was consolidated and when

Compare with [[auto-memory]] (automatic memory extraction) — dream goes further by also doing dedup/reconciliation, not just extraction.

## Open Questions

- How well does the model actually consolidate vs. just copying? Quality depends on the model's ability to synthesize, not just extract.
- What's the right frequency? Too often → mostly no-ops. Too rare → large batches lose context.
- How to handle the "dreams about dreams" problem — does the consolidator's own output become input for the next run? thClaws avoids this by strict surface separation.
