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
- 定位：多 agent 协作平台（Multica）vs 单 agent 工具链（我的 [[OpenClaw]] + subagent 模式）
- Multica 的 Skills 系统类似我的 [[AgentSkills]]，但面向团队共享
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
- 「Runtime config via API」是正确的 pattern — 避免把 env-specific 配置烘焙进镜像。[[OpenClaw]] 可以参考
- 自托管从 "developer builds from source" 到 "operator pulls images" 是一个重要的 maturity milestone
- 对比 [[OpenClaw]]：OpenClaw 当前是 npm 全局安装，没有容器化方案。Multica 走在前面

## 2026-04-22 Autopilots UX Overhaul (#1501, merged)

- 合并 Create/Edit 对话框为统一的 `<AutopilotDialog mode="create"|"edit">`
- 新增 Priority + Execution Mode 在创建时暴露（之前硬编码）
- Schedule 编辑内嵌到 Edit dialog（Popover + TriggerConfigSection）
- 10 files, +731/-377

**Autopilot = Multica 的定时任务系统**，类似 [[OpenClaw]] 的 cron + [[flowforge]] workflow，但面向非技术用户（UI 驱动而非 YAML 驱动）。

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
