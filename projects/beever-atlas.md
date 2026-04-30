# Beever Atlas

> Source: Beever-AI/beever-atlas | ★191 | Python (Google ADK) + TypeScript (bot)
> License: Apache-2.0
> First read: 2026-04-30

## What It Does

Beever Atlas turns team chat (Slack, Discord, Teams, Mattermost) into a self-maintaining wiki — automatically. It syncs messages from chat platforms, extracts atomic facts, deduplicates them, clusters them into topic pages with citations, and builds an entity graph. Answers are cited back to source messages. Queryable via dashboard or MCP (Claude Code / Cursor).

**Core proposition:** "If you want a knowledge base that grows on its own from the chats your team already has, this is it."

## Architecture

**Three-layer design (Karpathy LLM Wiki pattern):**
1. **Raw Conversations** — unmodified messages from chat platforms (read-only)
2. **Structured Memory** — dual-memory system:
   - **Semantic Memory** (Weaviate) — 3-tier: channel summary → topic clusters → atomic facts
   - **Graph Memory** (Neo4j) — entities (people, decisions, projects) + relationships
3. **Persistent Wiki** — auto-generated from structured memory, incremental updates

**Stack:** Python backend (FastAPI + Google ADK agents), TypeScript bot (multi-platform bridge), React frontend, Docker Compose. Data stores: Weaviate (vectors), Neo4j (graph), MongoDB (state), Redis (cache).

**Key design: Google ADK as the agent framework.** All pipeline stages are ADK agents (SequentialAgent, ParallelAgent, LlmAgent). This is notable — one of the first serious OSS projects built on Google ADK rather than LangChain/LlamaIndex.

## Ingestion Pipeline (6-stage, ADK-based)

```
Preprocessor → [FactExtractor ‖ EntityExtractor] → [Embedder ‖ CrossBatchValidator] → Persister
```

1. **Preprocessor** — normalize messages, handle media (audio transcription, image description, document digestion, video analysis)
2. **Fact Extractor** (LLM) — extract 0-N atomic facts per message with quality scoring (specificity × actionability × verifiability, drop below 0.5)
3. **Entity Extractor** (LLM) — extract people, decisions, projects, technologies + relationships
4. **Embedder** — Jina v4 2048-dim embeddings for Weaviate
5. **Cross-Batch Validator** — deduplication + contradiction detection across batches
6. **Persister** — write to Weaviate + Neo4j

**Parallel execution:** Fact + entity extraction run in parallel; embedding + cross-batch validation run in parallel. Smart use of ADK's ParallelAgent.

### Fact Quality Scoring — The 6-Month Test

Before extracting any fact, the LLM asks: "Would a new team member joining in 6 months need this?" Quality score = (specificity + actionability + verifiability) / 3. This is a practical, well-calibrated approach to avoiding "database log entry" facts.

**Calibration examples in the prompt are excellent** — showing HIGH (0.90), MEDIUM (0.70), and TOO THIN (0.35-0.40) examples with explicit reasoning. The "TOO THIN" examples and rewrites are particularly useful for teaching the model what's missing.

### Contradiction Detection

Dedicated LlmAgent for finding contradictions between new and existing facts. Not just dedup — actual semantic contradiction detection. Uses schema-constrained JSON output with recovery for truncated responses. This is a hard problem most systems skip.

## Query System

**Smart Router** — classifies each question and routes to the best memory system:
- **Semantic-only** (most questions) — Weaviate hybrid BM25+vector search, <200ms
- **Graph-only** (relationship questions) — Neo4j traversal, ~500ms
- **Both (parallel)** — merge + dedupe + cross-validate, for complex questions

**Query Decomposition** — complex questions split into 2-4 focused sub-queries executed in parallel. Fast-path heuristic skips decomposition for simple questions ($0 cost). External sub-queries route to web search (Tavily) when retrieval confidence is low.

**3-Tier Semantic Memory for cost optimization:**
- Tier 0: Channel summary (cached, FREE reads)
- Tier 1: Topic clusters (cached, FREE reads)
- Tier 2: Atomic facts (vector search, paid)

This means most "overview" and "what's this channel about" queries cost $0 — they hit the pre-generated summaries.

## MCP Server

16 tools exposed via MCP for Claude Code / Cursor integration. Per-agent auth. External MCP registry for outbound connections (your MCP servers become tools in the QA agent). This bidirectional MCP design is interesting.

## Relevance to Us

### Comparison with [[llm-wiki]]

Both implement Karpathy's LLM Wiki pattern, but at different scales:
- **LLM Wiki** = desktop app for personal document ingestion, local-first, Tauri+React
- **Beever Atlas** = team infrastructure for chat ingestion, Docker stack with 4 data stores
- Both: markdown-based wiki output, incremental updates, contradiction detection

### What We Can Learn

1. **The 6-Month Test for fact quality** is directly applicable to our memory system. We could add quality scoring to beliefs-candidates: "Would this belief still be relevant in 6 months?" Maps to the Durability dimension we adopted from [[harmonist]].

2. **3-tier semantic memory with cached upper tiers** is a clever cost optimization. Our wiki already has a natural hierarchy (L1 index → project notes → concept cards). Making the upper tiers cached/pre-generated so queries can often skip vector search is worth considering for [[memex]].

3. **Contradiction detection as a pipeline stage** — we do ad-hoc contradiction checking in beliefs-candidates, but making it a formal pipeline step during ingestion would catch conflicts earlier. Related: [[confidence-decay-design]].

4. **Google ADK as agent framework** — first major use we've seen. The SequentialAgent/ParallelAgent composability is clean. Worth watching if ADK gains traction as a LangChain alternative.

5. **Bidirectional MCP** — Atlas exposes MCP tools AND consumes external MCP tools. Our OpenClaw has MCP client support; the "expose our knowledge as MCP tools" direction is interesting for skill ecosystem.

6. **Media ingestion pipeline** (audio transcription, image description, document digestion, video analysis) — modular, each is a separate ADK agent. Clean separation of concerns for multimodal memory.

### Key Differences from Our Approach

- **They ingest OTHER people's conversations** (team chat). **We ARE the conversation participant** — we generate and consume our own memory. This is a fundamental difference in agent vs tool positioning.
- **They use Gemini exclusively** (via Google ADK). We're model-agnostic.
- **Heavy infrastructure** (Weaviate + Neo4j + MongoDB + Redis). We run on flat files + memex. Their approach trades simplicity for query performance at scale.
- **No self-evolution.** Atlas doesn't improve itself from experience. It's a tool, not an agent. Our DNA/beliefs system has no equivalent here.

### Not a Competitor

Different market entirely. Atlas is team knowledge infrastructure (compete with Notion AI, Glean, Guru). We're building a self-evolving personal agent. But their ingestion pipeline design and quality scoring are directly transferable lessons.

## Key Insights

- **"Wiki-first RAG" is gaining traction** as a named pattern. Karpathy's original observation → LLM Wiki (desktop) → Beever Atlas (team infra) → likely more. The "compile once, query many" pattern is becoming consensus for moderate-scale knowledge.
- **Fact quality scoring is undersold.** Most memory systems treat all facts equally. The specificity × actionability × verifiability framework + the 6-Month Test + calibration examples is the most practical approach to memory quality I've seen. Better than our current "just write it down" approach.
- **Graph memory complements semantic memory** — not either/or. Entity relationships (who decided what, who works with whom) need graph traversal. Facts about those entities need semantic search. Both needed.
- **ADK adoption signal** — Beever Atlas betting on Google ADK for a production system suggests ADK is maturing beyond toy examples. Watch for more projects choosing ADK over LangChain.
- **The chat→wiki pipeline has product-market fit.** 191⭐ in 9 days (created 04-21). Teams clearly want this — turning noisy Slack into browsable knowledge is a real pain point.
