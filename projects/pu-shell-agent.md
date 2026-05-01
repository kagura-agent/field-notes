---
title: "pu.sh — Minimal Shell Coding Agent"
created: 2026-05-01
updated: 2026-05-01
tags: [agent-harness, shell, minimal, coding-agent]
source: https://github.com/NahimNasser/pu
stars: 53
status: active
---

# pu.sh — A Coding Agent in 400 Lines of Shell

A complete coding-agent harness in pure POSIX-ish shell. No npm, no pip, no Docker — just `curl`, `awk`, and an API key. Appeared on HN front page (66pts, 2026-04-30).

## Why It Matters

Proves that a functional coding agent needs surprisingly little infrastructure. While most agent frameworks ship 10K+ lines of TypeScript/Python, pu.sh achieves a working agent loop in 391 lines of shell.

## Architecture

Single-loop design:
```
user prompt → provider API → tool call → shell tool → tool result → repeat → final answer
```

### 7 Tools Only
`bash`, `read`, `write`, `edit`, `grep`, `find`, `ls` — no browser, no MCP, no skill system. The bare minimum for code exploration and editing.

### Dual Provider Support
- **Anthropic**: `/v1/messages` with `tool_use` / `tool_result` content blocks
- **OpenAI**: `/v1/responses` with `function_call` / `function_call_output` items
- Key insight: OpenAI requires `reasoning` items to be kept with their `function_call` — stripping reasoning during compaction causes provider errors

### JSON Parsing in Pure AWK
Custom `jp()` function does targeted JSON extraction without `jq`. Handles Unicode escapes, surrogate pairs, nested objects. Not a general parser — targeted extraction only. This is the most complex part of the codebase.

### Context Compaction
Byte-based (not token-based) compaction when transcript exceeds `CTX_LIMIT - RESERVE`:
1. Split transcript into top-level JSON entries
2. Keep ~80KB of recent tail (configurable)
3. Ask the model itself to summarize older context into a structured memory card
4. Rebuild as `[first message, summary, recent tail]`
5. Fallback chain: summary+tail → summary only → local compaction → last resort

Inspired by [[openclaw]]'s Pi compaction but much simpler. Trade-off: less precise (byte vs token counting) but zero dependencies.

### Safety Fuses
- `MAX_STEPS=100` — prevents runaway loops
- `AGENT_CONFIRM=1` — optional per-tool-call approval
- `AGENT_READ_MAX=1M` — refuses huge whole-file reads
- `AGENT_TOOL_TRUNC=100K` — truncates large tool output
- No sandbox — explicit design choice, runs with user permissions

## Key Design Decisions

1. **No streaming**: Simpler implementation, but means no incremental output during long model thinking
2. **No sandbox**: Trust the user, keep the harness simple
3. **Directory-local state**: `.pu-history.json` per directory = implicit project isolation
4. **Dual file strategy**: `.pu-history.json` (provider-shaped transcript) vs `.pu-events.jsonl` (human-readable event log)
5. **Effort/thinking support**: Adaptive thinking for Claude, reasoning effort for OpenAI — configurable per session

## Anti-Patterns Avoided

- No dependency tree (contrast: most agent frameworks pull hundreds of packages)
- No plugin/extension system — just 7 hardcoded tools
- No TUI — simple readline prompt
- No config files beyond `~/.pu.env`

## Relation to Our Direction

- **Contrast with [[openclaw]]**: OpenClaw is the full production runtime (skills, MCP, channels, memory, cron). pu.sh is the opposite end — proves the core loop is tiny
- **Compaction comparison**: Both use "ask model to summarize" approach, but OpenClaw has token-aware, turn-aware compaction while pu.sh uses byte budgets
- **Tool design**: pu.sh's `edit` tool (exact text replacement) is the same pattern as OpenClaw/Claude Code — this is becoming the standard
- **Lesson**: The agent loop itself is commodity. Value is in everything around it: memory, skills, channels, safety, orchestration

## Limitations

- No real JSON parser → fragile on edge cases
- Byte-based context budget → imprecise, especially for non-ASCII
- No multi-agent / subagent support
- Single-session only (no persistent memory across directories)
- Anthropic + OpenAI only

## See Also

- [[openclaw]] — full production agent runtime
- [[skill-ecosystem]] — the layer pu.sh doesn't have
- [[agent-experience-capitalization]] — learning from agent sessions
