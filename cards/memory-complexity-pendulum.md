---
title: "Memory Complexity Pendulum"
created: 2026-05-06
type: concept
---

# Memory Complexity Pendulum

Agent memory systems swing between "more pipeline = better" and "simpler = better." The pattern:

1. **Start simple** — append to file, manual curation
2. **Add complexity** — scoring, tiering, rescore candidates, multi-stage consolidation
3. **Simplify back** — remove features that don't pay off, flatten pipelines

## Evidence

- **[[invincat]]** (05-06): Removed entire rescore_candidates system, removed MAX_OPERATIONS_PER_RUN limit, flattened multi-turn messages to plain-text transcript. Net -185 lines. The most sophisticated open-source memory agent is *removing* complexity.
- **[[stash]]**: 9-stage consolidation pipeline. Works but expensive — multiple LLM calls per turn. Unclear if stages 4-9 justify their cost.
- **[[invincat]]** (05-07): Prompt compression -152 lines. Replaced verbose operation catalog with "DECISION ORDER" — a prescribed evaluation sequence. Three rounds of simplification totaling -326 lines. The pendulum has swung fully: code pipelines replaced by prompt instructions.
- **Our system**: Started with free-form markdown, still there. We never built the pipeline — and maybe that's not a bug.

## Insight

The features that survive simplification are the **structural ones** (score/tier, dual-store isolation, evidence-gating), not the **process ones** (rescore cadence, candidate selection, multi-stage pipelines). Structure constrains what goes in; process tries to fix what's already in. Prevention > cure.

## Implication

If we ever build automated memory, invest in **structure** (what qualifies as memory, how it's scored at creation) rather than **process** (periodic rescoring, consolidation pipelines). Invincat's refactor validates this — they kept the tier/score system but removed the rescore pipeline.

Links: [[invincat]], [[stash]], [[agent-memory-landscape-202603]], [[mechanism-vs-evolution]]
