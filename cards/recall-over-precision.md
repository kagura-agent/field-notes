---
title: "Recall Over Precision in Memory Compilation"
type: concept
status: active
created: 2026-05-13
last_verified: 2026-05-13
related:
  - "[[statewave]]"
  - "[[hermes-memory-skills]]"
  - "[[git-backed-agent-memory]]"
---

# Recall Over Precision in Memory Compilation

When compiling raw experiences into structured memories, **favor recall (capturing more specific details) over precision (fewer, cleaner summaries)**.

## The Principle

> "Better to emit 30 concrete granular memories than 5 vague ones — the retrieval layer ranks them; the compiler's job is recall."
> — [[statewave]] LLM compiler prompt (PR #71)

The retrieval layer (semantic search, scoring, ranking) can filter and rank. But it cannot retrieve what was never stored. A memory system that summarizes away specifics creates an irreversible information loss at compile time.

## Evidence

- **Statewave PR #71**: Changing compiler prompt from "concrete, generalizable facts" to explicit granularity rules increased compiled memories 111 → 154 (+39%) and lifted benchmark scores significantly. The LLM was interpreting "generalizable" as "high-level" and discarding specifics like colors, brand names, quantities.
- **Anti-pattern**: "Melanie is into running" vs "Melanie bought purple running shoes to de-stress" — the first is retrievable by fewer queries and answers fewer questions.

## Application to Our System

Our `MEMORY.md` curation tends toward summaries:
- ❌ "Studied Statewave" 
- ✅ "Statewave PR #71: granularity principle — compiler should favor 30 specifics over 5 summaries because retrieval can rank but can't recall what wasn't stored"

The compilation step (daily logs → curated memory) should preserve:
- Concrete objects + attributes (names, versions, patterns)
- Motivations and reasons (why something was chosen/rejected)
- Specific relationships (what connects to what)
- Stated preferences and decisions

## Related Concept: Silent Degradation

The corollary: when recall fails silently (e.g., [[statewave]]'s async embedding backfill bug), the system appears to work — just with degraded quality. No errors, no crashes, just gradually worse answers. This is the hardest failure mode to detect in memory systems.
