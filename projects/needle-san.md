---
title: "Needle — Simple Attention Network for Tool Calling"
status: active
created: 2026-05-14
updated: 2026-05-14
stars: 1372
repo: cactus-compute/needle
tags: [architecture, tool-calling, distillation, on-device, small-model]
last_verified: 2026-05-14
---

# Needle — Simple Attention Network (SAN)

> 26M parameter model distilled from Gemini 3.1 Flash Lite for single-shot function/tool calling.
> MIT license, weights open on HuggingFace.

## Why It Matters

Proves that tool calling — the core capability agents need — can be distilled into a tiny model (26M params, ~15MB INT4) that runs on phones, watches, glasses at 6000 tok/s prefill, 1200 tok/s decode. Beats FunctionGemma-270m, Qwen-0.6B, Granite-350m, LFM2.5-350m on single-shot function call benchmarks.

**Implication for us**: On-device tool routing is now viable. A local Needle model could pre-filter/route tool calls before hitting a full LLM, saving tokens and latency.

## Architecture: Simple Attention Network (SAN)

Key insight: **MLPs can be completely dropped from transformers when the task relies on external knowledge source.** Tool calling = retrieval-and-assembly (match query→tool, extract args, assemble JSON) — all alignment/copying ops that cross-attention handles natively.

### Specs
- d=512, 8 heads, 4 KV heads, BPE=8192
- **Encoder**: 12 layers, self-attention only (GQA + RoPE), **no FFN**
- **Decoder**: 8 layers, masked self-attention + cross-attention to encoder
- Shared embedding between encoder/decoder
- Tied output projection

### Novel Components

1. **No FFN in encoder** — saves ~2/3 parameters per layer. Softmax IS the nonlinearity. For routing/alignment tasks, attention alone is sufficient. FFN does per-position feature transformation, which tool-calling doesn't need.

2. **Gated Residuals** — `x = x + sigmoid(gate) * Attn(Norm(x))`, gate initialized to 0 (so sigmoid(0)=0.5, starts at half-strength). Without FFN to do nonlinear rewriting, pure additive residuals are too limiting. Gated lets model learn to sharpen useful layers (g→1) or suppress (g→0).

3. **ZCRMSNorm** — `x * (1 + gamma) / RMS(x)`, gamma initialized to 0. Identity-at-init. From nGPT/DeepSeek-V3 line. Pairs with gated residuals for "start as damped identity" training.

4. **Contrastive Tool Selection Head** — CLIP-style head for retrieving relevant tools before generation. Encoder output → mean pool → Dense(d/4) → ReLU → Dense(128) → L2-normalize. Trained jointly with CE loss at 0.1x weight. Enables top-k tool filtering from large tool sets.

5. **Muon Optimizer for attention-only** — Dual optimizer: Muon (Q/K/V/O projections, LR 0.02) + AdamW (everything else, LR 3e-4). Muon enforces orthogonality via Newton-Schulz, preventing representation collapse when stacking many linear layers without FFN.

6. **INT4 QAT as Regularization** — Fake quantization every 100 steps with STE. Acts as weight noise regularization for small models. Deploy-ready (no post-training quantization gap).

7. **Token-Level Loss Weighting** — argument values 4.0x, tool names 2.0x, argument keys 1.5x, JSON structure 1.0x. Matches the actual error distribution (values > names > keys > structure).

### Training
- Pretrained on 16 TPU v6e for 200B tokens (27hrs)
- Post-trained on 2B tokens of single-shot function call dataset (45min)
- Data synthesized via Gemini (they ship the generation tooling)

## Encoder-Decoder vs Decoder-Only (for tool calling)

Their argument for enc-dec:
1. **Bidirectional encoding** — tools are structured objects, bidirectional sees full definition at once vs causal's left-to-right
2. **No input tokens in KV cache** — encoder output is fixed-size cross-attention, not re-attending full input at each generation step
3. **Clean multi-head design** — encoder feeds both decoder (generation) and contrastive head (retrieval)

## Patterns Worth Borrowing

- **Task-specific architecture** — not everything needs a general-purpose decoder-only model. Tool calling is structured enough for specialized architecture.
- **Contrastive tool selection** — CLIP-style pre-filtering of tools is elegant. Could be applied to skill selection (our ~25 skills → semantic match before loading).
- **Loss weighting by error distribution** — simple but effective. Weight the tokens that actually cause errors, not uniform loss.
- **"No FFN" principle** — when the task is routing/alignment, attention alone suffices. Worth remembering for any structured-output task.

## Links
- Repo: https://github.com/cactus-compute/needle
- Weights: https://huggingface.co/Cactus-Compute/needle
- Runtime: https://github.com/cactus-compute/cactus
- Related: [[tool-calling]], [[distillation]], [[on-device-inference]]
