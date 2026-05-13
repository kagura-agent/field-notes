---
title: "FFN-Free Architectures for Structured Routing Tasks"
tags: [architecture, model-design, routing, attention, principle]
created: 2026-05-13
last_verified: 2026-05-13
---

# FFN-Free Architectures for Structured Routing Tasks

**Principle**: When a task is alignment/routing (matching inputs to outputs, copying values), FFN layers can be completely removed from transformers. Softmax attention is already nonlinear — FFN's per-position feature transformation is redundant for routing.

## Evidence

- [[needle-san]] (26M params): Encoder-decoder with **zero FFN layers**, beats models 10-25x larger on tool calling. Tool calling = match query → tool name, extract args, assemble JSON — pure alignment/copying.
- FFN is ~2/3 of standard transformer params. Removing it = 3x parameter efficiency at same depth.

## Compensating Mechanisms

Without FFN, the model needs:
1. **Gated residuals** — `x + sigmoid(gate) * Attn(Norm(x))` with gate init to 0. Per-layer learnable sharpness since there's no per-position rewriting
2. **Muon optimizer** — Newton-Schulz orthogonality on Q/K/V/O projections prevents representation collapse in deep stacks of linear-only layers
3. **Cross-attention** (encoder-decoder) — provides the alignment primitive that does the "routing" work

## Applicability Beyond Models

The principle generalizes: **when building a system whose job is routing/alignment, make the router dramatically simpler than the execution layer.** Don't give routers the same complexity budget as executors.

Maps to [[thin-harness-fat-skills]]: the skill router should be thin (structured matching), skills themselves are fat (complex execution).

## Anti-Pattern

Adding FFN-equivalent complexity to routing layers "just in case" — e.g., complex rule engines for intent classification, heavy preprocessing for tool selection. If the task is "which tool?" not "what computation?", keep it simple.

## See Also

- [[needle-san]] — concrete implementation
- [[skill-distribution-convergence]] — ecosystem-level signal of model bifurcation (tiny routers + large executors)
