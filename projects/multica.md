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
