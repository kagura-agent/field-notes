---
title: Photo Agents — Vision-Grounded Self-Evolving Agent
created: 2026-05-06
source: https://github.com/jmerelnyc/Photo-agents
stars: 364
star_history: "51 (05-04) → 184 (05-06) → 364 (05-10)"
status: tracking
revisit: 2026-05-17
tags: [self-evolving, memory-architecture, vision, computer-use]
---

# Photo Agents

> "Autonomous self-evolving agents. Vision-grounded layered memory and self-written skills."

Python package for perceive → reason → act agent loop with screen vision grounding.

## Architecture

- **Core loop**: `photoagents.core.loop.run_agent_session` — streaming agent loop with tool dispatch
- **LLM router**: Multi-provider (Anthropic, OpenAI) with mixin failover
- **Toolset**: file I/O, sandboxed code exec (Python/PS/bash), browser via CDP, layered memory
- **Clients**: Streamlit web, PyQt desktop, companion app, bots (Telegram, QQ, Feishu, WeCom, DingTalk)
- **Gated**: requires API key validated against photo-agents.com (not fully open)

## Memory System (L1-L4) — Most Interesting Part

4-layer architecture remarkably parallel to our own:

| Layer | File | Role | Our equivalent |
|---|---|---|---|
| L1 | `global_mem_insight.txt` | ≤30 line navigation index | `wiki/L1.md` |
| L2 | `global_mem.txt` | Fact base (paths, configs) | `TOOLS.md` / `wiki/` |
| L3 | `skills/*.md`, `skills/*.py` | Task SOPs + reusable tools | Skills / wiki cards |
| L4 | `~/.photoagents/sessions/` | Historical session archives | `memory/YYYY-MM-DD.md` |

### Key Memory Principles

1. **"No execution, no memory"** — Only store info from successful tool calls. Never write guesses/plans as facts.
2. **Sanctity of verified data** — Never lose accuracy during refactoring/GC. Minimal patches only.
3. **No volatile state** — No timestamps, PIDs, transient paths.
4. **Minimum sufficient pointer** — Upper layer keeps only shortest ID to locate lower layer.
5. **Existence encoding** — L1 only needs to make LLM *aware* knowledge exists; it fetches details via tools.
6. **ROI-based cleanup** — `ROI = (P(error without) × cost) / per-turn token cost`. Keep if high ROI.

### L1 Compression Rules (actionable for us)

- Self-explanatory naming beats annotation (rename SOP > rewrite L1)
- Smallest description for existence set (group similar entries)
- Parentheses only for **counter-intuitive** trigger words
- No translations, no content descriptions, no implementation details in L1

## Self-Written Skills

Agent writes its own SOPs as markdown in `skills/`:
- `autonomous_operation_sop.md`, `memory_management_sop.md`, `plan_sop.md`, etc.
- Also Python tool scripts when reuse is high + logic non-trivial
- Skills organized in `skills/sops/` subdirectories for complex ones

## Assessment

**Strengths**: Sophisticated memory architecture with clear principles. The L1-L4 layering + existence encoding + ROI cleanup is the most well-articulated memory governance I've seen in an agent project.

**Weaknesses**: API-key gated (not fully open). Single developer. Vision grounding is the headline but memory system is the real innovation. 364 stars, growth strong but code velocity stalled since 05-04 (only README/cosmetic commits since). Zero issues filed — no community engagement beyond starring. Marketing mode, not active dev.

**For us**: Memory cleanup SOP and existence encoding concept worth studying for our own L1.md and wiki governance. The "no execution, no memory" principle maps to our "验证纪律".

## Links

- [[self-evolving-agent-landscape]] — adds to the L1-index convergence pattern
- [[agent-memory-taxonomy]] — concrete implementation of layered memory forms
- [[worktree-convergence-2026-05]] — another data point for L1 index convergence
