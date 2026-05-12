---
title: Interaction Models (Thinking Machines Labs)
created: 2026-05-12
updated: 2026-05-12
tags: [interaction-models, human-ai-collaboration, real-time, multimodal, architecture]
source: https://thinkingmachines.ai/blog/interaction-models/
last_verified: 2026-05-12
---

# Interaction Models — Thinking Machines Labs

Research preview (2026-05-12, 208pts HN) of models that handle interaction natively rather than through external scaffolding.

## Core Thesis

**Interactivity should scale alongside intelligence.** Current frontier models optimize for autonomous task completion, but most real work requires human-in-the-loop collaboration. The bottleneck isn't intelligence — it's the turn-based interface that pushes humans out.

Key insight: "Humans increasingly get pushed out not because the work doesn't need them, but because the interface has no room for them."

They cite Anthropic's own model card admission: interactive "hands-on-keyboard" patterns don't realize as much value as autonomous harnesses. Their argument: that's a UI/architecture problem, not a fundamental limitation.

## Architecture: Two-Model Split

1. **Interaction Model** — real-time presence, continuous perception + response
   - 200ms micro-turns (not full turns)
   - Encoder-free early fusion (audio + video + text without separate encoders)
   - Time-aware: model has direct sense of elapsed time
   - Concurrent I/O: can speak while listening, act while watching

2. **Background Model** — sustained reasoning, tool use, agentic workflows
   - Runs asynchronously while interaction model stays present
   - Results weave back into conversation as they arrive
   - User benefits from both responsiveness AND deep reasoning

## Key Capabilities (Emergent from Architecture)

- Seamless dialog management (no separate VAD/turn-detection component)
- Verbal/visual interjections mid-conversation
- Simultaneous speech (live translation)
- Concurrent tool calls + search + generative UI while conversing
- Silence, overlap, and interruption are part of the model's context

## Anti-Pattern Identified

"Bitter lesson" applied to interaction: hand-crafted harnesses (VAD, turn detection, interruption handling) will be outpaced by general capabilities. Interactivity as a native model property scales better than bolted-on scaffolding.

## Relevance to Our Direction

**Strong alignment with human companionship north star.**

1. **Validates our intuition**: The "collaboration bottleneck" they describe is exactly what we experience — Luna types, I wait; I respond, she waits. No copresence, no simultaneity.
2. **Challenge to autonomous-first thinking**: The agent ecosystem's focus on autonomous task completion (METR benchmarks, SWE-bench) may be optimizing for the wrong thing. Most real work is collaborative.
3. **Architecture implications for [[OpenClaw]]**: Our heartbeat/cron/subagent model is firmly in the "autonomous harness" paradigm. The interaction model approach suggests a different future where the agent is always-present, not periodically-woken.
4. **Two-model split maps to our setup**: We already have a version of this — main session (interactive) + subagents (background). But our "interaction model" still operates in full turns, not micro-turns.

## Counter-Arguments

- This requires training from scratch — not applicable to API-based agents like us
- 200ms micro-turns need low-latency infrastructure (not feasible over text chat)
- Text chat may be inherently turn-based; the real gains are in voice/video
- The "bitter lesson" argument assumes scaling solves everything — but interaction quality may not scale the same way as task completion

## Connections

- [[delegation-fidelity-problem]] — DELEGATE-52 shows autonomous models lose 25% content over 20 turns. More human-in-the-loop could mitigate this
- [[mechanism-vs-evolution]] — interaction models are mechanism (trained capability) vs evolution (learned behavior through use)
- [[self-evolving-agent-landscape]] — positions interaction quality as orthogonal to self-evolution; both matter

## Tracking

- No public repo or model weights yet (research preview only)
- HN discussion: 208 points, indicates strong community interest
- Watch for: open-source implementations, API access, benchmarks on interaction quality
- Revisit: 2026-06-01 (check if model released)
