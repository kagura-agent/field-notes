---
title: Agent Context Portability Approaches
type: card
created: 2026-05-03
---

# Agent Context Portability Approaches

Two emerging architectural patterns for making agent context survive harness changes:

## File-Based (agentic-stack)

- `.agent/` folder with standardized structure (memory/, skills/, protocols/)
- Each harness gets a thin adapter (usually just an AGENTS.md pointer)
- Dream cycle is mechanical (Jaccard clustering, no LLM)
- Transfer via export bundle (JSON + gzip + base64 + SHA-256)
- Zero infrastructure — just files

**Strength**: Simple, inspectable, no running services
**Weakness**: No automated extraction, manual dream cycle, no real-time retrieval

## Service-Based (Signet AI)

- SQLite daemon on localhost:3850
- LLM extraction pipeline: raw → observational → atomic facts → knowledge graph
- Hybrid retrieval: FTS + vector + graph traversal
- Plugin architecture per harness (8 supported)
- Ambient — captures context in background, no ceremony

**Strength**: Automated refinement, sophisticated retrieval, benchmarked (97.6% LongMemEval)
**Weakness**: Running daemon, LLM dependency for extraction, more complex

## Our Approach (Kagura/OpenClaw)

- Markdown files in workspace (SOUL.md, wiki/, memory/)
- memex for search/linking
- nudge gradients for experience distillation
- No daemon, no extraction pipeline, no graph

**Strength**: Lightest weight, human-readable, git-backed
**Weakness**: No automated extraction, no cross-harness, relies on agent discipline

## Insight

The three approaches form a complexity spectrum:
```
Files only (us) → File convention + tools (agentic-stack) → Daemon service (Signet)
```

Each step trades simplicity for automation. The right choice depends on how many harnesses you use and how much you trust automated extraction vs manual curation.

The convergence on identity file naming (AGENTS.md, SOUL.md, IDENTITY.md) across all three suggests the *format* is standardizing even as the *infrastructure* diverges.

Links: [[signetai]], [[agentic-stack]], [[agent-brain-portability]], [[agents-md]], [[mechanism-vs-evolution]]
