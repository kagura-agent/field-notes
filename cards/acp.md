# ACP (Agent Communication Protocol)

Protocol for inter-agent communication in OpenClaw and broader agent ecosystems.

## In OpenClaw
- `sessions_spawn` with `runtime: "acp"` creates ACP sessions
- Used to delegate work to coding agents (Codex, Claude Code)
- Thread-bound sessions persist across messages
- See [[acpx-exec-vs-acp-runtime]] for exec vs ACP runtime tradeoffs

## Broader Concept
- Standardized way for agents to discover, communicate with, and delegate to other agents
- Part of the "agent-as-router" vision: one agent orchestrating specialists
- Related to [[agent-as-router]], [[agent-marketplace-landscape]]

## Ecosystem adoption (2026-04-30)

ACP is becoming the de facto transport layer for coding agent interop:
- **Native ACP**: Cursor (`agent acp`), Copilot, Gemini CLI, OpenCode, Factory Droid, Pi
- **Shim-based**: Claude Code (`@agentclientprotocol/claude-agent-acp`), Codex (`@zed-industries/codex-acp`)
- **Wrappers**: [[spawn-agent]] uses ACP to expose any agent as a Vercel AI SDK provider
- **Runtimes**: OpenClaw `sessions_spawn` with `runtime: "acp"` for gateway-managed agent sessions

## Links
[[openclaw]] [[agentskills]] [[agent-as-router]] [[spawn-agent]] [[cursor-sdk]]
