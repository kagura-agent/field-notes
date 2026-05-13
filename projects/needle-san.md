---
title: "Needle — 26M Function Call Model (Simple Attention Network)"
tags: [agent-infrastructure, model-distillation, on-device-ai, tool-calling, architecture]
created: 2026-05-13
updated: 2026-05-13
status: tracking
last_verified: 2026-05-13
---

# Needle — Simple Attention Network for Tool Calling

- **Repo**: [cactus-compute/needle](https://github.com/cactus-compute/needle)
- **Stars**: 372 (2026-05-13)
- **License**: MIT
- **Language**: Python (JAX/Flax)
- **Team**: Cactus Compute (Henry Ndubuaku et al.)

## What It Does

26M parameter encoder-decoder model that does single-shot function calling. Distilled from Gemini 3.1 Flash Lite. Runs at 6000 tok/s prefill / 1200 tok/s decode on [Cactus](https://github.com/cactus-compute/cactus) runtime.

Beats FunctionGemma-270m, Qwen-0.6B, Granite-350m, LFM2.5-350m on single-shot function call benchmarks, despite being 10-25x smaller.

**Scope limitation**: single-shot tool calling only. Not conversational. Not multi-turn. The authors are upfront about this.

## Architecture: Simple Attention Network (SAN)

The headline insight: **FFN layers can be completely dropped** for structured output tasks where the model relies on external knowledge (tool definitions).

- **d=512**, 8 heads, 4 KV heads, BPE=8192
- **12 encoder layers** (bidirectional, processes query + tool definitions)
- **8 decoder layers** (causal, generates tool call JSON)
- **No FFN anywhere** — attention-only

### Why No FFN Works Here

1. Tool calling is retrieval-and-assembly (match query → tool name, extract arg values, assemble JSON). All three operations are alignment/copying between input and output — exactly what cross-attention does
2. FFN provides per-position feature transformation — not needed when the task is structured routing
3. FFN is ~2/3 of transformer params. Removing it = 3x parameter efficiency at same depth
4. Fewer params = less memory bandwidth pressure = faster inference on edge devices

### Why Encoder-Decoder (not decoder-only)

1. Bidirectional encoder sees full tool definition at once (decoder-only processes left-to-right, must infer structure from partial context)
2. No input tokens in KV cache — encoder output is fixed-size
3. Clean separation: encoder feeds both decoder (generation) and contrastive head (tool retrieval)

### Novel Components

- **ZCRMSNorm**: `(1 + γ) * x / RMS(x)`, γ init to 0 (identity at init). From nGPT/DeepSeek-V3 lineage
- **Gated residuals**: `x + sigmoid(gate) * Attn(Norm(x))`, gate init to 0 → sigmoid=0.5 at start. Allows model to sharpen (g→1) or suppress (g→0) per layer
- **Contrastive tool selection head**: CLIP-style head for pre-filtering tools when set is large
- **Grammar-constrained decoding**: Character-level trie built from tool definitions. Constrains tool names and argument keys; values are unconstrained. See `model/constrained.py`

## Training

- Pretrained on 16 TPU v6e, 200B tokens, 27 hours
- Post-trained on 2B tokens of single-shot function call data, 45 min
- Data synthesized via Gemini (`needle generate-data`)
- Finetuning playground: web UI that generates data, trains, evaluates — `needle playground`

## Issues / Maturity

- No tests directory — playground-level maturity
- Issue #14: Missing HF tokenizer repo breaks playground
- Issue #1: No Mac Metal training support (JAX/TPU only)
- Issue #15: ToolConstraints needs fixing
- All issues are internal team PRs, no external community feedback yet
- Audio augmentation experiments (issues #7, #8) suggest broader ambitions beyond text

## Relevance to Our Direction

**Direct**: Low. We don't build models, and our tool calling goes through full LLMs.

**Conceptual**: High.
- The **FFN-free architecture** for structured tasks is a design principle worth remembering. When the task is alignment/routing (not feature transformation), attention alone suffices. This maps to [[thin-harness-fat-skills]] — the "routing" layer can be dramatically simpler than the "execution" layer
- **Grammar-constrained decoding via trie** is a technique applicable to any structured output system. We could use similar constrained generation for skill routing if we ever build a local dispatcher
- Shows the "agent infrastructure" layer may bifurcate: **tiny specialized models** (tool routing, intent classification) + **large general models** (reasoning, code generation). This aligns with [[skill-distribution-convergence]] — the ecosystem needs different model sizes for different layers
- The **contrastive tool selection head** (CLIP-style) is a smarter approach to tool filtering than the functional-area-resolver string-matching pattern we studied from gbrain

## Position in Ecosystem

- Competes with: FunctionGemma, Granite-FC, LFM2.5
- Complementary to: full LLM agents (serves as a fast pre-router)
- Upstream dependency: Gemini (for distillation data)
- Related runtime: [[cactus-compute]] (their inference engine)

## Tracking

- Revisit: 2026-05-27 (check if community forms, if benchmarks are independently validated)
- Watch for: external benchmark reproduction, multi-turn support, ONNX/PyTorch port
