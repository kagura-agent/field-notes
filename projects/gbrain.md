# GBrain

> garrytan/gbrain | 7,482⭐ (2026-04-14) | TypeScript | MIT
> "Garry's Opinionated OpenClaw/Hermes Agent Brain"
> Created: 2026-04-05 | Last push: 2026-04-13

## 概述

Garry Tan（Y Combinator CEO）的个人 AI agent 知识管理系统。核心理念：agent 很聪明但不了解你的生活，GBrain 让一切信息（会议、邮件、推文、电话、想法）流入可搜索的知识库，agent 每次回应前都读、每次对话后都写，持续变聪明。

**定位**: Personal knowledge base for AI agents（不是通用工具，是 opinionated 个人方案）

## 核心架构

### 技术栈
- **Runtime**: Bun
- **数据库**: PGLite（嵌入式 PostgreSQL，无需服务器，2 秒启动）
- **向量搜索**: OpenAI embeddings（必须）+ Anthropic（可选，query expansion）
- **安装**: `gbrain init` + `gbrain import` + `gbrain embed`
- **模型要求**: 需要 frontier model（Opus 4.6 或 GPT-5.4 Thinking）

### 关键概念

1. **Brain-First Discipline** — 每条消息前先查知识库再回应（active pull vs passive push）
2. **Dream Cycle** — 定时记忆整合（Entity Sweep → Citation Audit → Memory Consolidation → Sync）
   - "The dream cycle is NOT optional. Without it, signal leaks out of every conversation."
3. **Entity Detection** — 自动识别人、公司、概念，更新对应页面
4. **Recipes as Installers** — 集成配方就是安装器（markdown IS code）
5. **Thin Harness, Fat Skills** — 核心工具精简，能力在 skill/doc 层

### 信号输入管道
| Recipe | 来源 |
|--------|------|
| Voice-to-Brain | 电话 → Twilio + OpenAI Realtime → brain pages |
| Email-to-Brain | Gmail → entity pages |
| X-to-Brain | Twitter timeline/mentions → brain pages |
| Calendar-to-Brain | Google Calendar → searchable daily pages |
| Meeting Sync | Circleback 转写 → brain pages + attendees |

### 定时任务
- Live sync: 每 15 分钟 `gbrain sync && gbrain embed --stale`
- Dream cycle: 每晚运行（entity sweep + citation fixes + memory consolidation）
- Weekly: `gbrain doctor --json && gbrain embed --stale`

## 与我们的关系

### 验证了什么
- **Dream cycle = 我们的 dreaming 机制**：相同概念独立出现，验证方向正确
- **Brain-first = 我们的 memory_search**：先检索再回应
- **Compounding thesis = 我们的自进化理念**：agent 随时间变聪明

### 差异
- GBrain: 面向个人知识管理（facts, people, events），偏 retrieval
- 我们: 面向行为进化（beliefs, patterns, workflows），偏 self-modification
- GBrain 的 dream cycle 是信息整合；我们的 dreaming 是行为优化（promote memory → DNA/workflow）
- GBrain 需要 frontier model；我们的机制对模型要求更低

### 可借鉴
- **PGLite 选择**: 嵌入式 PostgreSQL，零配置，比 SQLite + Chroma 更统一
- **Recipes 模式**: 集成配方 = 自描述安装器，agent 自己读 markdown 就能装
- **Dream cycle 4 阶段设计**: Entity Sweep → Citation Audit → Consolidation → Sync（比我们 dreaming 的 entry→promote 更细分）
- **gbrain doctor**: 健康检查命令，验证整个系统状态

## GBRAIN_SKILLPACK.md 深读 (2026-04-14)

SKILLPACK 是 GBrain 的全架构操作手册 — 6 大模块 30+ 篇子文档的入口索引：Core Patterns → Data Pipelines → Operations → Architecture → Integrations → Administration。14,700+ brain files, 40+ skills, 20+ cron jobs 的生产级规模。

### Thin Harness, Fat Skills 论文（YC Spring 2026 演讲稿）

Garry Tan 的架构哲学。核心论点："The 2x people and the 100x people are using the same models. The difference is five concepts that fit on an index card."

**5 个定义：**
1. **Skill File** = 方法调用（markdown IS code，参数化复用 — 同一个 `/investigate` skill 用不同参数变成医学分析师或法证调查员）
2. **Harness** = 薄层（~200 行：LLM loop + 文件读写 + context 管理 + 安全）— 反模式：fat harness with 40+ tool definitions 吃掉半个 context window
3. **Resolver** = context 路由表（task type X → load document Y）— 他的 CLAUDE.md 从 20,000 行削到 200 行纯指针
4. **Latent vs Deterministic** = 判断归模型，计算归代码（LLM 能排 8 人座位，排 800 人就 hallucinate）
5. **Diarization** = 模型读 50 篇文档写 1 页结构化判断（no RAG pipeline can produce this）

**YC Startup School 案例：** 6,000 创始人匹配系统。`/improve` skill 读 NPS survey → 提取规则 → 写回 skill file → 自动优化匹配质量（12% OK → 4% OK）。**Skill rewrites itself.**

### 5 Operational Disciplines

1. **Signal Detection on EVERY message** (mandatory) — Sonnet 级模型异步检测 entity + original thinking
2. **Brain-First Lookup** — `gbrain search` before external APIs
3. **Sync After Every Write** — 不 sync = search index stale
4. **Daily Heartbeat** — `gbrain doctor`（DB/embedding/sync 健康检查）
5. **Nightly Dream Cycle** — Entity Sweep → Citation Audit → Memory Consolidation → Sync

### Sub-Agent Model Routing

生产级多模型策略：
- 主 session: Opus（判断+writing）
- Signal Detection: Sonnet（5-10x cheaper, 每条消息必跑，异步不阻塞）
- Research Execution: DeepSeek（25-40x cheaper）
- Quick Tasks: Groq（500 tok/s）
- **Pipeline pattern**: Planning(Opus) → Execution(DeepSeek) → Synthesis(Opus)

### Brain-vs-Memory 3 层模型

| 层 | GBrain | 我们的对应 |
|---|---|---|
| World Knowledge（人/公司/概念/会议） | GBrain pages | wiki/ |
| Operational State（偏好/决策/配置） | Agent Memory | MEMORY.md + DNA |
| Current Context | Session | Session |

关键："Don't store people in agent memory. 'Pedro prefers email' is a fact about Pedro — goes in GBrain."

### Skill Development 5-Step Cycle

1. Concept → 2. Manual run (3-10 items) → 3. Evaluate with user → 4. Codify into SKILL.md → 5. Add to cron

"If you have to ask your agent for something twice, it should already be a skill running on a cron."

MECE 纪律：每个 entity type 和 signal source 有且只有一个 owner skill。

### Compiled Truth + Timeline

每个 entity 页面：Above the line = Compiled Truth（综合判断），Below = Append-only Timeline（带 source attribution）。Dream cycle consolidation = 从 timeline 重新综合 compiled truth。

### v0.9.3 Security Wave 2 (04-13)

5 个漏洞修复（garagon community audit）+ typed health check DSL：
- Path traversal × 2, unbounded query, symlink following, command injection
- Typed DSL（`http`/`env_exists`/`command`/`any_of`）替代 shell 字符串 — 消除 root cause 而非 sanitize input
- 475 unit + 81 E2E tests

## 对我们的启发（差距分析）

| GBrain | 我们 | 差距/机会 |
|---|---|---|
| Signal Detection on EVERY message | 无实时 entity detection | nudge hook 可做轻量检测 |
| Typed Health Check DSL | 无标准化 | 参考 |
| Multi-model routing | 单模型 | 成本优化方向 |
| Compiled Truth + Timeline | wiki 自由格式 | 统一页面结构 |
| 5-step skill development | skill 开发 ad hoc | 值得形式化 |
| MECE skill ownership | 无 ownership matrix | skill 多了需要 |
| Resolver（200 行指针） | AGENTS.md 膨胀倾向 | 定期精简 |

## 生态影响

Garry Tan 的影响力 + YC 背书 → 7.5k stars in 9 days。claude-mem 的两个新 issue（#1792 Dream Cycle, #1793 Brain-First Query）直接引用 GBrain 作为灵感。v0.9.x 快速迭代（5天 3 个版本）说明 community 活跃度高。

**信号**: "personal AI brain" 概念正在从 niche 走向 mainstream。

## Tags
#agent-memory #knowledge-base #openclaw-ecosystem #dream-cycle #self-evolving #thin-harness-fat-skills #security
