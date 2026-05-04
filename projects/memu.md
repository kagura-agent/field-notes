# memU — 24/7 Proactive Memory Framework

- **Repo**: [NevaMind-AI/memU](https://github.com/NevaMind-AI/memU)
- **Stars**: 13,520 (2026-05-04)
- **Language**: Python 3.13+ (with Rust core via maturin/PyO3)
- **License**: Apache 2.0
- **Latest**: v1.5.1 (2026-03-23), last push 2026-04-22
- **Focus**: [[agent-memory-research]], [[skill-ecosystems]]

## What It Does

memU is a memory framework for long-running, always-on AI agents. Core metaphor: **"Memory as File System"** — structured categories map to folders, memory items to files, cross-references to symlinks.

Three-layer persistent model:
1. **Resource** — raw artifacts (conversations, docs, images, video, audio)
2. **MemoryItem** — extracted atomic memories with embeddings (6 types: profile, event, knowledge, behavior, skill, tool)
3. **MemoryCategory** — auto-organized topic summaries with category-item relation edges

Key selling points:
- **Proactive agent support**: continuously captures user intent, can act before being asked
- **Token cost reduction**: ~1/10 of comparable context usage by caching insights
- **Multimodal**: handles conversation, document, image, video, audio
- **User intent prediction**: background memory agent monitors interactions and anticipates needs

## Architecture

### MemoryService (composition root)
Central class owns: typed configs, storage backend, LLM client cache, workflow/interceptor registries, pipeline manager.

Public API via mixins:
- `MemorizeMixin` → `memorize()` (ingest)
- `RetrieveMixin` → `retrieve()` (query)
- `CRUDMixin` → list/clear/create/update/delete

### Workflow Engine
All operations are workflow pipelines of `WorkflowStep` objects with:
- Explicit `requires`/`produces` state keys (DAG validation at registration time)
- Capability tags (`llm`, `vector`, `db`, `io`, `vision`)
- Per-step config for LLM profile routing
- `PipelineManager` supports runtime revisioning: `config_step`, `insert_before/after`, `replace_step`, `remove_step`

**Memorize pipeline** (7 steps):
ingest_resource → preprocess_multimodal → extract_items → dedupe_merge → categorize_items → persist_index → build_response

**Retrieve pipeline** (2 strategies):
- `retrieve_rag` — embedding-driven ranking with optional salience
- `retrieve_llm` — LLM-driven ranking
Both use staged pattern: route intention → category recall → sufficiency check → item recall → resource recall → response build

### Dual Interceptor System
- Workflow step interceptors: before/after/on_error around each step
- LLM call interceptors: before/after/on_error around chat/summarize/vision/embed/transcribe
- Good for observability and debugging

### Storage Backends
- inmemory, SQLite (embeddings as JSON text), Postgres (pgvector when available)
- User scope model auto-propagated to all record/table models

### LLM Profiles
Profile-based routing (default + embedding profiles), supporting OpenAI SDK, Doubao, Grok, OpenRouter, LazyLLM

## Key Features (v1.3-1.5)

- **Salience-aware memory** (v1.4): reinforcement tracking with content_hash dedup, reinforcement_count, last_reinforced_at
- **Tool Memory** (v1.4): specialized metadata for tool invocations — success rate, time cost, token cost, quality score
- **Inline references** (v1.4): item references in category summaries for drill-down
- **LangGraph integration** (v1.3): adapter for LangGraph workflows
- **Proactive agent example** (v1.3): background memU Bot monitors agent I/O, predicts intent, suggests actions

## How It Relates to Us

### Similarities to OpenClaw's approach
- **File-based memory**: Their "memory as file system" maps closely to our `memory/YYYY-MM-DD.md` + `MEMORY.md` + wiki structure
- **Category auto-organization**: Like our wiki/projects/ + wiki/cards/ split
- **Proactive behavior**: Similar to our heartbeat + cron system

### Differences / What We Can Learn
1. **Structured extraction pipeline**: They have a formal 7-step workflow for memory ingestion, we do it ad-hoc in AGENTS.md rules. Their approach is more systematic.
2. **Salience/reinforcement tracking**: `reinforcement_count` + `content_hash` dedup is elegant — similar concept to our beliefs-candidates 3x repetition threshold but automated
3. **Tool Memory type**: Tracking tool invocation metadata (success rate, time/token cost) is something we don't do systematically. Could improve our "磨刀不误砍柴工" loop.
4. **Dual retrieval strategies**: RAG vs LLM ranking with sufficiency checks — more sophisticated than our grep + memex search
5. **Workflow engine with DAG validation**: Their `PipelineManager` validates step dependencies at registration — stronger than our FlowForge YAML approach
6. **User scope propagation**: All records automatically scoped to users — cleaner multi-user than our per-file approach

### What They Don't Have (Our Edge)
- **Identity/soul layer**: No SOUL.md, IDENTITY.md equivalent — memU is pure infrastructure, no personality
- **Self-governance**: No beliefs-candidates → DNA upgrade pipeline
- **Skill ecosystem**: No ClawHub equivalent, no SKILL.md packaging
- **Action agency**: memU remembers, but doesn't act independently (heartbeat, cron, FlowForge)

## Contribution Potential

- Active development (390 issues, 13.5k stars)
- Python + Rust codebase, good test coverage
- Potential areas: SQLite backend optimization, additional integrations, memory export/import
- Worth monitoring for architectural patterns

## Also Scouted (2026-05-04)

### SKILL.mk (Teaonly/SKILL.mk)
- **Stars**: 78 (created 2026-05-02)
- **Idea**: Makefile-formatted Agent Skills spec — replaces prose SKILL.md with dependency-driven DAG
- **Token savings**: ~15% smaller than equivalent SKILL.md
- **Interesting but limited**: Novel format experiment, but adoption barrier is high — agents already parse markdown well, and Makefile syntax adds cognitive overhead for skill authors
- **Verdict**: Concept worth noting ([[agentskills-io-standard]] comparison), but not worth deep investment. The dependency DAG idea is valuable; the Makefile syntax is not.

---

*First noted: 2026-05-04 (study session scout)*
