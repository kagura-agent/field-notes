# Verify Before Researching

> Before creating a "research X feasibility" TODO, spend 2 minutes checking if the current stack already has it.

## Pattern

When you encounter an idea or concept that seems worth researching:

1. **grep first** — search the codebase (`grep -r "keyword" ~/repos/`)
2. **check docs/changelog** — the feature may already exist under a different name
3. **search wiki** — `memex search "keyword"` to find existing notes

Only create a research TODO if the quick check confirms it's genuinely new.

## Why This Matters

- Saves hours of research on already-solved problems
- Prevents duplicate wiki entries
- Forces grounding in what's real vs what's imagined

## Origin

2026-04-22: Discovered that hybrid search was already built into OpenClaw after spending days assuming we needed to research it. The assumption was never checked against the actual codebase.

## Applied In

- [[study-workflow]] — added as mandatory pre-check in scout and apply nodes (2026-04-23)
- General principle for any "should we build X?" decision

## See Also

- [[data-discipline]] — same root cause: acting on assumptions instead of evidence
- [[smell-test]] — related diagnostic pattern
