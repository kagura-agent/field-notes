---
title: Friday Studio
created: 2026-05-05
updated: 2026-05-05
stars: 19
url: https://github.com/friday-platform/friday-studio
status: tracking
---

# Friday Studio

Self-hosted AI agent runtime — workspaces, MCP tools, skills, memory, and cron/webhook automations. Deno-based monorepo.

## Architecture

- **Daemon** (`atlasd`): Long-running Hono server managing workspace lifecycles, routing signals to agents
- **Workspace model**: Each workspace defines agents + signals + jobs in `workspace.yml`. Daemon routes incoming signals (HTTP, cron, platform messages) to the workspace runtime, which spawns sessions
- **Agent SDK**: TypeScript SDK (`@atlas/agent-sdk`) with Zod-validated schemas. Agents are code — you write a `handler` function, not a prompt file
- **Memory**: NATS JetStream-backed narrative stores. Post-2026-05 cleanup: narrative-only (removed retrieval/dedup/kv strategies). Interface: append, search, forget, history
- **Skills**: Versioned, hot-reloadable, publishable. Skill adapter interface with draft/version lifecycle. `atlas skill publish` workflow
- **Signals**: Cron timers (pause/resume API), HTTP webhooks, platform messages (Slack, Discord, Telegram, WhatsApp, Teams) via Chat SDK
- **MCP**: First-class MCP server config per agent
- **Tooling**: CLI (`atlas`), web playground (Svelte), Go tools (pty-server, webhook-tunnel, launcher)

## Key Design Decisions

1. **Deno monorepo** with workspace support — Go for system tools (pty, tunnels)
2. **Agents are code, not prompts**: `createAgent({ handler: ... })` — more structured than [[OpenClaw]]'s SKILL.md approach, but less accessible to non-devs
3. **NATS JetStream for memory** instead of file-based — durable streaming, but heavier infrastructure dependency
4. **Workspace isolation** — each workspace is a boundary for agents, signals, memory. Similar to [[OpenClaw]]'s workspace concept but more formalized
5. **Platform signals abstracted** through Chat SDK with webhook delegation — clean separation vs OpenClaw's channel plugin architecture

## Comparison to OpenClaw

| Aspect | Friday Studio | OpenClaw |
|--------|--------------|----------|
| Runtime | Deno daemon | Node.js gateway |
| Agent definition | TypeScript handler code | SKILL.md (natural language) |
| Memory | NATS JetStream narrative | File-based (markdown) |
| Skills | Versioned SDK objects | SKILL.md + file conventions |
| Cron | Daemon-managed timers | System cron + gateway |
| Messaging | Chat SDK webhooks | Channel plugins |
| Accessibility | Developer-first | User-first |

## Observations

- **Code-first vs prompt-first**: Friday requires TypeScript competence to define agents. OpenClaw's SKILL.md is arguably more "agent-native" — the agent reads instructions, not code. Trade-off: type safety vs accessibility
- **NATS dependency is heavy**: Requiring NATS for memory is serious infrastructure. OpenClaw's file-based approach (markdown in workspace) is simpler and more portable
- **Good signal abstraction**: The cron timer pause/resume API and platform signal delegation are well-designed. OpenClaw could benefit from similar cron management APIs
- **Small but well-structured**: 19⭐, but the codebase is professionally organized (monorepo, CI, CLA, SECURITY.md). Worth watching

## Relevance

- **Architectural comparison point** for [[OpenClaw]] — validates the workspace+cron+skills+messaging pattern
- **Signal**: More projects converging on the same architecture pattern (daemon + workspace + cron + multi-platform) — this is becoming the standard shape of agent runtimes
- **Cron management API** (pause/resume per-timer) is a feature gap in OpenClaw worth noting

## Links

- [[OpenClaw]], [[agent-skill-standard-convergence]], [[worktree-convergence-2026-05]]
