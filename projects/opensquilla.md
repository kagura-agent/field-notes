---
title: OpenSquilla — Token-Efficient AI Agent
created: 2026-05-10
updated: 2026-05-10
status: active
stars: 173
url: https://github.com/OpenSquilla/opensquilla
---

# OpenSquilla — Token-Efficient AI Agent

Apache-2.0, Python. 173⭐ in 4 days (created 2026-05-06). Self-described "microkernel AI agent."

## Core Idea

Three-lever token efficiency: **model selection × thinking depth × prompt compression**, all automated by a local ML classifier.

## SquillaRouter — the differentiator

A **local inference** message classifier that routes to 4 tiers without burning an LLM call:

| Tier | Model | Thinking | Prompt Policy |
|------|-------|----------|---------------|
| T0 | cheapest (flash/turbo) | none | P0: compressed, "answer directly" |
| T1 | `deepseek/deepseek-v4-flash` | low | P0: compressed |
| T2 | mid-tier | medium | standard |
| T3 | `anthropic/claude-opus-4.7` | high | P2: full, unmodified |

**Local classifier stack**: BGE-small-zh-v1.5 (ONNX) → TF-IDF + PCA + SVD features → LightGBM (main + aux heads) + MLP head. All shipped in-repo via Git LFS. Zero API cost for routing decisions.

**History-aware**: per-session routing history (last 5 decisions, 30min window) prevents flip-flopping between tiers mid-conversation.

**P0 prompt injection**: For simple messages, injects `[RESPONSE_POLICY: Answer directly, keep thinking short, avoid irrelevant expansion.]` — explicit instruction to the model to be terse.

## Context Overflow Management

Three policies, configurable per deployment:
- **auto_summarize** — call `session_manager.compact()` to collapse older history into a summary
- **hard_truncate** — drop oldest transcript entries until under budget
- **refuse** — short-circuit, don't invoke provider at all

Compaction uses chunked LLM summarization with configurable chunk ratios (default 40% of context window per chunk).

## Dream System (Memory Consolidation)

Automated cron-scheduled memory consolidation: `memory/*.md` → `MEMORY.md`
- **Phase 1**: LLM analyzes new daily files + current MEMORY.md, produces rationale
- **Phase 2**: Sub-agent with `read_file`/`edit_file` tools makes surgical edits to MEMORY.md

Essentially automated version of what we do manually. Cursor advances on success; TTL/FIFO sweeps processed files.

## Architecture Notes

- Shared `TurnRunner` across Web UI, CLI, and chat channels — single model loop
- Pluggable provider layer: OpenRouter, OpenAI, Anthropic, Ollama, DeepSeek, Gemini, Qwen/DashScope (~20 providers)
- SQLite-backed (migrations V001-V008 visible)
- Multi-agent support (scheduler with session fields, reservations, job tool policies)

## Anti-intuitive findings

1. **BGE-small-zh-v1.5** as the embedding model — Chinese-optimized. Suggests Chinese market focus despite English README. The topics list includes "openclaw" — they see us as comparable.
2. **Local ML classifier for routing** — most "smart routing" projects use an LLM to decide which LLM to call (recursive cost). OpenSquilla avoids this entirely with a trained classifier. Trade-off: requires training data and periodic retraining, but zero marginal cost per classification.
3. **Prompt policy injection** — P0 messages get an explicit `[RESPONSE_POLICY]` prefix telling the model to be brief. This is crude but probably effective for simple queries.

## Relevance to OpenClaw

| Aspect | OpenClaw | OpenSquilla |
|--------|----------|-------------|
| Model routing | Manual `/reasoning` toggle | Automated via local classifier |
| Thinking depth | User-controlled (off/low/medium/high) | Auto-derived from message complexity |
| Context overflow | Session compaction exists | 3 configurable policies |
| Memory consolidation | Manual memory/*.md → MEMORY.md | Automated "Dream" system |
| Prompt compression | [[skill-context-compression]] experiments | P0/P1/P2 prompt policies |

**What could we learn**: The local classifier approach is interesting but high-maintenance. More practically, the three-policy context overflow model (summarize/truncate/refuse) is cleaner than a single strategy. The automated memory consolidation ("Dream") validates our memory architecture direction.

**What they lack**: No skill ecosystem, no [[agentskills-io-standard]] concept, no multi-channel presence (they added Telegram recently). Their "token efficiency" is model-routing focused; ours is architecture-focused ([[thin-harness-fat-skills]]).

## Issues & Critiques

- Bug: `RuntimeError: aclose(): asynchronous generator is already running` in multi-agent tasks — async lifecycle management gaps
- Feature requests for cross-session fair queueing + per-channel caps (multi-tenant) — confirms this is a real production concern
- Feature request for provider-level model pinning — confirms benchmarking/cost accounting needs

## Position in Ecosystem

Positioned between [[genericagent]] (heavy governance) and lightweight coding agents. Differentiator is the token-efficiency angle. Comparable to [[deepclaude]] in cost arbitrage motivation but with a more sophisticated routing mechanism. The "dream" system overlaps with [[auto-memory]] concepts.

Links: [[context-budget]], [[skill-context-compression]], [[self-evolving-agent-landscape]], [[thin-harness-fat-skills]], [[deepclaude]], [[auto-memory]], [[genericagent]]
