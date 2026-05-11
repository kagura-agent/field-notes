---
title: Poco-Claw
url: https://github.com/poco-ai/poco-claw
stars: 1318
created: 2026-01-08
last_updated: 2026-05-11
depth: 🔬 deep-dive
status: active
last_verified: 2026-05-11
---

# Poco-Claw — OpenClaw's Direct Competitor

MIT, 1,318⭐, 121 forks. 3-core-dev team (qychen2001: 502, ffy6511: 344, Phil-Fan: 190 commits). Very active, pushing daily. Self-describes as "a more beautiful and easier-to-use alternative to OpenClaw."

## Architecture

4-service monorepo:
- **Frontend** — Next.js 16 (App Router), React 19, Tailwind v4, shadcn/ui
- **Backend** — FastAPI, SQLAlchemy 2.0, PostgreSQL, Alembic migrations
- **Executor** — FastAPI + **Claude Agent SDK** (official), hook-based extensibility
- **Executor Manager** — FastAPI + APScheduler, task scheduling & dispatch

Flow: User → Frontend → Backend → Executor Manager → Executor → Claude Agent SDK → Callbacks → Backend → Frontend polling

## Key Design Decisions (from specs/constitution/)

### Chat-First, Task-Derived
The core pivot: conversations precede tasks. Users enter channels, chat, and **explicitly derive tasks from messages**. Tasks are not the entry point — they're spawned artifacts. This is the opposite of issue-centered execution.

Model: `Server → Conversation (Channel|DM) → Task → Agent`

### Agent Identity: 4-Layer Split
1. **Identity** — who the agent is (name, avatar, profile)
2. **Preset** — runtime config (model, capabilities, tools, sub-agents)
3. **Persistent State** — long-term state directory (MEMORY.md, knowledge, context)
4. **Runtime** — execution container instance

This is more explicit than our approach where SOUL.md conflates identity with some runtime concerns.

### Single-Writer Rule
Each agent gets **at most one writable persistent runtime**. Other tasks queue or get cloned read-only snapshots. This prevents concurrent state pollution — a problem we haven't formally addressed (our subagents can write to the same workspace concurrently).

### Temporary Runtimes
Read-only snapshot of persistent state + explicit merge back. Clean separation of exploratory work from committed state.

## Features
- **Sandbox**: Docker-based isolated containers, local directory mounting for self-hosted
- **IM**: DingTalk, Feishu, Telegram (embedded backend messaging)
- **Memory**: mem0-powered (preferences, project context, past interactions)
- **Channels**: Server/Channel/DM model (Discord-like)
- **Artifacts**: Render HTML, PDF, Markdown, images, videos, Xmind, Excalidraw, Drawio
- **Playback**: Replay command I/O, browser sessions, tool calls
- **Background execution**: Agent keeps running after browser closes
- **Mobile**: Control agent from phone
- **MCP & Skills**: Extensible tool ecosystem
- **Browser**: Built-in autonomous web research
- **Plan Mode**: Claude Code-style planning

## Spec-Driven Development

Notable: `specs/constitution/` directory with dated design specs written before implementation:
- 2026-05-04: Server/Channel/Agent persistence
- 2026-05-05: Channel shared context and artifacts
- 2026-05-06: Agent observability, tasks, and persistence
- 2026-05-07: Agent dispatch latency optimization
- 2026-05-08: Persistent agent message passing & tool injection

Plus `specs/research/` for exploratory investigations. This is a mature engineering process.

## Issues / Real Usage Signals

- Executor container won't exit (resource leak) — real production bug
- IM (Feishu) messages don't auto-refresh in web — integration gap
- Multi-tenant question (8 comments) — users want per-user sandboxes
- MCP tool errors — real usage, not README-ware

## Comparison with OpenClaw

| Dimension | OpenClaw | Poco-Claw |
|-----------|----------|-----------|
| Interface | CLI-first + channel adapters | Web UI-first + IM integration |
| Agent loop | Custom agent loop | Claude Agent SDK (official) |
| Identity | SOUL.md/AGENTS.md flat files | 4-layer DB-backed split |
| Sandbox | Direct host execution | Docker containers |
| Memory | Markdown files (MEMORY.md, wiki/) | mem0 (vector-based) |
| Collaboration | Single human + agent | Multi-user, multi-agent team |
| State protection | None (subagents share workspace) | Single-writer rule |
| IM | Discord, Feishu, Telegram, WhatsApp, etc. | DingTalk, Feishu, Telegram |
| Deployment | Node.js single process | Docker Compose (4 services + PG) |

## Strategic Insights

1. **Validates our channel model** — They independently arrived at conversation-as-primary-unit, confirming our intuition
2. **4-layer identity split is worth studying** — We conflate identity/preset/state; their explicit separation is cleaner for multi-agent scenarios
3. **Single-writer rule is a real gap for us** — Our subagents can concurrently write to `~/.openclaw/workspace/` without coordination. As we scale subagent usage, this will bite us
4. **Web UI vs CLI is a positioning choice, not a technical one** — They went polished UI; we went system-level access. Different markets
5. **Claude Agent SDK adoption** — They use the official SDK rather than rolling their own agent loop. Tradeoff: less control, faster integration with Anthropic updates
6. **Spec-driven development** — Their `specs/constitution/` approach is disciplined and worth emulating for our own major decisions

## Relevance to Our Direction

- **Not a threat**: Different market segments (team collaboration platform vs personal AI companion)
- **Design validation**: Chat-first, agent-as-teammate model confirms our direction
- **Architectural learning**: 4-layer identity split and single-writer rule are concrete improvements we could adopt
- **Competitive intelligence**: Shows where the "OpenClaw alternative" market is heading — Web UI, sandboxing, team features

## Related
- [[openclaw-architecture]] — our architecture for comparison
- [[self-evolving-agent-landscape]] — poco-claw operates at Agent Infrastructure layer
- [[skill-ecosystem]] — they support MCP & Skills, similar extensibility model
