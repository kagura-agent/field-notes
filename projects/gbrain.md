# GBrain

> garrytan/gbrain | 9,403⭐ (2026-04-20) | TypeScript | MIT
> "Garry's Opinionated OpenClaw/Hermes Agent Brain"
> Created: 2026-04-05 | Last push: 2026-04-20

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

## 2026-04-15 Followup: v0.9.3 Security Wave 2

**Stars**: 7,913 (+24 since 11:15)

**v0.9.3 (04-13)**: 5 community security fixes batched + Health Check DSL
- Path traversal in LocalStorage + file-resolver (contained() validation)
- Unbounded file_list query → LIMIT 100
- Symlink following in file walkers → lstatSync + skip
- Command injection in recipe health_checks → `isUnsafeHealthCheck()` blocks shell metacharacters
- **Health Check DSL**: 4 typed check types (`http`, `env_exists`, `command`, `any_of`) 替代 shell strings
- All 7 first-party recipes migrated from shell strings to typed DSL
- 475 unit + 81 E2E tests, 0 fail
- Co-authored with garagon (community security auditor)

**洞察**: GBrain 的安全治理模式值得学习 — 社区安全审计 → batched collector PR → typed DSL 消除根因。不是逐个补 patch，而是重新设计接口消除整类漏洞。与 [[agent-security]] 相关。

## Tags
#agent-memory #knowledge-base #openclaw-ecosystem #dream-cycle #self-evolving #thin-harness-fat-skills #security #retrieval-evaluation #intent-classification

## 2026-04-16 Followup: v0.10.1 Skill Conformance
- **Stars**: 8,381 (+899 since 04-14)
- **v0.10.1**: sync pipeline + extract + features + autopilot fixes
- 8 个 existing skills 迁移到 conformance format: YAML frontmatter (name, version, description, triggers, tools, mutating), Contract, Anti-Patterns, Output Format sections
- Workflow → Phases 重命名; Ingest 变成 thin router 委托给 specialized ingestion skills
- 与 SkillClaw 的 skill 标准化方向趋同（frontmatter metadata + structured sections）

## 2026-04-17 Followup: v0.10.0 GStack Mod 架构深读

- **Stars**: 8,670 (+289 since 04-16, +1,188 since 04-14)，增长持续
- **v0.10.0 核心变化**: GBrain 从独立工具转型为 "GStack mod" — agent 平台的可安装插件

### Skills-as-Packages 架构

**manifest.json** — 25 个 skills 的包描述符：
- 每个 skill: name, path, description
- 包级元数据: conformance_version (1.0.0), dependencies (runtime: bun, package: gbrain)
- setup skill 指定安装入口
- 这是 **npm-for-skills** 的雏形 — skill 不只是文件，而是有版本、依赖、安装流程的包

**RESOLVER.md** — 显式 trigger→skill 路由表：
- Always-on: signal-detector（每条消息异步触发）+ brain-ops（所有 brain 读写）
- 按领域分类: Brain operations / Content ingestion / Thinking / Operational / Setup
- **跨包引用**: "Thinking skills (from GStack)" — GBrain 的 resolver 引用 GStack 的 skills
- 消歧规则: 两个 skill 可能匹配时读两个，they chain（如 ingest→enrich）
- 对比我们: OpenClaw 用 skill description 隐式匹配，GBrain 用显式路由表

### 跨包 Skill 组合

关键架构洞察 — GBrain skills + GStack skills = complete agent：
- Brain skills（query, ingest, enrich 等）独立工作（brain-only mode）
- Thinking skills（office-hours, ceo-review, investigate, retro）来自 GStack
- `detectGStack()` 检测 GStack 是否安装，有则启用 thinking skills
- 这是 **optional dependency** 模式 — 基础功能不依赖外部包，高级功能按需加载

### v0.10.1 修复
- sync pipeline、extract、features、autopilot 的 bugfix
- 说明 v0.10.0 大改后有质量收敛阶段

### 与 [[skill-ecosystem]] 的关系

| 维度 | GBrain | OpenClaw | 差距 |
|------|--------|----------|------|
| 包描述 | manifest.json | 无 | OpenClaw 缺包级元数据 |
| 路由 | RESOLVER.md（显式表） | skill description（隐式匹配） | 显式 vs 隐式 tradeoff |
| 跨包组合 | GStack bridge | 无 | 尚未有跨包需求 |
| 版本 | conformance_version | 无 | 格式兼容性管理 |
| 安装 | gbrain init + setup skill | 手动放目录 | 自动化程度差距 |

**反直觉发现**: 显式 RESOLVER.md（~100 行路由表）比 20,000 行 mega-prompt **更省 context**。不需要把所有 skill description 注入 context — resolver 本身就是压缩后的路由信息。这与 [[thin-harness-fat-skills]] 的 "CLAUDE.md 从 20,000 行削到 200 行指针" 一脉相承。

### 生态信号

- GBrain 从 v0.8.1（search quality）→ v0.9.x（security）→ v0.10.x（platform/mod）的演进路径清晰：先让产品好用 → 再安全 → 再平台化
- "Skills-as-packages" 趋势：GBrain manifest.json + SkillClaw frontmatter + OpenClaw skill catalog = 三个项目独立趋同于同一方向
- 跨包 skill 组合（GBrain + GStack）是新信号 — agent 能力将从单体走向可组合模块

## 2026-04-18 Followup: Knowledge Graph + Minions + Skillify

- **Stars**: 9,046 (+376 since 04-17, +1,564 since 04-14)
- **v0.12.0** (PR #188, 13.4k additions, 304 files): 自连线知识图谱层
- **Minions v7 + Skillify** (PR #130, 13k additions, 79 files): 持久化作业队列 + 自动技能创建

### Knowledge Graph Layer (v0.10.3→v0.12.0)

`put_page` 自动提取 entity 引用并创建 typed links — brain 从 "flat pages" 演进为 **self-wiring graph**。

**核心机制：**
- Auto-link: 每次写入时事务内提取 entity 引用，通过 `getLinks` diff 清理过期链接
- `graph-query <slug>`: typed-edge 遍历（递归 CTE + visited-array 防环），支持 `--type`/`--depth`/`--direction`
- `extract <links|timeline|all> --source db`: 批量回填已有数据
- Hybrid search 对 well-connected entities 排名更高

**量化结果 (BrainBench v1, 240-page Opus corpus)：**
- Recall@5: 83.1% → **94.6%** (+11.5 pts, +30 correct answers in top-5)
- Precision@5: 39.2% → **44.7%** (+5.4 pts)
- Graph-only F1: 57.8% (grep) → **86.6%** (+28.8 pts)
- works_at precision: 21% → **94%**, invested_in: 32% → **90%**, advises: 10% → **78%**
- Eval 可复现: `bun run eval/runner/all.ts`, ~3 min, PGLite in-memory, zero API keys
- 1,151 unit + 105 E2E tests, 0 fail

**安全设计：**
- `traverse_graph` MCP depth 硬限 10（DoS 防护）
- 远程 MCP 调用者禁用 auto-link（link injection 攻击面）
- reconciliation 在事务内（防 lost-update race）

**与我们的关联：**
- 我们的 wiki [[双链]] 是手动标注 → GBrain 自动提取。方向一致，自动化程度差距大
- [[memex]] backlinks 是类似概念的简化版，但缺少 typed relationships 和 graph query
- Auto-link 在写入时做（not batch post-processing）= 知识图谱始终最新

### Minions v7: Durable Agent Job Queue

用 Postgres-native job queue 替代 `sessions_spawn` subagents。直击 OpenClaw 6 大痛点：

| 痛点 | 解决方案 |
|------|----------|
| Spawn storms | `max_children` cap + `SELECT FOR UPDATE` |
| Agent 无响应 | `timeout_ms` + DB dead-letter + AbortSignal |
| 编排器丢失任务 | `child_done` 事务内通知 + `readChildCompletions()` |
| 调试困难 | `parent_job_id` + `depth` + 完整 attempt history |
| Gateway 崩溃 | 作业持久化在 Postgres，stall detection 重新认领 |
| 失控子任务 | `cancelJob()` 递归 CTE 原子取消整个子树 |

**关键设计：**
- `FOR UPDATE SKIP LOCKED` 认领（无锁竞争）
- Idempotency keys（PG unique partial index，cron 双触发安全）
- Cooperative AbortSignal（cancel 传播到运行中的 handler）
- 事务正确性：`completeJob()`/`failJob()` 包裹在 `engine.transaction()` 中

**与我们的关联：**
- 我们的 subagent 也有 Copilot API 60s 超时问题 — Minions 的 DB-enforced timeout + dead-letter 是更健壮的方案
- `parent_job_id` + `depth` 的树状追踪比我们的 subagent list 更完整
- 但实现成本高（需要 Postgres），我们的场景可能不需要这么重的方案

### Skillify: 用户可控的自动技能创建

`skillify` meta-skill + `check-resolvable` 配对 — 用户说 "skillify this" / "is this a skill?" → 走 10-item checklist 生成规范 skill。`scripts/skillify-check.ts --json --recent` 可用于 CI 审计。

关键设计: **user-controlled beats auto-generated** — 不是自动把每个 pattern 变 skill，而是用户决定何时何物。与我们的 [[skill-creator]] 方向一致但理念更克制。

同 PR 还弃用了 `handlers.json`（shell RCE 面）→ code-level plugin contract（`MinionWorker.register(name, fn)`），安全边界更清晰。

### 演进信号

- v0.8（search）→ v0.9（security）→ v0.10（platform/mod）→ v0.12（graph + orchestration）：从工具到平台到**基础设施**
- 9k+ stars in 13 days，增速健康
- Knowledge graph + durable jobs = GBrain 不再只是 "knowledge base"，开始触及 **agent runtime** 层
- 与 [[evolver]] 和 [[genericagent]] 的自进化方向形成互补：GBrain 做知识基建，它们做行为进化

## Security Wave 3 深读 (2026-04-17)

> PR #174 | 9 vulns fixed | ★8762 (+873 since 04-15)

### 漏洞类别

| ID | 严重度 | 问题 | 修复 |
|----|--------|------|------|
| #139 | High | `file_upload` MCP 读 `/etc/passwd` — 无路径校验 | `validateUploadPath()` confinement |
| B1 | High | `loadAllRecipes` 把 cwd recipes 标为 `embedded=true` — 假信任边界 | 区分 embedded vs cwd trust |
| B2 | High | `health_check` 用 `execSync` 绕过 typed-DSL gate | wave-2 的 typed DSL 被绕过 |
| B3 | Medium | `fetch` 跟随重定向不重新校验 | redirect re-validation |
| M1 | Medium | 用户查询注入 LLM expansion prompt | `sanitizeQueryForPrompt()` |

### 关键安全模式

1. **Path confinement (strict/loose)** — `validateUploadPath(path, root, strict)`:  
   - strict (MCP/remote): `realpathSync` + `path.relative` 确认在 root 内 + 拒绝 symlink
   - loose (local CLI): 只验证文件存在
   - 总是拒绝 final-component symlink（防 transparent redirection）
   - **关键**: 用 `realpathSync` 解析后再 `relative()`，不是直接比较字符串

2. **Multi-layer query sanitization** (defense-in-depth):  
   - Layer 1: `sanitizeQueryForPrompt()` — 截断 500 chars, 去 code fences/XML tags/injection prefixes
   - Layer 2: structural prompt boundary — `<user_query>` tags + "untrusted data" system instruction
   - Layer 3: `sanitizeExpansionOutput()` — 验证 LLM 输出，去控制字符、去重、截断
   - **privacy-safe logging**: 只 warn "stripped content"，不 log 原始查询

3. **Recipe trust boundary** — 区分 embedded (内置, trusted) vs cwd (用户目录, untrusted) recipes

4. **Search limit clamping** — `clampSearchLimit()` 防资源耗尽

### 与 [[agent-security]] 的关系

- 这些是**真实生产环境的漏洞**，不是理论分析。GBrain 被社区安全审计（@garagon, @Hybirdss）后由 Codex outside-voice review 补漏
- Path traversal + symlink escape = MCP 工具的经典攻击面，OpenClaw 的 `mediaLocalRoots` 白名单是类似方案
- Query sanitization 三层模式值得借鉴 — 我们的 memory_search 目前无输入清洗
- **教训**: wave-2 的 typed DSL gate 被 `execSync` 直接绕过（B2）— 安全层必须覆盖所有代码路径，不只是"正常"路径

### 演进信号

- v0.8→0.9→0.10: 产品→安全→平台。安全是中间阶段，不是事后补丁
- 社区 PR + AI review 的组合发现更多漏洞 — 纯人工或纯 AI 都有盲区
- GBrain 3 天内 ★+1280（7482→8762），增速未减，可能进入 10k 里程碑冲刺

---

## 更新 (04-19): v0.10→v0.12 — Knowledge Graph Layer

> ⭐ 9,171 (04-19) | v0.12.1 | 5 个版本 in 4 天

### 重大变化：自组装知识图谱

v0.10.3 (#188) 是 GBrain 目前最大的单次 PR：304 files, +13,436 lines。核心：把空的 graph schema 变成自组装、可查询的知识图谱。

**机制：**
1. **Auto-link in `put_page`** — 每次写入页面后自动提取 entity references（`[Name](people/slug)` 等），创建 typed links（works_at, attended, invested_in, founded, advises, mentions, source）
2. **Link reconciliation** — diffing 已有 links vs 新提取结果，自动 create/remove。幂等
3. **`gbrain graph-query`** — typed-edge traversal，递归 CTE + visited-array cycle prevention，支持 `--type`/`--depth`/`--direction`
4. **Hybrid search boost** — well-connected entities 排名更高
5. **Batch backfill** — `gbrain extract links|timeline --source db` 对已有 brain 全量补建图谱

**架构洞察：**
- `link-extraction.ts` 是**纯函数**（no DB access），engine 调用它拿 candidates 再 persist。干净的关注点分离
- Auto-link 从 code fences 和 inline code 中排除 slug（`stripCodeBlocks`）— 防止代码示例污染图谱
- Schema migrations v5/v6/v7 自动应用：UNIQUE 约束扩展支持多类型关系、timeline 幂等 insert、trigger 修复

**安全设计（值得学习）：**
- Auto-link **对 remote MCP callers 禁用**（`ctx.remote=true` → skip）。原因：untrusted page 可以在 body 里植入 `see meetings/board-q1` 来注入 outbound links，结合 backlink boost 会让攻击者控制搜索排名
- `traverse_graph` depth hard-cap 10（DoS prevention）
- Reconciliation 在 transaction 内执行（防 lost-update race）

**Benchmark 结果：**
- A/B 对比：no-graph vs full-graph
- Relational recall 相同（100% both，markdown 已有 refs）
- **Relational precision: 58.8% → 100% (+70%)**
- 原因：无图谱时 "who works at X?" 返回 5 candidates（2 right + 3 noise），有图谱后只返回 exact 2
- 对 LLM 阅读量：~3x less per relational query

**其他版本变化（04-15→04-19）：**
- v0.10.0: GStackBrain — 16 new skills, resolver, conventions, identity layer
- v0.10.1: sync pipeline + autopilot fixes
- Security wave 3 (#174): 9 vulns fixed (file_upload, SSRF, recipe trust, prompt injection)
- v0.11.x: Minions v7 + canonical migration + skillify
- v0.12.1: JSONB double-encode fix + splitBody wiki + N+1 hang fix

### 跟我们的关联

- **知识图谱 vs 我们的 memex 双链**：GBrain 的 auto-link 是自动提取 typed relationships，我们的 [[双链]] 是手工语义链接。GBrain 更结构化但也更 rigid（固定的 entity directories），我们更灵活但缺 graph query 能力
- **Security-by-default 的 auto-link 设计**很成熟 — remote callers 禁用自动链接是个好范例。我们的 memex 如果加 auto-link 也应考虑 trust boundary
- **Benchmark-driven development**: 每个 feature 附带 A/B benchmark 量化 delta，这比 "feels better" 有说服力得多。参考 [[eval-driven-self-improvement]]
- GBrain 从 v0.8 到 v0.12 用了 5 天，单人项目（Garry + AI）的迭代速度惊人。证明 opinionated single-user system 迭代速度远超通用框架

### Multica 快速更新 (04-16→04-18)

> 16,205⭐ (04-19) | v0.2.4→v0.2.6 | 3 releases in 3 天

- v0.2.5 重点：**autopilot CLI commands** + persistent daemon UUID identity + desktop Canary brand
- v0.2.6 重点：per-agent MCP config 恢复 + open redirect 修复 + fresh session_id clear
- 趋势：multica 在快速产品化（desktop app, docs site, CLI project commands），跟 OpenClaw 的竞争面持续扩大

### 04-19 跟进：v0.12.1 稳定化 + 星标 9,237

- **Stars**: 9,237 (+191 since 04-18)，增长持续但放缓（从日均 +400 降到 +200）
- **v0.12.1** (04-18~19): 3 个 bugfix PR — JSONB double-encode + splitBody wiki + parseEmbedding (#196), N+1 hang + migration timeout (#198), KG layer 已 landed
- **Evolver v1.68.0-beta.1**: 内部重构（daemon loop 简化），source-available 过渡公告已发布，无大 feature 变化
- **multica 16,377★**: v0.2.6 稳定化修复（infinite re-render, selfhost docs）
- **GenericAgent 4,335★** (+1,135 since first check): 活跃开发中 — memory_cleanup_sop 重大改进（存在性编码 4 原则），start_long_term_update 只在任务完成时调用

### GenericAgent 存在性编码 memory SOP 更新 (04-18)

跟我们的 [[context-budget]] 优化直接相关的洞察：

**核心理念**: L1（顶层记忆）只编码"什么场景下有什么知识可用"——存在性指针，不是知识本身。

**压缩四原则**:
1. 命名自解释 > 加描述（改名的 ROI 常高于改 L1）
2. 存在性集合最小描述（多个相近条目用集合名覆盖）
3. 条目 = 场景↔方案存在性（括号内只放反直觉触发词）
4. 分层归位（高 ROI 规则上方，纯指针归 L2/L3）

**ROI 公式**: (不放这几个词的犯错概率 × 代价) / 每轮词数成本

**跟我们的关联**: 
- 我们的 AGENTS.md 压缩（232→198 行）用了类似思路但没有这么系统化
- "L1 只能 patch 词级别修改，禁 overwrite" — 记忆修改是持久性伤害，错误每轮复利。与我们的 DNA 更新谨慎原则一致
- 可以考虑用这个框架重审我们的 MEMORY.md 和 AGENTS.md 结构

---

## 更新 (04-20): v0.13.0 — Knowledge Runtime

> ⭐ 9,403 (04-20) | v0.13.0 | 从 knowledge graph 进化到 knowledge runtime

### 核心变化：知识库→运行时

v0.13 是 GBrain 从"存储层"到"运行时层"的跃迁。不再只是存和查，而是让知识库成为其他 agent 可以 adopt 的 typed runtime。五个模块：

**1. Resolver SDK** (`src/core/resolvers/interface.ts`)
- 通用 `Resolver<I,O>` 接口 — typed input/output + confidence score + cost tracking
- 每个结果必须带 confidence (0-1) 和 source attribution
- LLM-backed resolver 约定 confidence < 1.0；deterministic backend 返回 1.0
- 内置 2 个 reference resolver: `url_reachable`（带 SSRF 防护）、`x_handle_to_tweet`（X API v2）
- ResolverContext 继承 trust boundary（`remote=true` → 收紧行为）
- **架构洞察**: Resolver 是纯异步、无副作用的查询层。预留了 plugin contract 扩展点

**2. BrainWriter** (`src/core/output/writer.ts`)
- `BrainWriter.transaction(fn, ctx)` — 事务性写入 + pre-commit 验证器链
- 4 个 deterministic validators: citation / link / back-link / triple-hr
- `Scaffolder` 从 API ID 构建 citations（never from LLM text）
- `SlugRegistry` 检测 slug 冲突
- **关键设计**: v0.13 migration 对已有页面 grandfather `validate: false`，新页面强制验证
- Post-write lint hook（默认关闭，可 gate 切换）— observability for strict-mode rollout

**3. `gbrain integrity`** — 自修复命令
- 三桶置信度分流：≥0.8 自动修复 → 0.5-0.8 人工 review queue → <0.5 skip+log
- 进度文件可恢复（kill 后重跑不重复处理）
- `--dry-run` 不污染 progress state（adversarial review 发现的 P0，已修）
- 主要目标：bare tweet references（1,424/3,115 people pages 有 "tweeted about X" 但没链接）和 dead URLs

**4. BudgetLedger** (`src/core/enrichment/budget.ts`)
- 每日 spend cap，per {scope, resolver_id, local_date} 粒度
- Reserve → commit/rollback 三阶段，FOR UPDATE 防并发 double-spend
- TTL 自动回收（进程崩溃后 reservation 过期自动释放）
- IANA timezone midnight rollover（Intl.DateTimeFormat 取本地日期，无 rollover thread）
- **P0 fix**: commit() 重新检查 cap headroom，防 reserve(0.01)+commit(100) 绕过 cap
- **反直觉**: 负数 actual 被拒绝 — refund 必须走专门 API，不能用 commit(-x) 做侧通道

**5. CompletenessScorer** — 替代 Wintermute 的 length heuristic
- 7 个 entity-type-specific rubrics + default
- 维度举例：timeline entries, citations, source URLs, frontmatter fields, backlink hint, recency
- 每维度 0-1 + 权重加和 → 页面质量分数
- `non_redundancy` + `recency_score` 杀死了"越长越好"的 pathology

**6. Scheduler polish**
- Claim-time quiet-hours gate（IANA tz, wrap-around windows）
- 确定性 FNV hash stagger offset — 避免所有 cron job 同时开跑
- **P0 fix**: quiet_hours 原本是 dead code（schema 有列但 MinionJobInput 不接受），adversarial review 发现

### Frontmatter → Typed Graph Edges (#231)

YAML frontmatter 字段自动投射为 typed graph edges：
- 10 个 canonical 字段映射（company, investors, attendees, key_people, partner, lead, founded, sources, source, related, see_also）
- 方向尊重 subject-of-verb 语义（person → meeting, 不反过来）
- 4 步 fallback resolver chain（batch mode 不调 searchKeyword，保持确定性迁移）
- Reconciliation 在 transaction 内执行，双向 backlink 感知
- **效果**: hub entity 的 `gbrain graph --depth 2` 从 ~7 nodes 变成 50+ nodes，零 skill 编辑

### 工程质量观察

- **Adversarial review 发现 4 个 P0 bug** — 包括 dead code (quiet-hours)、state 污染 (dry-run)、cap 绕过 (commit)、parent job stranding (cancel)。全在 merge 前修复
- **AI-assessed coverage 72%** — 1626 tests (+104 new)
- **隐私 scrub**: PR body 和 CLAUDE.md 都加了 privacy rule — public docs 必须用 generic placeholders。跟我们的脱敏规范一致

### 跟我们的关联

**直接可借鉴的：**
1. **BudgetLedger 模式** — 如果我们的 dreaming/memory_search 需要付费 API（如 reranker），这个 reserve-commit-rollback 模式比简单计数器更安全。参考 [[eval-driven-self-improvement]]
2. **Integrity 三桶置信度分流** — 我们的 beliefs-candidates.md 升级也有类似需求：高置信度自动升级 DNA、中等人工 review、低置信度 skip。目前我们用"重复 3 次"作为阈值，可以更细化
3. **CompletenessScorer rubrics** — 替代 length heuristic 评估 wiki 页面质量。我们的 wiki health check 可以借鉴
4. **Frontmatter as graph edges** — 我们的 memex 双链是手动的，GBrain 证明从 frontmatter 自动提取 typed edges 效果巨大（7→50+ nodes）
5. **Adversarial review as P0 catcher** — 每次 PR 用一个独立 subagent 做对抗性 review，GBrain 4/4 P0 都是这样发现的

**差异与定位：**
- GBrain = 个人知识管理运行时（facts, people, events → graph → query → repair）
- 我们 = 行为进化系统（beliefs, patterns → DNA/workflow → self-modify）
- GBrain 的 Knowledge Runtime 让知识可查可修可验证；我们需要的是 Behavior Runtime 让行为可观测可调整可回滚
- GBrain 演进路径：存储 → 图谱 → 运行时。3 周内 v0.8→v0.13，单人+AI 产出惊人

## 2026-04-20 Followup: v0.13.0 Shell Jobs + Reliability Wave

> ⭐ 9,403 (+357 since 04-18) | v0.13.0 | 4 PRs in 2 days

### Shell Job Type (#217)

GBrain 的 OpenClaw gateway 被 32 个 cron job 压满 CPU（每个 cron 都启动 Opus session），其中 ~14 个是纯 API-fetch-and-write 脚本不需要 LLM。Shell job type 让这些确定性 cron 直接在 [[Minions]] worker 上用 `/bin/sh -c` 执行，**~60% gateway 负载降低，零 LLM token 消耗**。

**安全设计（值得学习）：**
- `PROTECTED_JOB_NAMES = {'shell'}` — 不可被用户 override
- MCP 提交被拒绝（`submit_job` rejects shell over MCP）— 只允许 local CLI 提交 shell job
- Env allowlist: 只传 PATH/HOME/USER/LANG/TZ/NODE_ENV，不泄露其他环境变量
- Whitespace bypass 防护：trimmed name check（`" shell "` ≠ `"shell"`）
- SIGTERM → 5s grace → SIGKILL abort 语义
- JSONL audit trail: `~/.gbrain/audit/shell-jobs-YYYY-Www.jsonl`
- UTF-8 安全的 64KB/16KB output tail（StringDecoder）

**Worker abort-path 修复：** 之前 timeout/cancel/lock-loss/shutdown 时 worker 静默返回（任务"消失"）。修复后所有异常路径都 `failJob()` 并记录 `aborted: <reason>`。

**跟我们的关联：** 我们的 cron 也有类似问题 — 每个 cron fire 都启动完整 agent session（含 LLM reasoning），但有些 cron 只是跑 API 调用。如果 OpenClaw 支持 shell job type，能显著降低 gateway 负载。

### Reliability Wave (#216)

社区贡献的稳定性修复：
1. **Sync deadlock** — PGLite 非可重入 mutex，outer transaction + per-file transaction 死锁。移除 outer wrap
2. **`statement_timeout` pool 泄露** — `SET statement_timeout='8s'` 在 postgres.js pool 连接间泄露。改用 `SET LOCAL` 限制事务内
3. **Obsidian `[[WikiLinks]]` 支持** — `extractEntityRefs` 现在匹配 `[[people/slug|Name]]` 格式。2,100 页 brain 从 0 auto-links 变成 1,377 typed edges
4. **`gbrain orphans`** — 发现无 inbound links 的孤立页面，闭环 v0.12 知识图谱故事

**洞察：** WikiLinks 支持是个好例子 — 用户已有的标注格式（Obsidian style）被自动识别，零迁移成本。我们的 memex 如果能识别更多标注格式（不只是 `[[]]`），backlink 覆盖率会大增。

### 演进总结

| 版本 | 主题 | 日期 |
|------|------|------|
| v0.8 | Search quality | 04-14 |
| v0.9 | Security | 04-13~15 |
| v0.10 | Platform/mod | 04-16~17 |
| v0.11 | Minions + skillify | 04-17~18 |
| v0.12 | Knowledge graph | 04-18~19 |
| v0.13 | Knowledge runtime + shell jobs | 04-19~20 |

2.5 周内 6 个 major 版本。速度惊人但节奏可持续性存疑 — 每个版本都有 reliability follow-up 说明快速迭代带来的稳定性债务。

### Frontmatter Relationship Indexing 补充 (PR #231, 04-20)

之前的 v0.13 笔记记录了 Knowledge Runtime 的 5 大模块，这里补充 frontmatter→graph edges 的实现细节：

- `FRONTMATTER_LINK_MAP`: 10 个 canonical 字段，每个定义方向（outgoing/incoming）+ 多 dir hint（investors 可能是 companies/funds/people）
- `makeResolver(engine, {mode})`: batch mode **永不调 searchKeyword**（保持确定性迁移）。4 步 fallback chain
- `extractFrontmatterLinks` 处理 array-of-objects（`investors: [{name: 'Fund A', role: 'lead'}]`），静默跳过 bad types
- Reconciliation 用 `getBacklinks` scoped by `origin_page_id`，不碰其他页面的 frontmatter edges
- `put_page` response 扩展 `unresolved: Array<{field, name}>`（additive，不影响现有 agent）
- Schema v11 要求 PG15+（NULLS NOT DISTINCT），<PG15 明确报错而非半应用
- Legacy NULL `link_source` backfill → `'markdown'`（防止 NULLS NOT DISTINCT 下的重复 edge）

**工程纪律亮点：**
- PR body 包含完整 adversarial review 过程和 P0 修复记录
- Privacy scrub: CLAUDE.md 加了 privacy rule，所有 public docs 用 generic placeholders
- Test: 22 new tests 覆盖 field mapping、方向语义、resolver fallback、bad type 静默跳过
- Migration orchestrator 3 阶段（schema→backfill→verify），用 `process.execPath` 避免 PATH 问题

**⭐ 9,562** (04-20 20:35)，vs 9,403 earlier today (+159)。增长持续。
