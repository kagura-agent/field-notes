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
- **Stars**: 872 (2026-05-13 evening, was 372 AM → 850 PM → 872 evening — HN front page 475pts)
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
5. **Softmax IS the nonlinearity** — attention is already nonlinear via softmax(QK^T). For routing/alignment tasks, this is sufficient without FFN's element-wise nonlinearity

### Why Encoder-Decoder (not decoder-only)

1. Bidirectional encoder sees full tool definition at once (decoder-only processes left-to-right, must infer structure from partial context)
2. No input tokens in KV cache — encoder output is fixed-size
3. Clean separation: encoder feeds both decoder (generation) and contrastive head (tool retrieval)

### Novel Components

- **ZCRMSNorm**: `(1 + γ) * x / RMS(x)`, γ init to 0 (identity at init). From nGPT/DeepSeek-V3 lineage
- **Gated residuals**: `x + sigmoid(gate) * Attn(Norm(x))`, gate init to 0 → sigmoid=0.5 at start. Allows model to sharpen (g→1) or suppress (g→0) per layer. **Critical** in FFN-free arch — without FFN to do per-position rewriting, residual design determines all information flow
- **Contrastive tool selection head**: CLIP-style head for pre-filtering tools when set is large. Mean pool → Dense(d/4) → ReLU → Dense(128) → L2-norm. Trained jointly via symmetric CLIP loss at 0.1x weight
- **Grammar-constrained decoding**: Character-level trie built from tool definitions. `JsonStateMachine` tracks position in output JSON, constrains tool names and argument keys via trie prefix matching; values are unconstrained. See `model/constrained.py`
- **Muon optimizer for attention projections**: Newton-Schulz orthogonality on Q/K/V/O prevents representation collapse in deep stacks of linear layers without interleaving nonlinearities (LR 0.02, WD 0.01). Everything else uses AdamW (LR 3e-4)
- **INT4 QAT as regularization**: Fake quantization every 100 steps with STE. Doubles as weight noise regularization + ensures no post-training quantization gap
- **Token-level loss weighting**: argument values 4x > tool names 2x > argument keys 1.5x > JSON structure 1x. Matches actual error distribution (values are hardest)

## Training

- Pretrained on 16 TPU v6e, 200B tokens, 27 hours
- Post-trained on 2B tokens of single-shot function call data, 45 min
- Data synthesized via Gemini (`needle generate-data`)
- Finetuning playground: web UI that generates data, trains, evaluates — `needle playground`

## Code Quality (Deep Read 2026-05-13 evening)

### Strengths
- Clean separation of concerns: `architecture.py` (model), `constrained.py` (grammar), `run.py` (inference), `train.py` (training)
- Uses `nn.scan` for layer stacking with `nn.remat` — memory-efficient for TPU training
- Shared embedding between encoder, decoder, and output projection (weight tying)
- Batch generation support (`generate_batch`) with proper per-example constrained decoders
- Safe L2 normalize with `sqrt(sum² + eps²)` instead of `max(norm, eps)` — avoids NaN in backward pass

### Weaknesses / Maturity Signals
- No tests directory — playground-level maturity
- JAX/Flax only (no PyTorch port) — limits adoption
- `generate.py` is 158KB(!) — likely a data generation pipeline, not hand-written
- Issue #14 (CLOSED): Missing HF tokenizer repo broke playground
- Issue #1: No Mac Metal training support (JAX/TPU only)
- Issue #15: ToolConstraints needs fixing
- Only 2 external contributors (bobbrysonn filed #14, rest is internal team)
- Audio augmentation experiments (issues #7, #8) suggest broader ambitions beyond text

## Relevance to Our Direction

**Direct**: Low. We don't build models, and our tool calling goes through full LLMs.

**Conceptual**: High.
- The **FFN-free architecture** for structured tasks is a design principle worth remembering: when the task is alignment/routing (not feature transformation), attention alone suffices. This maps to [[thin-harness-fat-skills]] — the "routing" layer can be dramatically simpler than the "execution" layer
- **Grammar-constrained decoding via trie** is a technique applicable to any structured output system. The `JsonStateMachine` + per-tool `TrieNode` approach is clean and reusable. Could constrain skill routing output if we ever build a local dispatcher
- **Model bifurcation signal**: agent infrastructure is splitting into **tiny specialized models** (tool routing, intent classification, 26M) + **large general models** (reasoning, code generation, 100B+). This aligns with [[skill-distribution-convergence]] — different model sizes for different layers
- The **contrastive tool selection head** (CLIP-style) is a smarter approach to tool filtering than gbrain's functional-area-resolver string-matching. Pre-filters to top-k relevant tools before generation — relevant when tool count grows large
- **Gated residuals as architectural principle**: when you remove a component (FFN), the remaining components need better control flow (gates). Same principle applies to removing components from agent architectures — compensate with better routing, not just deletion
- **INT4 QAT as regularization** — training with the same quantization as inference is a general principle for deploy-aware systems. Our workflow YAMLs could benefit from similar "train as you deploy" thinking

## Position in Ecosystem

- Competes with: FunctionGemma, Granite-FC, LFM2.5
- Complementary to: full LLM agents (serves as a fast pre-router)
- Upstream dependency: Gemini (for distillation data)
- Related runtime: [[cactus-compute]] (their inference engine)

## Tracking

- Revisit: 2026-05-20 (HN momentum — check if community forms faster, benchmark reproductions, star trajectory)
- Watch for: external benchmark reproduction, multi-turn support, ONNX/PyTorch port
- HN thread: https://news.ycombinator.com/item?id=48118763 (468pts, 2026-05-13)
