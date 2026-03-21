# openclaw-plugin-nudge — 田野笔记

## 项目概况
- **类型**: 自建工具（OpenClaw 插件）
- **目的**: 解决 agent 自动反思触发机制缺失的问题
- **诞生日期**: 2026-03-21
- **状态**: MVP 完成，已在本地使用

## 问题背景

OpenClaw 的 heartbeat 机制有已知 bug（#47282, #45772）——timer 初始化后从不 tick。cron 没有对话上下文。memoryFlush 不可预测。三个外部触发全部失效。

Hermes agent 用 nudge 机制（每 N 轮 fork agent 做 review）解决了这个问题，但它嵌在自己的 runtime 里。

## 解法

利用 OpenClaw 的 plugin hook 系统（25 个 hook 点），监听 `agent_end` 事件，每 N 次触发后台反思。

### 关键 API
- `api.on("agent_end", handler)` — 注册 hook
- `api.runtime.system.enqueueSystemEvent(text, { sessionKey })` — 注入系统消息
- `api.runtime.subagent.run(params)` — 备选：spawn subagent

### agent_end 事件 context
```typescript
event: { messages: unknown[]; success: boolean; durationMs?: number; error?: string }
ctx: { agentId?: string; sessionKey?: string; workspaceDir?: string; trigger?: string; channelId?: string }
```

`trigger` 字段可以判断来源（user/heartbeat/cron/memory），用于防递归。

## 架构洞察

1. **嵌入式 > 外挂式**: Hermes 在自己的主循环里插 nudge，OpenClaw agent 不控制主循环，但 plugin hook 提供了等效的插入点
2. **enqueueSystemEvent 是排队制**: 不是立即执行，是放入 session queue 等待下一次处理
3. **防递归**: 通过 `skipTriggers` 配置跳过 heartbeat/cron 触发的 agent_end，避免无限循环
4. **计数器持久化**: 写到 workspace 的 `.nudge-state.json`，跨 session 保持计数

## 迭代记录
1. v0.1: `api.runtime.enqueueSystemEvent` → 路径错误（应该是 `api.runtime.system.enqueueSystemEvent`）
2. v0.2: 修正路径 → 需要加 `plugins.allow` 白名单
3. v0.3: 成功触发！NUDGE.md 内容被注入到 session

## 与 Hermes 对比

| 维度 | Hermes | nudge 插件 |
|------|--------|-----------|
| 触发点 | 每 N 个对话轮次 | 每 N 次 agent_end |
| 执行方式 | fork AIAgent（后台线程） | enqueueSystemEvent（session queue） |
| 对话历史 | 完整复制 | 在同一个 session 里 |
| 防递归 | interval=0 | skipTriggers 配置 |
| 可配置性 | 硬编码在 runtime | 完全可配置（interval, prompt, model） |

## OpenClaw 插件开发要点
- 插件放在 `~/.openclaw/extensions/<id>/` 目录
- 必须有 `openclaw.plugin.json`（manifest + configSchema）
- 必须加入 `plugins.allow` 白名单
- 修改代码后必须重启 gateway
- 插件在进程内运行（in-process），不是沙箱

## OpenClaw 生态贡献者画像（附带调研）

### Maintainers（能 merge 代码的人）
- **joshavant** (Josh Avant) — 15 merged，核心开发
- **vincentkoc** (Vincent Koc) — 15 merged，AI Research Eng + DevRel @comet-ml
- **jalehman** (Josh Lehman) — 10 merged，Martian Engineering
- **BunsDev** (Val Alexander) — 7 merged，自称 OpenClaw Maintainer
- **huntharo** (Harold Hunt) — 6 merged，GIPHY/PwrDrvr

### 最强外部贡献者
- **scoootscooob** — 9 merged/3天，Paradigm，小而精确的 fix/test/refactor
  - 模式：跨模块（Discord/Slack/Signal/Agent），快速周转
  - 这就是有效贡献的标杆

### 活跃评论者
- **Hollychou924** — 小米，484 条评论，分析深度高
  - 4 分钟回复 heartbeat issue，分析直指 timer 被反复 clear 的可能性

### 疑似 Agent
- **ShionEria** — 2026-03-13 注册，4 个 PR，无 bio，名字像动漫角色
- **eggyrooch-blip** — 2025-08 注册，无名，3 个 PR + 评论

## 下一步
- [ ] 开源发布到 GitHub
- [ ] 发布到 npm（@kagura-agent/openclaw-plugin-nudge）
- [ ] 测试 subagent.run 作为替代注入方式
- [ ] 测试 nudge 触发后的反思质量
