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

## Links
[[openclaw]] [[agentskills]] [[agent-as-router]]
