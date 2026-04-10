# mempalace

> AI memory system — "store everything, make it findable"
> GitHub: milla-jovovich/mempalace | ⭐38k (5 days!) | Python | 2026-04-05

## What it does
- Verbatim conversation storage in ChromaDB (no summarization, no extraction)
- Spatial metaphor: wings (people/projects) → halls (types) → rooms (specific ideas) → drawers (chunks)
- 96.6% R@5 on LongMemEval benchmark in raw mode, fully local, zero API calls
- MCP server for Claude/ChatGPT/Cursor integration
- Claude Code plugin + Codex plugin (marketplace install)

## Architecture
- `palace.py` — ChromaDB access layer, collection management, mtime-based re-mining
- `searcher.py` — semantic search with wing/room metadata filtering
- `miner.py` / `convo_miner.py` — ingest code/docs/conversations
- `general_extractor.py` — auto-classify into decisions, preferences, milestones, problems, emotional context
- `dialect.py` — AAAK experimental compression (lossy, 84.2% vs raw 96.6%)
- `knowledge_graph.py` / `palace_graph.py` — entity relationships
- `entity_detector.py` / `entity_registry.py` — entity extraction and tracking

## Key design decisions
1. **No summarization** — store verbatim, let search find it. Philosophy: "AI shouldn't decide what's worth remembering"
2. **Metadata filtering as the main retrieval boost** — wing+room filtering, standard ChromaDB feature
3. **AAAK dialect** — lossy abbreviation for token density at scale, but regresses on benchmarks (84.2% vs 96.6%)
4. **Local-only** — no cloud, no API calls for storage/retrieval

## Honest assessment (from maintainers' own correction, April 7)
- AAAK token savings were overstated (actually increases tokens at small scale)
- "30x lossless compression" was wrong — it's lossy
- "+34% palace boost" is just metadata filtering (standard ChromaDB)
- Contradiction detection exists but not wired in yet
- The 96.6% number IS real and independently reproduced

## Relevance to us (OpenClaw/Kagura)
- **Our approach**: file-based memory (MEMORY.md + daily notes) + memex semantic search
- **Their approach**: ChromaDB verbatim storage + spatial metadata filtering
- **Key difference**: We curate (write summaries/notes), they store raw. Both have merit.
- **What we could learn**: Their "store everything" approach avoids the "AI decided it wasn't important" failure mode
- **What they could learn from us**: Curated notes are more token-efficient and maintain narrative coherence
- **Interesting parallel**: Their wings/rooms ≈ our wiki structure (projects/cards)
- **AAAK**: Their compression dialect is interesting but currently loses too much fidelity. Our approach of structured notes is a different kind of "compression"

## Trends this signals
- Memory is the hot problem in agent infra (38k stars in 5 days = massive demand)
- "Verbatim > summary" is gaining traction as a design philosophy
- ChromaDB is the default vector store for local AI memory
- MCP is the expected integration path

## First seen
2026-04-10, study #58 scout
