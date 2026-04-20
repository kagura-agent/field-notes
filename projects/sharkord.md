# Sharkord — 轻量 Discord 替代

> 2026-04-20 源码深读 | 关联：[[chat-infra-survey]], [[workshop]]

## 概览
- **Repo**: Sharkord/sharkord（1.3k⭐, MIT, alpha）
- **定位**: 自托管、轻量、隐私优先的 Discord 替代
- **技术栈**: Bun + TypeScript 全栈 monorepo
- **运行**: 单二进制（server+client 打包），Docker 支持
- **端口**: 4991 (HTTP) + 40000 (WebRTC/mediasoup)

## 架构

```
apps/
  server/     — Bun 后端（tRPC + WebSocket + mediasoup）
  client/     — React 前端（Vite）
packages/
  plugin-sdk/ — 插件开发 SDK
  shared/     — 共享类型和常量
  e2e/        — Playwright E2E 测试
  scripts/    — i18n 同步等工具
```

## DB Schema（SQLite, Drizzle ORM）

| 表 | 用途 | 关键字段 |
|---|---|---|
| **settings** | 全局服务器配置（唯一行）| name, password, serverId, secretToken, storage* 配额, enablePlugins, enableSearch |
| **users** | 用户 | identity(unique), password, name, avatar, banner, bio, banned |
| **roles** | 角色 | name, color, isPersistent, isDefault |
| **userRoles** | M2M 用户-角色 | userId, roleId |
| **rolePermissions** | 角色权限 | roleId, permission |
| **categories** | 频道分组 | name, position |
| **channels** | 频道 | type(text/voice), name, topic, private, isDm, categoryId, position |
| **channelRolePermissions** | 频道级角色权限覆盖 | channelId, roleId, permission, allow(bool) |
| **channelUserPermissions** | 频道级用户权限覆盖 | channelId, userId, permission, allow(bool) |
| **channelReadStates** | 已读状态 | userId, channelId, lastReadMessageId, lastReadAt |
| **messages** | 消息 | content, userId, pluginId, channelId, parentMessageId(threads), replyToMessageId, metadata(JSON), pinned |
| **messageFiles** | 消息附件 M2M | messageId, fileId |
| **messageReactions** | 消息 reaction | messageId, userId, emoji, fileId(custom emoji) |
| **files** | 上传文件 | name, originalName, md5, userId, size, mimeType |
| **emojis** | 自定义 emoji | name, fileId, userId |
| **invites** | 邀请链接 | code, creatorId, roleId, maxUses, uses, expiresAt |
| **logins** | 登录记录 | userId, userAgent, ip, geo 信息 |
| **activityLog** | 审计日志 | userId, type, details(JSON), ip |
| **directMessages** | DM 频道映射 | channelId, userOneId, userTwoId |
| **pluginData** | 插件持久化状态 | pluginId(PK), enabled, settings(JSON) |

**设计特点**:
- SQLite 单文件，零外部依赖
- 所有 timestamp 用 integer (epoch ms)
- 频道权限二层覆盖：角色级 + 用户级（Discord 模型）
- 消息支持 threads (parentMessageId) 和 inline reply (replyToMessageId)
- 插件可发消息（pluginId 字段）

## Plugin SDK（v1, 实验性）

### 生命周期
```typescript
// server/index.js — 每个插件必须导出
export async function onLoad(ctx: PluginContext) { ... }
export async function onUnload(ctx: UnloadPluginContext) { ... }  // 可选
```

### PluginContext API

| 命名空间 | 能力 |
|---|---|
| `ctx.events.on/off` | 订阅服务端事件 |
| `ctx.messages.send/edit/delete` | 以插件身份收发消息 |
| `ctx.commands.register` | 注册斜杠命令（带参数定义）|
| `ctx.actions.register` | 注册消息上下文操作 |
| `ctx.settings.register` | 声明插件设置（string/number/boolean）|
| `ctx.hooks.onBeforeFileSave` | 文件上传前拦截 |
| `ctx.voice.getRouter/createStream` | mediasoup 路由 + 外部音视频流注入 |
| `ctx.data.getUser/getChannel/getPublicUsers` | 查询用户/频道数据 |
| `ctx.ui.enable/disable` | 控制客户端 UI 组件显示 |
| `ctx.logger` | 带作用域的日志 |

### 事件类型
- `user:joined/left` — 用户上下线
- `user:joined_voice/left_voice` — 语音频道进出
- `message:created/updated/deleted` — 消息 CRUD
- `voice:runtime_initialized/closed` — 语音运行时生命周期
- `setting:set` — 插件设置变更

### 插件目录结构
```
plugins/<plugin-id>/
  manifest.json    — id, name, version, sdkVersion, description, author, logo
  server/index.js  — 服务端入口
  client/index.js  — 客户端入口
  package.json     — 可选依赖
```

### 内部实现
- **PluginManager** — 单例管理加载/卸载/切换
- **CommandRegistry** — 命令注册 + 执行（带 invoker 上下文）
- **ActionRegistry** — 消息操作注册
- **EventBus** — 事件分发（per-plugin 隔离）
- **HooksManager** — 文件保存前钩子链
- **PluginSettingsManager** — 设置持久化（pluginData 表）
- **PluginStateStore** — 启用/禁用状态
- **PluginLogger** — 带插件 ID 的日志 + 实时推送

### SDK 版本检查
加载时严格匹配 `manifest.sdkVersion === PLUGIN_SDK_VERSION`，不兼容直接拒绝。

## AI Agent 集成机会

1. **Plugin 方式**（首选）：
   - 写一个 Sharkord plugin，`onLoad` 时订阅 `message:created`
   - 用 `ctx.messages.send()` 回复消息（以 plugin 身份）
   - 用 `ctx.commands.register()` 注册 `/ask` 等命令
   - 通过 `ctx.voice.createStream()` 注入 TTS 音频流

2. **改造 fork**：
   - 在 message router 层加 agent 路由（@mention 触发）
   - tRPC 端点可直接被外部 agent 调用
   - WebSocket 实时推送给 agent

3. **评估**：
   - Plugin SDK 足够丰富，agent 集成不需要改 core
   - 但 SDK 标记为实验性，版本锁定严格
   - Voice 集成（mediasoup）需要底层音频处理能力

## 风险
- Alpha 阶段，breaking changes 预期
- 社区小（~1.3k stars）
- Bun runtime（非 Node.js，生态差异）
- 单人/小团队维护

## 对比 OpenClaw 的差异
- Sharkord = 完整 IM 平台（用户系统、频道、语音、文件）
- OpenClaw = AI agent 框架（多 channel adapter、工具调度、记忆）
- 互补关系：Sharkord 做 chat infra，OpenClaw 做 AI agent runtime
