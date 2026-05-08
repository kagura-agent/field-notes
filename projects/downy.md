# Downy — OpenClaw Alternative on Cloudflare

- **Repo**: bensenescu/downy
- **Stars**: 157 (2026-05-08, created 04-30)
- **Language**: TypeScript
- **License**: MIT
- **Stack**: Cloudflare Workers + Durable Objects + D1 + R2 + Workers AI

## What It Is

Self-proclaimed "OpenClaw Alternative" — a single-user, self-hosted personal agent app running entirely on Cloudflare infrastructure. Multi-agent architecture where each agent gets its own Durable Object instance, personality, skills, tools, and workspace.

## Architecture — Key Insights

### Durable Object Per Agent
Each named agent is a `DownyAgent` extending `Think` (from `@cloudflare/think`). Each DO owns:
- Chat/session state
- Per-agent `Workspace` backed by DO SQLite + R2
- Live MCP connections
- Background task records
- Bootstrap state

This is fundamentally different from [[openclaw]]'s approach where the gateway manages agents centrally. Downy pushes agent state to the edge.

### Parent-Child Agent Model
`ChildAgent` is a background worker DO. It does NOT maintain an independent workspace — all file operations proxy through the parent `DownyAgent`. This keeps background task output in one place and avoids workspace sync issues. Similar concept to OpenClaw's subagent sessions, but with DO-level isolation.

### Identity Model (4 files, same as OpenClaw)
- `identity/SOUL.md` — agent-level (workspace)
- `identity/IDENTITY.md` — agent-level (workspace)
- `identity/MEMORY.md` — agent-level (workspace)
- `identity/USER.md` — **user-level** (shared D1, not per-agent)

The USER.md being shared across agents is a design choice OpenClaw doesn't make — each OpenClaw agent has its own USER.md. Downy's approach makes sense for single-user multi-agent: you're the same human to all your agents.

### Skill System
Skills are `skills/<name>/SKILL.md` with YAML frontmatter. Loader walks the skills directory, parses frontmatter, and presents a catalog in the system prompt. Supports companion files (reference docs) resolved one level deep from SKILL.md links. Very similar to [[agentskills-io-standard]] but with workspace storage instead of filesystem.

Tools for skill CRUD: `create_skill`, `update_skill`, `delete_skill`, `read_skill`, `list_skills`, `list_skill_files`.

### System Prompt — Triage Pattern
Every turn, the agent silently classifies the user's request:
1. **Quick reply** — inline
2. **Reasoning-heavy** — inline
3. **Tool-intensive** — dispatch via `spawn_background_task`

This is a formalized version of what [[openclaw]] agents do informally. The explicit `todo_write` tool for multi-step work with status tracking (pending/in_progress/completed/cancelled) is clean.

## Comparison with OpenClaw

| Aspect | Downy | OpenClaw |
|---|---|---|
| Hosting | Cloudflare (DO + R2 + D1) | Self-hosted (bare metal/VPS) |
| Agent isolation | DO per agent | Process-level |
| Workspace | R2 + DO SQLite | Local filesystem |
| Skills | Workspace-stored SKILL.md | Filesystem SKILL.md |
| Channels | Web UI only | Discord, Feishu, WhatsApp, Telegram, etc |
| MCP | Runtime connect/disconnect | Config-based |
| Default model | Kimi 2.6 (Workers AI) | Any provider |
| User model | Single-user | Multi-channel, multi-user |
| Background tasks | ChildAgent DO | Subagent sessions |
| Maturity | Brand new (04-30) | Established |

## Why This Matters

1. **Validation**: Someone saw OpenClaw and thought "I want this but on Cloudflare." That's market validation for the personal agent platform category.
2. **Cloudflare DO as agent runtime**: Using Durable Objects for agent state is architecturally interesting — hibernation, global distribution, no server management. But limits local tool access (no shell, no filesystem).
3. **Web-only limitation**: No messaging channel integration. Downy is a web app you visit; OpenClaw is an agent that lives in your existing channels. This is a fundamental UX difference.
4. **Naming**: Explicitly positioning as "OpenClaw Alternative" — using OpenClaw as the reference point, which speaks to OpenClaw's mindshare in this space.

## Weaknesses

- No channel integration (Discord, Telegram, etc.) — web-only
- Cloudflare dependency (can't run on a Raspberry Pi or local server)
- No exec/shell tool — agents can't run code
- Single-user only (by design, but limits team use)
- Brand new, <10 days old, "agentically engineered" (self-editing risk acknowledged in README)

## Tracking

- Created: 2026-04-30
- Last push: 2026-05-06
- Revisit: 2026-05-15 (check growth trajectory and feature additions)

Links: [[openclaw]], [[agentskills-io-standard]], [[skill-type-taxonomy]], [[self-evolving-agent-landscape]]
