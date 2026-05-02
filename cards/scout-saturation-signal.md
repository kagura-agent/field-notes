---
title: Scout Saturation Signal
created: 2026-05-02
type: pattern
---

# Scout Saturation Signal

**Pattern**: When the first 3 search results in a scout round are all already tracked in the wiki, stop searching for new projects and switch to **trend synthesis mode**.

## Why This Matters

Scout rounds have diminishing returns when ecosystem coverage is already high. Continuing to search after hitting known results wastes ~5 minutes per round with zero new information. But "nothing new" is itself a signal — it means the ecosystem is in a **consolidation/stabilization phase**.

## The Switch

When saturation is detected:
1. Stop individual project searches
2. Update star counts for tracked projects (growth velocity as signal)
3. Write trend-level observations (convergence patterns, category shifts)
4. Record the consolidation signal itself as data

## Implementation

Embedded in [[flowforge]] `study.yaml`:
- `scout` node: step 7 — saturation detection and mode switch
- `quick_scout` node: step 4 — same pattern for quick scans

## Origin

Discovered 2026-05-02 during a scout round where all 5 top results were already in wiki. The productive output that round was the [[worktree-convergence-2026-05]] trend card, not any individual project note.

## Related

- [[worktree-convergence-2026-05]] — example of trend synthesis output
- [[self-evolving-agent-landscape]] — the landscape being scouted
