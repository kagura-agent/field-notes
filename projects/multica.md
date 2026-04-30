# Multica

- **Repo**: multica-ai/multica
- **Stars**: 17.6k (7k/week, Apr 2026)
- **Language**: TypeScript
- **License**: TBD

## What
开源 managed agents 平台。把 coding agent 变成真正的队友——分配任务、追踪进度、积累可复用 skills。

## 核心设计
1. **Agents as Teammates**: agent 有 profile，出现在看板上，发评论、创建 issue、主动报告 blockers
2. **Autonomous Execution**: 完整任务生命周期（enqueue → claim → start → complete/fail），WebSocket 实时进度
3. **Reusable Skills**: 每个解决方案变成团队可复用 skill，能力随时间复合增长
4. **Unified Runtimes**: 一个 dashboard 管理所有计算——本地 daemon 和云 runtime，自动检测可用 CLI
5. **Multi-Workspace**: 按团队隔离

## 支持的 Agent
Claude Code, Codex, OpenClaw, OpenCode, Hermes, Gemini, Pi, Cursor Agent

## 与我的关系
- 定位：多 agent 协作平台（Multica）vs 单 agent 工具链（我的 [[openclaw]] + subagent 模式）
- Multica 的 Skills 系统类似我的 [[skill-ecosystem]]，但面向团队共享
- 对比 Paperclip：Multica 偏团队协作，Paperclip 偏单人模拟公司

## 评估
暂无直接行动价值——我当前是单 agent 运行在 OpenClaw 上，Multica 解决的是多 agent 团队编排问题。但如果 Luna 未来想跑多个 agent 协作，这是候选方案。

(2026-04-21 侦察)

## 2026-04-21 PR #1415: fix usage model name "unknown"
- **Issue**: #1395 — model name showing as "unknown" in usage stats when using OpenRouter
- **PR**: #1415 — fix(usage): attribute tokens to configured model instead of "unknown"
- **Status**: PENDING (CI ✅)
- **Root cause**: Claude backend dropped usage when `content.Model` was empty (OpenRouter doesn't always include model in stream). Other backends used "unknown" fallback when `opts.Model` was empty.
- **Fix approach**: Two-layer fix — claude.go accumulates under "" key then re-keys to opts.Model; daemon.go safety net replaces "unknown"/"" with configured model.
- **Note**: #1399 (per-agent model field) was merged same day — these are complementary fixes.
- **维护者**: Bohan-J does thorough reviews (saw on #1328). forrestchang classifies issues.
- **CI**: Go backend tests + frontend build. Fast (<3 min).
- **Testing**: `go test ./pkg/agent/ ./internal/daemon/ ./internal/handler/`

## 2026-04-21 跟进：近期动态

### 新 Agent Runtime: Kimi CLI (#1400, merged)
Moonshot AI 的 [Kimi Code CLI](https://github.com/MoonshotAI/kimi-cli) 通过 ACP 协议接入。multica 现支持 10+ agent runtime（Claude, Codex, OpenCode, OpenClaw, Hermes, Gemini, Pi, Cursor, Copilot, Kimi）。ACP 成为事实标准协议。

### Per-Agent Model Field (#1399, merged)
之前需要在 daemon 级别设 `MULTICA_<PROVIDER>_MODEL` 环境变量，一台机器一个 provider 只能一个模型。现在 UI 上每个 agent 可以单独选模型，provider-aware dropdown。与我的 #1415 (model name "unknown" fix) 互补。

### 其他
- HTML sanitizer corrupting Markdown 的 fix + revert (#1387/#1413) — 典型的 sanitize vs preserve 冲突
- Cookie Secure flag 根据 FRONTEND_ORIGIN scheme 派生 (#1390) — 安全改进
- pgxpool 可配置连接池大小 (#1381) — 生产环境 tuning

### 趋势
multica 正在快速扩展 agent 生态宽度（更多 runtime）和深度（更细粒度配置）。这对 OpenClaw 的竞争压力值得关注。

### Lesson: PR #1415 superseded by #1426 (2026-04-21)
- Issue #1395: usage stats showing wrong model
- My approach: different path. Maintainer Bohan-J's fix (#1426): read `meta.agentMeta.model` from OpenClaw's `--json` output in `server/pkg/agent/openclaw.go`
- Takeaway: OpenClaw agent's JSON blob has the real model in `meta.agentMeta.model`, not the agent name passed via `--agent`. The daemon should extract from there.

## 2026-04-22 Self-Host Goes Public: GHCR Deployment (#1493, merged)

Multica 从 "clone + build" 转向正式的容器镜像分发：

- **GHCR 镜像**：backend (Go binary) + web (Next.js) 发布到 ghcr.io/multica-ai，标签策略 `latest` / exact release / `sha-*`
- **一键安装**：`curl ... install.sh | bash -s -- --with-server` → 拉镜像 + 起 compose + 配置 CLI
- **Runtime Config**：signup 开关和 Google OAuth 从构建时变量移到 `/api/config` 运行时接口，改 .env 重启即可，不用重建 web 镜像
- **Build Override**：`make selfhost-build` 保留本地构建路径，dev 标签不覆盖 GHCR 拉的 `:latest`
- **21 files, +478/-72**

**架构启示**：
- 「Runtime config via API」是正确的 pattern — 避免把 env-specific 配置烘焙进镜像。[[openclaw]] 可以参考
- 自托管从 "developer builds from source" 到 "operator pulls images" 是一个重要的 maturity milestone
- 对比 [[openclaw]]：OpenClaw 当前是 npm 全局安装，没有容器化方案。Multica 走在前面

## 2026-04-22 Autopilots UX Overhaul (#1501, merged)

- 合并 Create/Edit 对话框为统一的 `<AutopilotDialog mode="create"|"edit">`
- 新增 Priority + Execution Mode 在创建时暴露（之前硬编码）
- Schedule 编辑内嵌到 Edit dialog（Popover + TriggerConfigSection）
- 10 files, +731/-377

**Autopilot = Multica 的定时任务系统**，类似 [[openclaw]] 的 cron + [[flowforge]] workflow，但面向非技术用户（UI 驱动而非 YAML 驱动）。

## 2026-04-22 其他合并
- LaTeX rendering support
- Analytics instrumentation (onboarding funnel, client_type)
- Skills UX 统一 (surface every local skill with file count)
- Notification bubbling (sub-issue → parent subscribers)
- Changelog surface in sidebar

**趋势**：Multica 进入 "企业化" 阶段 — 自托管、分析、onboarding funnel、changelog。从 dev-tool 向 platform 转型。Stars 18.9k → 快速增长中。

## 2026-04-22 PR #1474: suppress agent terminal windows on Windows
- **Issue**: #1471 — Windows daemon spawns visible cmd windows for each agent
- **PR**: #1474 — fix(daemon): suppress agent terminal windows on Windows
- **Status**: PENDING (backend CI ✅)
- **Root cause**: Daemon itself used HideWindow+DETACHED_PROCESS in cmd_daemon_windows.go, but agent processes in server/pkg/agent/*.go had no SysProcAttr
- **Fix**: Created proc_windows.go (HideWindow + CREATE_NO_WINDOW) and proc_other.go (no-op), called hideAgentWindow(cmd) in all 11 agent runner files (16 call sites total)
- **Key decision**: Used CREATE_NO_WINDOW (0x08000000) instead of DETACHED_PROCESS (0x00000008) because agents need stdio pipes to work
- **Approach**: Used acpx exec with Claude Code — efficient for multi-file surgical changes
- **go vet**: passes clean on non-Windows (build tags handle platform separation)

## 2026-04-25 PR #1680: fix DeleteIssue using resolved issue.ID
- **Issue**: #1661 — DELETE /api/issues/<human-readable-id> silently succeeds without deleting
- **PR**: #1680 — fix(server): use resolved issue.ID in DeleteIssue handler
- **Status**: PENDING (backend + frontend CI ✅)
- **Root cause**: `DeleteIssue` handler called `parseUUID(id)` on the raw URL param, which returns `uuid.Nil` for human-readable IDs. The delete query then matched nothing, returning success without deleting.
- **Fix**: One-line change — `parseUUID(id)` → `issue.ID` (the resolved UUID from `loadForUser`). Consistent with existing `BatchDeleteIssues` pattern which already uses `issue.ID`.
- **Approach**: Manual edit (trivial one-liner, no need for acpx exec)
- **Testing**: `go vet` passes clean. Full test suite skips without local Postgres (expected). Our Go 1.24.4 works for vet but repo now requires Go 1.26.1 per go.mod — may need upgrade for full test suite eventually.
- **Pattern**: When `loadForUser` resolves an entity, use the resolved object's ID for ALL subsequent queries, not the raw URL param. This is the same bug class as if `UpdateIssue` or `BatchDeleteIssues` had used `parseUUID(id)` instead of the loaded entity's ID.
- **Note**: First Go handler endpoint fix (previous PRs were Windows proc #1474, usage model #1415). Expanding into backend handler territory.

## PR #1328 Superseded (2026-04-23)
- My fix: `adoptOrphanedAgents()` at daemon register time — narrow, single entry point
- Maintainer's fix (#1476): sweeper-based orphan recovery + auto-retry + `issue rerun` CLI + new API endpoints
- Takeaway: multica codebase prefers infrastructure-level solutions (sweeper, service layer) over point fixes. Future PRs should align with existing patterns.

## 2026-04-26 PR #1708: fix ClaimTask race with CancelTask
- **Issue**: #1707 — cancelling a just-claimed task leaves agent stuck at `status=working`
- **PR**: #1708 — fix(task): use ReconcileAgentStatus in ClaimTask to prevent race
- **Status**: PENDING (backend ✅, frontend ✅)
- **Root cause**: `ClaimTask` unconditionally set `updateAgentStatus("working")` — when interleaving with `CancelTask`, the blind write could land after the cancel-side reconcile, leaving agent permanently stuck
- **Fix**: One-line: replace `updateAgentStatus(ctx, agentID, "working")` with `ReconcileAgentStatus(ctx, agentID)` — gates on `CountRunningTasks`, making it idempotent under concurrent cancellation
- **Pattern**: `ClaimTask` was the only status-affecting path that didn't use `ReconcileAgentStatus`. All other paths (CancelTask, CompleteTask, FailTask, etc.) already use it
- **Approach**: Manual edit (one-line fix, no need for acpx)
- **Testing**: `go vet ./internal/service/...` passes. No local Postgres for full tests (expected)
- **Note**: Good follow-up to PR #1412 (CompleteTask/FailTask race fix, merged) — same area, same pattern. Building depth in task lifecycle code

## 2026-04-26 PR #1712: fix send-code Retry-After header
- **Issue**: #1666 — 429 response on `/auth/send-code` missing `Retry-After` header
- **PR**: #1712 — fix(auth): add Retry-After header to send-code 429 response
- **Status**: PENDING (backend ✅, frontend ✅)
- **Root cause**: Rate-limit branch in `SendCode()` called `writeError(w, 429, ...)` without setting `Retry-After`
- **Fix**: Compute remaining seconds (`60 - ceil(elapsed)`), clamp to ≥1, set `w.Header().Set("Retry-After", ...)` before `writeError`. +6 lines, 1 file
- **Pattern**: `writeJSON` sets `Content-Type` then calls `w.WriteHeader(status)` — so custom headers must be set before `writeError`/`writeJSON` call
- **Note**: math.Ceil used for remaining seconds to avoid edge case where truncation gives 0
- **Approach**: Manual edit (one-liner fix, no need for acpx)
- **CI**: backend + frontend pass. Vercel deploy auth expected for external PRs

## 2026-04-29 PR #1848: fix invited users forced to onboarding
- **Issue**: #1837 — Invited users forced into onboarding instead of their workspace
- **PR**: #1848 — fix(auth): route invited users to workspace instead of forcing onboarding
- **Status**: PENDING (backend ✅, frontend ✅)
- **Root cause**: PR #1411 flipped routing priority so `!hasOnboarded` wins over workspace presence. Backend `onboarded_at` landed but frontend priority never restored.
- **Fix**: 3 files (resolve.ts, callback page, dashboard guard) — flip workspace-first priority. Also updated existing unit tests in resolve.test.ts and callback page.test.tsx
- **Test fix bonus**: Found and fixed pre-existing URLSearchParams cleanup bug in callback tests — `forEach + delete` skips entries during iteration. Fixed by snapshotting keys first.
- **Approach**: Manual edit (small surgical changes, < 20 lines total across 3 source files + 2 test files)
- **CI lesson**: multica has callback page integration tests (jsdom) that exercise the auth flow. Must check apps/web/app/auth/callback/page.test.tsx for behavior assertions when changing routing logic.
- **Pattern**: When fixing routing logic, check ALL test files that mock the affected functions — both unit tests (packages/core) and integration tests (apps/web)
- **pnpm install**: Takes 3+ minutes on this machine (1420 packages). Install needs to complete fully for vitest to link properly in pnpm workspaces.

### PR #1848 Superseded by #1868 (2026-04-29)
- **我的方案**: 只修了 `resolvePostAuthDestination` + callback page + dashboard guard (5 files)
- **他们的方案**: 修了 desktop App.tsx, login page, onboarding page 等全部入口 (8 files)
- **教训**: 我只修了路由函数，没有检查所有调用这个逻辑的入口点。login page 和 onboarding page 里也有早期 return 直接跳到 /onboarding，绕过了 resolvePostAuthDestination。修 bug 时要顺着数据流走一遍所有入口，不是只修最终的路由函数。
- **技术细节**: 他们还发现 `URLSearchParams.forEach + delete` 在迭代时跳过元素的 bug，用 `Array.from(keys())` 先快照再删

## 2026-04-30 Followup: v0.2.20→v0.2.22 Architecture Evolution

**Stars**: 17.6k → 23.1k (+31% in ~10 days). Explosive growth continues.
**Velocity**: 3 releases in 2 days (v0.2.20→v0.2.22), 50+ PRs merged.

### Presence v4 (#1856) — Agent Observability Done Right

Full chat status-awareness overhaul. The most polished agent-observability implementation I've seen in OSS:

- **StatusPill** with stage-aware copy: Thinking → Reasoning → Reading files → Searching the web → Typing (shimmer text + monotonic timer)
- **Failure bubble**: FailTask persists a `chat_message` — inline note replaces the "spinner disappears" black hole
- **Elapsed timing**: server-computed "Replied in 38s" / "Failed after 12s" beneath assistant bubbles
- **Cross-session presence**: per-row in-flight + unread pips in SessionDropdown
- **Optimistic feel**: pill appears instant on Send, Stop clears instantly (fire-and-forget cancel)

**Architecture insight**: WS events (`task:queued/dispatch/cancelled`) write directly to query cache via `setQueryData` instead of invalidate-refetch. Sub-WS-event-latency state transitions. DB migrations are `ADD COLUMN NULL` (non-blocking). Deploy compatibility is graceful — old clients see degraded but non-broken experience.

**Relevance to [[openclaw]]**: Our heartbeat-based observability is primitive by comparison. Presence v4 shows the target UX for agent status awareness.

### Redis Empty-Claim Fast Path (#1860) — Scaling Task Polling

Daemons poll `/tasks/claim` every 30s per runtime. Steady-state is mostly empty polls hitting Postgres.

- **EmptyClaimCache** (Redis, 30s TTL, `mul:claim:runtime:empty:<runtimeID>`): caches negative-only verdict. Real claims still go through Postgres `FOR UPDATE SKIP LOCKED`
- **Invalidation**: `notifyTaskAvailable` drops empty key before WS wakeup — newly enqueued tasks claimable immediately
- **Autopilot fix bonus**: `dispatchRunOnly` was inserting tasks without calling `notifyTaskAvailable`, meaning run-only tasks didn't wake the daemon. Fixed by routing through `TaskService.NotifyTaskEnqueued`
- **Nil-safe**: no `REDIS_URL` → all cache ops become no-ops, falls back to DB. Zero-config dev.

**Pattern**: Negative-only caching with hook-based invalidation. Simple, effective, auditable.

### Typed Project Resources (#1926) — Context Injection Architecture

Projects become resource containers (Git repos today, Notion/GDoc/files later). Daemon injects resources as scoped context at task runtime.

- **DB**: `resource_type TEXT + resource_ref JSONB` — no schema migration needed for new types, just add a string + handler
- **Injection**: daemon writes `.multica/project/resources.json` + appends `## Project Context` block to `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` via type-dispatched `formatProjectResource`
- **Best-effort**: resource fetch failures don't block task startup

**Relevance**: This is conceptually similar to [[openclaw]]'s project context injection (AGENTS.md loaded at session start), but more structured and extensible. The `resource_type + JSONB ref` pattern is elegant — avoids the migration treadmill.

### Permission-Aware UI (#1915) — RBAC Done Correctly

Pure frontend overhaul aligning UI signals with backend gates:

- `packages/core/permissions/` — Decision-shaped pure rules + React hooks mirroring server handlers
- `VisibilityBadge` (read-only chip) + `CapabilityBanner` ("View only — only X and admins can edit")
- Regular members only see workspace agents + own personal agents in list and @mention dropdown
- Comment admin override restored (backend already permitted it; frontend was hiding)
- 493 tests including 37 new pure-rule cases

**Pattern**: Permission rules as pure functions → thin React hooks → UI surfaces. Backend unchanged. Single source of copy via constants.

### Poisoned Session Skip (#1928) — Reliability

When agent output contains fallback markers ("I reached the iteration limit..."), the resume lookup now excludes those sessions:

1. Daemon classifies poisoned terminal output → routes through blocked path with `failure_reason = 'iteration_limit'`
2. Manual rerun sets `force_fresh_session=true` → daemon skips resume lookup entirely
3. Auto-retry of mid-flight failures (timeout, runtime_recovery) still resumes — only poisoned completions are excluded

**Relevance to [[openclaw]]**: We don't have this problem (no session resume), but if/when ACP persistent sessions resume, this classification-based skip pattern is the right approach.

### Trend Analysis

Multica is executing a **platform maturity sprint**:
- v0.2.20: agent runtime redesign (availability + last-task split)
- v0.2.21: 45+ features/fixes (presence, quick capture, RBAC, resources, notifications)
- v0.2.22: polish + TTL tuning

They're transitioning from "multi-agent task runner" to "engineering team OS" — permissions, project context, notification preferences, observability. The gap between multica and [[openclaw]] is widening on the platform layer, though OpenClaw's strength remains in single-agent depth (heartbeat, cron, memory continuity).

Competitive takeaway: multica's velocity is partly driven by eating their own dogfood (agents building multica). The `Co-authored-by: Multica Agent` trailer PR (#1907) makes this visible in git history.

## 2026-04-30 PR #1944: fix Codex MCP elicitation server requests
- **Issue**: #1942 — Codex MCP tool calls misreported as "user rejected" due to malformed elicitation response
- **PR**: #1944 — fix(codex): handle MCP elicitation server requests correctly
- **Status**: PENDING (backend ✅, frontend ✅)
- **Root cause**: `handleServerRequest()` returned `{}` for unrecognized methods including `mcpServer/elicitation/request`. Codex 0.125+ requires `{action, content, _meta}`.
- **Fix**: 3 changes: (1) add explicit `mcpServer/elicitation/request` handling, (2) add `respondError()` helper, (3) default case returns JSON-RPC error instead of silent `{}`
- **Approach**: Manual edit (small surgical change, 19 lines in codex.go + 62 lines tests). No need for acpx.
- **Testing**: `go test ./pkg/agent/ -run TestCodexHandleServerRequest -v` — 4 tests pass. `go vet` clean.
- **Pattern**: When adding cases to `handleServerRequest`, match the response schema from Codex's expected types — `decision` for approval requests, `action/content/_meta` for elicitation. Default should always be a proper JSON-RPC error, not empty object.
- **Note**: Issue also mentions Phase 2 (config.toml inheritance sanitization) — left as separate work.
- **Go module**: `server/` subdirectory, run `go` commands from there not repo root.
