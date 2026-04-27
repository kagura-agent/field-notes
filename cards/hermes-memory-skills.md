---
title: "Hermes Memory Skills"
created: 2026-04-27
updated: 2026-04-27
tags: [memory, consolidation, hermes, scoring, skill-ecosystem]
---

# Hermes Memory Skills

**Repo:** [nexus9888/hermes-memory-skills](https://github.com/nexus9888/hermes-memory-skills) (17 ⭐, created 2026-04-25)

Two complementary skills for [Hermes Agent](https://github.com/NousResearch/hermes-agent) that automate memory hygiene — keeping `MEMORY.md` lean and accurate.

## Architecture

```
agent-dreaming (produces) → memory-lean-check (trims/verifies)
```

### Agent Dreaming — 3-Phase Consolidation
Modeled explicitly on [[dreaming|OpenClaw's dreaming metaphor]]:

| Phase | Purpose | Autonomy |
|-------|---------|----------|
| **Light** | Ingest session transcripts, stage candidates | Autonomous |
| **Deep** | Score candidates with 4D rubric, promote to MEMORY.md | Autonomous |
| **REM** | Extract cross-session patterns, propose structural actions | **Interactive** — sends proposals, waits for user approval |

### Memory Lean Check — Surgical Trimmer
- Validates wiki pointers (flags broken, preserves working)
- Condenses verbose entries into wiki pointers
- Removes stale/temporary entries
- Post-write integrity check (re-read, verify entry count)

## The 4-Dimension Scoring Rubric

Core contribution — a formalized gate for memory promotion:

| Dimension | Question | Fail Signal |
|-----------|----------|-------------|
| **Novelty** | Is this genuinely new? | Similar entry already exists in MEMORY.md |
| **Durability** | Will this still be true in 30 days? | Task progress, TODOs, session outcomes |
| **Specificity** | Is this precise enough to be actionable? | "User might like X" — requires guessing |
| **Reduction** | Does promoting this let you remove/shorten existing entries? | (Soft — priority bonus, not hard fail) |

Must pass ALL hard gates (N+D+S) to be promoted. Reduction gives priority.

### Capacity-Aware Thresholds
- Under 60%: healthy, proceed normally
- 60-80%: allow replacements, defer new additions
- Over 80%: flag critical, run lean-check first

## Relationship to Our System

Compared this rubric to our [[dreaming-vs-beliefs-candidates|beliefs-candidates upgrade quality gate]]:

| Hermes Dimension | Our Equivalent | Gap? |
|-----------------|---------------|------|
| Novelty | "Uniqueness" supplementary check | Covered |
| Durability | **Missing** → adopted 2026-04-27 | ✅ Fixed |
| Specificity | "Specificity & Reusability" | Covered |
| Reduction | **Missing** → adopted 2026-04-27 | ✅ Fixed |

We have dimensions Hermes doesn't need: Grounded in Evidence, Preserves Existing Value, Safe to Publish — because we graduate behavioral patterns (higher stakes than factual memory).

**Key insight**: The same meta-pattern (stage → score → promote) works for both factual memory and behavioral beliefs, but the scoring dimensions differ by content type. Hermes optimizes for storage efficiency (Reduction, capacity thresholds); we optimize for behavioral safety (Evidence, Preservation, Safety).

## Design Decisions Worth Noting

1. **REM phase is interactive** — structural changes (wiki pages, skills) require user approval. This is a trust boundary that [[mechanism-vs-evolution]] would call a "safety ratchet."
2. **Profile isolation** — wiki path resolved from `$HERMES_HOME/config.yaml`, never `$HOME/wiki`. Multiple agent profiles can coexist without memory contamination.
3. **§ delimiter integrity** — post-write verification re-reads file and counts entries. Defensive against LLM formatting errors corrupting structured data.
4. **Dream diary is append-only** — audit trail. Each promotion traces to source session ID.

## Convergence Signal

This is another data point for [[convergent-evolution]]: an independent developer (nexus9888) built memory consolidation that mirrors our architecture almost exactly (3-phase, cron-triggered, scoring-gated promotion). They explicitly cited OpenClaw as inspiration. The convergence suggests these patterns are natural consequences of the problem space, not arbitrary design choices.

## Related
- [[dreaming]] — OpenClaw's implementation that inspired this
- [[dreaming-vs-beliefs-candidates]] — comparison of our two consolidation paths
- [[self-evolving-agent-landscape]] — where memory scoring fits in the 4-layer stack
- [[convergent-evolution]] — independent teams arriving at similar solutions
- [[skill-is-memory]] — the broader principle connecting skills and memory
