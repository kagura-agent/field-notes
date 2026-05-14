---
title: Explicit Spawn Contract
tags: [pattern, agent-architecture, skill-design, multi-agent]
created: 2026-05-14
updated: 2026-05-14
status: active
depth: concept
last_verified: 2026-05-14
---

# Explicit Spawn Contract

**Principle**: Agent descriptions declare design intent; skill files are execution contracts. Without explicit spawn instructions in the skill, agents are dead code.

## Origin

Discovered via [[oh-story-claudecode]] PR #44 (2026-05-12). User-reported bug: `narrative-writer` agent defined in `.claude/agents/` but never invoked by any writing skill. 3 of 13 skills had agents available but not spawned. Claude Code does NOT auto-select agents from descriptions alone.

## The Pattern

```
❌ Agent description: "I should be used by story-long-write"
   → Declares INTENT, not invoked

✅ SKILL.md: "In Phase 4, spawn narrative-writer to execute writing"
   → Explicit EXECUTION CONTRACT, actually invoked
```

## Why It Matters

1. **Description ≠ Execution**: Declaring what an agent CAN do is not the same as specifying WHEN to invoke it
2. **No magic routing**: Even sophisticated runtimes (Claude Code, OpenClaw) don't automatically match agents to tasks based on descriptions
3. **Graceful degradation**: Check if agent exists → spawn if yes → fall back to main thread if no. Users without agent setup aren't blocked

## Applicability

| Framework | How it applies |
|---|---|
| Claude Code | `.claude/agents/` descriptions vs SKILL.md spawn instructions |
| OpenClaw | `available_skills` descriptions route to skill; SKILL.md content drives execution |
| FlowForge | `executor: subagent` in YAML is the explicit contract |
| Any multi-agent | Agent registry ≠ agent invocation. Both are needed |

## Our Situation

OpenClaw's `available_skills` block uses `<description>` for routing (which skill to load) and SKILL.md content for execution (what to do). FlowForge uses `executor: subagent` as explicit spawn contract. We don't have the "implicit matching" anti-pattern — but if we ever build multi-agent skills, this pattern is the guard rail.

## Related

- [[oh-story-claudecode]] — origin project
- [[skill-distribution-convergence]] — skill must be self-contained
- [[thin-harness-fat-skills]] — execution logic lives in skills, not in the harness
