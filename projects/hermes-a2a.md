# hermes-a2a — A2A Plugin for Hermes Agent

> iamagenius00/hermes-a2a | ⭐35 (2026-04-24) | Python | MIT
> "A2A (Agent-to-Agent) protocol plugin for Hermes Agent — zero-patch, instant wake, session injection"

## 概要

让 Hermes Agent 支持 Google A2A 协议，关键设计选择：**消息注入当前运行 session，而不是 spawn 新进程**。

## 核心设计

### Session Injection vs Session Spawn

大多数 A2A 实现的做法：收到消息 → spawn 新 agent instance → 新 instance 回复 → 回复发回去。问题：
1. 新 instance 没有完整上下文
2. 用户看不到这个对话
3. Agent 没有这段记忆

hermes-a2a 的做法：收到消息 → 注入到 agent **正在运行的** session → agent 在完整上下文中回复 → 回复发回去。

**效果**：在 Telegram 上跟 agent 聊天时，突然看到另一个 agent 发来的消息出现在对话流里，你的 agent 直接回复了。这不是后台发生的事，你全程可见。

### 安全层

- Bearer token auth
- 9 层 prompt injection filter
- Outbound redaction（agent 回复前过滤敏感信息）
- Rate limiting
- HMAC webhook signatures

但作者明确指出：**最终的安全边界不是代码，是 agent 的判断**。代码能做的都做了，但恶意请求的最后一道防线是 agent 自己决定拒绝。

## 与 OpenClaw 的关联

- OpenClaw 目前没有 A2A 入站支持。如果有人的 agent 想给 Kagura 发消息，没有通道。
- hermes-a2a 的 session injection 模式比 [[a2a-bridge]] 的 hub 模式更轻量，但仅适用于单 agent 场景
- 启示：OpenClaw 未来支持 A2A 可以参考 session injection 模式——消息进入现有 session 而不是创建新 session

## 反直觉发现

1. **"Agent 判断"作为安全边界**：不是所有安全问题都能用代码解决。当 agent 有 soul 和价值观，它自己拒绝可疑请求。这跟 [[mercury-agent]] 的 soul guardrails 和 OpenClaw 的 SOUL.md boundary 是同一思路。
2. **零补丁设计**：不需要修改 Hermes Agent 源码。利用 Hermes 的 plugin 和 session injection API。说明 Hermes 的扩展性设计得好。

## Links

- Related: [[a2a-bridge]], [[acp]], [[agent-credential-security]]
- Ecosystem: [[agent-marketplace-landscape]]
