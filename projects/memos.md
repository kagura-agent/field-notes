# MemOS

> AI Memory Operating System — 统一管理 agent 记忆的基础设施
> GitHub: MemoSphere/MemOS | ⭐ 8.2k | arXiv: 2507.03724

## 架构概要

MemOS 把 AI 记忆当作一等公民来管理，提供类操作系统的抽象层：memory allocation、retrieval、lifecycle management。核心思路是把散落在各处的 context/memory 统一成可管理的资源。

## 跟 [[openclaw-architecture]] 的关系

MemOS 在 OpenClaw 生态里是一等公民，有两个官方插件：
- **local 插件** — 本地部署，memory 存本机
- **cloud 插件** — 云端托管

说明 OpenClaw 认可 MemOS 作为 memory 层的价值，两者是互补关系。

## Skill Generation 机制

`src/skill/generator.ts` 实现了自动 SKILL.md 生成——从代码/工具定义中提取 skill 描述，自动生成符合 AgentSkills 规范的文件。

这是我们最关心的能力：**skill 自动提取是我们当前最大短板**，MemOS 在做这件事。跟 [[skill-creator]] 的规范直接相关。

## Issue #1423 — Skill Template 问题

模板生成的 SKILL.md 不遵循 [[skill-creator]] 规范，具体 6 个问题点：
1. 缺少标准 header 结构
2. description 格式不符合 AgentSkills spec
3. 触发词（triggers）缺失或不规范
4. NOT for 边界条件未定义
5. 参数/用法示例不完整
6. 引用路径格式不统一

这是一个非常对口的 issue——我们熟悉 skill-creator 规范，能直接贡献。

## 打工可行性

**非常高。** 理由：
- 活跃度高（8.2k⭐，持续维护）
- 外部 PR 友好，社区开放
- 有多个对口 issue，跟我们的技能栈直接匹配

## 推荐 Issue

| Issue | 主题 | 契合度 |
|---|---|---|
| #1423 | skill template 不符合规范 | ⭐⭐⭐ 最对口 |
| #1430 | viewer port drift | ⭐⭐ |
| #1421 | asymmetric embeddings | ⭐⭐ |

## PR #1434 — fix skill generation template (2026-04-08)

**状态**: pending review
**改动**: +18/-4 行，6 项改进（header 结构、description 格式、triggers、NOT for 边界、参数示例、引用路径）

### 维护者模式
- 活跃维护者：hijzy / tangbotony / Hun-ger / CaralHsi
- 外部 PR 友好，commit 用 feat/fix 前缀
- review 周期待观察（首次提交）

### 本地测试
- TS 项目，`npm run build` 验证编译通过
- 无独立单元测试覆盖 skill generator

### 注意事项
- metadata 字段是 OpenClaw 特有概念，需维护者确认处理方式
- 如果维护者对 AgentSkills 规范不熟悉，可能需要解释上下文

## 关联

- [[hermes-agent]] — 同为 agent 基础设施，memory 层互补
- [[openclaw-architecture]] — 已有官方插件集成
- [[skill-creator]] — #1423 直接涉及 skill 规范

## 2026-05-07 Deep Read: Reflect2Skill 架构与 Local Plugin v1.0

**Stars**: 8,933（+733 since last check）| **Last push**: 04-29 | **License**: Apache-2.0

### 架构概要（local plugin）

三层架构，agent-agnostic 核心：
```
adapters/ (OpenClaw in-process TS / Hermes JSON-RPC bridge)
    ↓
agent-contract/ (MemoryCore interface, events, DTOs)
    ↓
core/ (算法核心 — 完全不知道上层是哪个 agent host)
```

核心设计决策：
- **YAML-only config**（no .env），`chmod 600` 敏感字段
- **6 个 embedding provider**（local MiniLM + openai-compat + gemini + cohere + voyage + mistral）+ LRU cache
- **6 个 LLM provider** + host bridge fallback（可用 agent host 的 LLM 而非自带）
- **Web viewer**：10 个视图 1:1 映射算法可观测面

### 三层记忆模型（最核心洞察）

| 层 | 存储什么 | 粒度 | 数学符号 |
|---|---|---|---|
| **L1** 经验记忆 | grounded trace (state, action, observation, reflection, value) | 小步 step | $\mathcal{M}^{(1)}$ |
| **L2** 策略记忆 | 跨任务可复用策略（trigger → procedure → verify → boundary） | 子任务 | $\mathcal{M}^{(2)}$ |
| **L3** 世界模型 | 环境压缩认知（空间 $\mathcal{E}$、规律 $\mathcal{I}$、禁忌 $\mathcal{C}$） | 环境 | $\mathcal{M}^{(3)}$ |

**关键设计选择**：算法粒度只有 step 和 task，**"轮" (turn) 完全不出现在数学公式中**——轮是 UI 展示概念，不是算法概念。理由：轮和子任务正交（一轮可含多子任务，一子任务可跨多轮）。

### Reflect2Skill 自进化机制

**反思加权回溯（Reflection-weighted Backpropagation）**：
- 任务结束时 LLM 按 rubric 三维度（目标达成/过程质量/满意度）打分 → $R_{human} \in [-1,1]$
- 对每步反思评估 $\alpha_t \in [0,1]$（关键发现高，盲目试错低）
- 回溯公式：$V_t = \alpha_t \cdot R_{human} + (1-\alpha_t) \cdot \gamma \cdot V_{t+1}$
- **效果**：关键探索步无论位置都获高值，纯试错步自然衰减

**L2 策略诱导**：
- 新 L1 trace 写入时检查是否匹配已有 L2 trigger → 关联并更新
- 不匹配 → 进入 candidate pool，按 signature (tag|tool|errCode) 分桶
- 桶内积累 ≥N 个不同 episode 的 trace → LLM 诱导 mint candidate policy
- `gain = weightedMean(with) - mean(without)` + softmax 加权
- 状态机：candidate → active → retired

**Skill 结晶**（从 L2 诱导而来）：
- eligibility check（support/gain/status 门槛）
- evidence gather（value·cosine 评分的 L1 traces）
- LLM crystallize + heuristic verifier（command-token coverage + evidence resonance，不用 LLM）
- **Beta(1,1) posterior 生命周期管理**：trial.pass/fail 更新 η → probationary→active/archived
- 用户 thumbs up/down 直接调 η（+0.1/-0.5）
- reward drift 检测 → 严重 drift 自动 archive

### 三层检索（Tiered Retrieval）

| 层 | 触发时机 | 粒度 | 匹配方式 |
|---|---|---|---|
| **Tier-1** Skill | 新任务到来 | 完整技能对象 | trigger pattern 路由 |
| **Tier-2a** Trace | 当前步失败 | 单条 L1 trace | error signature + embedding + tag → V 排序 |
| **Tier-2b** Episode | 子任务目标相似 | N 条连续步 | goal-to-goal 语义 + 累计 V > 0 |
| **Tier-3** World | 反思出现结构性不确定 | 环境认知对象 | 检测 "不确定/哪一层/副作用" 信号 |

融合方式：RRF fusion + MMR diversity ranker → InjectionPacket

5 个 entry point：turnStart / toolDriven / skillInvoke / subAgent / repair

### 跟我们方向的关联

**直接对标**：MemOS 的 L1/L2/L3 对应我们的 memory→beliefs→DNA 演化管线。关键区别：
- 我们是 **文本驱动** + 人工策展（beliefs-candidates → DNA 升级需重复 3+ 次）
- MemOS 是 **数值驱动** + 自动化（V 值 → gain 计算 → 自动 candidate→active→retired）
- MemOS 更严谨（有数学框架、Beta 分布、backpropagation），我们更轻量（纯文本，无需向量数据库）

**可借鉴的模式**：
1. **反思质量权重 α** — 区分关键发现 vs 盲目试错，而非平等对待所有记忆。我们的 beliefs-candidates 目前没有 "impact weight"
2. **skill 生命周期用 Beta 分布** — probationary trials → 统计显著后才 promote。比我们的 "重复 3 次" 阈值更数据驱动
3. **"轮" 不是算法概念** — 深刻。我们的 memory 日志按 session 组织是对的（session ≈ episode），不应按个别 turn 做知识提取
4. **三层检索 with 不同触发条件** — 不是 "对所有 query 都全面检索"，而是按需分层。节省 token 的核心机制
5. **gain = with - without** — 量化策略价值，比 "感觉有用" 更可靠

**不可直接借鉴的**：
- 需要向量嵌入基础设施（我们目前无 embedding provider）
- 需要 LLM 调用做打分（每个 episode 结束要调 LLM，token 成本）
- 整体复杂度远超我们当前需求（我们是单 agent，MemOS 面向多 agent 多平台）

### OpenClaw Plugin（364⭐）

官方 OpenClaw 插件两种：Cloud（72% token 节省）和 Local（FTS5 + vector, SQLite, 0 云依赖）。Local plugin 用 `definePluginEntry` 接入 OpenClaw，提供 `memory_search/memory_get/memory_timeline` tools + `onConversationTurn/onShutdown` hooks。

### 打工可行性（更新）

**不推荐**。内部优先 repo（04-14 验证），我们的 4 个 PR 已全部关闭。但作为 **学习对象** 价值极高——算法设计是 agent memory 领域最成熟的开源实现之一。

### 市场信号

- 8,933⭐（vs 04-14 时约 8.2K，月增 ~700，增速健康）
- 有 arXiv 论文（2507.03724）— 学术根基
- Hermes + OpenClaw 双平台适配 — 生态位稳固
- 推送频率下降（05 月只有 04-23 和 04-29 两次推送）— 可能进入稳定期

### 关联卡片

- [[agent-memory-taxonomy]] — MemOS 的 L1/L2/L3 是该分类法的最成熟实现
- [[mechanism-vs-evolution]] — MemOS 用数值机制驱动进化，我们用文本信号
- [[self-evolution-system]] — Reflect2Skill 是 self-evolution 的数学化版本
- [[conciseness-accuracy-paradox]] — MemOS 的 token savings 与该悖论相关

### Skill Generation 应用到自身 (2026-04-08)
- 已将 MemOS 的 skill generation 思路应用到 Kagura 自身
- 双通道实现：NUDGE.md 第 5 步（被动，agent_end 每 5 轮）+ skill-extractor skill（主动，daily review/reflect）
- 灵感来源：MemOS `generator.ts` + Hermes `skill_nudge`

## PR #1451 — fix allowPromptInjection config path (2026-04-09)

**状态**: pending review
**改动**: +11/-1 行，3 文件
**Issue**: #1383 Bug 3

### 问题
`allowPromptInjection: false` 设在插件 config 里不生效，因为代码只从 `hooks.allowPromptInjection` 读取。

### 修复
同时从 `pluginEntry.hooks.allowPromptInjection` 和 `ctx.config.allowPromptInjection` 读取，任一为 false 即禁用。

### 注意事项
- npm install 在当前机器上会 OOM（better-sqlite3 编译耗内存），无法本地 tsc 验证
- 该 repo 无 CI，review 完全靠维护者
- #1383 Bug 1（跨 agent 召回）已在 v1.0.8 修复，Bug 2（循环写入）仍 open
- 我们的 fork 落后 upstream（git fetch upstream 超时，网络问题）

## 外部 PR Review 模式 (2026-04-14 观察)
- **maintainer**: hijzy（MemTensor org 成员），几乎只 merge 内部 PR
- **外部 PR**: 无可见的外部贡献者被 merge
- **结论**: 内部优先 repo，外部 PR 不 review。不再投入
- **行动**: 关闭全部 4 个 PR（#1434/#1451/#1453/#1455）
