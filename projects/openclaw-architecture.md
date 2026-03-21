# OpenClaw 架构概览 — 田野笔记

## 核心模块规模
| 模块 | 行数 | 文件数 | 职责 |
|------|------|--------|------|
| agents | 90,272 | 431 | LLM 调用、工具系统、ACP |
| gateway | 44,846 | 219 | HTTP/WS 服务、RPC、路由 |
| infra | 40,685 | 229 | heartbeat、系统事件、日志 |
| auto-reply | 34,877 | 194 | 消息处理、命令解析、agent runner |
| channels | 13,673 | 110 | 渠道抽象（正在迁移到 extensions） |
| memory | 11,686 | 63 | 记忆存储、搜索、管理 |
| plugins | 9,278 | 54 | 插件系统（发现、加载、注册） |
| hooks | 4,333 | 25 | 钩子系统（内部+插件） |

## 消息处理流程
```
inbound message → dispatch.ts → dispatchReplyFromConfig → reply-dispatcher → agent runner → LLM call → response
                                                                                            ↓
                                                                                     agent_end hook
```

## 插件系统架构

### 四层设计
1. **Manifest + Discovery** — 读 `openclaw.plugin.json`，不执行代码
2. **Enablement + Validation** — 决定启用/禁用/阻止
3. **Runtime Loading** — jiti 加载 TypeScript 模块
4. **Surface Consumption** — 注册工具/通道/hook/命令

### 关键设计决策
- **Manifest-first**: 配置验证不需要执行插件代码（安全性）
- **In-process**: 插件和 gateway 在同一进程（性能 vs 安全 tradeoff）
- **AsyncLocalStorage**: 用 Node.js 的 AsyncLocalStorage 管理请求级上下文

### `agent_end` hook 的限制（根因分析）
- `subagent.run` 需要 `GatewayRequestContext`（通过 `AsyncLocalStorage` 获取）
- `agent_end` hook 虽然在请求生命周期内触发，但请求上下文可能已释放
- `enqueueSystemEvent` 不需要请求上下文（只往队列写消息），所以能工作
- 这是 **架构约束**，不是 bug：subagent 需要完整的 gateway 连接来处理新请求

### 插件注册 API
```typescript
// 工具、hook、通道、命令等的注册都通过同一个 api 对象
api.on("agent_end", handler, { priority: -10 })  // hook
api.registerTool(tool)                             // 工具
api.registerChannel({ plugin })                    // 通道
api.registerCommand(command)                       // 命令
api.registerService(service)                       // 后台服务
api.registerContextEngine(id, factory)             // 上下文引擎
```

## 架构方向（从 scoootscooob 的 PR 推断）
- **Channel-to-Extension 迁移**：把 Discord/WhatsApp/Slack 等从 `src/` 移到 `extensions/`
- 目的：让 channel 成为可选插件，核心包更小
- 这是 OpenClaw 当前最大的架构重构方向

## 对我的意义
1. **nudge 插件的优化方向**：了解了 `AsyncLocalStorage` 和请求上下文的限制，可以更聪明地设计触发机制
2. **潜在贡献方向**：channel 迁移还没完成（line、signal 等可能还在 src/），可以帮忙迁移
3. **插件系统的扩展性**：理解了插件系统后，可以做更复杂的插件（不只是 nudge）

## 开放问题
- [ ] auto-reply 和 agents 模块的边界在哪里？为什么分开？
- [ ] context-engine 只有 432 行，但有 slot 系统——这意味着核心逻辑在哪？
- [ ] memory 模块 11k 行，这和 memex 有什么关系？
