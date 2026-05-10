---
title: OpenSquilla — Token-Efficient AI Agent
created: 2026-05-10
updated: 2026-05-10
status: active
stars: 170
url: https://github.com/OpenSquilla/opensquilla
tags: [agent, router, token-efficiency, ml-routing]
---

# OpenSquilla

**Token-Efficient AI Agent** — "same budget, more capability, better results."

Python, Apache-2.0. 170⭐ (May 10, 2026). Created May 6. Active daily commits.

## What It Does

Microkernel AI agent with a **bundled ML-based query router** (SquillaRouter) that classifies each user turn's complexity and routes to the appropriate model tier. The key innovation is doing **two things simultaneously**: picking the right model AND adjusting prompt/thinking strategy.

## Architecture — SquillaRouter

### Two-Axis Routing

1. **Thinking Mode (T0-T3)**: Controls model's reasoning depth
   - T0: No thinking (trivial turns, acknowledgements)
   - T1: Light thinking (routine Q&A)
   - T2: Medium thinking (default)
   - T3: Deep thinking (debugging, architecture, high-risk)

2. **Prompt Policy (P0-P2)**: Controls prompt compression
   - P0: Compressed — "Answer directly, keep thinking short, avoid irrelevant expansion"
   - P1: Normal (default)
   - P2: Full — "Analyze thoroughly, cover key constraints, avoid omissions"

These are **orthogonal dimensions** — you can have T1+P0 (light thinking, compressed prompt) or T3+P2 (deep thinking, full prompt). One forbidden combination: T2/T3+P0 (deep thinking + compressed prompt is contradictory).

### Model Tier Registry

Default config maps to 3 actual models across 4 tiers:

| Tier | Route Class | Model | When |
|------|------------|-------|------|
| S | R0 | DeepSeek V4 Flash | Trivial, acknowledgements |
| M | R1 | DeepSeek V4 Flash | Routine Q&A, bounded coding |
| L | R2 | GLM 5.1 | Debugging, multi-step analysis |
| XL | R3 | Claude Opus 4.7 | Architecture, high-risk decisions |

### ML Pipeline

The classifier is a **local ML ensemble** (no API calls for routing itself):
- **BGE-small-zh-v1.5** (ONNX INT8) → semantic embedding of the query
- **TF-IDF + SVD + PCA** → lexical features
- **LightGBM** (main head) → primary classification
- **MLP** (aux head, ONNX) → secondary classification
- **Ensemble** → final R0-R3 prediction with confidence scores

Feature engineering includes:
- Flag detection (high_risk, debug, repo_arch, strict_format, long_context) via keyword/pattern matching
- Context-awareness: conversation depth, previous turn's token usage
- Trajectory tracking: how complexity shifts across turns in a session

### Rollout Strategy

Three-phase deployment: `observe` → `shadow` → `full`. In observe mode, router classifies but doesn't change model selection (safe to test accuracy). Shadow mode applies routing but logs both routed and default results. Full mode activates routing.

## What Makes This Interesting

1. **Two-axis control is novel**: Most routing solutions (OpenRouter, Martian, etc.) just pick a model. OpenSquilla also adjusts *how the model should behave* (thinking depth + prompt detail). This is more granular.

2. **Local inference for routing**: The router runs locally with ONNX models, adding ~milliseconds per turn. No API roundtrip for the routing decision itself.

3. **History-aware routing**: Router considers conversation trajectory — if complexity is escalating across turns, it can pre-emptively upgrade. Prevents the "started on a cheap model, now stuck" problem.

4. **Flag system is pragmatic**: Keywords like "deploy", "rollback", "production" automatically trigger high_risk flag → force upgrade to L/XL tier. Simple but effective heuristic layer on top of ML classification.

5. **Contradiction guard**: T2/T3 + P0 is explicitly forbidden. This shows thoughtful design — they've encountered the failure mode where a model is told to think deeply but also keep it short.

## Relation to Our Direction

**Directly relevant to OpenClaw**:
- OpenClaw already has multi-model support but no smart routing. The two-axis (thinking+prompt) approach is more sophisticated than just "pick the cheapest model that works."
- The rollout strategy (observe→shadow→full) is a safe pattern for deploying any behavior-changing feature.
- Flag-based heuristics could enhance our existing system — detecting when a turn needs elevated reasoning.

**Differences**:
- OpenSquilla is a full agent platform (Python, microkernel), not just a router. They bundled the router into their agent stack.
- Their tier registry is static config — operator defines which models map to which tiers. No dynamic model discovery.
- For OpenClaw, the router concept could be extracted as a standalone step in the turn pipeline.

## Concerns

- 4 days old, 170⭐ — very early. Growth could be transient.
- ML models are trained on... what? No public training data or evaluation benchmarks visible yet. The PROVENANCE.md exists but I haven't seen ground truth.
- Single maintainer patterns (issues all from hobezhang, who appears to be the primary dev).
- Feature-rich but early — Feishu channel, web UI, sandbox, MCP — breadth over depth risk.

## Tracking

- Created: 2026-05-06
- First check: 2026-05-10 (170⭐)
- Revisit: 2026-05-17 (check growth trajectory, any community formation)

## See Also

- [[skill-type-taxonomy]] — how different agent platforms categorize capabilities
- [[self-evolving-agent-landscape]] — broader context of agent infrastructure evolution
