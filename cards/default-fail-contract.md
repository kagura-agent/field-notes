---
title: Default-FAIL Contract
tags: [agent-harness, verification, quality-gate]
created: 2026-05-10
source: https://github.com/anthropics/cwc-long-running-agents
---

# Default-FAIL Contract

Pattern from Anthropic's "Harness Primitives for Long-Running Claude Agents" (Code with Claude 2026).

## Core Idea

Every verification criterion starts as `false` (failing). The agent must produce **observable evidence** (screenshots, logs, test output files) before the criterion can be flipped to `true`. A structural gate blocks progression until all criteria pass.

Key insight: asking agents to "verify before proceeding" in prose instructions doesn't reliably prevent premature completion claims. Making "done" structural — via a file-based evidence ledger — closes the gap.

## Three Primitives

1. **Default-FAIL contract** — criteria start false, evidence-gated
2. **Fresh-context evaluator** — separate agent (no write tools) grades work from clean context
3. **Agent-maintained handoff** — agent writes PROGRESS.md + git commits for session continuity

## Our Adoption

Applied Default-FAIL to FlowForge workloop `pre_push_audit` node:
- Created `scripts/default-fail-gate.sh` (init/record/verify)
- 4 criteria: test-output, diff-stat, verify-claims, interface-check
- Gate blocks submission unless all criteria are TRUE with non-empty evidence files
- Shifts verification from "paste your output" (advisory) to "evidence files must exist" (structural)

## Related

- [[pr-superseded-lessons]] — related quality gate concerns
- [[verify-claims]] — our existing mechanical verification script
- Fresh-context evaluator maps to our `plan_review` subagent pattern
- Agent-maintained handoff maps to our PROGRESS.md / memory system
