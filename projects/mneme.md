# Mneme — Reconsolidation-Native Memory for AI Agents

> Billy1900/mneme | ⭐3 (2026-04-23) | Rust | MIT
> "Memory compaction, evolution, and conflict resolution from cognitive neuroscience"

## Core Ideas

### Three Operations (no existing system combines all three)
1. **Compaction** — Working memory → semantic memory via embedding clustering + LLM synthesis
2. **Evolution** — Every retrieval triggers drift detection; if context diverges (cosine > 0.3), LLM evaluates whether to update the memory (implements Nader's reconsolidation)
3. **Conflict Resolution** — Three strategies: temporal supersede, confidence merge, conditional coexist

### Engram Data Model (progressive disclosure)
- **Envelope** (~200 bytes): embedding, confidence, timestamps, access count, summary, tags — always loaded
- **Content Body**: full text, provenance chain, conflict log, relationships — loaded on demand
- 10-50x token savings vs flat memory approaches

### Architecture
- `mneme-api` — 4 verbs: remember / recall / expand / end_session
- `mneme-consolidate` — The three operations + LLM prompt templates
- `mneme-store` — EnvelopeIndex + ContentStore
- `mneme-embed` — EmbeddingModel adapter

## Relevance to OpenClaw

OpenClaw uses flat markdown files (MEMORY.md + daily logs) + memex semantic search. Mneme's ideas that could inform evolution:

1. **Confidence decay with reinforcement on access** — memories that are never recalled should fade; frequently accessed ones strengthen. Our current approach has no decay.
2. **Drift-based evolution on retrieval** — instead of append-only memory, facts could update when context shows they've changed. We currently rely on manual curation.
3. **Envelope/body split** — We already do something similar (memex search returns excerpts, full file read on demand), but formalizing it could improve token efficiency.
4. **Conflict resolution** — We have no mechanism for contradicting memories. When a fact changes, old entries persist alongside new ones.

## Code-Level Observations (2026-04-23 deep read)

### What's implemented
- **Engram data model**: Envelope (metadata) + ContentBody (full text + provenance + conflict log + relationships). Clean separation.
- **Compaction**: agglomerative clustering by embedding similarity → LLM synthesis. If cluster matches existing semantic memory (sim > 0.80), merges via evolution instead of creating new.
- **Reconsolidation**: on retrieval, computes cosine drift between stored embedding and current context. If drift > 0.3, LLM evaluates keep/update/conflict. Creates new versioned engram on update, preserves supersession chain.
- **Conflict resolution**: 3 strategies defined (temporal supersede, semantic merge, contextual coexist) but only conflict detection during reconsolidation is implemented (reduces confidence). Full resolution appears planned but not yet wired.
- **Confidence reinforcement**: `(similarity - 0.5) * 0.1 * diminishing_factor` — subtle; frequently accessed high-similarity memories strengthen, low-similarity ones weaken.
- **Ebbinghaus decay**: `exp(-lambda * hours_since_access)` on Envelope, configurable lambda (default 0.05).

### Architecture quality
- Clean Rust crate separation: mneme-core (types), mneme-store (SQLite/Qdrant), mneme-embed (embedding), mneme-consolidate (engine), mneme-api (4 verbs)
- LLM-agnostic via trait — Anthropic backend + MockLLM for tests
- Provenance chain preserved through every transformation
- FIX comments in code show active development (#3, #11, #16)

### Gaps
- Conflict resolution only partially implemented (detect + confidence reduction, no full merge/coexist)
- No GC/pruning yet (config has `gc_confidence_floor` but no implementation found)
- Rust-only, no FFI or HTTP server — not directly usable from JS/Python agents
- 3 stars — may not sustain development

## Assessment
- Conceptually strongest memory system I've seen in the agent ecosystem
- Code quality is high; clean abstractions, proper error handling
- Design patterns worth stealing: envelope/body split, drift-triggered evolution, confidence reinforcement with diminishing returns, supersession chains
- Unlikely to adopt directly (Rust, no integrations), but ideas could inform OpenClaw memory evolution
- Worth checking back in 2-4 weeks for conflict resolution completion

Links: [[openclaw]], [[orb]], [[write-time-vs-read-time-arbitration]]
