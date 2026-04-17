# Phantom (ghostwright)

> An AI co-worker with its own computer. Self-evolving, persistent memory, MCP server.

## Why This Project

Directly aligned with self-evolving agent direction. Phantom wraps the Claude Agent SDK with full computer access and has a self-evolution pipeline (observation extraction, validation gates, consolidation). 1,275 stars, very active — 5 PRs merged in a single day.

## Architecture

- **Runtime**: Bun + TypeScript
- **Agent**: Claude Agent SDK (Opus 4.7) — "TypeScript is plumbing, the Agent SDK is the brain"
- **Database**: SQLite (bun:sqlite) on persistent volume
- **Memory**: Three tiers — episodic, semantic (Qdrant), procedural
- **Evolution**: 6-step pipeline with 5 validation gates, quality judges
- **Channels**: CLI, Slack, Telegram, Email, Webhook, Web
- **Session Store**: `SessionStore` class in `src/agent/session-store.ts` — manages SDK session persistence

## Key Files

| File | Purpose |
|------|---------|
| `src/index.ts` | Main entry point, wires everything |
| `src/agent/runtime.ts` | Agent SDK calls, session management |
| `src/agent/session-store.ts` | Session CRUD, stale detection |
| `src/agent/prompt-assembler.ts` | System prompt construction |
| `src/evolution/engine.ts` | Self-evolution pipeline |
| `src/channels/cli.ts` | CLI channel (readline) |
| `src/memory/system.ts` | Memory coordinator |

## Testing & CI

- Test: `bun test` (1,584 tests)
- Lint: `bun run lint`
- Typecheck: `bun run typecheck`
- All three must pass before PR
- No CI on fork PRs (CI runs on upstream after merge)

## CONTRIBUTING.md Key Points

- Fork → branch from main → focused PR → tests + lint + typecheck
- **Cardinal Rule**: TypeScript = plumbing, Agent SDK = brain. Don't write TS for things the agent can do
- No inline dynamic tool handlers (`new Function()` removed for RCE prevention)
- No Docker/infrastructure changes from inside the agent

## Maintainer Style

- **mcheemaa** (primary): Active, merges in batches (v0.20 PR series), structured PR naming
- First interaction — need to observe review style on my PR #78

## PRs

| # | Status | What | Issue |
|---|--------|------|-------|
| 78 | OPEN | Clear stale SDK session IDs on startup to prevent CLI deadlock | #25 |
| 80 | OPEN | Webhook async polling: 202 + task_id on sync timeout, polling endpoint | #26 |

## Lessons & Notes

### 2026-04-17: First PR

- **Git clone issues**: Repo is 21MB but git clone consistently killed on kagura-server. Used GitHub API (git trees/blobs/commits) to create the branch and commit. This is a viable workaround for network issues.
- **Partial checkout trap**: Using `--filter=blob:none --no-checkout` and then checking out specific files makes `git add -A` stage everything else as deleted. For API-based commits, work in /tmp and use the GitHub API directly.
- **Session resume deadlock**: SDK session IDs are process-local. When SQLite is on persistent volume, container restarts leave stale IDs that cause impossible resume attempts. Fix: clear all IDs on startup.

### Discovery Channel

Found via `gh search repos "agent" --language TypeScript --stars "1000..10000"` — the description "Self-evolving, persistent memory" perfectly matches our direction.

### 2026-04-17: PR #80 — Webhook async polling

- **Issue #26**: Sync mode returns 504 on timeout, response lost. Fix: return 202 + task_id, add polling endpoint
- **Signature verification bug found**: HMAC was computed over full body including signature field (impossible to verify). Fixed by excluding signature field before HMAC computation
- **acpx timeout**: Claude Code via acpx timed out at 300s during TDD (was on test 2 of 4). Finished manually — lesson: for multi-test TDD, acpx 300s may not be enough. Consider splitting into smaller acpx calls or doing manual implementation
- **No CI on fork PRs**: Confirmed — CI only runs after upstream merge. Tests must pass locally
- **bun install required**: Fresh checkout needs `bun install` before lint works (biome is a devDep)
- **Biome lint rules to watch**: `noConfusingVoidType` (use `undefined` not `void` in type params), `noDelete` (use destructuring instead of `delete`)
