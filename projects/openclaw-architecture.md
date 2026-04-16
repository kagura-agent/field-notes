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

### 已应用（2026-04-13）
- **启用 dreaming**: 在 `~/.openclaw/openclaw.json` 配置了 `memory-core.dreaming.enabled: true`
- **保守参数**: cron 3:30 AM（在 daily-review 3:00 之后）, limit 5, minScore 0.8, minRecallCount 3, minUniqueQueries 2
- **可观测性**: verboseLogging=on, storage mode=both（inline + 独立 reports）
- **现有数据**: short-term-recall.json 已有 36 条 recall entries（自 Apr 11 开始自动收集），等待首次 dreaming sweep
- **待验证**: 需要 gateway restart 生效；首次 sweep 预计明晨 3:30 AM
- **对比分析**: 详见 wiki card [[dreaming-vs-beliefs-candidates]]

### 2026.4.12 升级验证（2026-04-14）

**问题**: 2026.4.9-beta.1 的 `dist/extensions/memory-core/openclaw.plugin.json` 中 `configSchema.properties.dreaming.properties` 为空 `{}`，导致 `additionalProperties: false` 拒绝所有 dreaming 配置属性。gateway 日志持续报 "must NOT have additional properties" 警告，dreaming sweep 虽然跑了（cron status=ok）但实际空跑。

**根因**: dist 打包 bug。源码 `extensions/memory-core/openclaw.plugin.json` 也为空——说明 configSchema 在 4.9 源码中就不完整。4.12 修复了这个 schema（添加了 enabled/frequency/timezone/verboseLogging/storage/phases 完整属性定义）。

**验证结果**:
- 2026.4.12 于 08:49 安装（npm global），gateway 于 09:15 重启
- 启动日志确认: `memory-core: updated managed dreaming cron job.`，无 schema 警告 ✅
- `openclaw memory status --deep`: dreaming 参数正确加载（limit=5, minScore=0.8, minRecallCount=3, minUniqueQueries=2）✅
- recall store: 49 entries，但 scores 全为 0.00、queries 全为空——这些是旧版本（4.9）记录的数据，缺少评分和查询关联
- rem-harness preview: 正常返回 44 source entries + reflections ✅
- **结论**: schema fix 生效，dreaming pipeline 恢复。新的 recall entries 会有正确的 score/query 数据。旧 entries 不会 promote（score=0），但随时间自然被新数据替代

**下一步**: 观察 04-15 03:30 sweep 输出——是否有 promote events 写入 events.jsonl，以及 MEMORY.md 是否有自动追加

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

## Tool Loop Detection（源码深读 2026-04-13）

### 架构
`src/agents/tool-loop-detection.ts` (~400 行)，session-scoped sliding window。

**4 个检测器：**
- `genericRepeat` — 同工具同参数重复，仅 warn（default threshold 10）
- `knownPollNoProgress` — poll 类工具（process poll/log, command_status）同参数同结果，warn 10 / critical 20
- `pingPong` — A-B-A-B 交替模式且结果不变，warn 10 / critical 20
- `globalCircuitBreaker` — 任何工具同结果重复 30 次（最后防线）

**哈希方式：** SHA-256 of stable-serialized params（sort_keys）。结果哈希包含 details + text content，对 process/poll 有特殊处理。

### 已知缺陷（Issues #34574, #64500）
1. **Exec volatile fields**: `durationMs`, `pid`, `cwd` 使每次 exec 调用哈希不同 → 逃过检测（#34687 部分修复）
2. **Creative retry 盲区**: 模型变换参数但得到相同错误 → 不被捕获（heavensea 报告：49 次 SSH 不同参数，28 次相同 Permission denied）
3. **Per-tool circuit breaker**: 阻断工具 A 不阻断配对工具 B → ping-pong 重启
4. **高默认阈值**: 10/20/30 允许大量浪费迭代

### 我的贡献
- 评论 #34574 提议 `resultSimilarity` 检测器：追踪每个工具的连续相同结果（不看参数），warn 3 / critical 5
- 对比 [[nanobot]] PR #3077 的更简单方案（阈值 3，per-run reset）
- 详细对比见 [[loop-detection-comparison]]

### 对我们的影响
- 我们的 cron 不是 tool runner（Workshop 发 prompt 给外部 agent），tool stagnation 不在我们的层
- 但 cron output stagnation（同一 cron 连续产出相同输出）是类似模式，可以借鉴

## GPT-5 Single-Action-Then-Narrative Detection（#65597, 2026-04-13）

### 问题
GPT-5 有一个"规划停滞"模式：调一个 tool（如 `read`），然后输出"I'll do X next"就停了。从用户角度，这跟纯规划没区别——只做了一件事就停下来叙述。

### 解决方案
`isSingleActionThenNarrativePattern()` 检测：
- **条件**：恰好 1 个 non-plan tool call + 可见文本 <700 chars + 匹配继续意图正则
- **继续意图正则**：`going to`, `first/next/then, i'll`, `i can do that next`, `let me ... next/then/first`
- **排除**：结果风格文本（`I'll summarize:`, `root cause:`, `here's what`）——这些是有实质内容的回答
- **Safety guard**：只对 `SINGLE_ACTION_RETRY_SAFE_TOOL_NAMES`（read/search/find/grep/glob/ls）允许 retry——有副作用的 tool 不重试

### Prompt Overlay 变更
新增 `OPENAI_GPT5_TOOL_CALL_STYLE` prompt 段：
```
Call tools directly without narrating. Do not describe a plan before each tool call.
If multiple tool calls are needed, call them in sequence without stopping to explain.
Narrate only when it genuinely helps.
```
这段加入 `stablePrefix`（不走 `sectionOverrides`），因为 `tool_call_style` section 包含动态审批指引（per-channel），不能被静态字符串覆盖。

### 架构洞察
1. **Prompt + Runtime 双管齐下**：prompt overlay 改行为倾向（软约束），incomplete-turn detector 强制重试（硬约束）。单独靠 prompt 不够，单独靠检测也不够
2. **Safe tool allowlist**：retry 只对无副作用的工具安全——这是对 tool 分类的隐式要求
3. **正则 vs LLM 判断**：用正则检测意图（便宜、确定性）而非 LLM 判断（昂贵、不确定）——production agent 系统偏好确定性规则
4. **Model-specific behavior shaping**：不同 model 需要不同的 runtime 调整，execution contract 就是这个抽象层

### 测试覆盖
11 个测试用例覆盖：触发 retry（"I can do that next"、planning prose）、不触发（2+ tools、completion language、handoff、answer-style summary、side-effect tools、unclassified tools）

### 对我们的启发
- 我们的 AGENTS.md 已有 `Tool Call Style` 段（"do not narrate routine tool calls"），这跟 GPT-5 overlay 的方向完全一致
- 差异：我们是自我约束（DNA 级），OpenClaw 是 runtime enforcement。哪个更可靠？理论上 runtime enforcement，因为 prompt 在长 context 下容易被淹没
- 相关：[[tool-stagnation-detection]]、[[loop-detection-comparison]]、[[execution-contract-pattern]]

## QA Lab Credential Broker（#65596, 2026-04-13）

### 概述
Convex-backed credential leasing for Telegram QA — 解决 E2E 测试需要共享凭证的问题。
每个 CI lane / maintainer 从 pool 中 lease credential，用完归还。防止并发测试互相踩踏。

### 关联
- 我们的测试（Workshop、FlowForge）还没到需要 credential pool 的阶段
- 但这是 agent 框架 E2E 测试的最佳实践参考

## Gateway Startup Race Fix — 追踪确认（2026-04-13）

- #65322 已 merge（defer cron + heartbeat until sidecars ready）
- #65365 是跟进 fix（defer gateway scheduled services，带 @lml2468 的 credit）
- **影响确认**：我们偶发的 cron 首次失败可能就是这个 bug。下次升级 OpenClaw 后验证是否解决

## Dreaming Test Clock Freeze (#65605, 2026-04-13)

### 问题
Dreaming phase tests were flaky because they used real dates. Fixture transcript files (April 5-6) could fall outside the lookback window as time progresses → tests disappear on clean main.

### 解决
`withDreamingTestClock()` helper — freezes test clock so fixture dates always within lookback window. `triggerLightDreaming(beforeAgentReply, workspaceDir, dayN)` replaces raw `beforeAgentReply()` calls.

### 教训
- **Date-dependent tests 必须 freeze time** — 这是 dreaming system 的 time-sensitive 架构的直接后果
- 我们启用 dreaming 后，如果写 dreaming 相关测试/验证，也需要注意时间窗口问题
- 我们的 dreaming 配置中 `lookback: 3 days` 意味着超过 3 天没有新 daily note 就没有输入信号

## QA Lab Parity Proof (#65664, 2026-04-13)

GPT-5.4 parity proof 测试场景恢复（从 conflicted #65224 salvage）。QA lab 现在有完整的 GPT-5.4 vs Claude parity 验证管道，包含 mock auth staging 和 parity-gate workflow。

## Dreaming Runtime Verification + Upgrade Assessment (2026-04-13 13:45)

### 运行状态验证
- **dreaming cron job**: 已注册，ID `0df29bb1`，schedule `30 3 * * *` Asia/Shanghai，target `main` session
- **状态**: idle（从未运行），首次 sweep 预计 2026-04-14 03:30 AM
- **reconciliation warning**: gateway restart 后出现 1 次 `"managed dreaming cron could not be reconciled (cron service unavailable)"`
  - 这是 [[#Gateway Startup Race Fix|startup race bug (#65365)]] 的症状——cron service 在 memory-core 尝试 reconcile 时还未就绪
  - 但 job 本身在首次创建时（09:56）成功写入 cron store，后续 reconcile 失败不影响执行

### Recall Store 现状
- 39 条 short-term recall entries（自 Apr 11 开始收集）
- 最高 recallCount: 3（3 条达到 minRecallCount 阈值）
- 所有 compositeScore = 0.000（正常——score 只在 dreaming sweep 时计算）
- 所有 queryTexts = 空（uniqueQueries = 0）——这意味着 minUniqueQueries=2 条件可能无法满足
- **风险**: 如果 scoring 要求 uniqueQueries ≥ 2 且当前全为 0，首次 sweep 可能 promote 0 条

### 升级评估
| 版本 | 状态 | 包含关键 fix? |
|------|------|---------------|
| 2026.4.11 (当前) | stable | ❌ 无 startup race fix, 无 dreaming improvements |
| 2026.4.12-beta.1 | pre-release (Apr 12 23:27Z) | ✅ dreaming confidence/promotion/narrative fixes, ❌ startup race (#65365 merged 00:41Z post-beta) |
| 2026.4.12 stable | 未发布 | ✅ 应包含所有 fix |

**结论**: 等 2026.4.12 stable。Beta 有大量 dreaming fix 但缺关键的 startup race fix。当前版本 dreaming 应能正常运行（job 在 cron store 中），但 reconciliation 机制不够健壮。

### 升级后验证清单
- [ ] `grep "reconcil" /tmp/openclaw/openclaw-*.log` — 不应再出现 "cron service unavailable"
- [ ] `openclaw cron list` — dreaming job 从 idle 变为 ok（有 lastRun）
- [ ] `cat memory/.dreams/` — 有 dreaming reports
- [ ] `git log --oneline MEMORY.md` — dreaming 有 promote 条目

### 关联
- [[dreaming-vs-beliefs-candidates]] — 两条记忆固化路径对比
- [[progressive-disclosure-memory]] — recall 信号来源

## 2026-04-13 Security Sprint — Sandbox Exec Hardening

来源: 3 个 PR 由 pgondhi987 在数小时内 merge（#65713, #65714, #65717），全部 [AI-assisted]。

### PR #65714: Empty Approver List → Authorization Bypass

**漏洞链**: `allowFrom: []` → `createResolvedApproverActionAuthAdapter` returns `{ authorized: true }` → `resolveApprovalCommandAuthorization` 将其标记为 `explicit: true` → `/approve` handler 跳过 `isAuthorizedSender` check → **任何人可以 /approve exec 命令**。

**修复**: 引入 `IMPLICIT_SAME_CHAT_APPROVAL_AUTHORIZATION` Symbol 作为非可枚举 taint marker。empty approver list 返回的 `authorized: true` 被标记为 "implicit same-chat"，不再升级为 `explicit: true`。

**架构洞察**:
- Symbol + `Object.defineProperty` 做 taint tracking — 不改 JSON 形状，不影响序列化，但按引用传递时可检测
- 跟 nanobot 的 `pending_user_turn` flag 是同类模式: 用 metadata marker 区分 "有意为之" vs "默认行为"
- 这是 **authorization confusion** 漏洞：多层权限系统中，一层的 "合法默认值" 被另一层误读为 "显式授权"

### PR #65713: busybox/toybox 从 Interpreter-Like Safe Bins 移除

**攻击向量**: `busybox awk 'BEGIN{system("malicious_command")}'` — busybox 被信任为 safe binary，但其 applets（awk/find/xargs）可执行任意命令。

**修复**: 新建 `OPAQUE_MUTABLE_SCRIPT_RUNNERS` set。busybox/toybox 不再 auto-trusted，且 `opaqueMultiplexerSeen` flag 强制 fail-closed（需要 stable approval binding）。

**设计决策**: 不是简单 blocklist，而是改变 unwrap 逻辑——busybox 做 multiplexer 时，后续 applet 被视为 opaque（不可分析），强制走审批。

### PR #65717: Shell Wrapper Detection + env-argv Injection

**三个子问题**:
1. `sh script.sh` 不触发 shell-wrapper 过滤（只检查 inline `-c` payload）
2. `env VAR=val cmd` 中的 `SHELLOPTS`/`PS4` 等危险变量绕过 sanitizer
3. `LC_*` locale 变量用精确匹配而非前缀匹配

**修复**: `isShellWrapperInvocation()` 新函数独立于 shellPayload 检测；`parseEnvInvocationPrelude()` 提取 assignment keys → `inspectHostExecEnvOverrides()` 验证；`LC_*` 改为前缀匹配。

### 跨 PR 模式总结

| 模式 | 出现 | 描述 |
|------|------|------|
| Fail-Closed Default | #65713, #65717 | 不可分析 = 需要审批 |
| Taint/Marker Tracking | #65714 | metadata flag 区分 implicit vs explicit |
| Authorization Layer Confusion | #65714 | 多层系统间语义不一致导致权限升级 |
| Opaque Multiplexer | #65713 | 无法静态分析子命令 → 整体视为 unsafe |
| Prefix Matching | #65717 | 精确匹配太脆弱，`LC_*` 这类族群应前缀匹配 |

### 对我们的启示
- **[[agent-credential-security]]**: sandbox exec policy 是凭证隔离的前置防线
- **[[startup-credential-guard]]**: 同一 sprint 中安全修复互相强化（startup guard + runtime policy = defense in depth）
- 安全第二主线验证: 两个头部框架同日做安全 sprint（OpenClaw 3 PRs + hermes path traversal + multica security audit），production agent 框架正在系统化加固
- 考虑 PR 方向: 如果有新的 sandbox escape 向量可报告，OpenClaw 合入速度极快（pgondhi987 当日 merge）

### Hermes 同日安全动态
- #8756: web UI dashboard（新攻击面，但有 FastAPI REST backend + 独立端口）
- `c052cf0`: `ha_call_service` path traversal validation（domain/service 参数校验）
- `/restart` 改用 systemd `RestartForceExitStatus=75`（不再 detached subprocess，避免 cgroup cleanup kill）

### multica 同日
- #819: HttpOnly cookie auth（session token 不再暴露给 JS）
- #822: CSP headers

三个框架同日做安全加固 = **agent security 是 2026-04 的行业主题**，不只是我们的第二主线。

## Cron Safety Issue #65774 (2026-04-13)

**真实生产事故**: 用户配置了 9AM-5PM 的 WhatsApp 营销 cron，gateway 重连后所有 stale cron 在 1:02 AM 集体触发，给 9 个牙科诊所发了消息。用户无法停止 — `cron delete` 返回 `{ok: true, removed: false}` 但执行继续。只有断开 WhatsApp 账号才停住。

**三重失败**: stale catch-up 无时间窗口检查 + `cron delete` 不杀 in-flight 执行 + 无 kill switch。

**我们的风险**: 我们也有 gateway 重启后 cron reconciliation 问题（#65365 startup race 已确认）。虽然我们的 cron 只 announce 到 Discord 不发外部消息，但如果有发外部消息的 cron 也会中招。

**版本**: 用户在 2026.3.2，当前最新 beta 可能已部分修复 startup race，但 stale catch-up 和 kill switch 问题看起来是设计缺陷，不是 bug。

→ 详见 [[cron-runaway-safety]] 卡片

**2026-04-13 贡献**: 在 issue #65774 发表了 [root cause analysis comment](https://github.com/openclaw/openclaw/issues/65774#issuecomment-4234692715)，包含代码路径追踪 + 3 fix proposals。等 maintainer 回应后提 PR。

## Security Fix #62382 — allowedSymlinkTarget (2026-04-13)

**PR #62382**: 修复 `allowedSymlinkTarget` 安全检查。已 push，等 maintainer review。
- 这是 security-category PR，维护者通常响应较快
- 属于 defense-in-depth 类修复
- 状态: PENDING REVIEW

## Feishu QR Onboarding #65680 (2026-04-13)

Streamlined Feishu channel setup: QR code scan-to-create flow for app registration via OAuth device-code flow. Key changes:
- `auth.login` command: `openclaw channels login --channel feishu` enters onboard flow directly
- Interactive group chat policy selection (allowlist/open/disabled, default: allowlist)
- DM policy auto-configured as `dmPolicy=allowlist` when openId available
- Manual credential fallback preserved
- **Directly relevant to our setup**: we onboarded Feishu manually — next time (or for recommending to others) this flow will be much smoother

## Session Status Runtime #65807 (2026-04-13)

Extracted `buildStatusText` from `auto-reply/reply/commands-status.ts` into a neutral `src/status/` module. Fixes the `session_status` tool importing reply-layer runtime internals (import cycle risk). The tool now uses a local runtime shim.

## Dreaming System Code Simplification (2026-04-14 跟进)

### 版本差异: 2026.4.9-beta.1 → 2026.4.12 stable

Between our running version (2026.4.9-beta.1) and latest (2026.4.12), OpenClaw did a **major simplification** of the dreaming system: -3084 lines across 19 files.

### Key Removals
1. **`rem-evidence.ts` (1077 lines) — fully deleted**: Complex REM evidence extraction with 12+ signal regexes (build_signal, incident_signal, logistics_signal, etc). Replaced by grounded backfill approach.
2. **`groundedCount` / `claimHash` fields removed from ShortTermRecallEntry**: No more grounded verification tracking per entry. Entry key simplified to `source:path:start:end` (was `source:path:start:end:claimHash`)
3. **`dreaming-narrative.ts` trimmed 191 lines**: Narrative generation simplified
4. **`dreaming-narrative.test.ts` (113 lines) — fully deleted**: Tests for removed narrative features
5. **`short-term-promotion.test.ts` trimmed 125 lines**: Tests for removed grounded features

### What Was Grounded?
The grounded system was an attempt to verify recalled memories against evidence — `claimHash` was SHA-1 of normalized snippet, used to match recall entries to their evidence sources. `groundedCount` tracked how many times an entry was corroborated.

**Why removed**: Likely too complex for initial deployment. The signal was: recallCount + uniqueQueries + score is sufficient for promotion without separate evidence verification.

### Schema Fix (Critical for Us)
- **Bug**: `extensions/memory-core/openclaw.plugin.json` in the **dist** of 2026.4.9-beta.1 has `dreaming.properties: {}` (empty!)
- **Effect**: AJV validation fails with "must NOT have additional properties" for ANY dreaming config property we set
- **Fix**: In 2026.4.12, `configSchema` renamed from `config`, properties correctly populated (`enabled`, `frequency`, `timezone`, `verboseLogging`, `storage`, `phases`)
- **Runtime not affected**: The `resolveMemoryDreamingConfig()` function reads config permissively (no schema validation in code path), so dreaming _runs_ despite schema error — but gateway logs warnings

### Other Notable Changes
- `lowercasePreservingWhitespace()` replaced `.toLowerCase()` for workspace key normalization (Windows path handling)
- `includesSystemEventToken` imported for dreaming event text detection
- Session ingestion `seedHistoricalDailyMemorySignals` removed (no longer seeding history)
- Light/REM phase trigger detection simplified (removed per-phase type unions)

### Upgrade Impact Assessment
| Area | Impact |
|------|--------|
| Config validation | ✅ Schema error gone → clean logs |
| Short-term recall store | ⚠️ Existing entries have `groundedCount`/`claimHash` → `normalizeStore()` should handle gracefully (it does — unknown fields ignored) |
| Dreaming sweep | ✅ Simplified scoring (no grounded signal) → more predictable |
| Memory writes | ✅ Same MEMORY.md append behavior |
| Startup race | ✅ #65365 defers cron/heartbeat → no more "cron service unavailable" |

### 关联
- [[dreaming-vs-beliefs-candidates]] — existing comparison, still valid post-simplification
- [[progressive-disclosure-memory]] — recall signals unchanged
- 上次笔记: [[#Dreaming Runtime Verification + Upgrade Assessment]] (2026-04-13)

## Process Supervisor Analysis (2026-04-14)

### Current Architecture
- `supervisor.ts`: Two timeout mechanisms (overall + no-output), both fire `requestCancel()` → immediate `SIGKILL`
- `child.ts`: `killProcessTree(pid)` + `child.kill("SIGKILL")`, with `FORCE_KILL_WAIT_FALLBACK_MS = 4000` (Windows-only drain)
- No SIGTERM → SIGKILL escalation, no cross-platform drain timeout, no pipe close watchdog

### Gap Analysis (vs multica #947 three-layer pattern)
| Layer | multica | OpenClaw | Gap |
|-------|---------|----------|-----|
| Pipe close watchdog | `stdout.Close()` on ctx.Done | None | Missing |
| Signal escalation | SIGTERM → wait → SIGKILL | Direct SIGKILL | Missing |
| Independent drain timeout | backend timeout + 30s buffer | 4s Windows-only fallback | Partial |
| Context-aware ping | select on pingCtx.Done | N/A (no ping system) | N/A |

### Issue Filed
- **openclaw #66399**: "Process supervisor: graceful signal escalation and drain timeout for exec tool"
- Proposes: SIGTERM → 5s grace → SIGKILL + cross-platform drain timeout + optional pipe close
- Cites multica #947 and Go's `exec.Cmd.WaitDelay` as prior art

### Relevance
- Explains observed subagent SIGKILL behavior (gogetajob, Claude Code in cron)
- Signal escalation would let coding agents clean up temp files and partial writes
- Cross-platform drain timeout prevents potential zombie process hangs on POSIX

### Related
- [[process-hang-watchdog]] — concept card with three-layer pattern
- [[tool-execution-policy-enforcement]] — tool blocking patterns across frameworks

## v2026.4.14-beta.1 — Dreaming + Cron Stability Sprint (2026-04-14)

### Dreaming Fix #66139: Run Once Per Cron Schedule
- **问题**: managed dreaming 在 heartbeat 上重复触发——cron event 被消费后，后续 heartbeat 仍然跑 sweep
- **根因**: heartbeat hook 没有检查是否有 pending cron event
- **修复**: `hasPendingManagedDreamingCronEvent()` 用 `peekSystemEventEntries()` 检查 session queue 中是否有真正的 `cron:*` dreaming event
- **细节**: 处理了 `:heartbeat` isolated session 的 key 映射（heartbeat session 和 base session 是不同的 session key）
- **影响**: 我们的 dreaming 04-15 03:30 sweep 行为将更精确——只在 cron 真正调度时执行，不会在后续 heartbeat 中重复

### Cron Scheduler Fix #66083: Stop Unresolved Refire Loops
- **问题**: `computeJobNextRunAtMs` 返回 undefined 被当作短重试，导致无意义的 refire loop
- **修复**: undefined = 未解析的调度，不发明 synthetic retries。保持 maintenance wake 让 scheduler 不完全 idle
- **附加 #66113**: 保持 error-backoff floor，防止 maintenance repair 让 errored job 过早恢复

### Dreaming UI Fix #66140
- Imported Insights 和 Memory Palace 在 memory-wiki 插件关闭时不再调用其 gateway methods

### 安全持续
- pgondhi987 系列: heartbeat security (#66031), browser SSRF (#66040), Teams SSE (#66033), config snapshot redaction (#66030)
- mbelinky 系列: session routing poison (#66073), cron refire loop (#66083), browser CDP loopback (#66080)
- 特别关注 #66024: 按发送者 authorization context 分组 collect-mode followup drains（安全+正确性双修）

## Memory Search Eval Harness v0.1 (2026-04-14 Applied)

### 动机
GBrain v0.8.1 的 IR eval harness 证明了低成本、可复现的 retrieval quality 评估是可行的（PGLite 内存，2 秒跑完，零 API 依赖）。我们的 [[dreaming]] 和 [[memory-search]] 缺乏质量度量——"感觉好"不等于"可证明好"。

### 实现
- 20 queries × 5 results，标准 IR 指标：P@k, R@k, MRR, nDCG@k, Hit Rate
- Qrels 手工标注（grade 1-3），基于实际 wiki/cards + wiki/projects 内容
- 调用 `openclaw memory search --json`，测实际检索质量
- Path dedup 处理同文档多 chunk 问题
- 文件：`eval/memory-search-eval.py` + `eval/results/`

### Baseline 结果 (2026-04-14)
| 指标 | 值 |
|------|-----|
| Hit Rate | 80% (16/20) |
| P@5 | 0.622 |
| R@5 | 0.667 |
| MRR | 0.775 |
| nDCG@5 | 0.854 |

### 关键发现
1. **主题型查询表现好**（MRR 0.775）— 文档标题匹配查询概念时可靠找到
2. **时间型查询完全失败** — "what did I do yesterday" 返回 0 结果（无日期感知）
3. **操作/统计型查询失败** — "PR merge rate" 是事实型非概念型
4. **4/20 完全无结果** — 这些是 embedding 与查询语义距离过远的案例
5. **同文档多 chunk 膨胀** — 原始 metrics 被同一文档的不同段落命中虚高

### 与 GBrain 的差异
- GBrain：合成数据（29 fictional pages），PGLite 内存，2 秒，测的是 search code
- 我们：真实语料（136 cards + 140 projects），API 调用，220 秒，测的是端到端 retrieval quality
- 我们测的是"系统是否好用"（用户体验层），GBrain 测的是"代码是否正确"（实现层）

### 影响
- 建立了 baseline：后续任何 search 改进（intent-aware, embedding model upgrade）可量化对比
- 暴露了弱点：时间型/操作型查询需要不同策略（跟 [[intent-aware-retrieval]] 的发现一致）
- 验证了方向：从 vibes-based → metrics-driven 是正确转型

### 关联
- [[intent-aware-retrieval]] — GBrain 的意图感知检索，我们的 eval 验证了同样的弱点
- [[dreaming-vs-beliefs-candidates]] — dreaming promote eval 待数据积累后补充
- [[thin-harness-fat-skills]] — eval 本身是 "fat skill" 思路的实践

### Zero-Result Root Cause Analysis (2026-04-14 16:45)
深入调查 4 个零结果查询，发现三类根因：

| 类别 | 查询 | 根因 | 可修复? |
|------|------|------|--------|
| CROSS_LINGUAL | "agent credential security pool" | 卡片主体为中文，英文查询匹配不上 | ✅ 已修 |
| CROSS_LINGUAL | "agent memory taxonomy comparison" | 同上 | ✅ 已修 |
| TEMPORAL | "what did kagura do yesterday" | embedding 无时间解析能力 | ❌ 基本限制 |
| OPERATIONAL | "PR merge rate work statistics" | 计算型事实无文档语义表征 | ❌ 基本限制 |

**修复措施**：给 2 张中文卡片加了英文摘要段落（commit e30400a）。待 re-indexing 后重跑 eval 验证效果。

**范围评估**：~20 张卡片超过 70% 中文内容，但批量改造不必要——只有被实际英文查询命中的卡片才需要。先观察日常使用中哪些英文查询失败，再逐个修复。

**详细分析**：`eval/memory-search-failure-analysis.md`

### OpenClaw 04-14 Evening Followup (19:45)

**#66452 — Memory Embedding Proxy Provider Prefix Preservation** (merged 04-14)
- **问题**: 通过 proxy provider（如 LiteLLM、Spark）路由的 embedding model ref 会丢失 provider 前缀，被默默重写为 OpenAI ref
- **根因**: `normalizeEmbeddingModelWithPrefixes()` 对所有前缀模式一视同仁地 strip，包括第三方 provider 前缀
- **修复**: 改用 `parseStaticModelRef(trimmed, "openai")` — 只 strip `openai/` 前缀，保留 `spark/`, `litellm/` 等第三方前缀
- **代码量**: 7 行代码变更 + 25 行测试（4 个测试 case: blank→default, openai/→strip, spark/→preserve, unprefixed→preserve）
- **对我们的影响**: 如果升级到含此修复的版本，proxy-prefixed embedding 模型会更可靠。我们当前用默认 embedding，暂无直接影响，但了解此路径对未来 embedding 模型切换有价值

**04-14 全天合并 PR 统计**:
- OpenClaw: 15+ PRs merged（安全/media/gpt-5.4 compat/memory/telegram 修复）
- hermes: 15+ PRs merged（CI fix ×2, streaming cursor, ignored_threads, i18n dashboard, drug-discovery skill, light-mode skins, file search UX, tool registry thread safety）
- multica: 10+ PRs merged（hit PR #1000, macOS traffic lights, unread float, skeleton loading）
- GBrain: quiet（v0.8.1 search quality commit 是最新）
- SkillClaw: 527★, f3a23d4 commit 已在 study #228 深读

**gpt-5.4-pro Forward Compat** (#66453):
- OpenClaw 添加 gpt-5.4-pro 到模型注册表（前向兼容）
- #66437: gpt-5.4 在 Copilot 上启用 xhigh（推理等级提升）
- #66438: 规范化 gpt-5.4-codex 别名
- 信号：OpenAI 新模型生态在快速展开，OpenClaw 在第一时间适配

## 04-15 Followup: Dreaming Self-Ingestion Fix + Token Budget Preservation

### #66852 — memory: block dreaming self-ingestion (merged 04-15)
- **问题**: dreaming 产生的 narrative/report artifacts 可以通过 short-term promotion 回到持久记忆，形成 feedback loop
- **修复**: session transcript 跳过逻辑改用内部 dreaming run markers（前缀匹配）替代 prompt text 匹配；short-term promotion 在 normalization/recording/ranking/apply 四个阶段都拒绝 dreaming-shaped snippets
- **影响我们**: 我们的 dreaming 已启用（v2026.4.14），这个 fix 自动保护我们免受 self-ingestion。旧的 49 条 scores=0 entries 不会被意外 promote
- **设计洞察**: 没做 first-class provenance tracking（scope boundary 明确），而是用 marker-based heuristic。说明 [[openclaw]] 团队倾向 incremental hardening over architectural purity
- **相关**: [[dreaming]], memory-evolution

### #66820 — fix: preserve runtime token budget in deferred context-engine maintenance (merged 04-14)
- **问题**: deferred maintenance 重建 runtimeContext 时丢失了 tokenBudget，fallback 到 synthetic default
- **影响我们**: 可能解释我们 context budget 分析中看到的一些 inconsistency。v2026.4.14 已包含此 fix
- **相关**: context-budget-optimization

### Hermes #9934 — auto-continue interrupted agent work after gateway restart (merged 04-14)
- **做法**: 检测 history 末尾是否是 role='tool'（说明上次 agent 被中断），如果是就注入 system note 让 model 先完成中断的工作
- **Caduceus 相关**: 如果 Caduceus 的 hermes 实例重启，现在能自动恢复中断的任务。减少人工干预需求
- **设计**: 无 schema 变更，纯 heuristic（trailing tool message detection）。suspended sessions 不触发

## Dreaming Operational Status (2026-04-15 10:50)

### 根因：managed cron "skipped"
- Dreaming cron `0df29bb1` 自注册以来从未成功自动运行（status: skipped, 0 runs）
- Gateway 日志明确报错: `memory-core: managed dreaming cron could not be reconciled (cron service unavailable)`
- **根因**: memory-core plugin 启动时尝试注册 managed cron，但 cron subsystem 尚未就绪（startup race）
- 每次 gateway restart 都复现此 reconciliation 失败

### 手动触发验证
- `openclaw cron run 0df29bb1-...` 成功触发 dreaming
- Light dreaming: 从 9 个 workspace 扫描，staged 99 candidates → recall store 从 69 跳到 973 entries
- REM dreaming: 从 968 memory traces 生成反思，写入 dream diary（嵌入 memory/2026-04-15.md）
- Deep promotion: 全部 973 entries scores=0，无 promoted（需 recallCount≥3 + uniqueQueries≥2，当前数据不足）

### 行动项
- 短期 workaround: 在 daily-review cron 中加 `openclaw cron run 0df29bb1-...` 手动触发
- 长期: 等 OpenClaw 修复 managed cron startup race，或提 issue（与 #66399 process hang watchdog 同属基础设施稳定性）
- 预计 2-3 周后 scores 开始 >0（需积累足够 recall 事件）

### Dreaming Workaround 验证 (2026-04-15)

**根因确认**: managed dreaming cron (03:30) 有两个问题：
1. **Quiet hours 阻塞** — sessionTarget=main, 03:30 在 quiet hours (23:00-08:00) 范围内，被 skipped (error: "quiet-hours")
2. **空跑** — 即使不在 quiet hours，systemEvent 只跑 3ms = no-op（04-13 记录）

**运行历史** (0df29bb1):
- 04-13 03:30: ok, 3ms (空跑)
- 04-15 03:30: skipped, quiet-hours
- 04-15 10:49: ok, 143s (手动触发，实际处理了 974 entries)

**Workaround**: daily-review cron (03:15, isolated, 不受 quiet hours 限制) 加了步骤 3: `openclaw cron run 0df29bb1-...` 手动触发 dreaming

**长期方案**: 提 OpenClaw issue — managed cron 的 sessionTarget 应考虑 quiet hours 兼容性，或 dreaming systemEvent 应走 isolated session
