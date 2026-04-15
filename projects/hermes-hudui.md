# hermes-hudui

Web UI consciousness monitor for [[hermes-agent]].

- **Repo**: joeynyc/hermes-hudui (890★, 2026-04-09)
- **License**: MIT
- **Author**: joeynyc (same as hermes-hud TUI)

## What It Does

Browser-based dashboard for Hermes agent state — 13 tabs: identity, memory, skills, sessions, cron, projects, health, costs, patterns, corrections, live chat.

## Architecture

- Python backend (FastAPI + WebSocket) + React/TypeScript frontend
- Reads `~/.hermes/` data directory via file watchers, real-time push via WebSocket
- No database — file-system-first, same as Hermes itself
- 4 cyberpunk themes, i18n (EN/CN), keyboard shortcuts, command palette

## Ecosystem Position

- Companion to hermes-hud (TUI version, same author)
- Parallel to [[rivonclaw]] (OpenClaw GUI layer, 252★)
- Part of growing "agent observability" trend — treating agent state as something to monitor, not just log

## Relevance

- Shows what agent dashboard UIs converge on: identity + memory + sessions + costs + live chat
- "Consciousness monitor" framing is interesting — agent state as observable phenomenon
- We contribute to hermes upstream; understanding its ecosystem tools helps

## See Also

- [[claude-code-routines]] — Anthropic's first-party cron/trigger system (validates OpenClaw architecture pattern)
