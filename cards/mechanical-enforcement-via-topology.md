---
title: Mechanical Enforcement via Topology
created: '2026-05-06'
source: thClaws /goal system + kiwifs PR#38 + agentic-stack ztk_policy
tags: [architecture, workflow, governance]
---

# Mechanical Enforcement via Topology

Pattern: instead of writing "don't skip X" in task descriptions (cultural enforcement), make X a separate node/gate in the workflow topology (mechanical enforcement). The agent physically cannot reach the next step without going through the gate.

## Why This Matters

Cultural enforcement (text instructions) has a fundamental failure mode: the agent can always skip it when pressed for time or when the instruction is buried in a long task description. Mechanical enforcement makes skipping structurally impossible.

## Examples

| Project | Mechanism | What it enforces |
|---------|-----------|-----------------|
| [[thclaws]] | `/goal` authority-separated tools | Cannot mark goal complete without audit prompt |
| [[kiwifs]] | ValidateTransition in write pipeline | Cannot transition task state without valid preconditions |
| [[agentic-stack]] | ztk_policy.py travels with agent | Policy applies regardless of which harness runs the agent |
| [[flowforge]] workloop | `pre_push_audit` node between implement and submit | Cannot submit PR without pasting actual test output and diff-stat |

## Design Principle

```
Cultural:   task: "Don't forget to run tests before pushing"
            → Agent can say "tests should pass" without running them

Mechanical: implement → pre_push_audit → submit
            → Agent must provide evidence in pre_push_audit to reach submit
```

## Tradeoffs

- **Pro**: Eliminates the most common failure mode (skipping verification under time pressure)
- **Pro**: Creates audit trail (the evidence is in the workflow log)
- **Con**: Adds latency (one more node transition)
- **Con**: Can become bureaucratic if gates are too numerous or too strict
- **Sweet spot**: Use for high-consequence steps (PR submission, deployment), not for every action

## Relation to Existing Patterns

- [[mechanical-verification]] — related but different: that's about metric-based evaluation, this is about workflow topology
- [[mechanism-vs-evolution]] — this is firmly on the mechanism side
- [[adaptive-workflow-rigidity]] — topology gates are "always rigid" steps, task descriptions are "adaptive" steps
