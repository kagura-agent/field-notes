---
title: semble_rs
created: 2026-05-14
updated: 2026-05-14
tags: [code-search, rust, agent-tool]
last_verified: 2026-05-14
---

# semble_rs (johunsang)

Rust rewrite of MinishLab's semble — agent-native code search with AST chunking and dependency analysis.

- **Repo**: johunsang/semble_rs
- **Stars**: 30 (2026-05-14)
- **Language**: Rust
- **License**: MIT
- **Created**: 2026-05-12

## Architecture

Three-layer pipeline:
1. **AST Chunking** (Tree-sitter, 8 languages) → definition-boundary chunks (~1,500 chars)
2. **Hybrid Search** (BM25 + potion-code-16M semantic, RRF k=60)
3. **Dependency Graph** (import extraction → reverse dep map → impact analysis)

Ranking: symbol-aware boost + sibling chunk boost + multi-chunk file boost + top-k rerank.

## Verdict (2026-05-14)

Concept sound. AST chunking + hybrid search + impact analysis is novel combination. But **too young** (2 days, 0 tests, 0 issues, 0 community). Not tracking. Pattern captured in [[agent-native-code-search]].

## Related

- [[agent-native-code-search]] — concept card
- [[ast-outline]] — adjacent tool (outline vs search)
