# Workshop — 项目笔记

> 从 wiki/projects/workshop.md 迁移为完整项目笔记

## 产品定义 (2026-04-13 确认)

**Workshop = 我们的项目管理工具，聊天是交互方式。**

- 项目管理是骨架，聊天长在上面（跟 Discord 反过来）
- 只给我们自己用，不做平台/SaaS
- 详见 `workshop/docs/PRODUCT.md`

### 核心体验
1. **总控室** — Dashboard，北极星 + 全项目状态 + 卡住的任务
2. **项目空间** — 每个项目一个 room：原生 TODO + 聊天 + 活动摘要
3. **Agent 自治** — 任务自动流转，Kagura 自主推进，Luna 随时介入

### 开发原则
- Claude Code 写所有代码 + ralph-loop 拆任务
- 自己做自己测（dogfooding）
- 从 Discord 痛点出发

## 技术栈

- Monorepo: `~/.openclaw/workspace/workshop/`
- Server: Express + TypeScript (port 3200)
- Web: React + Vite (port 5173)
- 连接: OpenClaw Gateway WebSocket (port 18789)
- 部署: systemd (workshop-server + workshop-web) + supervise.sh

## Gateway 协议要点 (2026-04-02)

### 连接认证
- `client.id: "openclaw-tui"` + `mode: "ui"` = Control UI 身份，scopes 保留
- `gateway.controlUi.dangerouslyDisableDeviceAuth: true` = 允许无 device identity 的 Control UI 连接

### 事件格式
- Gateway → TUI: `event: "chat"` (state: delta/final/error, message 对象)
- Gateway → all: `event: "agent"` (stream: assistant/lifecycle/tool, data 对象)
- 两种格式 payload 完全不同

### Session Key
- chat.send: `workshop:product`
- Gateway 内部: `agent:kagura:workshop:product`
- 必须同时匹配两种格式

### 多 Agent 路由
- 一个 gateway 连接可路由到多个 agent
- `parseAgentSessionKey` 从 session key 解析 agent ID

## 版本历史

- v0.3.1 (2026-04-13): Markdown 渲染 + Agent 头像 + DM
- v0.3.0: 19 PRs — channel metadata, global TODO, cron, patrol, kanban, lifecycle...
- v0.2: 基础聊天 + channel

## Discord 痛点 (Workshop 要解决的)

1. Pin 2000 字符限制 → TODO 静默失败
2. 无任务状态流转 → 只有"在"和"不在"
3. Thread 堆积 → 几天就找不到
4. Cron 输出刷屏
5. 跨 channel 上下文丢失
6. Project Board 不适合混合任务

## 竞品

- **Clawith**: agent 办公室概念，跟 Workshop 最像但他们做 SaaS 我们做自用
- **CrewAI/LangGraph**: orchestration 框架，无 human-in-the-loop chat
- 详见 `workshop-competitors-2026-04-02.md`
