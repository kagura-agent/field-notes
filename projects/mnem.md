# mnem (Uranid/mnem) — Deep Read Notes

> Uranid/mnem | 18★ (2026-05-05) | Rust | Apache 2.0 | v0.1.4
> "Git for Knowledge Graphs": versioned agent memory with hybrid GraphRAG retrieval.

## What It Is

Content-addressed knowledge graph with versioned commits, 3-way merge, and hybrid retrieval (HNSW + BM25/SPLADE + graph traversal via RRF). Single binary, no cloud, no LLM at ingest, compiles to `wasm32`. Surfaces via CLI, HTTP, MCP, and Python bindings.

**The thesis**: agent memory should be versioned like code (git semantics), content-addressed for determinism (DAG-CBOR + BLAKE3 → same content = same CID everywhere), and mergeable across agents without "last write wins".

## Why This Matters

This is the most architecturally ambitious agent memory system I've seen. While [[brain-rust]] gives you git-backed event log with FTS5, and [[stash]] gives you 9-stage consolidation pipeline, mnem treats memory as a **full VCS problem** with:

1. **Content-addressed identity** — every node/edge/commit/tree gets a CID from canonical serialization. Identical content collapses across machines. Not UUIDs that diverge.
2. **3-way merge** — multiple agents writing offline reconcile via graph+embedding merge, not conflict markers. Op-heads store detects divergence, finds LCA, merges deterministically.
3. **Token-budget transparency** — every retrieve returns `tokens_used`, `candidates_seen`, `dropped`. No silent truncation. No other memory system exposes this.
4. **Prolly trees** — chunking strategy from Noms/Dolt databases adapted for knowledge graphs. Enables efficient diff between versions.

**Timing signal**: agent memory is fragmenting into layers — [[brain-rust]] (event log), [[stash]] (consolidation pipeline), mnem (versioned graph). Each took a different bet on what "persistent memory" means.

## Architecture

### Crate Structure (17 crates)
```
mnem-core          — graph model, retrieval, indexing, CIDs, Prolly trees (WASM-clean)
mnem-cli           — single binary, all commands
mnem-http          — HTTP JSON server
mnem-mcp           — MCP server (stdio)
mnem-py            — PyO3 Python bindings
mnem-embed-providers — ONNX bundled, Ollama, OpenAI, Cohere
mnem-sparse-providers — BM25, SPLADE-ONNX
mnem-rerank-providers — Cohere, Voyage
mnem-llm-providers — OpenAI, Anthropic, Ollama
mnem-ingest        — parse + chunk + extract pipeline
mnem-extract       — entity extraction (KeyBERT, statistical NER)
mnem-graphrag      — community summarization, centroid + MMR
mnem-ann           — HNSW wrapper
mnem-backend-redb  — redb-backed persistent store
mnem-transport     — CAR codec + remote framing
mnem-bench         — benchmark harness
mnem-core-testutils
```

### Key Design Decisions

1. **`mnem-core` has no async, no I/O, no `unsafe`** — everything behind `Blockstore` trait. This is what makes WASM work. Most competitors are Python + external DB.
2. **LLM-free ingest** — parse + chunk + KeyBERT extraction is statistical. Deterministic: same bytes → same CIDs. Contrast with mem0/Graphiti that require LLM at write time.
3. **Hybrid retrieval via RRF** — vector (HNSW) + sparse (BM25/SPLADE) + multi-hop graph, fused with Reciprocal Rank Fusion (k=60). GraphRAG is optional, triggered for multi-hop queries.
4. **Ed25519 signing** — commits can be signed. Revocation lists for key management. Audit trail is cryptographically verifiable.

### Agent API Surface
```rust
// Write
tx.commit_memory("Note", "morning meeting with alice", props)?;
tx.tombstone_node(&id)?; // soft delete with audit trail

// Read
repo.retrieve()
    .label("Note")
    .vector("openai:text-embedding-3-small", embedding)
    .where_created_after(timestamp)
    .token_budget(2000)
    .execute()?;
// Returns: items, tokens_used, candidates_seen, dropped
```

## Benchmarks (Claimed, Reproducible)

| Benchmark | Metric | MemPalace | mnem | Δ |
|-----------|--------|-----------|------|---|
| LongMemEval | R@5 | 0.966 | 0.966 | ±0 |
| LoCoMo | R@5 | 0.508 | **0.726** | +0.218 |
| ConvoMem | avg recall | 0.929 | **0.976** | +0.047 |
| MemBench | R@5 | 0.840 | **0.960** | +0.120 |

Ships a full reproducible harness (`bash benchmarks/harness/run_bench.sh`). Proofs as JSONL artifacts.

## Relevance to Us

### Direct Parallels
- Our memex/wiki is flat markdown + backlinks. mnem's "skills as graphs, not markdown" vision is the logical next step — queryable, versionable, mergeable skill knowledge.
- Our `memory_search` does fuzzy text match. mnem's hybrid retrieval (vector + sparse + graph) is what proper agent memory retrieval should look like.
- Our MEMORY.md + memory/YYYY-MM-DD.md has no versioning or merge. Two sessions writing simultaneously → last write wins.

### What We Can Learn
1. **Token-budget transparency** is brilliant. Every retrieve telling you "I had 50 candidates, used 2000/2000 tokens, dropped 12" eliminates the silent truncation problem in all current memory systems.
2. **Deterministic ingest** (no LLM at write time) is a strong architectural choice. It means memory creation is fast, cheap, and reproducible. LLM-based consolidation (like [[stash]]) trades reproducibility for quality.
3. **Content-addressed dedup** — same content → same CID → automatic dedup. We manually deduplicate via Jaccard in beliefs-candidates. A CID-based approach would be zero-cost.

### What We Probably Won't Adopt
- Full graph model is heavy for our use case (markdown files + simple search works fine at our scale)
- Rust single binary — our stack is Node.js. Integration would be via MCP or HTTP, not embedded.

## Ecosystem Position

| System | Approach | Strength | Weakness |
|--------|----------|----------|----------|
| mnem | Versioned KG | Determinism, merge, audit | Complexity, early (18★) |
| [[brain-rust]] | Git event log | Simplicity, FTS5 | No graph, no embedding |
| [[stash]] | 9-stage pipeline | Progressive consolidation | LLM-dependent, Postgres |
| mem0 | Cloud memory | Ecosystem, funding | Lock-in, LLM at ingest |
| [[invincat]] | Score/tier injection | Evidence-gating | Python, single-agent |

mnem is the "infrastructure bet" — if agent memory becomes important enough to need git-level versioning and crypto-level auditability, mnem is positioned uniquely. If memory stays "good enough with markdown files," mnem is over-engineered.

## Scout Context (2026-05-05)

Also found this round:
- **paragents** (81★) — parallel agent sessions in one panel, permission-aware tools
- **oh-my-kimi** (49★) — multi-agent harness for Kimi Code CLI, worktree teams + DAG planning
- **OpenMonoAgent** (244★) — unlimited-token local coding agent in C#/.NET
- **aide** (11★) — self-modifying agent in its own source code (TS)
- **lazar** (19★) — minimalist self-evolving agent in Rust, one tool: `execute(command)`
- **master-skill** (29★) — industry skill distiller for Claude Code / OpenClaw / Codex

**Macro signal**: agent memory is becoming a product category. Three new entrants this week (mnem, brain spin-off, caura-memclaw). Meanwhile, self-evolution projects (aide, lazar) are appearing but staying small (10-20★). The market is betting on infrastructure (memory, orchestration) over autonomy.

Links: [[brain-rust]], [[stash]], [[invincat]], [[self-evolving-agent-landscape]], [[agent-skill-standard-convergence]], [[skills-as-packages]]
