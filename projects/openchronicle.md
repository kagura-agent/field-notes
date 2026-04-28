# OpenChronicle

Open-source, local-first memory for any tool-capable LLM agent. MIT-licensed. macOS-only (alpha). 1658⭐ in first 7 days (2026-04-28).

**Repo:** [Einsia/OpenChronicle](https://github.com/Einsia/OpenChronicle)
**Team:** Einsia (appears to be a small team, ~8 contributors, all Chinese developers based on names). Core maintainers: KMing-L (Qianli Ren), abmfy (Bowen Wang), Xiao-ao-jiang-hu.
**Stack:** Python 3.11+, uv, SQLite FTS5, LiteLLM, FastMCP, macOS AX Tree APIs (Swift helpers)

## What Problem Does It Solve?

OpenAI announced "Chronicle" — persistent memory from screen context. OpenChronicle is the open alternative: same idea (agents that remember your real working context), but local-first, model-agnostic, inspectable.

The core insight: **agents can't help you well without knowing what you've been doing.** Current MCP-connected agents see only what you explicitly pass them. OpenChronicle bridges the gap by continuously capturing screen context (via macOS Accessibility APIs), compressing it through a deterministic funnel, and making it queryable.

## Architecture — The Compression Funnel

Single-daemon architecture. One ingestion path, no modes. The pipeline is a 5-stage funnel:

### Stage 0: Capture (AX-first)
- **mac-ax-watcher** (Swift binary) subscribes to macOS AX notifications (window focus, typing, title changes, app activation)
- S0 dispatcher: debounce (3s for typing), dedup (1s same event), min-gap (2s between captures)
- S1 parser: enriches captures with `focused_element`, `visible_text`, `url`
- Content-fingerprint dedup: same screen content → no write, no session event
- **AX-first philosophy**: structured text cheaper than OCR, better for intent capture, smaller memory. Screenshots secondary.
- **Default ax_depth=100** because Electron apps (Claude Desktop, VS Code, Slack) nest content 20-60 layers deep

### Stage 1: Timeline (1-min blocks)
- Every 60s, scans closed 1-min windows
- LLM normalizes captures into activity entries — **normalization, NOT summarization**
- Critical rule: verbatim preservation of authored text, URLs, proper nouns
- Anti-hallucination: never cross-attribute between independent conversations in same app

### Stage 2: Session Management (3-rule cutter)
1. **Hard cut**: no events for 5 min → session ends
2. **Soft cut**: single unrelated app focused 3 min (unless frequent-switching detected)
3. **Timeout**: max 2h per session

### Stage 3: S2 Reducer (session → event-daily)
- Runs incrementally: flush every 5 min during active sessions + final on session end
- Writes to `event-YYYY-MM-DD.md` with time-ranged sub-tasks
- Novel: **drill-down breadcrumbs** — each sub-task gets an inline `read_recent_capture(at="14:30", app_name="Cursor")` so agents can bridge compressed → raw
- **Observed-regularity surfacing**: reducer flags behavioral patterns for the classifier to pick up

### Stage 4: Classifier (durable fact extraction)
- Runs on 30-min interval during sessions + trailing-window pass at session end
- Tool-call loop with 12-iteration cap: read_memory, search_memory, append, create, supersede, flag_compact, commit
- Writes to `user-*.md`, `project-*.md`, `tool-*.md`, `topic-*.md`, `person-*.md`, `org-*.md`
- **Strong anti-noise bias**: default is "write nothing." Must pass a 3-day durability test
- Pattern confirmation via search before writing borderline facts

### Stage 5: Compaction (on-demand)
- LLM rewrites overgrown files (soft limit 20K tokens, hard 50K)
- Fact-preservation check: rejects if >5% unique noun phrases lost

## Memory Format — Supersede-Not-Delete

Brilliant design choice. Plain Markdown files with YAML frontmatter + append-only entries. When facts change:
1. Old entry body wrapped in `~~strikethrough~~`
2. Old heading tagged `#superseded-by:{new_id}`
3. FTS row gets `superseded=1` (hidden from default search)
4. New entry appended

Nothing deleted. Full timeline preserved. Human-readable, greppable, diffable. SQLite FTS5 is a derived index — `rebuild-index` regenerates it from files any time.

Entry IDs: `YYYYMMDD-HHMM-xxxx` (6 hex from blake2s), collision-safe for heavy batched writes.

## Query Layer — MCP Server

Read-only MCP server at `127.0.0.1:8742/mcp` (Streamable HTTP). **All tools read-only** — no MCP tool can mutate memory. This is a hard guarantee.

Key tools:
- `list_memories` / `read_memory` / `search` / `recent_activity` — compressed memory layer
- `current_context` / `search_captures` / `read_recent_capture` — raw captures layer
- `get_schema` — memory organization spec

The two-layer design (compressed + raw) with drill-down breadcrumbs is elegant. Agents can start with compressed summaries and drill into raw screen content when needed.

Supports: Claude Code, Claude Desktop, Cursor, Codex, opencode, ChatGPT Desktop (via tunnel, with privacy caveats).

## Key Design Decisions & Tradeoffs

### What's Good
1. **AX-first over screenshots**: 10x cheaper, better for structured memory. Screenshots kept for future vision paths.
2. **Session as natural unit**: solves v1 problem of long sessions being under-reported after first append.
3. **Compression-first, classification-second**: bounded prompt size at each stage. Classifier sees session summaries, not raw AX dumps.
4. **Incremental processing**: flush every 5 min + classify every 30 min. No waiting for session end.
5. **Supersede semantics**: fact evolution without data loss. Much better than delete-and-rewrite.
6. **Verbatim preservation through the funnel**: authored text, URLs, proper nouns survive normalization. Critical for grounding.
7. **Anti-hallucination at every stage**: explicit rules against cross-attribution, context bleed, inference without evidence.
8. **One process, many tasks**: avoids IPC, keeps SQLite single-writer, WAL for concurrent readers.

### What's Limiting
1. **macOS only**: AX Tree APIs are Apple-specific. No Windows/Linux support.
2. **Heavy LLM dependency**: timeline (every minute), reducer (every 5 min), classifier (every 30 min). Could get expensive.
3. **No write-through from agents**: MCP is read-only. If an agent learns something new, it can't store it directly. Must go through capture buffer → normal pipeline.
4. **Privacy concern**: captures everything on screen (though password fields are redacted).
5. **No cross-device sync**: local-first means local-only.
6. **No Linux/headless mode**: tied to macOS AX APIs, no terminal-only or SSH-based capture.

## Comparison with Other Agent Memory Approaches

### vs [[memex]] (our wiki tool)
- Memex is manually-curated knowledge base with wikilinks. OpenChronicle is automatic capture from screen context.
- Different layers: Memex = intentional notes; OpenChronicle = ambient observation.
- Complementary, not competing. Could see OpenChronicle feeding facts into a Memex-like system.

### vs [[stash]] / conversation memory
- Stash captures within-conversation context. OpenChronicle captures cross-app screen context.
- OpenChronicle's scope is much broader — it knows what you did in Cursor, Slack, Chrome, etc.

### vs OpenClaw's current memory (MEMORY.md / memory/*.md)
- We use file-based daily logs + curated long-term memory. Manual curation.
- OpenChronicle automates the capture-compress-classify pipeline.
- Our supersede approach (beliefs-candidates → DNA/workflow/knowledge-base) is similar in spirit to their classifier → durable facts.
- Key difference: we don't capture screen context. Our memory comes from conversation + explicit observation.

### vs [[hindsight]] (Rewind.ai alternative)
- Hindsight focuses on screenshot-based recording + OCR search.
- OpenChronicle is AX-first (structured text) with screenshots secondary.
- OpenChronicle adds the LLM compression/classification layer that Hindsight lacks.

### vs [[engram]] / agent brain approaches
- Engram focuses on within-agent memory persistence.
- OpenChronicle focuses on capturing the human's context and making it available TO agents.
- Different direction: agent-self-memory vs human-context-for-agent.

## Relevance to Our Direction

### What We Can Learn
1. **Supersede-not-delete pattern**: Our beliefs-candidates.md approach is similar but less formalized. Their entry-level supersede with `#superseded-by` chain is cleaner than our manual updates.
2. **Compression funnel design**: Their 5-stage pipeline with bounded prompt sizes at each stage is a good pattern for any LLM-heavy processing.
3. **Anti-noise classifier**: Their "default is silence" + 3-day durability test + pattern confirmation search is a good template for any automated knowledge extraction.
4. **Drill-down breadcrumbs**: Linking compressed summaries to raw evidence is a pattern we could adopt for session logs → raw transcript access.
5. **Verbatim preservation philosophy**: "Normalization, not summarization" at the timeline stage is important for grounding downstream decisions.

### What Doesn't Apply (Yet)
1. **Screen capture**: We don't run on macOS desktop. Our context comes from chat channels + CLI, not screen AX trees.
2. **Ambient observation**: We're chat-first, not screen-first. Our "capture" happens through conversation, not surveillance.
3. **Single-user assumption**: They assume one user at one Mac. We handle multiple channels with different contexts.

### Potential Integration Points
- If OpenChronicle adds Linux support or a CLI/terminal capture mode, it could complement our chat-based memory
- Their MCP query layer design could inspire how we expose our own memory to external agents
- The memory format (Markdown + frontmatter + FTS) is similar enough to our wiki that tooling could be shared

## Technical Quality Assessment

**Code quality: High.** ~8400 lines of Python, well-structured modules, comprehensive tests (2277 lines), good separation of concerns. The prompts are carefully engineered with explicit anti-hallucination rules and verbatim preservation requirements.

**Architecture maturity: Early but thoughtful.** v0.1.0 alpha, but the v1→v2 evolution (per-capture → session-level writes) shows they've learned from real-world failures. The safety-net cron, retry logic, and concurrent-write protection (per-path locks) suggest production experience.

**Documentation: Excellent.** 1724 lines of docs covering every subsystem. Architecture doc includes sequence diagrams. Each decision is motivated.

## Why 1658⭐ in 7 Days?

1. **Timing**: OpenAI just announced Chronicle. Open alternative = instant demand.
2. **Real problem**: Agents without context are handicapped. Everyone building with LLMs feels this.
3. **Right positioning**: local-first + model-agnostic + inspectable hits all the trust buttons.
4. **Clean execution**: README is well-structured, comparison table is clear, the project looks credible.
5. **MCP integration**: Works with the tools people already use (Claude Code, Cursor, Codex).

## Links
[[memex]] [[agent-memory]] [[mcp]] [[self-evolving-agent-landscape]] [[hindsight]] [[engram]] [[stash]]
