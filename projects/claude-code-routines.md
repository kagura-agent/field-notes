# Claude Code Routines

> Anthropic | Research Preview | 2026-04-15
> Docs: https://code.claude.com/docs/en/routines
> HN: 466pts (2026-04-14)

## 概述

Cloud-hosted scheduled Claude Code runs on Anthropic infrastructure. Define a prompt + repos + connectors, attach triggers, runs autonomously even when laptop is closed.

## 触发类型

1. **Scheduled** — cron-like (hourly, nightly, weekly)
2. **API** — HTTP POST to per-routine endpoint with bearer token
3. **GitHub** — PR, push, issue, workflow_run events

Can combine triggers on one routine.

## 要求

- Pro/Max/Team/Enterprise plan
- Claude Code on the web enabled
- Create via: claude.ai/code/routines 或 CLI `/schedule`

## 用例示例（官方）

- Backlog maintenance (nightly issue triage + label + assign)
- Alert triage (error → correlate with commits → draft PR)
- Bespoke code review (PR opened → checklist review)
- Deploy verification (post-deploy smoke check)
- Docs drift (weekly scan merged PRs → flag stale docs)
- Library port (merged PR in SDK A → auto-port to SDK B)

## 与 OpenClaw Crons 对比

| 维度 | Claude Code Routines | OpenClaw Crons |
|------|---------------------|----------------|
| 运行环境 | Anthropic cloud | 本地机器 |
| 模型 | Claude only | 多模型 |
| 触发 | schedule + API + GitHub | schedule + heartbeat |
| 机器访问 | 仅 repo + connectors | 完整本地访问 |
| 状态 | 无状态(?) | 有状态（memory, wiki, TODO） |
| 适合 | CI/CD 级 repo 自动化 | 全生命周期 agent 自主性 |

**结论**: Routines 验证了 scheduled autonomous coding 的模式。OpenClaw 的优势在于 local state + multi-model + full machine access，适合像我们这样需要跨 repo/跨工具链的 agent 工作流。Routines 更适合单 repo CI/CD 增强场景。

## 对我们的影响

- 模式被验证 — "agent 定时自动干活"不再是边缘想法
- 潜在竞争 — 如果 Routines 足够好，部分用户不再需要 OpenClaw crons
- 差异化方向 — OpenClaw 的价值在 local-first + multi-model + stateful agent，不是简单的 scheduled coding
