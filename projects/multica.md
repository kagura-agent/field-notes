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
