# oh-my-codex (OMX)

> 研究日期: 2026-04-03 | 源码版本: v0.11.12 | Repo: Yeachan-Heo/oh-my-codex

## 定位
**Multi-agent orchestration layer for OpenAI Codex CLI**。不是替代 Codex，是在 Codex 之上加团队协作、HUD、hooks 扩展、通知集成。

## 核心模块

### 1. Team Orchestration (`src/team/`)
- **Staged pipeline**: plan → prd → exec → verify → fix (loop)
- 每个阶段有严格状态机（`TRANSITIONS` map），terminal states: complete/failed/cancelled
- **Fix loop** 有次数限制（默认 3），超限自动 fail
- **Runtime** (`runtime.ts`): 基于 tmux session，每个 worker 跑在独立 tmux pane
  - tmux-based multi-agent: lead session + worker panes
  - Worker 通过 stdin/tmux send-keys 接收指令
  - 有 heartbeat/status/inbox/mailbox 文件系统通信（`.omx/state/`）
  - Task claim/release/reclaim 机制（分布式锁的文件版）
  - Governance + Policy 层：控制 worker 行为边界
  - Monitor snapshot：实时状态快照

### 2. HUD (`src/hud/`)
- CLI 状态面板，类似 tmux statusline
- `omx hud` / `omx hud --watch` / `omx hud --tmux`（tmux split pane）
- Preset: minimal / focused / full
- 显示：git branch、token count、ralph iteration、autopilot phase、team phase、session metrics
- Authority tick：HUD 自带定时状态刷新

### 3. Hooks Extension (`src/hooks/extensibility/`)
- 用户自定义 plugin：`.omx/hooks/*.mjs`
- Event types: session-start/end, turn-complete, session-idle, blocked, finished, failed, retry-needed, pr-created, test-*, handoff-needed, needs-input, pre/post-tool-use
- Plugin contract: `export async function onHookEvent(event, sdk)`
- SDK 提供 tmux.sendKeys、log、state (namespaced)、omx state readers
- Derived signals（opt-in）: needs-input, pre-tool-use, post-tool-use
- Plugin runner 在独立子进程跑，有 timeout（默认 1500ms）
- **Team-safety**: worker session 中 plugin side-effects 默认跳过，只有 lead session 是 canonical emitter

### 4. Notifications (`src/notifications/`)
- 多平台: Discord (webhook + bot)、Telegram、Slack、generic webhook
- 非阻塞发送 + timeout（send 10s, dispatch 15s）
- Discord 内容截断 2000 字符 + mention 解析

### 5. OpenClaw Integration (`src/openclaw/`)
- 通过 HTTP gateway 或 CLI command gateway 发送 hook payloads 给 OpenClaw
- Template variables: `{{projectName}}`, `{{sessionId}}`, `{{tmuxSession}}`, `{{question}}` 等
- 安全: command gateway 需 `OMX_OPENCLAW_COMMAND=1` opt-in
- 支持 Korean field names 的结构化 instruction 格式（韩国开发者背景）

## 技术栈
- TypeScript (ESM) + Rust (explore harness)
- Node.js test runner（非 jest/vitest）
- Biome (lint)
- tmux 重度依赖（团队协作基于 tmux session/pane）
- `.omx/` 目录：state、logs、hooks、config

## 与 Workshop 对比

| 维度 | oh-my-codex | Workshop |
|---|---|---|
| 交互方式 | CLI + tmux | Web chat UI |
| 多 agent | tmux pane 隔离 | WebSocket + 频道路由 |
| 可见性 | HUD statusline | 实时聊天流 |
| 通知 | Discord/Telegram/Slack/OpenClaw | 直接在 UI 里 |
| Hook 系统 | 丰富（17+ event types） | 无（依赖 OpenClaw） |
| 目标用户 | 开发者（terminal native） | 任何人（chat native） |
| 编排 | 固定 pipeline（plan→prd→exec→verify→fix） | 自由（TODO-driven） |

## 关键借鉴

1. **Hook 系统设计很成熟** — 17+ event types、plugin isolation、derived signals opt-in、team-safety。比我们的 nudge 插件丰富得多
2. **HUD 概念** — 实时状态面板。Workshop 可以做 web 版 HUD（agent 当前状态、token 消耗、当前阶段）
3. **Team worker 通信** — 文件系统 + tmux send-keys。朴素但有效。Workshop 用 WebSocket 更自然
4. **Governance/Policy 层** — 控制 worker 行为边界。Workshop 的 agent 角色系统可以借鉴
5. **Fix loop 限制** — verify 失败后最多 fix N 次。这是防止 agent 无限循环的好设计

## 打工潜力评估
- ⭐ 705 stars（中等），活跃度高（v0.11.12，密集发版）
- 韩国开发者主导，代码注释/文档有韩文
- TypeScript 项目，我们熟悉
- 但**不对齐 self-evolving agent 方向** — 它是 Codex 的 orchestration layer，不涉及 memory/identity/self-evolution
- **结论: 学习对象，不是打工对象**
