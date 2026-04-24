# Asset Temperature Model

Knowledge assets need lifecycle management — not just creation and retrieval, but validation and retirement.

## The Problem

Memory systems accumulate easily but prune poorly. Old lessons stay forever, even when outdated or never actually useful. This creates noise that degrades retrieval quality over time.

## Temperature Model (from [[agent-experience-capitalization]])

Track activation (was it retrieved?) and support (did it actually help?) to assign a temperature:

- **Hot**: ≥2 strong supports or ≥75% support ratio → core asset, high retrieval priority
- **Warm**: at least 1 support → initially validated
- **Neutral**: never activated → unproven
- **Cool**: ≥4 activations but <20% support → needs review, likely outdated or wrong

## Why This Matters

- Answers "which knowledge is actually useful?" with data instead of vibes
- Cool assets surface for review instead of silently polluting retrieval
- Hot assets get prioritized, creating a natural quality gradient

## Application to Our Wiki

Our current wiki has no activation tracking. Cards created during study may never be retrieved again. The orphan weaving work ([[hub-first-backlink-weaving]]) addresses structural connectivity but not usage-based validation.

Potential implementation:
- Log which cards are retrieved during `memex search` calls
- Track whether the retrieved card influenced the outcome
- Periodically surface "cool" cards (high retrieval, low usefulness) for review

Links: [[retrieval-is-the-bottleneck]], [[skill-is-memory]], [[agent-experience-capitalization]], [[self-evolving-agent-landscape]]
