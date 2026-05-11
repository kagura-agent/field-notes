# Sentra RAG Failure Modes

**Repo**: [niashwin/sentra-rag-failure-modes](https://github.com/niashwin/sentra-rag-failure-modes)
**Stars**: 2 (2026-05-11, brand new)
**License**: MIT | **Language**: Python 3.11
**Depth**: 🔬 deep-read | **Last Updated**: 2026-05-11
**Paper**: "The Geometry of Failure: Empirical Failure Modes of gemini-embedding-2 and What They Imply About RAG as Memory" (21 pages)

## What

Rigorous empirical study of 8 failure modes in embedding-based retrieval, tested on Google's `gemini-embedding-2` (May 2026 GA multimodal model) and OpenAI's `text-embedding-3-large`. Key thesis: **RAG is not memory, it's a similarity oracle** with structural failure modes inherent to pure-cosine retrieval.

Reproducible in ~6 min / ~$2 API costs.

## Core Findings

### Geometric Reality
- gemini-embedding-2 uses only **0.6–2.5%** of its 3,072 nominal dimensions
- Text participation ratio: 75; image: 38; audio: 18; video: 23
- Cross-modal joint manifold collapses to participation ratio 17.9 (smaller than any individual modality)
- This predicts and explains every failure mode below

### The 8 Failure Modes (F1–F8)

| # | Mode | What breaks | Headline number | Severity |
|---|---|---|---|---|
| F1 | Negation insensitivity | "safe" ≈ "not safe" | 65% at cos ≥ 0.85 | 🔴 Critical |
| F2 | Numeric/entity confusion | "$4.2M" ≈ "$42M" | 90% indistinguishable | 🔴 Critical |
| F3 | Role-swap blindness | "A acquired B" ≈ "B acquired A" | 30% inverted | 🟡 Moderate |
| F4 | Hubness | Some vectors are "popular" regardless of query | max 4.1× expected | 🟡 Moderate |
| F5 | Threshold instability | Cosine baseline varies wildly | 0.587 (Gemini) vs 0.081 (OpenAI) | 🟡 Moderate |
| F6 | Ebbinghaus forgetting | Old content gets buried as corpus grows | b = 0.467 (matches Ebbinghaus law) | 🟡 Moderate |
| F7 | DRM false recall | Associative lures rank high | +0.110–0.194 lure-control sep | 🟡 Moderate |
| F8 | Cross-modal leakage | Text→image query lands on audio | 100% top-1 leaked | 🔴 Critical |

### Mitigation Playbook (from supplementary)

**F1 Negation** → NLI verification, cross-encoder re-ranker, hybrid BM25+dense, contrastive fine-tuning. Residual: 2–5%.

**F2 Numeric** → Structured side-index (SQL for numbers/dates/entities), hybrid BM25, LLM verification. Residual: <5%.

**F3 Role-swap** → SRL/dependency parse, cross-encoder re-ranker, contrastive training. Residual: 5–10%.

**F4 Hubness** → MMR (λ=0.5), k-occurrence suppression, dimensional whitening. Residual: 1.5–2×.

**F5 Threshold** → Use rank-based (top-k), not threshold-based retrieval. Per-query calibration. Basically a non-issue with top-k.

**F6 Forgetting** → Hierarchical retrieval (cluster first), deduplication, chunk-level diversification, time-decay. With cluster size 50: ~70% retention vs 12% raw at N=500.

**F7 DRM** → Same family as F4+F1. No fully clean solution—associative structure is also what makes paraphrase work.

**F8 Cross-modal** → Per-modality indexes (dominant production pattern). Residual: ≤1%.

### Key Insight
> None of these mitigations drive failure to zero. Every mode is bounded below by the effective rank of the embedding space. Mitigations work by introducing *new score families* (BM25, NLI, SRL, structured side-indexes, re-rankers) whose failure modes are partially independent. The residual is the joint failure rate of independent score families.

## Applicable to Us

### Direct Impact
1. **Our wiki/search.sh hybrid search** (built 05-11) already addresses F1, F2 via BM25+cosine combo. Validated empirically: numeric queries that returned 0 results now surface correctly.
2. **F5 is why we should never threshold-gate** our memex searches. Always use top-k.
3. **F6 confirms temporal decay value** — as our wiki grows, older notes will get buried. The Ebbinghaus exponent (b≈0.5) gives us a quantitative model for decay.

### Framework for Evaluating Any RAG System
When evaluating memory/retrieval projects (krusch, mnem, etc.), check:
- Does it do hybrid retrieval? (addresses F1, F2, F3)
- Does it have structured side-indexes? (addresses F2)
- Does it use re-rankers? (addresses F1, F3)
- Does it handle corpus growth? (addresses F6)
- If multimodal, does it separate modality indexes? (addresses F8)

### What We Don't Need
- F7 (DRM false recall) and F8 (cross-modal leakage) aren't relevant to our text-only system
- F4 (hubness) is low-priority at our corpus size (<1000 items)
- Contrastive fine-tuning is overkill for our scale

## Connections

- [[krusch-context-mcp]] — cites this report; Krusch implements some countermeasures (hybrid retrieval, temporal decay). Now we have the full taxonomy to evaluate Krusch's coverage
- [[retrieval-is-the-bottleneck]] — Sentra provides the mathematical proof: bottleneck is bounded by embedding geometry, not fixable by scaling
- [[caveman]] — compression strategies interact with F2 (numeric information loss during compression)
- [[mnem]] — GraphRAG approach partially bypasses F1–F3 by using structured relationships, not just cosine

## Meta

- Very low stars (2) but high-quality academic work with reproducible code
- From Sentra (startup building "semantic file systems" to bypass these exact failure modes)
- The probe corpora (supplementary) are useful as test fixtures for any retrieval system evaluation
- Paper builds on two prior Sentra reports: "Geometry of Forgetting" and "Price of Meaning" (2026)
