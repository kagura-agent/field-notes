---
title: LLM Decision Layer Pattern
tags: [architecture, agent-design, pattern]
created: 2026-05-07
---

# LLM Decision Layer Pattern

## Core Idea

Separate **what to do** (LLM decides, expensive, non-deterministic) from **when/how to execute** (deterministic state machine, cheap, predictable). The LLM is a decision oracle called at key moments, not a continuous controller.

## Pattern Structure

```
State (deterministic) → LLM (structured JSON decision) → Execution (deterministic)
```

The LLM never directly produces user-facing output in the decision layer. It returns structured intent (`reply | ignore | react | delay`), which the execution layer interprets with timing, formatting, and delivery rules.

## Examples

| Project | Decision Layer | Deterministic Substrate |
|---|---|---|
| [[girl-agent]] | behavior-tick returns JSON intent | presence patterns, hormones, conflict cold-until |
| OpenClaw heartbeat | "should I act?" based on state | cron timing, channel routing, quiet hours |
| [[agentic-stack]] trust-console | trust score gates | adapter routing, file-based state |

## Why It Works

1. **Cost control** — LLM called once per event (not streaming), cheap structured output
2. **Predictability** — deterministic layers guarantee bounds (never reply at 3 AM, always wait X seconds in cold stage)
3. **Debuggability** — state is inspectable JSON, decisions are logged
4. **Composability** — swap LLM provider without changing behavior substrate

## Anti-pattern

Letting the LLM control timing AND content AND delivery in a single free-form response. Results in:
- Inconsistent timing (sometimes instant, sometimes never)
- Unpredictable emotional tone
- No way to enforce behavioral constraints without prompt-stuffing

## Relation to Other Concepts

- [[mechanism-vs-evolution]]: This pattern is firmly "mechanism" — deterministic rules dominate
- [[thin-harness-fat-skills]]: The decision layer IS the thin harness; skills/modules are the fat substrate
- [[nudge-over-workflow]]: Nudges are lightweight decision-layer queries ("should I X?")

## Application for Us

Our heartbeat is partially this pattern, but we lack:
1. **Structured decision output** — heartbeat actions are free-form, not constrained JSON
2. **Emotional substrate** — no deterministic emotional state affecting response style
3. **Proactive agenda** — no "mental note" extraction → timed follow-up pipeline

These are design opportunities, not bugs to fix immediately.
