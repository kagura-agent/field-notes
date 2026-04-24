# Session Injection vs Session Spawn (A2A Pattern)

> Agent-to-agent 通信中，收到消息时的两种处理模式。

## 两种模式

### Session Spawn（主流做法）
收到 A2A 消息 → 创建新 agent instance → 新 instance 回复。
- **优势**：隔离性好，不影响当前对话
- **劣势**：新 instance 没有完整上下文，用户看不到，agent 没有记忆

### Session Injection（[[hermes-a2a]] 做法）
收到 A2A 消息 → 注入当前运行 session → agent 在完整上下文中回复。
- **优势**：agent 有完整记忆和上下文，用户可见整个交互
- **劣势**：打断当前对话流，单线程处理

## 类比

| 维度 | Session Spawn | Session Injection |
|---|---|---|
| 类比 | 接电话时找助手帮回邮件 | 接电话时自己顺手回邮件 |
| 记忆 | 无 | 完整 |
| 隔离 | 强 | 弱 |
| 适用 | 多 agent 编排 | 单 agent 多通道 |

## 对 OpenClaw 的启示

OpenClaw 当前是 **session spawn** 模式（ACP harness 创建独立 session）。如果未来支持 A2A 入站，可以考虑 session injection——让消息进入 Kagura 的当前 session，而不是创建临时 clone。

这跟 OpenClaw 的 heartbeat 已经在做的事类似——heartbeat 消息注入当前 session 而不是创建新的。

## Links

- Implementation: [[hermes-a2a]], [[a2a-bridge]]
- Related: [[async-agent-transport]], [[acp]]
