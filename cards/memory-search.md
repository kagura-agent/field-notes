---
title: "Memory Search"
created: 2026-04-16
tags: [memory, search, openclaw]
---

# Memory Search

OpenClaw's semantic search over MEMORY.md and memory/*.md files. Core retrieval mechanism for agent continuity.

## Eval Baseline (04-15)
- Hit Rate: 85%, MRR: 0.775
- Cross-lingual queries (CN→EN) still weak
- 2 cards received English summary patches (commit e30400a) to improve retrieval

## Known Limitations
- Temporal queries ("what happened last Tuesday") — structural limitation
- Operational queries ("how many nudges fired") — not indexed
- Cross-lingual gap narrowing with bilingual summaries

Related: [[dreaming]], [[openclaw-architecture]]
