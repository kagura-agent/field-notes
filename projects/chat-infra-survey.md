# Chat-Infra 开源 IM 平台调研

> 2026-04-20 深读 | 为 [[chat-infra]] 项目选型
> 关联：[[workshop]] → [[chat-infra]]（方向转换 04-15），[[sharkord]]

## 背景
Luna 04-15 提出：与其从零造 Workshop，不如 fork 开源 Discord 替代 + AI-native 层。需要找可 fork 改代码的开源 chat 平台。

## 候选对比

| 项目 | ⭐ | 语言 | 许可证 | 定位 | Fork 可行性 |
|---|---|---|---|---|---|
| **Rocket.Chat** | 45k | TypeScript | MIT→商业 | 企业 CommsOS | ❌ 太重，企业导向 |
| **Mattermost** | 36k | TypeScript/Go | AGPL | 企业协作 | ❌ 太重，Slack 替代 |
| **Element/Matrix** | 13k | TypeScript | Apache-2.0 | 联邦协议 | ⚠️ Matrix 协议复杂，但生态最大 |
| **StoatChat** (原 Revolt) | 3k | Rust | 自定义 | Discord 替代 | ⚠️ Rust 后端，许可证不明 |
| **Sharkord** | 1.3k | TypeScript | MIT | 轻量 Discord 替代 | ✅ 最佳候选 |
| **dcts-shipping** | 590 | JavaScript | AGPL | Discord-like | ⚠️ JS 而非 TS |

## 深读：Sharkord

### 为什么是最佳候选
1. **MIT 许可** — fork 无法律风险
2. **全 TypeScript** — 和 OpenClaw 技术栈一致（Bun + tRPC + React）
3. **轻量 monorepo** — apps/client + apps/server + packages，结构清晰
4. **Plugin SDK** — 已有插件系统（packages/plugin-sdk），AI-native 层可作为插件
5. **Discord-like 功能完整** — channels, categories, voice (mediasoup), DMs, roles, emojis, file sharing
6. **活跃开发** — 2026-04-17 最后更新，93 open issues，112 forks
7. **Bun 运行时** — 单二进制分发，部署简单

### 技术栈
- **Runtime**: Bun v1.3.12
- **Server**: tRPC routers（channels/messages/users/voice/plugins/roles/dms）
- **Client**: React
- **DB**: Drizzle ORM + SQLite（推测，轻量定位）
- **Voice/Video**: Mediasoup v3.19.19 (WebRTC SFU)
- **UI**: packages/ui 共享组件库
- **测试**: packages/e2e + 各模块 __tests__

### 服务端架构（apps/server/src）
- `routers/` — tRPC API（categories, channels, dms, emojis, files, invites, messages, others, plugins, roles, users, voice）
- `db/` — Drizzle schema + migrations + mutations + queries
- `plugins/` — 插件加载/生命周期/actions
- `queues/` — 异步任务（activity-log, logins, message-metadata）
- `crons/` — 定时任务
- `helpers/`, `utils/` — 工具函数
- `http/` — HTTP 中间件
- `runtimes/` — 运行时抽象

### AI-Native 改造机会
1. **Plugin 层** — 通过 plugin-sdk 注入 AI agent 作为"虚拟用户"
2. **Message router** — 在 messages router 层加 agent 路由/@mention 触发
3. **tRPC** — agent 可直接调用 tRPC API 收发消息
4. **WebSocket** — 实时消息推送给 agent

### 风险
- Alpha 阶段，可能有 breaking changes
- 社区还小（1.3k stars），长期维护不确定
- 单人/小团队项目？需确认贡献者数量

## StoatChat（原 Revolt）备选

- Rust 后端性能好，但 fork 改造门槛高
- 许可证 "NOASSERTION"，需确认
- 多 repo 分散（server/web/desktop/mobile 分开），集成复杂
- 生态更大（各客户端 app 齐全）

## 结论

**Sharkord 是 chat-infra fork 首选**：MIT、TypeScript 全栈、结构清晰、已有插件系统、Discord-like 功能完整。

**下一步建议**：
1. Luna 试用 demo.sharkord.com 评估 UX
2. 本地部署一个实例验证 plugin SDK
3. 写 PoC：AI agent 通过 plugin SDK 在 Sharkord 里收发消息
