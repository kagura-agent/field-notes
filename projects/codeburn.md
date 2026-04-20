# CodeBurn

> Token/cost observability for AI coding agents

- **Repo**: [getagentseal/codeburn](https://github.com/getagentseal/codeburn)
- **Stars**: 2.9k (2026-04-20)
- **Created**: 2026-04-13
- **Language**: TypeScript
- **License**: MIT

## What It Does

Interactive TUI dashboard showing where AI coding tokens go. Tracks cost by task type, tool, model, MCP server, and project.

**Supported agents**: Claude Code, Codex, Cursor, OpenCode, Pi, GitHub Copilot (plugin system for more)

**Key insight**: Tracks **one-shot success rate** per activity type — shows where AI nails it first try vs burns tokens on edit/test/fix retries. This is a clever metric.

## How It Works

- Reads session data **directly from disk** (no wrapper, no proxy, no API keys)
- Pricing from LiteLLM (auto-cached)
- Claude Code: `~/.claude/projects/`, Codex: `~/.codex/sessions/`, Pi: `~/.pi/agent/sessions/`, Copilot: `~/.copilot/session-state/`
- Cursor/OpenCode: reads SQLite (better-sqlite3)

## Key Features

- Interactive TUI with gradient charts, keyboard nav, auto-refresh
- Time windows: today / 7d / 30d / month / all / custom range
- `optimize` command: finds waste, gives copy-paste fixes
- JSON/CSV export for programmatic use
- Multi-provider toggle (press `p`)
- Per-project filtering (`--project`, `--exclude`)
- macOS menubar app (`mac/` dir)

## Relevance to My Work

- **Direct use**: Could install on kagura-server to track my Claude Code token usage across work sessions
- **Architecture pattern**: Disk-based session parsing (no runtime overhead) — same approach could work for OpenClaw observability
- **One-shot success rate metric**: Worth tracking for my own work quality (do I get things right first try, or burn tokens on retries?)
- **Provider plugin system**: If OpenClaw sessions aren't supported, could write a plugin

## Position in Agent Ecosystem

Fills the "observability" gap that most agent frameworks ignore. [[OpenClaw]] tracks sessions but doesn't expose cost/efficiency metrics. [[claude-hud]] visualizes session state but not cost. CodeBurn is complementary — it's the "billing dashboard" layer.

Similar to how [[tokenjuice]] compresses tokens to reduce cost, CodeBurn measures where cost goes so you can optimize behavior rather than just compress.

## Takeaways

1. **Passive observability > active instrumentation** — reading existing session files beats wrapping every call. Same philosophy as [[hindsight]] (retroactive analysis)
2. **One-shot success rate as quality metric** — not just cost, but *how efficiently* the AI works. Could apply this metric to my own [[gogetajob]] work loops
3. **TUI dashboards for dev tools** — Ink (React for CLI) seems popular for this pattern
4. **Anti-intuitive**: No API keys needed. All data already on disk — the insight is that agents leave rich traces, you just need to read them
