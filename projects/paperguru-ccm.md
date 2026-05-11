---
title: "PaperGuru — Lifecycle-Aware Memory (LAM)"
slug: paperguru-ccm
tags: [agent-memory, benchmark, architecture, provenance]
created: 2026-05-11
source: https://github.com/PaperGuru-AI/PaperGuru-Benchmark
status: active
stars: 70
last_verified: 2026-05-11
---

# PaperGuru — Lifecycle-Aware Memory (LAM)

Benchmark repo demonstrating a closed-source "Capital Chunk Memory" (CCM) architecture for long-horizon LLM agents. 70⭐, created 2026-05-08. No source code published — only benchmark results (PaperBench + SurveyBench submissions).

## The 4 LAM Axioms

The most valuable contribution is the conceptual framework. Four axioms any production agent memory system should satisfy:

1. **Versioned content** — facts can become stale after revision/deprecation/retraction; the memory layer must know
2. **Structural multi-hop relevance** — the right evidence is 2+ hops away, not one cosine-similarity jump
3. **Bounded query cost under unbounded archive growth** — routing cost can't grow linearly with archive size
4. **Provenance-grounded composition** — every claim traces back to a verifiable artifact in memory

> Most existing approaches (MemGPT tiers, Ebbinghaus forgetting, KG wrappers) satisfy 1-2 axioms but never all 4.

## CCM Architecture

Two-surface memory:
- **Chunk heads** — compact, bounded routing surface (one head per artifact)
- **Chunk contents** — unbounded raw text, lazily accessed on demand

Central "capital chunk" indexes all heads via a **temporal artifact graph** with two edge classes:

| Edge class | Examples |
|---|---|
| Structural | `cites`, `benchmarked-on`, `introduced-by`, `implements` |
| Historical-causality | `discussed-in`, `deprecated-by`, `retracted-by`, `superseded-by` |

Pipeline: **Route-first → Expand-second → Distill-last** → produces "evidence cards"

## Benchmark Results

- **PaperBench** (OpenAI): 66.05% mean reproduction across 23 papers (vs 35.74% previous SOTA)
- **SurveyBench**: 94.66% content score (vs 80.60%)
- Used H200, Claude backbone, o3-mini judge. Paper-reproduction domain.

## Connection to Us

### What we already do

- **Axiom 1 (staleness)**: Partially covered by our [[confidence-decay-design]] — time-based `last_verified` flagging. Simpler than LAM's semantic versioning but functional for file-based wiki.
- **Axiom 3 (bounded query)**: memex search provides bounded retrieval cost.

### What we're missing

- **Axiom 4 (provenance)**: Our wiki notes don't systematically trace claims back to sources. Study notes have `source:` frontmatter but beliefs-candidates don't always link to the observation that generated them.
- **Axiom 2 (multi-hop)**: Our wikilinks are untyped — just "related." No distinction between structural vs historical-causality edges. A card linking to [[stash]] doesn't say whether it's "inspired-by", "competes-with", or "superseded-by" stash.

### Actionable ideas

1. **Typed wikilinks** — `[[stash|inspired-by]]` or `[[stash|deprecated-by]]` syntax in wiki. Would enable richer traversal. Low priority — manual graph curation has high overhead for uncertain benefit.
2. **Provenance for beliefs-candidates** — each gradient entry should link to the specific observation/session that generated it. Some do, many don't.
3. **Evidence cards** as a study output format — instead of free-form notes, produce structured { claim, source, confidence, staleness_date } cards. Heavy investment, unclear ROI for our scale.

## Assessment

Academically interesting conceptual framework. The 4 axioms are a good checklist for evaluating any memory system. But the repo is a marketing vehicle for a closed-source product — no code, no tests, no issues. The benchmark numbers are impressive but unverifiable without the implementation.

**Verdict**: Conceptual value (LAM axioms as evaluation framework) but low practical value (can't learn from implementation, can't adapt). Track conceptually, don't invest time following the repo.

## Links

- [[confidence-decay-design]] — our existing staleness mechanism (covers axiom 1)
- [[agent-memory-taxonomy]] — broader taxonomy of memory approaches
- [[self-evolving-agent-landscape]] — where memory fits in the stack
- [[frozen-trust-vs-time-decay]] — related concept on trust dynamics
- [[git-backed-agent-memory]] — our actual memory architecture
