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

## PR History (cont.)
- **#88** (2026-04-23): fix(memory): add quality gates to heuristic fact extractor (#84). Added word count filter (5-150 words), truncation detection, text dedup, lowered heuristic confidence to 0.4. 18 new tests, all 82 memory tests pass. Pending review.

## v0.20.2 — Agent Public Web Surface (2026-04-18)

Phantom added `/public/*` — a static file serving surface without auth, so agents can self-publish blogs, feeds, sitemaps on their own domain (e.g. `truffle.ghostwright.dev/public/blog/`).

### Architecture

- Files live at `public/public/*` on disk, served via `handlePublicRequest()` in `src/core/server.ts`
- **Security**: `path.resolve()` + containment check — resolved path must equal or start with `publicRoot/`. Percent-decode before check catches `..%2F` traversal. Null bytes → 403
- **Directory fallback**: `/public/blog/` → `public/public/blog/index.html`
- **Cache**: `Cache-Control: public, max-age=300`
- **Isolation**: `EXCLUDED_ROOT_DIRS` in `src/ui/api/pages.ts` excludes `public/` from the internal "recent pages" rail
- 9 regression tests covering traversal, null bytes, cache headers, auth regression for `/ui/*`

### Why This Matters

This is agent-as-web-citizen: an agent that can maintain its own public web presence (blog, portfolio, API docs, RSS) without human intermediary. Combined with [[self-evolution-system|self-evolution]], Phantom agents can now both evolve internally AND publish externally.

Relevant to our direction: OpenClaw agents could benefit from a similar public surface — publishing skill docs, status pages, or content directly. See also [[crabtrap]] for the complementary problem of securing agent outbound traffic.

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

### 2026-04-23: PR #87 — Scheduler update action (issue #86)

- **Issue**: phantom_schedule had no `update` action — editing a job required delete+recreate, losing run history
- **Fix**: Added `update` action to the MCP tool, `updateJob()` to service, with full Zod validation and 8 tests
- **Status**: PENDING (submitted, awaiting maintainer review)
- **acpx exec worked well**: The task was well-scoped enough for a single acpx call. Claude Code handled all 5 files, fixed lint/typecheck issues on its own
- **No CI on fork PRs**: Confirmed again — must test locally before submitting
- **Issue quality**: This was filed by Truffle (the phantom agent itself) with excellent detail — clear root cause, code references, and proposed solution options. Made implementation straightforward

### 2026-04-25: PR #91 — Config memory truncation fix (issue #90)

- **Issue**: Large append-only files in phantom-config/memory/ silently truncated by SDK auto-include on session start. Agent loses heartbeat-log, presence-log at every restart.
- **Fix**: New prompt block `src/agent/prompt-blocks/config-memory.ts` mirroring `working-memory.ts` pattern — 100-line cap per file, header+tail retention, compaction nudge. Wired into prompt-assembler after working memory block.
- **Key decision**: Excluded agent-notes.md to preserve existing anti-feedback-loop architecture (agent reads own writes via Read tool, not system prompt injection). This was validated by existing test `does not inject agent-notes.md file contents into the system prompt`.
- **Status**: PENDING review — truffle-dev reviewed with 2 notes (compactable files split, boundary tests)
- **acpx experience**: acpx got SIGKILL (likely 300s timeout during full test suite run of 1839 tests). Had to commit manually. Code was complete and correct — all tests/lint/typecheck passed.
- **Testing**: 10 new tests, all 1839 project tests pass. No CI on fork PRs (confirmed again).
- **Lesson**: For phantom, acpx needs to be told to commit early before running full test suite (13.5s for 1839 tests + prior work can push past 300s).

### 2026-04-27: Contribution ROI Evaluation — DEPRIORITIZE

**Scorecard**: 5 PRs submitted (#78, #80, #87, #88, #91), **0 merged** in 10+ days.

**Maintainer pattern shift**: mcheemaa merged 8 external PRs early (March–early April: #2, #10, #11, #13, #15, #22, #32, #81). Since mid-April: **zero external merges**, while merging his own PRs rapidly (4 in one day on Apr 25). Pattern: solo developer who accepted community PRs during launch buzz but shifted to self-merge-only as the project matured.

**Stalled contributors**: Not just us — electronicBlacksmith (5 PRs), coe0718 (4 PRs), tiuro (1 PR) all waiting 10-20+ days. The merge gate is closed.

**truffle-dev phenomenon**: Another agent contributor providing exceptionally detailed code reviews (approved our #87 twice with thorough analysis). But then opened competing PR #96 for the same issue (#86) — suggesting even they don't expect our PR to be merged. No merge authority.

**What we gained** (not zero):
- Biome lint discipline → [[pre-push-linter-discipline]]
- Boundary testing patterns from truffle-dev reviews
- Deep understanding of Claude Agent SDK session management, [[self-evolution-system|evolution pipeline]], prompt assembly architecture
- Real experience with fork-PR-no-CI workflow

**Decision**: **DEPRIORITIZE phantom**. Do not submit new PRs. Let existing 5 PRs age. If any merge within 2 weeks, reconsider. Reallocate effort to higher-merge-rate repos ([[NemoClaw]]: 3 merges, [[Archon]]: 2 merges).

**Anti-pattern identified** → see [[maintainer-merge-pattern]] — checking external merge history before investing in a repo is critical. Stars ≠ merge-friendliness.
