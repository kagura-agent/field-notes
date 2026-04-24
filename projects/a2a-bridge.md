# a2a-bridge — Agent-to-Agent Hub

> firstintent/a2a-bridge | ⭐6 (2026-04-24) | TypeScript | MIT
> "Claude Code, Codex, OpenClaw, Hermes Agent, Gemini CLI, Zed & VS Code agents finally talk to each other."

## 概要

多 agent 互联桥接。一个 daemon 进程作为 star topology 中心，翻译 A2A (Google 协议) 和 ACP (Agent Client Protocol) 之间的调用。任何支持的 agent 通过桥接可以调用其他 agent。

## 架构

- **Star topology**: daemon 进程 → 多个 agent adapter
- **Protocol translation**: A2A (HTTP + SSE) ↔ ACP (stdio JSON-RPC) ↔ MCP Channels
- **Multi-session isolation**: RoomRouter + SQLite TaskLog，并发不串扰
- **Multi-workspace routing** (v0.2): 一个 daemon 对多个 Claude Code session，通过 `kind:id` TargetId 路由

## 连接方式

| Agent | Protocol | 备注 |
|---|---|---|
| Claude Code | ACP (server 端) | 核心，通过 `a2a-bridge claude` 启动 |
| OpenClaw | ACP (client) | 注册为 acpx agent |
| Hermes Agent | ACP (client) | 同 OpenClaw 模式 |
| Codex | peer | 双向 |
| Gemini CLI | A2A (HTTP) | remoteAgents 配置 |
| Zed / VS Code | ACP | 编辑器 agent 扩展 |

## 为什么重要

这是第一个试图**统一所有主流 coding agent 通信**的项目。之前各 agent 是信息孤岛：
- Claude Code 只能通过 ACP 被调用
- Codex 有自己的 session 协议
- Gemini CLI 支持 A2A 但不支持 ACP
- OpenClaw 有 ACP harness 但不能主动调用外部 agent

a2a-bridge 做的是协议翻译层，让任意 agent 调用任意 agent。

## 与 [[hermes-a2a]] 的对比

| 维度 | a2a-bridge | hermes-a2a |
|---|---|---|
| 模型 | Hub (star topology) | Plugin (session injection) |
| 协议 | A2A + ACP + MCP | A2A only |
| Session 模型 | 每消息可选 session | 注入当前运行 session |
| 优势 | 多 agent 互联 | 零进程开销，agent 有完整记忆 |
| 劣势 | 额外 daemon 进程 | 仅 Hermes Agent |

hermes-a2a 的核心洞察：**消息注入现有 session，而不是 spawn 新 session**。这意味着 agent 回复时有完整上下文。大多数 A2A 实现 spawn 新进程——clone 回复，但"你"不知道发生了什么。

## 与 OpenClaw 的关联

- OpenClaw 已有 ACP harness (sessions_spawn runtime="acp")，a2a-bridge 可以直接接入
- 当前 OpenClaw 不能主动调用外部 agent → a2a-bridge 补这个缺
- 未来方向：OpenClaw 可能内建 A2A 支持，而不是通过第三方桥接

## 反直觉发现

- **项目很小 (6★) 但设计成熟**：multi-target routing、session isolation、cross-host 支持都已实现
- **OpenClaw 是显式支持目标**：README 有完整的 OpenClaw 集成指南，说明作者了解 OpenClaw 生态

## 可借鉴

- [ ] A2A 协议支持 → OpenClaw 未来可能内建
- [ ] Star topology 多 agent 编排模式

## Links

- Related: [[hermes-a2a]], [[acp]], [[openclaw-architecture]]
- Concept: [[async-agent-transport]]
- Ecosystem: [[agent-marketplace-landscape]]
