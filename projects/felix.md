---
title: "Felix — Single-Binary Agent Gateway"
created: 2026-05-03
source: https://github.com/sausheong/felix
stars: 16
language: Go
author: sausheong (Chang Sau Sheong)
status: active
revisit: 2026-05-10
tags: [agent-gateway, self-hosted, go, memory, knowledge-graph, mcp]
---

# Felix — Single-Binary Agent Gateway

Self-hosted Go agent gateway. Single binary, no runtime dependencies. Multi-provider LLM (Claude, GPT, Gemini, Qwen, Ollama). Runs entirely on user hardware.

## Why Interesting

Direct architectural peer to OpenClaw with overlapping philosophy (self-sufficient, robust, secure-by-default) but different implementation choices. Studying Felix reveals where the "personal agent gateway" design space is converging and where it diverges.

**Key signal**: Felix's skill loader explicitly parses **OpenClaw-format metadata** (`openclawMetadata` struct with `openclaw.requires.bins`). This means either (a) OpenClaw's skill format is becoming a de facto standard, or (b) the author studied OpenClaw specifically. Either way, it's an interoperability signal worth tracking. → [[library-skills]], [[agentskills-io-standard]]

## Architecture

### Memory — Dual Layer
- **BM25 lexical search** over Markdown files (`internal/memory/`), recalled automatically each turn
- **Optional vector search** via chromem-go (in-process, no external vector DB) when an embedding provider is configured
- On-disk embedding cache with model fingerprinting — model swap invalidates cache automatically
- All memory stored as plain Markdown in `~/.felix/`

Compare: OpenClaw uses dreaming + MEMORY.md + daily files. Felix uses BM25/vector search over structured entries. Both are file-based, both avoid external databases. Felix has more automatic retrieval (every turn); OpenClaw has more curated memory (dreaming distillation). → [[agent-memory-taxonomy]], [[dreaming]]

### Cortex Knowledge Graph (SQLite)
- **Separate from memory** — ingests completed conversation threads, extracts entities/facts/relationships
- Background async ingestion with WaitGroup tracking
- Trivial-thread filter (`ShouldIngest`) skips "ok"/"thanks" before spawning goroutine
- Per-agent Cortex clients sharing same SQLite DB (WAL mode permits concurrent pools)
- LLM-powered extraction (hybrid: deterministic + LLM extractor)

This is a layer OpenClaw doesn't have. The closest analog is dreaming's "possible lasting truths" extraction, but Felix's Cortex is structured graph data (entities + relationships), not free-form text. Worth monitoring whether graph-based recall outperforms BM25+embedding. → [[self-evolving-agent-landscape]]

### Compaction — Circuit Breaker Pattern
- Three-stage fallback chain for context window management
- Per-session circuit breaker: after `MaxConsecutiveFailures` (3) consecutive stage-3 drops, stops trying
- Breaker resets on genuine summarizer success (stage 1 or 2)
- Preventive (token threshold) + reactive (hit limit) + manual triggers
- Code comment explicitly credits **Claude Code's `MAX_CONSECUTIVE_AUTOCOMPACT_FAILURES`** pattern

Well-engineered compaction is table stakes for long-running agents. The circuit breaker is the interesting part — prevents runaway API costs when a session is irrecoverably over context limit. → [[worktree-convergence-2026-05]]

### Skills — OpenClaw-Compatible Format
- Markdown files with YAML frontmatter
- `openclawMetadata` struct: parses `openclaw.requires.bins` from skill YAML
- Lazy loading by agent on demand from system-prompt index
- Bundled starters: ffmpeg, imagemagick, pandoc, pdftotext, cortex
- User skills managed via Settings UI

### Session Storage
- Append-only JSONL with DAG view
- Splice-based compaction (never destructive)
- Cache-stability invariant: sorted tool defs, deterministic schema normalization so provider prompt caches keep hitting
- Stream-failure resilience: partial streaming output discarded, retries via non-streaming endpoint with identical prompt prefix

### Security Defaults
- Localhost-only binding
- Bash in allowlist mode (not full shell)
- SSRF protection: blocks internal IPs and cloud metadata endpoints
- Symlink resolution for file access containment
- Owner-only file permissions

### Provider Portability
- Cross-provider tool schema normalization: strips fields rejected by specific providers (Gemini drops `anyOf`/`oneOf`/`format`; OpenAI drops `$ref`/`definitions`)
- Per-agent reasoning mode mapped to provider-specific APIs (Claude thinking budgets, OpenAI reasoning_effort, Gemini ThinkingConfig)
- Context-window auto-detection from model identifier

## Position in Agent Ecosystem

Felix occupies the same niche as OpenClaw: **personal agent gateway for technical users**. Key differences:

| Dimension | Felix | OpenClaw |
|-----------|-------|----------|
| Language | Go | Node.js/TypeScript |
| Distribution | Single binary + macOS .pkg | npm package |
| Memory | BM25 + vector + knowledge graph | Dreaming + file-based |
| Skills | OpenClaw-compatible YAML+MD | Native SKILL.md |
| Messaging | CLI + web chat | Multi-channel (Discord, Feishu, Telegram, etc.) |
| Agent model | Multi-agent per install | Single agent + subagents |
| MCP | Client only | Client + growing ecosystem |
| Maturity | Very new (16⭐, Apr 2026) | Established |

Felix's strength is **architectural cleanliness** — Go's concurrency model fits the agent gateway pattern well. Its weakness is **reach** — CLI + web chat only, no messaging platform integration.

## Takeaways for Us

1. **Cortex knowledge graph** is the most novel component. If graph-based recall proves valuable, OpenClaw could add a similar layer (SQLite-backed entity/fact extraction from sessions).
2. **Compaction circuit breaker** is a proven pattern worth adopting — prevents runaway costs on broken sessions.
3. **OpenClaw skill format as interop standard** — Felix adopting it is a positive signal for the ecosystem. Strengthens the case for [[library-skills]] and [[agentskills-io-standard]].
4. **Cache-stability invariant** (sorted tool defs, deterministic schema) — practical optimization for reducing API costs with Anthropic/OpenAI prompt caching.

## Scout Context (2026-05-03)

Found during routine scout. 16⭐ but high code quality and active daily commits. Author appears to be building a serious personal tool, not a weekend project. The `sausheong/cortex` knowledge graph library is a separate Go package, suggesting deeper investment.

Revisit 05-10 to check growth trajectory and whether the cortex pattern gets adopted by others.
