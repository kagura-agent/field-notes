# mnem — Git for Knowledge Graphs

> Uranid/mnem | ⭐17 (2026-05-04) | Rust | Apache-2.0
> "Content-addressed knowledge graph with hybrid GraphRAG retrieval, versioned commits, and deterministic ingest."

## Core Architecture

### Content-Addressed Objects (DAG-CBOR + BLAKE3)
- Every object (Node, Edge, Commit, View) has a CID derived from canonical DAG-CBOR encoding + BLAKE3 hash
- Same content → same CID on any machine. Deduplication is free.
- Embeddings stored in **per-commit sidecar** (not on the Node), so different embedders don't change NodeCid
- Forward-compat: unknown fields land in `extra: BTreeMap` and survive round-trip

### Prolly Tree Data Structure
- Core merge primitive borrowed from Dolt/IPFS world
- Enables deterministic 3-way merge: two agents writing independently can reconcile without "last write wins"
- Trees store nodes, edges, schema — all chunked and content-addressed

### Versioning Model (Git-like)
- Commits chain by parent CID; branches, merge, log, diff, blame
- Operations form a DAG (op-heads store)
- On open: if >1 op-head exists, transparently 3-way merges, converging to single head
- Merge is deterministic — concurrent readers produce byte-identical ops

### Hybrid Retrieval (3 Lanes + RRF)
1. **Vector** — HNSW over per-commit sidecar embeddings
2. **Sparse** — BM25 / SPLADE (feature-gated)
3. **Graph** — n-hop traversal over authored edges, PPR-scored
- Fused via Reciprocal Rank Fusion (k=60)
- Greedy token-budget packing in RRF rank order
- Returns `tokens_used`, `candidates_seen`, `dropped` — no silent truncation

### GraphRAG (LLM-free)
- Leiden community detection over adjacency index
- Extractive centroid+MMR summarization (no LLM, reuses embedder)
- Score calibration: per-query quantiles + distribution-shape labels for agent interpretation

### Ingest Pipeline (LLM-free, deterministic)
- Parsers: Markdown (GFM), plain text, PDF (pure-Rust), conversation exports
- Chunkers: Paragraph, Recursive (token-budgeted), Session (conversation)
- Entity extraction: rule-based (capitalized phrases) + optional Ollama NER
- Same bytes in → same CIDs out (auditable, reproducible)

## Crate Structure
```
mnem-core        — format types, codec, prolly trees, repo, retrieval (no IO, no tokio, WASM-clean)
mnem-backend-redb — embedded storage (redb key-value store)
mnem-ingest      — parse + chunk + extract pipeline
mnem-graphrag    — community detection + extractive summarization
mnem-embed-providers — ONNX MiniLM (bundled), Ollama, OpenAI, Cohere
mnem-cli         — CLI binary
mnem-mcp         — MCP server
mnem-http        — HTTP API
mnem-ann         — ANN/KNN edge computation
mnem-bench       — benchmark harness
```

## Benchmarks (vs MemPalace)

| Benchmark | Metric | MemPalace | mnem | Δ |
|-----------|--------|-----------|------|---|
| LongMemEval | R@5 | 0.966 | 0.966 | ±0 |
| LoCoMo | R@5 | 0.508 | **0.726** | +0.218 |
| ConvoMem | avg recall | 0.929 | **0.976** | +0.047 |
| MemBench simple | R@5 | 0.840 | **0.960** | +0.120 |

Reproducible: `bash benchmarks/harness/run_bench.sh` (30-50 min, 16-core box).

## Key Design Decisions & Tradeoffs

1. **Embeddings in sidecar, not on Node** — prevents nondeterministic embedding producers from perturbing NodeCid. Smart tradeoff: dedup is preserved even when switching embedders.
2. **WASM-clean core** — no tokio, no filesystem, no println. Same retrieval logic compiles to wasm32. This is unusually principled for a 17⭐ project.
3. **No LLM at ingest** — determinism trumps extraction quality. Optional Ollama NER is fallback-safe (fails to empty Vec, not error).
4. **Labels for multi-tenancy** — simple string namespace instead of complex permission model.
5. **Ed25519 signing** — commits are signed, enabling trust chains for federated scenarios.

## "Skills as Graphs, not Markdown"

mnem explicitly pitches itself as an alternative to flat SKILL.md files:
> "Today, agent skills live in flat .md files — downloaded, pasted into prompts, hand-edited, never queried. mnem promotes them to a versioned, queryable, mergeable graph."

This is a direct challenge to the OpenClaw/Claude Code skill model.

## Relevance to Us

### What mnem does better than our wiki/ approach
- **3-way merge for multi-agent writes** — our wiki uses git (which also merges), but mnem's object-level merge is more granular (node-level, not file-level)
- **Token-budget transparency** — we have no mechanism to report "I left stuff out because of context limits"
- **Hybrid retrieval** — memex does vector search only; mnem adds BM25 + graph traversal + RRF fusion
- **Deterministic replay** — same query same state = same result. Our memex search order isn't guaranteed.

### Why we probably won't adopt it
- 17 stars, single author — sustainability risk (same concern as mneme)
- Rust-only core, no JS bindings yet — can't easily integrate into OpenClaw (Node.js)
- Our wiki/ + memex approach is "good enough" and deeply integrated
- Graph model is heavier than markdown — higher barrier to human editing
- MCP server exists but doesn't solve the "skills in prompts" problem better than SKILL.md

### Ideas worth stealing
1. **Token-budget transparency in retrieval** — memex search should report how much was found vs returned
2. **Sidecar embeddings** — keeping vector data separate from content identity is elegant
3. **Deterministic ingest** — our wiki-lint could verify that same input produces same index
4. **Score calibration** — per-query quantiles to interpret "is 0.7 good or bad for this query?"
5. **Content-addressed dedup** — if we ever need to merge wiki branches, CID-based dedup would help

## Position in Agent Memory Ecosystem

```
                    Flat files          Structured          Graph-native
                    ─────────           ──────────          ────────────
Read-time evolve    mneme               mem0                mnem ←
Write-time govern   OpenClaw wiki       Letta               Graphiti
Append-only         daily logs          Engram              —
```

mnem occupies a unique position: **graph-native + versioned + deterministic + LLM-free ingest**. No other project combines all four. Closest competitor is Graphiti (graph-native but LLM-dependent, no versioning).

## Risks & Watch Items
- Single author, 17⭐ — may not sustain
- No remote protocol yet (docs say "next phase")
- Python bindings exist (`mnem-py` on PyPI) but JS/TS bindings absent
- Benchmark numbers are self-reported, need independent verification

## Verdict (2026-05-04)
Architecturally the most rigorous agent memory system in the ecosystem. The WASM-clean core, content-addressing, and deterministic properties are genuinely novel in combination. However, adoption barrier is high (Rust, no JS), community is nascent, and our current approach works. **Track**, don't adopt. Revisit 05-11.

Links: [[mneme]], [[memory-reconsolidation]], [[agent-memory-landscape-202603]], [[self-evolving-agent-landscape]], [[skills-as-packages]], [[deterministic-vs-llm-compression]], [[confidence-decay-design]]
