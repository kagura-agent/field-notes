# GBrain

> garrytan/gbrain | 7,889⭐ (2026-04-15 11:15) | TypeScript | MIT
> "Garry's Opinionated OpenClaw/Hermes Agent Brain"
> Created: 2026-04-05 | Last push: 2026-04-15

### 更新 (04-15)
- v0.9.3 (04-13): security wave 2 — 5 vulns fixed + typed health check DSL
- v0.8.1 (04-14): search quality boost — compiled truth ranking + detail parameter
- ★ +303 in 1 day (7586→7889), 仍在快速增长

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

## GBrain 动态跟进 (2026-04-14)

### v0.9.3 后续 (04-13~14)
- **7,518★** (04-14 12:45)，vs 7,482★ (04-14 earlier) — 增长放缓但仍健康
- **#110 readonly MCP** (closed/merged): `gbrain serve --readonly` — MCP server 只读模式，防止共享集成修改 brain。利用已有 `mutating` flag，只是之前没人检查
- **#111 symlink permission denied** (open): Linux 上 `bun install -g gbrain` 后 cli.ts 缺执行位，MCP 调用失败。社区痛点（Hermes 用户报告）
- **#103 "GBrain vs Active Memory"** (open): 用户困惑是否该用 GBrain 还是 OpenClaw Active Memory（2026.4.11 新功能）。**关键信号：agent memory 空间进入 user confusion 阶段**——多产品解决类似问题，用户不知如何选择
- **#104 Captain multimodal** (open): 添加 Captain（YC W26）作为多模态搜索层——GBrain 处理文本，Captain 处理图片/视频/音频。GBrain 走平台化路线
- **Security issues #105-109**: 5 个安全 hardening issue（path traversal confine, health check gate, query sanitization 等），community audit 持续输出

### 信号
- GBrain 从 "个人工具" 快速走向 "平台"：readonly MCP（共享场景）+ Captain 集成（多模态）+ security hardening（生产化）
- #103 的 confusion 是生态成熟度信号：当多个产品覆盖类似空间时，差异化和定位变得关键
- Security wave 持续（v0.9.3 + 5 new issues），community audit 模式健康

## v0.8.1 Search Quality Boost (2026-04-14 deep read)

PR #64: 从 "search works" 到 "search works well" 的关键升级。2,899 additions。

### 核心问题
GBrain 页面有两段：compiled truth（综合判断）和 timeline（时间线事件）。之前 search 把两者同等对待 —— 问 "who is Alice?" 可能返回会议笔记，问 "when did we meet?" 可能返回人物评估。

### 解决方案：Intent-Aware Hybrid Search

**Pipeline**: keyword + vector → RRF fusion → normalize → boost → cosine re-score → dedup

**3 个关键创新：**

1. **Intent Classifier** — 零延迟 regex heuristic（非 LLM），从查询文本检测 intent：
   - entity ("who is X?") → boost compiled truth
   - temporal ("when did we meet?") → skip boost, show timeline
   - event ("what launched?") → skip boost
   - general → moderate boost
   - 用 `detail` parameter 映射（low/medium/high），agent 也可显式指定

2. **Compiled Truth Boost** — RRF 归一化后 2.0x 分数乘数（仅在 detail ≠ high 时应用）。关键设计：**不是 raw score boost 而是归一化后 boost**，防止极端偏斜

3. **Cosine Re-scoring** — 用 query embedding 对 RRF 结果重排：0.7*rrf + 0.3*cosine。在 dedup 之前执行（语义更好的 chunk 更可能存活）

### 正式 IR Eval 框架
这是 GBrain 最有价值的新增——不是 search 改进本身，而是 **how they measure it**：

- `gbrain eval --qrels`：标准 IR metrics（P@k, R@k, MRR, nDCG@k）+ A/B 配置对比
- 29 fictional pages, 58 chunks, 20 queries with graded relevance (1-3)
- 可在 PGLite 内存中 2 秒跑完，零 API 依赖
- EvalQrel 格式：`{query, relevant: string[], grades?: Record<string, number>}`

### 结果
- Page-level retrieval 基本不变（P@1 94.7%，MRR 0.974）—— 之前就能找到对的页面
- **Chunk-level 显著改善**：unique pages +21%（7.2→8.7），compiled truth ratio +29%（51.6%→66.8%）
- **关键反直觉发现**：naive boost（无 intent）**大幅恶化** source accuracy（89.5%→63.2%）—— 因为强制 compiled truth 到顶部即使 timeline 才是正确答案。Intent classifier 是必要的修正

### 4-Layer Dedup Pipeline
升级后的 dedup（`dedup.ts`）：
1. By source: top 3 chunks per page by score
2. By text similarity: >0.85 Jaccard 相似度去重
3. By type: 单一类型不超过 60% 结果
4. By page: max 2 chunks per page
5. **Compiled truth guarantee**: 每个页面至少 1 个 compiled truth chunk

### 跟我们的关联
- **Eval 框架直接可借鉴**：我们的 [[dreaming]] 系统缺乏 retrieval quality 度量。GBrain 证明了低成本、可复现的 eval 是可行的（PGLite 内存测试，2 秒）
- **Intent-aware search 思路**：我们的 [[memory-search]] 不区分查询意图。"我昨天做了什么" vs "什么是 dreaming" 应该有不同检索策略
- **Naive boost 陷阱**：提醒我们做 dreaming promote 时也要注意——单纯提高 recall count 权重可能恶化其他场景
- **Compiled truth = 我们的 MEMORY.md**：都是从 raw data (timeline/daily notes) 提炼出的综合判断

## 跨项目跟进 (2026-04-14 15:45)

### OpenClaw v2026.4.14-beta.1 — Dreaming 修复
- **#66139**: 修复 dreaming 在 heartbeat 上重复触发。gate on `peekSystemEventEntries()` 检查是否有真正的 pending cron event。处理了 `:heartbeat` isolated session 的 key 映射
- **#66083**: cron scheduler 修复 `computeJobNextRunAtMs` 返回 undefined 导致的 refire loop。保持 maintenance wake 但不发明 synthetic retries
- **#66140**: Dreaming UI 修复——Imported Insights/Memory Palace 在 memory-wiki 插件关闭时不再调用
- 大量安全修复（pgondhi987 系列）：gateway config guard, attachment canonicalization, Slack auth, config snapshot redaction
- **直接影响**：我们的 dreaming 04-15 03:30 sweep 行为将受 #66139 影响（更精确的触发），需升级到 4.14 验证

### Hermes 04-14 merged (7 PRs)
- **#9364 QQBot adapter**: 2835 行，raw Official API v2（非 SDK），WebSocket lifecycle、voice STT pipeline（QQ ASR→Whisper→SILK→WAV）。第 17 个平台
- **#9481 Tool Registry Thread Safety**: `RLock` + coherent snapshots，解决 MCP dynamic discovery 并发问题
- **#9467 File Search UX**: fuzzy `@` completions（rg --files + 5 层评分: exact 100→prefix 80→substring 60→path 40→subsequence 35/25），mtime sorting
- **#9461 Light-mode skins**: skin system 支持 + completion menus skin-aware
- **#9453 i18n Dashboard**: +1711 行，English + Chinese 双语 web dashboard
- **#9429 Reasoning effort clamp**: 'minimal' → 'low'（Responses API 兼容）
- **#9424 Model name auto-correct**: close match 自动纠正在 /model 验证中

### Multica 04-14 merged (8 PRs)
- **#897 OpenClaw multi-line JSON**: 处理 pretty-printed 多行 JSON（之前逐行解析失败）
- **#961 NEW comment emphasis**: `[NEW COMMENT]` tag 防止 session resume 时混淆新旧评论
- **#956 Cancel completed tasks**: 优雅处理取消已完成任务的请求
- **#959 Issue mentions refresh**: 修复页面刷新后 status/title 丢失
- **#950 --parent flag**: CLI 支持设置 parent issue
- 继续快速迭代（v0.1.32 后 8 PRs merged）

### 信号汇总
- GBrain 从 vibes-based search 走向 **metrics-driven search**（eval harness 是分水岭）
- Hermes 继续横向扩展（QQBot = 第 17 平台 + file search UX + i18n dashboard）
- OpenClaw 安全+稳定性冲刺继续（dreaming/cron 修复 + 安全 PRs）
- Multica 在 OpenClaw 集成上持续投入（multi-line JSON fix + NEW comment emphasis）

## Tags
#agent-memory #knowledge-base #openclaw-ecosystem #dream-cycle #self-evolving #thin-harness-fat-skills #security #retrieval-evaluation #intent-classification
