---
title: Multi-Agent Quality Gate
created: 2026-05-06
type: concept
tags: [architecture, quality, multi-agent]
---

# Multi-Agent Quality Gate

Pattern where agent outputs are evaluated by multiple independent "panelists" before being accepted. Unlike single-pass generation, outputs must pass a threshold score to ship.

## Origin: Open Design Critique Theater

[[open-design]] v0.4.0 introduced "Critique Theater" (user-facing: "Design Jury"):
- 5 panelists score each design artifact
- Minimum 8.0/10 to ship
- Dimensions: accessibility (WCAG AA), brand fidelity, craft quality
- Full persistence + replay via `critique_runs` SQLite table
- Wire protocol v1 with SSE streaming for real-time panel events

## Pattern Structure

```
generate → panel evaluation (N agents) → score aggregation → threshold gate → ship/reject
```

Key components:
1. **Panel definition** — independent evaluators with different concerns
2. **Scoring protocol** — structured dimensions, not just thumbs-up/down
3. **Threshold** — hard minimum, not advisory
4. **Persistence** — runs are stored for replay and audit
5. **Recovery** — stale run reconciliation on restart

## Applicability

| Domain | Panel members | Threshold |
|--------|--------------|-----------|
| Design artifacts | Accessibility, brand, craft, UX, performance | 8/10 |
| Code generation | Tests pass, lint clean, security scan, reviewer | All green |
| Skill validation | Syntax valid, test coverage, no regressions, perf | Pass/fail |
| Content creation | Factual accuracy, tone, readability, privacy | 7/10 |

## Tradeoffs

- **Pro**: Catches quality issues single-pass misses. Structured, not vibes-based
- **Pro**: Replay/audit trail useful for debugging and learning
- **Con**: N× cost (5 evaluations per artifact)
- **Con**: Threshold tuning is non-trivial (too high = nothing ships, too low = rubber stamp)
- **Con**: Panelists may agree on wrong things (correlated errors)

## Relation to Existing Patterns

- **[[mechanism-vs-evolution]]** — This is mechanism (explicit gates) vs evolution (let quality emerge). Both have value
- **[[supervisor-pattern]]** — Supervisor evaluates; quality gate is a specialized supervisor with structured scoring
- **[[flowforge]]** — Could add quality gate nodes to workflows

## Update: Phase 5 Anti-Collusion (2026-05-08)

[[open-design]] v0.5.0 Critique Theater Phase 5 adds two convergence constraints that address the correlated-errors weakness:

1. **Disagreement requirement**: At least two panelists must diverge on a MUST_FIX target per non-final round. Unanimous agreement is treated as shallow critique.
2. **Transcript shrinkage**: Each round's transcript bytes must be strictly less than the previous round — forces convergence, prevents scope creep.

These are transferable to any quality gate implementation, not just design.

See [[open-design]], [[supervisor-pattern]]
