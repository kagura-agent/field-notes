---
title: Agent-Native Code Search
created: 2026-05-14
updated: 2026-05-14
tags: [agent-infrastructure, token-optimization, code-search]
last_verified: 2026-05-14
---

# Agent-Native Code Search

The pattern of building code search tools specifically designed for LLM agents, optimizing for token efficiency over human readability.

## Core Insight

Agents exploring codebases via `grep` + `cat` spend 60%+ of their token budget reading files. Purpose-built search tools can reduce this by 90%+ by returning only relevant snippets with context.

## Key Components

1. **AST-boundary chunking** — Use [[tree-sitter]] to split code at function/class/struct boundaries instead of fixed line counts. Chunks never break mid-function, producing semantically complete units. See also [[ast-outline]] for the outline-only variant.

2. **Hybrid search (BM25 + semantic)** — BM25 catches exact identifier matches; semantic embeddings catch intent/concept matches. Fused via RRF (Reciprocal Rank Fusion) — simple, parameter-light, effective.

3. **Dependency impact analysis** — Build a cross-file dependency graph from import/use statements → answer "what breaks if I change this?" in one query. Transforms multi-step agent reasoning into single-command lookup.

4. **Compact output mode** — Return file path + line numbers + matching lines only. Agents get what they need without reading full files.

## Implementation Examples

- **semble** (MinishLab, Python) — Original. Line-based chunking, BM25 + potion-code-16M semantic. MCP server mode.
- **semble_rs** (johunsang, Rust) — Rewrite adding AST chunking + dependency graph. 3,727 LOC. Too young to evaluate (2 days, no tests, May 2026).

## Static Embedding Trade-off

Using tiny embedding models (16M params, CPU-only) instead of transformer encoders. Sacrifices some semantic quality for zero-GPU-dependency and fast cold start. For code search where exact match matters more than nuanced semantics, this trade-off works.

## Relevance to Us

- Our [[gogetajob]] workflow uses `grep` + `cat` for code exploration — could benefit from agent-native search
- [[ast-outline]] covers structure extraction; this pattern extends to search + retrieval
- Token efficiency directly impacts our contribution cost per PR
- If a mature tool emerges, could become an OpenClaw skill

## Related

- [[ast-outline]] — AST-based outline extraction (structure without search)
- [[context-budget-constraint]] — why token efficiency matters for agents
- [[retrieval-is-the-bottleneck]] — search quality as limiting factor
