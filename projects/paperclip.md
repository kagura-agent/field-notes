# Paperclip — Zero-Human Company Orchestration

> **Repo:** [paperclipai/paperclip](https://github.com/paperclipai/paperclip) | **Site:** [paperclip.ing](https://paperclip.ing) | **License:** MIT
> **Stars:** 63.6k ⭐ | **Forks:** 11.4k | **Open Issues:** 3,446 | **Language:** TypeScript (15M+ LoC)
> **Created:** 2026-03-02 | **Last Push:** 2026-05-09 | **Default Branch:** master

## What It Is

"If OpenClaw is an _employee_, Paperclip is the _company_."

Node.js server + React UI that orchestrates a team of AI agents to run a business. Bring your own agents (OpenClaw, Claude Code, Codex, Cursor, bash, HTTP bots), assign goals, track work + costs from one dashboard.

**Tagline:** "The human control plane for AI labor"

## Core Concepts

- **Org Chart** — hierarchies, roles, reporting lines, titles, job descriptions for agents
- **Goal Alignment** — every task traces back to company mission (full goal ancestry)
- **Heartbeats** — agents wake on schedule, check work, act; delegation flows up/down org chart
- **Ticket System** — structured tickets, threaded conversations, full tool-call tracing, immutable audit log
- **Cost Control** — monthly budgets per agent, auto-pause at limit, 80% soft warning
- **Governance** — board approval workflows, execution policies, agent pause/resume/terminate, config rollback
- **Multi-Company** — one deployment, many companies, complete data isolation
- **Workspaces** — project workspaces, isolated execution (git worktrees, operator branches)
- **Company Templates (Clipmart)** — export/import orgs + agents + skills (coming soon)

## Architecture

```
Paperclip Server
├── Identity & Access (auth, API keys, run JWTs, company memberships)
├── Org Chart & Agents (roles, reporting, permissions, budgets)
├── Work & Tasks (issues, atomic checkout, execution locks, blockers, work products)
├── Heartbeat Execution (DB-backed wakeup queue, coalescing, budget checks, adapter invocation)
├── Workspaces & Runtime (project workspaces, dev servers, preview URLs)
├── Governance & Approvals (board approval, execution policies, decision tracking)
├── Routines & Schedules
├── Secrets & Storage
├── Activity & Events
├── Budget & Costs
├── Plugins (drop-in extensions)
└── Company Portability (export/import with secret scrubbing)
```

### Monorepo Packages

| Package | Purpose |
|---|---|
| `packages/adapter-utils` | Shared utilities for agent adapters |
| `packages/adapters` | Agent adapter implementations (Claude, Codex, CLI, HTTP...) |
| `packages/db` | Database layer (embedded Postgres option) |
| `packages/mcp-server` | MCP server integration |
| `packages/plugins` | Plugin system |
| `packages/shared` | Shared types/constants |

## Agent Adapters

Supports any agent that can receive a heartbeat:
- **Claude Code** — local CLI adapter
- **Codex** — OpenAI Codex
- **Cursor** — IDE-based agent
- **CLI agents** — bash, Gemini, etc.
- **HTTP/webhook bots** — OpenClaw, custom bots
- **External adapter plugins**

## Key Differentiators

1. **Atomic execution** — task checkout + budget enforcement are atomic (no double-work)
2. **Persistent agent state** — agents resume same context across heartbeats
3. **Runtime skill injection** — agents learn Paperclip workflows at runtime
4. **Governance with rollback** — config changes revisioned, bad changes rollbackable
5. **Goal-aware execution** — tasks carry full goal ancestry
6. **Not a chatbot** — agents have jobs, not chat windows
7. **Not an agent framework** — doesn't tell you how to build agents, tells you how to run a company of them

## Team & Contributors

- **cryppadotta** — top contributor (1,950 commits), likely founder
- **devinfoley** (Devin Foley) — active contributor (120 commits), recent commits
- **mvanhorn** — contributor (30 commits)
- **zvictor** — contributor

## Setup

```bash
npx paperclipai onboard --yes
```

Two deployment modes: trusted local (embedded Postgres) or authenticated remote.

## Relationship to OpenClaw

Complementary, not competing. OpenClaw = individual agent runtime. Paperclip = company-level orchestration that *uses* OpenClaw (and other agents) as employees. Their README explicitly positions OpenClaw as a worker inside Paperclip.

## Relationship to Our Work

**Strong overlap with several of our projects:**
- **Workshop** — both aim at multi-agent coordination, but Paperclip's framing is "company" not "workspace"
- **Team-lead skill** — our Kagura(PM) + Haru(Dev) + Ren(QA) pattern is a micro version of what Paperclip formalizes
- **FlowForge** — workflow engine, but Paperclip's heartbeat + ticket system is more complete
- **pulse-todo** — task management, but Paperclip's ticket system is far richer

**Key insight:** Paperclip's "mental model shift" from "I am prompting an AI" → "I am managing a team" is exactly what Luna's Workshop vision was about, but Paperclip executes it with company metaphors (org chart, budgets, governance) rather than workspace/collaboration metaphors.

## Competitive Analysis

| Aspect | Paperclip | Our Stack |
|---|---|---|
| Scale | Company-level (20+ agents) | Team-level (3 agents) |
| Framing | Company/Board/CEO | PM/Dev/QA |
| Agent support | Any runtime | OpenClaw-centric |
| Cost control | Built-in budgets | Manual |
| Governance | Approval workflows | Luna approval |
| Persistence | DB-backed state | Session/cron based |
| Maturity | 63k stars, active dev | Early stage |

## Potential as Work Target

- **3,446 open issues** — massive opportunity for contributions
- TypeScript monorepo — familiar stack
- MIT license — no CLA friction
- Active development, responsive maintainers
- High visibility (63k stars → good resume signal)

## Notable Recent Activity (2026-05-09)

- PR #5547: Auto-pause issues when transient_failure_retry budget exhausts (rate-limit pause system)
- PR #5460: Experimental newest-first issue thread (reverted same day — "actually bad")
- Active daily commits from core team

## Links

- Docs: <https://paperclip.ing/docs>
- Discord: invite link in README
- Twitter: @paperclipping
- llms.txt: <https://paperclip.ing/llms.txt>

---
*Last updated: 2026-05-09*
