# Agentara — 24/7 Personal Assistant

**Repo:** MagicCube/agentara | **Stars:** 221 | **Created:** 2026-03-05 | **Language:** TypeScript

## What It Is
A 24/7 personal assistant called "Tara" powered by Claude Code and OpenAI Codex. Multi-channel messaging, long-term memory, skills, task scheduling — all running locally.

## Core Architecture
- **Backend:** Bun + Hono + SQLite (Drizzle ORM)
- **Frontend:** React 19 + Vite 7 + Shadcn
- **Sessions:** JSONL persistence (same as OpenClaw)
- **Agent:** Claude Code / Codex via managed sessions
- **Channels:** Feishu/Lark (same as us!)
- **Skills:** 22 built-in skills including heartbeat, pulse, scheduled-tasks

## Why It Matters
This is the closest thing to what we're building with OpenClaw. Same channel (Feishu), same agent backend (Claude Code), same problems (session management, memory, scheduling). Created 2 weeks before us.

## Key Differences from Our Setup
| Aspect | Agentara | Our Setup |
|--------|----------|-----------|
| Runtime | Bun (standalone) | OpenClaw (gateway) |
| Agent | Claude Code / Codex via ACP-like sessions | Claude via OpenClaw embedded |
| Scheduling | Built-in cron + task queue | OpenClaw cron |
| Memory | SQLite + long-term | File-based (MEMORY.md) |
| Dashboard | React web UI | OpenClaw web UI |
| Skills | 22 built-in | ClawHub ecosystem |

## Interesting Skills
- `heartbeat` — same concept as OpenClaw heartbeat, might work better?
- `pulse` — periodic check-in, similar to our nudge plugin
- `fix-my-life` — life management, amusing but shows the "personal agent" vision
- `daily-hunt` — daily research, similar to our study workflow

## Insight
The convergent evolution is striking. Different teams independently arriving at: SOUL.md, heartbeat, skills, Feishu integration, session persistence, daily routines. This validates that "personal AI agent" is a real category, not just our niche experiment.

## Relevance
- Could be a contributor target (TypeScript, similar problem space)
- Their heartbeat implementation might solve our heartbeat bug workaround
- Worth watching for memory architecture patterns

---
*First noted: 2026-03-22*
