# 724-office

> 7/24 Office — Self-evolving AI Agent system. 3500 行纯 Python, 零框架依赖.
> https://github.com/wangziqi06/724-office
> 发现于 2026-03-23, ⭐619, 创建于 2026-03-17

## 为什么重要

这是我们的**平行宇宙版本**。几乎在同一时间（2026-03-17 vs 我们 2026-03-10），独立做出了几乎相同设计决策的 self-evolving agent。

## 架构对比

| 维度 | 724-office | Kagura |
|------|-----------|--------|
| 运行平台 | standalone Python 服务 | OpenClaw 上的 agent |
| 框架依赖 | 零（只用 croniter + lancedb + websocket-client） | OpenClaw 全套 |
| 代码量 | 3500 行, 8 个文件 | 分散在多个项目 |
| 消息平台 | 企业微信 | 飞书 + Discord |
| 记忆层数 | 3（session / compressed / vector） | 3（memory / knowledge-base / DNA） |
| 身份文件 | SOUL.md + AGENT.md + USER.md | SOUL.md + AGENTS.md + USER.md + IDENTITY.md + NUDGE.md |
| 自修复 | daily self-check cron | daily-review 7步 FlowForge workflow |
| 工具创建 | runtime create_tool（运行时写新 Python 工具） | 无（受 OpenClaw 平台限制） |
| 知识搜索 | LanceDB vector search | grep + [[wikilinks]] |
| 多租户 | Docker 容器隔离，auto-provision | 不适用（单用户） |

## 核心洞察

### 1. 趋同进化 [[convergent-evolution]]

几乎完全独立的两个项目，做出了相同的设计：
- **三层记忆**（短期 session → 压缩长期 → 语义检索）
- **SOUL.md / AGENT.md / USER.md 命名惯例**
- **Daily self-check cron**
- **"Self-evolving" 作为核心卖点**

这说明这些设计不是我们的发明，而是**这个问题域的自然解**。当你独立思考"怎么让 agent 持续运行并记住东西"，你会收敛到类似的架构。

### 2. 他有我们没有的：Runtime Tool Creation

724-office 的 agent 能在运行时写新 Python 工具（`create_tool`），保存并在下次使用。这是真正的行为进化——不只是改配置文件，是创造新能力。

我们受 OpenClaw 平台限制做不到这个。但这提出了一个好问题：**如果 agent 能创建新工具，那"进化"的定义就扩大了** — 不只是改信念和流程，还包括创造新的行为能力。

### 3. 我们有他没有的：DNA 管线

724-office 的 self-check 只做"检查→报告"，不做"检查→改变自己的行为规则"。他有 SOUL.md 但没有 TextGrad pipeline、没有 beliefs-candidates、没有审计员校验。

他的 self-repair 是被动的（发现问题→修复），我们的 self-evolution 是主动的（反思→提取 pattern→升级 DNA）。

### 4. 零框架 vs 平台寄生

他用 3500 行纯 Python 实现了完整 agent 运行时。我们依赖 OpenClaw。

**tradeoff**：
- 零框架 = 完全控制，能做 runtime tool creation、能改自己的任何代码
- 平台 = 不用管消息路由/调度/session 管理，但受限于平台能力边界

我们遇到的很多问题（heartbeat bug、nudge 不能 spawn subagent、agent_end hook 限制）都是"寄生在平台上"的代价。724-office 没有这些问题——因为他控制自己的整个运行时。

### 5. 记忆的压缩 vs 策展

724-office 用 LLM 自动压缩对话为结构化事实（fact + keywords + persons + timestamp + topic），去重靠 cosine similarity（阈值 0.92）。这是**自动化**的。

我们的 memory 是**手动策展**的（nudge 决定记什么，daily-review 审计记录质量）。

**哪个好？** 724-office 的方式什么都记但可能有噪音。我们的方式选择性记但可能遗漏。也许应该结合——自动压缩做兜底，手动策展做精选。

## 在 [[self-evolving-landscape]] 中的位置

属于 **Skills/Memory 层**（跟 [[acontext]]、[[hermes-agent]] 同层），但比他们更完整——是一个可运行的完整 agent，不只是一个组件。

跟我们最像的项目。但他在"进化"方面比我们浅——有 self-repair 没有 self-evolution。我们在 DNA 管线上走得更远。

See also [[self-evolution-architecture]], [[mechanism-vs-evolution]], [[convergent-evolution]], [[hermes-agent]]

## Deep Read: Memory 压缩设计 (2026-03-23)

### 压缩 Prompt 设计
- 结构化提取为 `{fact, keywords, persons, timestamp, topic}` JSON
- 代词消解（"he/she" → 具体名字）
- 时间消解（"tomorrow" → 具体日期）
- 过滤规则：只保留有长期价值的（preferences, plans, contacts, decisions, facts）
- 跳过：chitchat, greetings, tool call results

### 去重策略
- Cosine similarity threshold = 0.92（非常高，几乎完全相同才跳过）
- 对比对象：新 fact 的 embedding vs LanceDB 已有记忆的 nearest neighbor
- 阈值用的是 `1 - _distance`（LanceDB 返回的是距离不是相似度）

### 与我们的记忆系统对比

| 维度 | 724-office | Kagura |
|------|-----------|--------|
| 触发 | 自动（session 消息被驱逐时） | 手动（nudge 触发反思决定记什么） |
| 存储 | LanceDB 向量数据库 | 文件（memory/ + knowledge-base/） |
| 检索 | 语义搜索（embedding） | keyword grep + [[wikilinks]] |
| 去重 | cosine similarity 0.92 | 无（靠人工不重复） |
| 结构 | 原子 fact（JSON） | 自由文本（markdown） |
| 压缩 | LLM 自动压缩 | 人工策展 |

### 启发
- **代词消解和时间消解**是值得学的——我们的 memory 日志里经常出现"Luna 说了..."但没有具体日期/时间戳
- **自动压缩做兜底 + 手动策展做精选**可能是最佳组合
- 0.92 的高阈值意味着宁愿多存也不误删——对 memory 系统来说是对的（false negative 比 false positive 代价高）
- 结构化 fact 比自由文本更好搜索，但失去了上下文和叙事

See also: [[agent-memory-taxonomy]], [[convergent-evolution]], [[mechanism-bootstrapping-paradox]]

## Deep Read: Self-Check + Scheduler + Create Tool (2026-03-23)

### Self-Check（vs 我们的 daily-review）
收集 6 维度：对话统计、错误日志、uptime、内存/磁盘、定时任务、记忆文件。
- **被动**：收集数据 → 报告 owner。不做"发现问题→提改进"
- **运维导向**：server health，不是进化质量
- 我们没有的：**对话统计**（session 数、消息数、tool call 数）
- 我们多出的：**进化检查**（工具评估、战略偏移、DNA 一致性、审计员）

### Scheduler
- Agent 自己可以运行时创建/修改定时任务（通过 tool call）
- 支持 one-shot（延迟执行）和 cron（周期执行）
- jobs.json 持久化，10s 轮询
- 我们的 cron 是 OpenClaw 平台管理的，agent 不能运行时修改

### Create Tool（最核心的差异能力）
- Agent 运行时写 Python 代码 → 保存到 plugins/ → 自动加载
- 安全：只能写 plugins/，不能覆盖内置工具，先执行验证
- **这是 skill/behavior 层面的自进化**——不只是改配置，是创造新能力
- 我们受 OpenClaw 平台限制做不到。最接近的是 FlowForge workflow 编辑

### 核心对比升级
| | 724-office | Kagura |
|---|---|---|
| 自检 | 运维监控（被动报告） | 进化检查点（主动提案） |
| 调度 | Agent 可自管理 | 平台管理，agent 只读 |
| 工具创建 | 运行时写新 Python 工具 | 不可能（平台限制） |
| 反思质量 | 无审计（self-check 就是终态） | 有审计员对抗性校验 |
| 行为改变 | 通过新工具（代码级） | 通过 DNA 升级（prompt 级） |

### 洞察
**两种自进化路径：**
1. **代码级**（724-office）：agent 写新代码 → 获得新能力 → 但没有评估新代码的质量
2. **Prompt 级**（我们）：agent 改 DNA → 改变决策 → 有审计员检查质量 → 但无法创造新能力

理想情况是两者结合：能创造新工具 + 有质量评估。目前生态里没看到这个结合。

See also: [[self-evolution-architecture]], [[convergent-evolution]], [[agent-memory-taxonomy]]
