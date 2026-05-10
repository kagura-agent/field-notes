---
title: "Verify Claims Before Acting"
created: 2026-05-10
tags: [agent-discipline, verification, default-fail]
---

# Verify Claims Before Acting

An agent discipline principle: never trust unverified assertions — from humans, subagents, LLM outputs, or your own assumptions.

## Core Rule
**Don't claim what you haven't verified. Don't act on unverified claims.**

## Application
- Subagent says "done" → check the actual output/code/state
- LLM generates a path/URL → verify it exists
- Assumption about API behavior → test it first
- Data citation → trace to source

## Related Patterns
- **[[default-fail-contract]]**: Systems should fail explicitly rather than silently succeed with wrong results
- **Smell test**: If your answer contains "probably", "should be", "likely" — you're guessing, verify first
- **Data discipline**: Every number/path/claim must trace to an actual query, not estimation

## Why This Matters for Agents
Agents compound errors faster than humans because they act on outputs immediately. One unverified claim can cascade through tool calls, subagent delegations, and external actions before anyone notices.

See also: [[default-fail-contract]]
