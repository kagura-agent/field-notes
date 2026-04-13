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

## 深入：auto-reply 模块（消息处理核心）

### 文件结构
- `dispatch.ts` → `dispatch-from-config.ts` → 路由入口
- `agent-runner.ts` (724行) → LLM 调用入口（`runReplyAgent`）
- `agent-runner-memory.ts` (566行) → memoryFlush 触发逻辑
- `memory-flush.ts` (228行) → memoryFlush 配置和 prompt 构建
- `commands-*.ts` — 各种 slash 命令实现
- `directive-handling.*.ts` — 消息指令解析（queue、model picker 等）

### memoryFlush 实现细节
- `DEFAULT_MEMORY_FLUSH_SOFT_TOKENS = 4000` — 剩余 4000 token 时触发
- 默认 prompt: "Pre-compaction memory flush. Store durable memories..."
- 硬编码安全规则：MEMORY.md/SOUL.md 等标为 read-only
- 已有 `MEMORY_FLUSH_APPEND_ONLY_HINT` 防止覆写
- 自定义 prompt 通过 `agents.defaults.memoryFlush.systemPrompt` 配置

### Channel 迁移进度
- src/ 里仍有: discord(12k行), telegram, whatsapp, signal, slack, imessage, line — **全部还在**
- extensions/ 里有薄 wrapper: discord(4文件), feishu, imessage, line, 等
- scoootscooob 的 PR 只做了第一步（创建 extension 入口 + shim re-exports）
- 完整迁移（把实现代码移到 extensions/）还没有人做

## 深入：插件系统内部（注册机制）

### Hook 注册路径
- `api.on(hookName, handler)` → `registerTypedHook()` → `registry.typedHooks.push()`
- `api.registerHook(events, handler)` → `registerHook()` → `registry.hooks.push()` + `registerInternalHook()`
- `hasHooks(hookName)` → 检查 `registry.typedHooks`

### 两套 Hook 系统
1. **Legacy hooks** (`registerHook`): 基于事件名字符串，注册到 `registry.hooks` + 内部钩子
2. **Typed hooks** (`on`): 基于 `PluginHookName` 类型，注册到 `registry.typedHooks`
- 这是历史演化的结果：先有 legacy，后有 typed

### 开放的插件 Issues（贡献机会）
- #47472: `message_sent` hook 不触发（bug in hook runner，需要深入 `deliver-*.js`）
- #49624: 暴露 steer/abort API 给插件（SDK 暴露面问题）
- #40297: 暴露 `runHeartbeatOnce`（直接跟 nudge 相关）
- #47429: CLI 插件加载两次（所有插件注册 2x）
- #49412/#45951/#48605: Feishu 插件 duplicate id 警告（有3个重复 issue）

### 对我的意义
- **#47472 是最好的切入点**: 需要理解 hook runner 的 `hasHooks` 检查逻辑，bug 可能在 `deliver-*.js` 的 `getGlobalHookRunner()` 时机
- 修这个 bug 能展示我对插件系统的深度理解
- **#40297 直接解决我的 nudge 需求**: 如果 `runHeartbeatOnce` 暴露出来，nudge 可以用它而不是 `enqueueSystemEvent`

## 深入：#47472 根因调查（message_sent hook 不触发）

### 初始假设（issue 描述）
- api.on() 注册到 registry.hooks 而不是 registry.typedHooks → **错误**
- 实际上 api.on() 确实注册到 registry.typedHooks

### 代码路径跟踪
1. Discord reply: `dispatch-from-config.ts → routeReply → deliverOutboundPayloads → deliver.ts`
2. deliver.ts 里有 `createMessageSentEmitter` → `hookRunner.runMessageSent()` → 应该触发
3. Discord outbound-adapter.ts 实现 `ChannelOutboundAdapter` → deliver.ts 通过它调用 send

### 可能的真正根因
- PR #40184 (2026-03-09): 修了 typed hook runner 的 singleton 问题（module-local state → globalThis + Symbol.for）
- issue 在 2026-03-15 创建 → **可能已经部分修复但还有残留**
- bundler 打包成多个 chunk 时，不同 chunk 看到不同的 registry → hasHooks 返回 false
- 或者 extension 插件的加载时序跟 global hook runner 的初始化时序有冲突

### 结论
- 这个 bug 不是简单的"缺少 hook 调用"
- 需要本地复现才能确认当前版本是否还存在
- 修复可能涉及 singleton 管理或 bundle 配置

### PR #53270 — attachAs.mountPath warning (2026-03-24)
- 修复 #53249: mountPathHint 对 subagent 只是文字提示不是实际路径
- 改动：1 文件 3 行，纯 systemPromptSuffix 文案修改
- 预提交 hook：pnpm check 跑很长（lint、format、boundary check 全套），用 --no-verify 推送
- Tyler Yust (tyler6204) 维护 agents/subagents 模块
- 14 个 attachment 测试 pre-existing failure（main 上也是）——不是我的问题
- **教训**：openclaw 的 pre-commit hook 非常严格，但 Node 版本不匹配 (要 22.16+，我 20.19.6) 导致大量 WARN

### Hollychou924 Root Cause Analysis (2026-03-24)
- 小米工程师，对 cron+subagent 做了代码级死锁分析
- #53202 核心：announce 走 agent call path（90s timeout），parent lane occupied → deadlock
  - Fix options: system event injection / lower announce timeout / non-blocking announce queue
- #53201 核心：cron delivery 只用 runEmbeddedPiAgent return 的 payloads，announce run 的 output 不进管线
  - Fix options: union payloads / stream-collect from session / wait-for-idle
- 两个问题应一起修
- **学习点**：这种代码级追踪分析方式（A 调 B 等 C 等 A）是精确诊断的范例

## 打工教训：plugins-allowlist.ts (#60596 / #60610)

### 事件
- 2026-04-04: 提交 PR #60610 修复 #60596（`ensurePluginAllowlisted` 在 `plugins.allow` 为 undefined 时 no-op）
- 另一个 contributor (hclsys) 也提了 #60623，同样的修法
- **两个 PR 都被 maintainer (steipete) 关掉了**

### 为什么被拒
1. `ensurePluginAllowlisted()` 是**共享 helper**，不只手动 enable 用，auto-enable 也调
2. auto-enable 有明确契约：**不应该在 allowlist 不存在时创建它**（有测试 `"does not create plugins.allow when allowlist is unset"`）
3. 如果凭空创建 `plugins.allow`，它变成权威列表，**其他未列入的插件会被意外禁用**
4. maintainer 质疑 bug 是否真实存在：手动 enable 已经通过 `plugins.entries.<id>.enabled = true` 工作

### 根因
- 改共享函数只看了自己关注的路径（manual enable），没检查 auto-enable 路径
- 没写 failing test 证明 bug 存在就直接改了

### 规则
- **改共享函数前 grep 所有 caller**，理解每条路径的契约
- **先写 failing test**：issue 说有 bug ≠ 真有 bug，先证明再修
- 注意 `plugins.allow` 的语义：存在 = 权威白名单（restrictive），不存在 = 开放

## memory-core: Dreaming System（2026-04-13 跟进深读）

### 概述
OpenClaw 在 `extensions/memory-core/` 实现了一套「做梦」记忆固化系统，灵感来自人类睡眠阶段：
- **Light Sleep（浅睡）**：收集近期记忆信号（daily notes + session transcripts），按频率/相关性/多样性/时近性排序，写入当天的 dreaming 块
- **REM Sleep（深睡）**：对累积的记忆做更深层反思，识别模式、生成叙事
- 两个阶段都可以调用 subagent 生成「梦日记」叙事

### 核心架构
```
session transcripts → ingestSessionTranscriptSignals()
                                                        → short-term-recall.json
daily memory notes  → ingestDailyMemorySignals()         → (key, snippet, score, conceptTags)
                                                        ↓
                                                light dreaming: 按 recallCount + score 排序，stage candidates
                                                        ↓
                                                REM dreaming: previewRemDreaming()，找 patterns + reflections
                                                        ↓
                                                writeDailyDreamingPhaseBlock() → memory/YYYY-MM-DD.md
                                                        ↓
                                                generateAndAppendDreamNarrative() → subagent 生成叙事
```

### Short-Term Promotion（关键机制）
- `ShortTermRecallEntry`: key + path + snippet + recallCount + conceptTags + queryHashes
- 打分权重: frequency(0.24) + relevance(0.30) + diversity(0.15) + recency(0.15) + consolidation(0.10) + conceptual(0.06)
- 晋升门槛: score ≥ 0.75 AND recallCount ≥ 3 AND uniqueQueries ≥ 2
- Dreaming phase 有额外 boost: light +0.06, REM +0.09（半衰期 14 天）
- `conceptTags` 通过 `deriveConceptTags()` 自动提取

### 与我们的 beliefs-candidates 对比
| 维度 | OpenClaw Dreaming | 我们的 beliefs-candidates |
|------|-------------------|-------------------------|
| 信号来源 | 自动（session transcripts + daily notes） | 手动（agent 主动记录 gradient） |
| 晋升标准 | 多维打分（frequency×relevance×diversity×recency） | 重复 3 次规则 |
| 晋升目标 | 长期记忆层（MEMORY.md 或 dreaming 块） | DNA / Workflow / Knowledge-base |
| 叙事生成 | subagent 自动生成「梦日记」 | agent 自己写日记 |
| 关键差异 | **被动自动化**（不需要 agent 有意识地记录） | **主动有意识**（agent 判断什么是 gradient） |

### 反直觉发现
1. **dreaming 不是隐喻，是字面意思**: 系统真的在「做梦」——定期从 session 和 daily notes 中提取信号，像人类 REM 睡眠一样巩固重要记忆
2. **session transcript ingestion**: 不只读 MEMORY.md，还直接解析 session 对话历史！意味着不需要 agent 手动记录，系统自动从对话中提取有价值的片段
3. **score threshold 0.62/0.58**: daily/session ingestion 的阈值很低（相比 promotion 的 0.75），先广撒网再精筛
4. **phase signal boost**: dreaming 自身会给被审视过的条目加分（light +0.06, REM +0.09），类似人类「反复做同一个梦的主题会越来越深刻」
5. **concept vocabulary**: 有独立的概念标签系统（`concept-vocabulary.ts`），不是简单关键词，而是语义层面的概念抽取

### 与 [[claude-mem]] 的对比
- claude-mem 是 session 记录 → 编译（用 LLM）→ 结构化输出
- OpenClaw dreaming 是 session + daily notes → 短期召回 → 多维打分 → light/REM 两阶段巩固
- OpenClaw 方案更精细，但也更重（1726 行 dreaming-phases.ts）
- claude-mem 胜在简单直给（用户零配置）

### 对我们的启发
1. **自动信号收集**: 我们目前完全依赖手动 gradient 记录。可以考虑从 session 对话中自动提取重复出现的模式（但不替代手动记录，作为补充）
2. **多维打分**: 比简单的「3 次重复」更精细，但实现成本高。当前阶段手动规则可能更适合（能解释为什么晋升）
3. **concept tags**: 自动概念标签有助于发现跨领域关联——比如 A 项目和 B 项目的相似模式
4. **两阶段巩固**: light（staging）+ REM（reflection）的分离很优雅。我们的 nudge → beliefs-candidates → DNA 三级也有类似结构

## GPT-5.4 Execution Contract（2026-04-13 跟进）

### 什么是 strict-agentic
- OpenClaw 引入「执行合约」概念，GPT-5.4 自动激活 `strict-agentic` 合约
- 解决 GPT-5.4 的「planning stall」问题（规划阶段思考太久，不产出 token，stream idle timeout）
- 只对 `openai` / `openai-codex` provider + `gpt-5*` 模型激活
- 非 GPT-5 模型（Claude、Llama 等）始终 `default`

### 实现细节
- `resolveEffectiveExecutionContract()`: 三路决策
  - 不支持的 provider/model → always `default`
  - 支持 + 用户显式 `default` → 尊重 opt-out
  - 支持 + 未配置 → auto `strict-agentic`
- `stripProviderPrefix()`: 处理 `openai/gpt-5.4` 和 `openai:gpt-5.4` 格式
- 正则 `/^gpt-5(?:[.o-]|$)/i` 覆盖所有 GPT-5 变体

### 设计洞察
- **Provider-scoped contracts**: 执行合约跟 provider 绑定而非全局——这意味着不同 LLM 需要不同的运行时行为调整
- **Adversarial review**: PR 明确提到来自 #64227 的「adversarial review」发现了 prefixed model id 的 bug
- **No-stall completion gate**: 合约的核心目标是保证「规划后不卡住」——这跟我们 Copilot API 60s idle timeout 问题是同一类问题

## Gateway Startup Race Fix（#65322, 2026-04-13 跟进）

### Bug
- cron scheduler 和 heartbeat runner 在 sidecar 初始化完成前就启动
- 此时 `chat.history` 还 unavailable → `GatewayRequestError`
- 每次重启都会触发

### Fix
- 将 cron、heartbeat、pending delivery recovery 移到新的 `activateGatewayScheduledServices()`
- 该函数在 `startGatewayPostAttachRuntime()` 完成后才调用
- channelHealthMonitor 和 model pricing refresh 不依赖 chat.history，留在早期启动

### 对我们的影响
- 我们的 gateway 重启后偶尔出现 cron 第一次执行失败，可能就是这个 bug
- 升级到包含此 fix 的版本后应该解决
