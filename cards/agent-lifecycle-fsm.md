# Agent Lifecycle FSM

显式状态机管理 agent 生命周期。

## Pattern

定义有限状态集合（如 `unborn → birthing → onboarding → idle ⇄ thinking ⇄ responding, idle ⇄ sleeping`），用 `VALID_TRANSITIONS` 数组验证每次状态迁移。非法迁移被拒绝并记日志。

## 优势
- 防止非法状态转换（sleeping 时不应处理消息）
- 可调试：每次迁移有日志
- 可扩展：加新状态只需加 transition 规则

## 实例
- [[mercury-agent]] `core/lifecycle.ts`：7 个状态，11 条合法 transition
- OpenClaw：目前隐式状态（session 状态 + heartbeat 状态），无显式 FSM

## 关联
- agent-daemon-mode — daemon 需要 lifecycle 管理
- [[self-evolution-system]] — 进化时需知道 agent 当前状态

## 新实例 (2026-04-27)
- [[wanman-skill-evolution]]：三种 lifecycle mode（`24/7` / `on-demand` / `idle_cached`），未用显式 FSM，而是 config-driven mode 选择
- OpenClaw ACP `persistent` mode：通过 `resolveRuntimeResumeSessionId` + `ensureSession` + fallback retry 实现隐式 lifecycle，含可恢复性检测（`isRecoverableMissingPersistentSessionError`）
- 详见 [[idle-cached-session-resume]]

## 评价
对 long-running 24/7 agent 有价值。简单 agent（单次对话）不需要。OpenClaw 通过 gateway + session 管理 + ACP persistent mode 实现了类似效果，但没有显式 FSM 层。行业趋势：config-driven mode 选择比显式 FSM 更常见。
