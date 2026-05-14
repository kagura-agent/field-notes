---
title: "semble_rs — Rust Hybrid Code Search for AI Agents"
status: noted
updated: 2026-05-14
stars: 39
repo: johunsang/semble_rs
language: Rust
license: MIT
last_verified: 2026-05-14
---

# semble_rs

Rust rewrite of MinishLab/semble (Python) — hybrid BM25 + semantic code search designed as a drop-in replacement for `grep`, `cat`, `read`, `ls` when LLMs explore code.

## Key Architecture

- **Tree-sitter AST chunking** (vs line-based in original) — functions/classes/structs as atomic units
- **Hybrid search**: BM25 (keyword) + model2vec embeddings (semantic) → RRF fusion
- **Added over original**: dependency graph analysis, impact analysis, line numbers in results
- Claims **-93% token reduction** (58K → 4K tokens/session)
- Unicode-aware BM25 tokenizer (Korean/CJK support)

## Relevance

Niche but well-executed. The token reduction claim is significant for agent cost optimization. AST-aware chunking > line-based chunking is a known-good pattern (see [[code-search-patterns]]). Not directly on our north star but useful reference for anyone building agent-native code tools.

Korean developer (johunsang). Active development (pushed 05-14).
