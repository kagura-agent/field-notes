---
title: "agents-md — AGENTS.md Context Engineering Patterns"
slug: agents-md-context-patterns
tags: [context-engineering, token-efficiency, coding-agent, AGENTS.md]
created: 2026-05-11
source: https://github.com/Austin1serb/agents-md
status: noted
stars: 82
last_verified: 2026-05-11
---

# agents-md — AGENTS.md Context Engineering Patterns

82⭐ repo by Austin Serb. Curated AGENTS.md + Codex system prompt patterns for coding agents. Focus: context discipline, token efficiency, safer command output.

## Key Patterns

### Byte-cap over line-cap (★ most actionable)

```bash
COMMAND 2>&1 | head -c 4000   # bounded by bytes, not lines
COMMAND 2>&1 | tail -c 4000   # for recent output
```

One huge line can flood the entire context window. `head -n 20` is unsafe because it doesn't bound bytes. Author claims ~50% token reduction from this single rule.

**Our status**: We don't have a byte-cap convention. Our agents use `head -n` or `| head -20` which is vulnerable to the same failure mode. Consider adopting `head -c` in subagent templates.

### Context discipline hierarchy

1. Answer the narrow question first
2. Inspect the smallest relevant file/symbol/route
3. Only expand scope if the narrow read is insufficient
4. Never dump full files, full logs, or broad repo searches after the relevant code is found

**Our status**: Implicit in our "验证纪律" but not as explicit. Our AGENTS.md says "先验证最基础假设" but doesn't prescribe the read-narrow-first pattern.

### Anti-confirmation-bias for subagents

> "Do not pass a preferred conclusion. Ask the subagent to investigate, compare, or verify, and require evidence, tradeoffs, uncertainty, and better alternatives."

**Our status**: We don't have explicit anti-confirmation-bias framing. Our team-lead skill assigns tasks but doesn't explicitly warn against leading the subagent toward a predetermined conclusion.

### Subagent result template

Required from subagents: findings, files inspected, files changed, validation run, risks/uncertainty. Simple and complete.

## What's Not Useful

- The Codex personality prompt is interesting as a data point but not actionable for us (we have SOUL.md)
- No issues, no community, no tests — it's a one-person reference doc, not a living project

## Connections

- [[claude-code-source-analysis]] — similar context discipline patterns in Anthropic's own system prompt
- [[token-efficiency]] — byte-cap is a concrete implementation of token efficiency
- [[team-lead]] — anti-confirmation-bias pattern relevant for subagent delegation
