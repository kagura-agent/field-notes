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

### Adoption evidence: open-design daemon (2026-05-01)

[[open-design]] (9.2k⭐) now supports 11 agent CLIs with 4 stream formats. 3 out of 4 structured protocols are ACP:
- `acp-json-rpc`: Hermes, Kimi, Kiro
- `pi-rpc`: Pi (own JSON-RPC, not ACP)
- `claude-stream-json`: Claude Code (proprietary)
- `plain`: 6 agents (raw stdout)

ACP is winning the structured agent communication race by adoption. Any CLI that implements ACP gets multi-platform support (OpenClaw, open-design, multica) for free.
- **Wrappers**: [[spawn-agent]] uses ACP to expose any agent as a Vercel AI SDK provider
- **Runtimes**: OpenClaw `sessions_spawn` with `runtime: "acp"` for gateway-managed agent sessions

## Links
[[openclaw]] [[agentskills]] [[agent-as-router]] [[spawn-agent]] [[cursor-sdk]]
