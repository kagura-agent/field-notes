---
title: agent-skills-eval
tags: [skill-eval, testing, agentskills-io, quality]
created: 2026-05-11
stars: 276
url: https://github.com/darkrishabh/agent-skills-eval
---

# agent-skills-eval

Test runner for [agentskills.io](https://agentskills.io)-style AI agent skills. MIT, TypeScript, CLI + SDK. Created 2026-05-06, ⭐276 in 5 days.

## What It Does

A/B testing framework for agent skills: runs the same prompt **with** and **without** a SKILL.md loaded, has a judge model grade both outputs, produces a side-by-side comparison report. Answers the question: "does this skill actually make the model better?"

## Architecture

```
eval prompt → target model (with_skill / without_skill)
           → raw output + tool_calls
           → judge model grades against assertions
           → JSON artifacts + HTML report
```

**Key design decisions:**

1. **Dual-mode comparison** — Every eval runs twice (with_skill, without_skill). Not just "does it pass" but "does the skill add lift." This is the right question.

2. **Separated grading** — Judge is a different model call. Free-form assertions go through LLM judge; tool-call assertions are deterministic (local checks). Clean separation of fuzzy vs. exact.

3. **Provider-agnostic** — OpenAI-compatible interface. Any chat model works as target or judge. No vendor lock-in.

4. **Artifact-first** — Everything is JSON/JSONL. `iteration-N/` layout with full artifacts. Diffable across runs.

5. **Spec-compliant** — Implements the full agentskills.io specification: frontmatter parsing, evals.json, references, scripts.

## Interesting Details

- `ToolAssertion` types: `tool-called`, `tool-not-called`, `tool-arg-equals`, `tool-arg-contains`, `tool-arg-matches`, `tool-call-count` — deterministic, no judge needed
- Skill system message rendered as XML: `<skill><description>...</description><instructions>SKILL.md content</instructions><references>...</references></skill>`
- Supports attached files in evals (e.g., CSV data), falls back to inline XML if provider doesn't support attachments
- `completeWithFallback` handles both system-role-aware and single-prompt providers

## Relevance to Us

| Aspect | Their Approach | Our Situation |
|---|---|---|
| Skill format | agentskills.io spec (SKILL.md + evals/) | OpenClaw SKILL.md (similar but different spec) |
| Eval method | with/without comparison + LLM judge | No formal skill eval — we test manually |
| Artifact format | JSON/JSONL + HTML report | N/A |

**Applicable insights:**

1. **Skill lift measurement** — The with/without comparison is the right way to evaluate skills. We could adapt this for ClawHub skills: does installing skill X actually improve task Y? Currently we have no way to measure this.

2. **Tool-call assertions** — Deterministic assertions on tool calls (was the right tool called? with the right args?) are more reliable than LLM-judged text output. Useful pattern for [[cwc-long-running-agents]]'s default-fail-gate concept.

3. **Convergence signal** — Another data point for [[skill-distribution-convergence]]: the ecosystem is maturing from "ship skills" to "prove skills work." Eval tooling is the next layer.

## Gaps / Criticism

- Only 1 issue, no real community yet (5 days old)
- Assumes chat-completion interface — doesn't handle agentic loops where skills affect multi-turn behavior
- No cost tracking per eval (tokens counted but not priced)
- "Judge grades judge" problem: LLM judge reliability is the weakest link, especially for subtle skill differences
- No statistical significance testing — single run, no confidence intervals

## Status

New project (5 days). Watch for: community adoption, integration with agentskills.io registry, multi-turn eval support.
