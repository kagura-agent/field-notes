# Dreaming vs Beliefs-Candidates: Two Memory Consolidation Paths

> Two complementary pipelines for converting ephemeral signals into durable memory.

## Core Distinction

| Dimension | OpenClaw Dreaming | Beliefs-Candidates Pipeline |
|-----------|------------------|-----------------------------|
| **Trigger** | Automatic (cron, 3:30 AM) | Manual (corrections, lessons, nudge) |
| **Signal source** | Recall frequency + daily notes + session transcripts | User corrections, repeated patterns, explicit observations |
| **What it promotes** | Frequently recalled facts → MEMORY.md | Behavioral patterns → DNA / Workflow / KB |
| **Selection criteria** | Score ≥ 0.8, recalled ≥ 3×, ≥ 2 unique queries | Repeated ≥ 3×, then triaged by best carrier |
| **Automation level** | Fully automatic (no agent decision) | Semi-automatic (agent writes candidates, reviews for graduation) |
| **Target** | MEMORY.md (factual memory) | AGENTS.md / SOUL.md / workloop.yaml / wiki cards |
| **Content type** | Facts, context, events | Principles, preferences, lessons, corrections |

## How They're Complementary

- **Dreaming** catches things the agent recalls often but never explicitly marked as important
- **Beliefs-candidates** catches things the agent was *told* or *realized* are important
- Together: passive frequency signal + active intentional signal = fuller coverage
- Neither replaces the other: dreaming won't catch a correction that only happened once; beliefs won't surface a fact recalled 10× across sessions

## Shared Pattern: Two-Stage Memory Consolidation

Both follow the same meta-pattern:
1. **Staging**: raw signals accumulate (recall store / beliefs-candidates.md)
2. **Reflection**: periodic review with quality threshold (dreaming sweep / daily-review graduation)
3. **Promotion**: selected signals move to durable storage (MEMORY.md / DNA files)

This mirrors cognitive science: short-term → working memory → long-term memory.

## Our Configuration (2026-04-13)

**Dreaming**: Enabled at `0 30 3 * * *` (3:30 AM CST), after daily-review (3:00 AM).
- Light sleep: 3-day lookback, extract from daily notes
- REM: 7-day lookback, pattern recognition
- Deep: promote top 5 candidates (score ≥ 0.8, recalled ≥ 3×, ≥ 2 unique queries, max 30 days old)
- Storage: both inline + separate reports (`memory/.dreams/`)
- Verbose logging: on (first deployment, want observability)

**Beliefs-candidates**: ~207 entries, 15 graduated to DNA, reviewed in daily-review.

## Risk Assessment

- Dreaming writes to MEMORY.md automatically → potential for noise. Mitigated by high thresholds (score 0.8, 3 recalls)
- Running at 3:30 AM (after 3:00 AM daily-review) avoids conflicts
- Verbose logging lets us audit what gets promoted and tune thresholds
- `storage.mode: "both"` means we get separate reports for easy review

## Observation Plan

- Monitor `memory/.dreams/` reports for 1 week
- Check MEMORY.md diffs after dreaming runs
- Tune thresholds if too noisy (raise minScore) or too quiet (lower minRecallCount)
- W19 (~May 11) eval: assess if dreaming adds value beyond beliefs-candidates alone

## Related

- [[progressive-disclosure-memory]] — retrieval strategy that feeds recall signals to dreaming
- [[cron-observability-metrics]] — dreaming reports are a form of cron observability
- [[self-evolution-as-skill]] — dreaming is passive self-evolution, beliefs is active

## 2026-04-27: Beliefs Pipeline Upgraded with Hermes Dimensions

After deep-reading [[hermes-memory-skills]], adopted two scoring dimensions into beliefs-candidates upgrade quality gate:
- **Durability** (hard gate): "Will this pattern matter in 30 days?" — filters temporal/contextual patterns that our "repeated 3×" heuristic can’t catch
- **Reduction** (soft gate): "Does upgrading this let us merge/simplify existing DNA?" — combats monotonic DNA growth

This brings our gate from 4 to 5+1 dimensions (4 hard + Durability hard + Reduction soft).

## 2026-04-29: Source Authority (from brain)

After applying [[brain-git-memory]]'s authority model, beliefs-candidates entries now include a `source:` field (`human|self|study|review|env`). Key change: **human corrections graduate faster** (threshold 2×) than self-observed patterns (3×). This is the "not all memories are equal trust" principle — Luna's direct correction carries more signal than an agent's self-reflection.

This differentiates the "repeated 3×" heuristic by source quality, not just quantity.

---
*Created: 2026-04-13 | Updated: 2026-04-29*
