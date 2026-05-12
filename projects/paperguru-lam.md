---
title: "PaperGuru — Lifecycle-Aware Memory (LAM) for Long-Horizon Agents"
created: 2026-05-12
updated: 2026-05-12
status: active
stars: 109
url: https://github.com/PaperGuru-AI/PaperGuru-Benchmark
last_verified: 2026-05-12
---

# PaperGuru — Lifecycle-Aware Memory (LAM)

Benchmark + paper repo. 109⭐ (2026-05-12, 4 days old). TeX + benchmark data, no source code released. CC-BY-NC-ND-4.0. 10 peer-reviewed acceptances (FSE 2026, ICML 2026, TOSEM, AEI, ICoGB).

## Core Thesis

AI infra has three commodity primitives (compute, models, retrieval). A fourth — **long-term memory with lifecycle semantics** — is missing. Every long-horizon agent reinvents it badly.

## The 4 LAM Axioms

| Axiom | Statement | Our Status |
|-------|-----------|------------|
| **A1: Versioned content** | Statements once correct must become *stale* after revision/deprecation. Memory must know. | ❌ We have no version tracking. Wiki edits overwrite, no "deprecated-by" semantics. |
| **A2: Structural multi-hop** | The right evidence is 2 citations away, not 1 cosine hop. | ⚠️ Wikilinks provide graph structure, but our search is single-hop (cosine or keyword). |
| **A3: Bounded query cost** | Archive grows unbounded; routing cost must not grow with it. | ⚠️ Our grep is O(n), memex semantic search presumably bounded by index size. |
| **A4: Provenance-grounded** | Every claim traces to a verifiable artifact in memory. | ❌ No provenance tracking in our memory/wiki system. |

## CCM (Capital Chunk Memory) Architecture

Two-surface design:
- **Chunk heads**: compact bounded routing surface (1 head per artifact). Analogy: our wiki/L1.md index.
- **Chunk contents**: unbounded raw text, accessed lazily on demand. Analogy: our wiki card bodies.

Central **capital chunk** indexes all heads. Query pipeline: **route-first → expand-second → distill-last**.

Temporal artifact graph with two edge classes:
- **Structural**: `cites`, `benchmarked-on`, `introduced-by`, `implements`
- **Historical-causality**: `deprecated-by`, `retracted-by`, `superseded-by`

Output: **evidence cards** — compact, provenance-grounded data structures.

## Results

- **PaperBench**: 66.05% mean (vs 35.74% best baseline, +30.21%)
- **SurveyBench**: 94.66% content score (vs 80.60% best baseline)
- 20/23 papers clear human ML-PhD 41% bar

## Why This Matters

1. **Axiom A1 (versioned content)** is the biggest gap in most agent memory systems including ours. When we update a wiki card, the old version vanishes. We can't ask "what did I believe about X last month?" or "was this ever retracted?"
2. **Axiom A2 (multi-hop)** validates the value of wikilinks — they create structural edges. But our search doesn't traverse them. A query about "agent skill packaging" won't find a card about "token efficiency" even if they're linked.
3. **The chunk-head / chunk-content split** maps cleanly to our wiki/L1.md (heads) + wiki/cards/ (contents). We accidentally arrived at a similar architecture. But we lack the routing layer that makes heads useful at query time.
4. **Historical-causality edges** (`deprecated-by`, `superseded-by`) are the most underappreciated feature. Most memory systems (including ours) treat knowledge as timeless. Knowledge decays. Projects stall. Patterns get superseded. Encoding this in the graph itself is the right idea.

## Anti-intuitive

- Pure cosine similarity doesn't satisfy any of the 4 axioms. It's an approximation that works for simple cases but fails at exactly the moments memory matters most (contradictions, superseded info, multi-hop reasoning).
- The benchmark is paper-reproduction, not chat. This means the memory requirements are fundamentally different from conversational agents — they need *months* of accumulated context, not *hours*. But the axioms still apply to shorter horizons.

## Limitations

- No source code. Benchmark-only release. Can evaluate the theory but can't study the implementation.
- CC-BY-NC-ND-4.0 — restrictive license, no commercial use, no derivatives.
- 10 accepted papers from a single system feels like self-citation farming. The results are impressive if real.
- TeX repo pushed once on creation day, no follow-up commits. Could be a paper dump.

## Connections

- [[krusch-context-mcp]] — Krusch addresses F6 (Ebbinghaus forgetting) with temporal decay, which partially satisfies A1. But no versioning, no multi-hop.
- [[agent-memory-taxonomy]] — The Forms-Functions-Dynamics taxonomy is descriptive; LAM axioms are prescriptive. Complementary frameworks.
- [[retrieval-is-the-bottleneck]] — LAM formalizes *why* retrieval is the bottleneck: the 4 axioms describe the gaps that retrieval must bridge.
- [[self-evolving-agent-landscape]] — CCM could be the memory layer that enables reliable self-evolution. Evolution requires accurate recall of what worked and what didn't (A1 + A4).
- [[mnem]] — mnem's content-addressed CIDs partially satisfy A1 (versioned). Its GraphRAG partially satisfies A2 (multi-hop). Closest to LAM-complete among projects we track.

## Applicable to Us

1. **A1 quick win**: When updating wiki cards, append a `## History` section instead of overwriting. Track what changed and why.
2. **A2 quick win**: Enhance wiki search to follow wikilinks 1 hop deep (find cards linked from search results).
3. **A4 quick win**: Tag memory entries with source (session ID, URL, command output) for traceability.
4. **LAM as evaluation framework**: Use the 4 axioms to audit our own memory system and any competitor we study.

## Tracking

| Date | Stars | Notes |
|------|-------|-------|
| 2026-05-12 | 109 | First observation. Benchmark/paper only, no code. LAM axioms theoretically valuable. |
