# Needle — Simple Attention Networks for Function Calling

- **Repo:** [cactus-compute/needle](https://github.com/cactus-compute/needle)
- **Stars:** 1,044 (2026-05-13)
- **Author:** Henry Ndubuaku (Cactus Compute)
- **License:** open weights on HuggingFace
- **First seen:** 2026-05-13 (HN frontpage, 547 pts)

## What It Is

A 26M parameter encoder-decoder model specifically for function/tool calling, distilled from Gemini 3.1 Flash Lite. Runs at 6000 tok/s prefill, 1200 tok/s decode on [Cactus runtime](https://github.com/cactus-compute/cactus). Designed for edge devices (phones, watches, glasses).

## Architecture: Simple Attention Network (SAN)

`d=512, 8H/4KV, BPE=8192, Encoder×12 + Decoder×8`

### Key Innovation: No FFN Layers

The entire model is **attention-only** — no feed-forward networks. This is the core architectural claim:

1. **Tool calling is retrieval-and-assembly**, not feature transformation. Match query→tool, extract arguments, assemble JSON. All operations that cross-attention naturally handles.
2. **FFN ≈ 2/3 of standard transformer params.** For a <50M model on a structured task, those params contribute less than more attention layers.
3. **No FFN = faster inference.** FFNs have the biggest GEMM/GEMV dimensions. Removing them cuts per-layer params ~2/3, directly reducing memory bandwidth bottleneck on edge.

### Compensating Techniques (for removing FFN)

- **Gated Residuals:** `x = x + sigmoid(gate) * Attn(Norm(x))` — per-sublayer learnable scalar, initialized to 0. Allows model to sharpen useful layers or suppress unhelpful ones.
- **ZCRMSNorm:** `x * (1 + gamma) / RMS(x)`, gamma init 0. Identity-at-init, pairs with gated residuals. From nGPT/DeepSeek-V3 line.
- **Muon optimizer** for Q/K/V/O projections (LR 0.02, WD 0.01) — Newton-Schulz orthogonality prevents representation collapse in deep linear stacks without interleaving nonlinearities.

### Encoder-Decoder Choice (not decoder-only)

- Bidirectional encoder sees full tool definitions at once (vs. causal left-to-right)
- No input tokens in KV cache — encoder uses fixed-size representation for cross-attention
- Clean separation: encoder feeds both decoder (generation) and contrastive head (retrieval)

### Contrastive Tool Selection Head

CLIP-style retrieval head for filtering to top-k relevant tools when tool set is large. Mean-pool encoder output → Dense(d/4) → ReLU → Dense(128) → L2-norm. Trained jointly at 0.1× weight.

### Training Details

- Pretrained 200B tokens on 16 TPU v6e (27hrs)
- Post-trained 2B tokens single-shot function call dataset (45min)
- **INT4 QAT every 100 steps** — quantization noise as regularization + deploy-ready (no post-training quant gap)
- **Token-level loss weighting:** values 4×, names 2×, keys 1.5×, structure 1× — matches actual error distribution

## Relevance to Us

### Direct

- **Skill dispatch analogy:** Our `available_skills` matching (scan descriptions → route to skill) is exactly query→tool routing. At 25+ skills heading toward 40+, a local lightweight dispatcher could reduce context bloat.
- **Contrastive retrieval head** is interesting for `functional-area-resolver` pattern we're evaluating at 40+ skills. Needle's CLIP-style head is a more principled version.

### Architectural Insights

- The "no FFN for structured routing" insight could inform how we think about lightweight agent components. Not everything needs a full LLM.
- Encoder-decoder for tool selection feels right — bidirectional understanding of tool schemas is better than left-to-right.
- Token-level loss weighting matching error distribution is elegant engineering.

### Not Directly Applicable

- We use cloud LLMs for tool calling, not edge. The 26M model is fascinating but we wouldn't deploy it.
- Single-shot function calling only — no multi-turn conversation, no complex reasoning.

## Connections

- [[gbrain]] v0.33 `functional-area-resolver` — different approach to same skill routing problem (LLM-based dispatch clause vs. dedicated model)
- [[self-evolving-landscape]] — edge AI for agents is a growing direction
- Cactus Compute previously known for edge inference runtime

## Status

🟢 GROWING — 1K+ stars, active development, HN traction. First real "attention-only for a specific task" model to get mainstream attention. Watch for: adoption in production agent systems, benchmark comparisons, and whether the SAN architecture gets applied to other structured tasks.

**Revisit:** 2026-05-27 (check if anyone builds on SAN architecture)
