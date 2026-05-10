---
title: cwc-long-running-agents
tags: [anthropic, agent-harness, quality]
created: 2026-05-10
stars: 215
url: https://github.com/anthropics/cwc-long-running-agents
---

# cwc-long-running-agents

Anthropic's official code companion for long-running agent harness patterns. Ships as Claude Code hooks + subagent examples. "Event demo; not maintained."

## Architecture

Three primitives forming a quality loop:

1. **[[default-fail-contract]]** — `test-results.json` with all features starting `false`. PreToolUse hook blocks writes to results unless evidence file (screenshot/log) was first Read. Agent can't claim success without observing it.

2. **Fresh-context evaluator** — Separate subagent (`agents/evaluator.md`) with no Write/Edit tools reviews diff + screenshots from clean context. Returns PASS or NEEDS_WORK. On NEEDS_WORK, findings become next builder session's starting prompt.

3. **Agent-maintained handoff** — PROGRESS.md + git commits. `commit-on-stop.sh` backstop catches uncommitted work. Agent scopes to one feature per session.

Two operator controls: `kill-switch.sh` (AGENT_STOP file halts all tools) and `steer.sh` (surfaces steer file contents to agent mid-run).

## Key Insights

- "Asking nicely in the prompt doesn't reliably stop" premature completion claims → structural enforcement needed
- Builder shouldn't grade its own work → separate evaluator with no write access
- "Re-simplify on model upgrades" — newer models need less scaffolding
- The patterns translate 1:1 to Agent SDK PreToolUse/Stop callbacks

## Relevance to Us

| cwc Pattern | Our Equivalent | Gap |
|---|---|---|
| Default-FAIL | verify-claims.sh → **default-fail-gate.sh** (adopted 05-10) | ✅ Closed |
| Fresh-context evaluator | plan_review subagent | Partial — our reviewer sees plan, not code |
| Agent-maintained handoff | memory/ + HEARTBEAT.md | Similar, less structured |
| Kill switch | No equivalent | Could add AGENT_STOP check to FlowForge |
| Steer | No equivalent | Could add STEER.md check to heartbeat |

## Applied

- 2026-05-10: Created `default-fail-gate.sh` and integrated into workloop pre_push_audit node
