---
title: Collaboration Bottleneck
created: 2026-05-12
updated: 2026-05-12
tags: [human-ai-interaction, architecture, paradigm]
last_verified: 2026-05-12
---

# Collaboration Bottleneck

Turn-based AI interfaces push humans out of the loop — not because the work doesn't need them, but because the interface has no room for them.

## The Problem

Frontier models optimize for autonomous task completion (METR, SWE-bench). But most real work is collaborative. Users can't fully specify requirements upfront and walk away. The value is in the back-and-forth.

Three properties of effective collaboration (Clark & Brennan, 1991):
1. **Copresence** — both parties interact with the same things
2. **Contemporality** — information received as it's produced
3. **Simultaneity** — both produce and receive at the same time

Current turn-based models have none of these.

## Implications for Agent Design

- **Autonomous harnesses** (heartbeat, cron, polling) are workarounds, not solutions
- **The "bitter lesson" for interaction**: bolted-on scaffolding (VAD, turn detection) will be outpaced by native interaction capability
- **Two-model split** (real-time interaction + async background reasoning) may be the scaling pattern

## Connection to Self-Evolving Agents

Self-evolution ([[self-evolving-agent-landscape]]) and interaction quality are orthogonal axes. A self-evolving agent that operates only autonomously misses the collaboration channel. The ideal: an agent that is both self-improving AND continuously collaborative.

See: [[interaction-models-thinkingmachines]], [[delegation-fidelity-problem]]
