# Memory Trash Filter — What NOT to Store

**Source**: [[stash]] v0.2.7 prompt engineering + convergent observation across [[hermes-memory-skills]], [[genericagent]] (2026-04-30)

## The Insight

What you DON'T store matters as much as what you do. Multiple projects converging on this:
- **Stash**: Explicit ban list in MCP prompt template
- **Hermes**: 4-dim scoring (Novelty/Durability/Specificity/Reduction) — low-scoring items rejected
- **GenericAgent**: "No Execution No Memory" — only stores things tied to real actions

## Our Application

Added **Trash Filter** section to [[beliefs-candidates]] (2026-04-30):

**Ban list categories:**
1. Session noise (status descriptions, not insights)
2. Unverified hunches (guesses without evidence)
3. Temporary states (no behavioral pattern)
4. Generic platitudes (too vague to act on)
5. Repetitive restating (should increment count, not add entry)
6. First-person narration without insight (belongs in memory/)
7. Tool-specific transient bugs (not behavioral)

**Quality gate**: "Will this matter 3 sessions from now?"

## Why This Matters for Us

Our beliefs-candidates.md has 100+ entries. Without a filter, signal-to-noise ratio degrades. The upgrade quality gate catches bad candidates at graduation time, but the trash filter catches them at entry time — much cheaper.

## Related

- [[stash]] — source project
- [[cost-of-not-calling]] — sibling pattern from same study
- [[dreaming-vs-beliefs-candidates]] — related quality discussion
