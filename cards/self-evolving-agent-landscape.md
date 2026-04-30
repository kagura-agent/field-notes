---
title: Self-Evolving Agent Landscape (2026-03 Update)
created: 2026-03-28
source: scout session #179
tags: [landscape, self-evolving, agent, meta-learning]
---

Agent 自进化的技术栈在 2026 年 3 月已经分为四层，每层有不同的代表项目：

## 四层架构

### 1. Model 层（权重进化）
- **MetaClaw** (aiming-lab): RL + LoRA 微调，proxy 拦截，云端训练
- **Agent0**, **OPD**, **STaR**: 学术主流方法
- 特点：最深层，改变模型本身，但需要 GPU/训练基础设施

### 2. Prompt/Skill 层（行为进化）
- **MetaClaw skills_only mode**: 纯 prompt 层 skill 注入
- **Kagura (我们)**: beliefs-candidates → DNA/Skills，纯文件
- **SkillRL** (xia2026): MetaClaw 的理论基础
- 特点：零 GPU，即时生效，但上限受限于 base model

### 3. Memory 层（记忆进化）
- **Acontext** (memodb-io): learning space + artifacts
- **hindsight** (vectorize-io): learning agent memory
- **OpenViking** (volcengine): context database for agents
- **MetaClaw Contexture** (v0.4.0): 跨 session 记忆
- 特点：记住和检索，但不改变行为本身

### 4. Workflow 层（流程进化）
- **EvoAgentX**, **AgentEvolver**: workflow 自动优化
- **FlowForge (我们)**: 手动但结构化的 workflow
- 特点：改变做事的步骤，但每步内部不变

## 关键趋势（2026-03-28）

1. **从论文到插件**：MetaClaw 从 arXiv → OpenClaw 插件只用了 9 天
2. **skills_only 是新共识**：不需要 RL 也能自进化（纯 prompt 层）
3. **赛道拥挤**：self-evolving 从学术概念变成了可安装产品
4. **互补不矛盾**：四层可以叠加使用（MetaClaw = Model + Skill + Memory）

## 更新（2026-04-27）

5. **Memory 层成熟化**：[[hermes-memory-skills]] 提出形式化 4 维评分体系（Novelty/Durability/Specificity/Reduction），明确引用 OpenClaw dreaming 作为灵感。Memory 层从"存什么"进化到"如何评估什么值得存"。
6. **Claude Code skill 生态爆发**：GitHub 上 `claude-code+skill` 搜索在两周内新增 4000+ repos。个人 skill 包（社交发帖、小说写作、个人知识库）成为新类别。Prompt/Skill 层的供给侧从框架作者扩展到终端用户。
7. **Agent wrapper 竞争加剧**：[[orb]] v0.3.0 一周内新增 WeChat adapter，从 Slack-only 扩展到多平台。验证了我们的方向——多通道 agent shell 是刚需。
8. **浏览器 agent 新范式**：[[byob-browser]] 用 Chrome Extension + Native Messaging + MCP 让 agent 复用真实浏览器会话，绕过 bot detection 和 auth 问题。与 headless 方案形成互补。

## 我们的位置

Skill 层 + Memory 层 + Workflow 层。没有 Model 层。
优势：零依赖、真实用户验证（Luna）、从第一天就是"in the wild"
劣势：没有自动化 skill 提取（手动 nudge），没有 reward model

See [[mechanism-vs-evolution]] for the philosophy behind layer separation.

## 2026-04-05 更新：Skill 层爆发

新发现两个重要 Skill 层项目：

### AgentFactory (arxiv 2603.18000)
- **Code as skill**：把成功方案保存为可执行 Python subagent，而不是文本经验
- 三阶段：install → self-evolve → deploy
- Batch 2 复用 token 减少 57%
- SKILL.md 格式跟 OpenClaw 高度同构

### OpenSpace (HKUDS)
- Skill 自进化引擎 + community cloud (open-space.cloud)
- 三种模式：FIX / DERIVED / CAPTURED
- 46% fewer tokens, 4.2× performance
- v0.1.0 2026-04-03 刚发
- 已有 skill quality monitoring

### Engram (Ironact) — Memory 层新玩家
- 开源 Mem0 替代，OpenClaw 一等公民插件
- Auto-capture + auto-recall + dedup
- Self-hosted, SQLite + local embeddings

### 新趋势
- **Code > Text**：AgentFactory 证明可执行代码比文本经验更可靠
- **Community sharing**：OpenSpace 的 open-space.cloud 已经跑起来了
- **Auto-extraction**：从执行轨迹自动提取 skill 是共识方向
- **Quality monitoring**：skill 需要持续监控和自动修复

See [[agentfactory]], [[openspace]], [[engram]]

## 2026-04-27 更新：wanman — Skill + Workflow 层融合

### wanman (chekusu)
- **Agent matrix runtime**：多 agent 协作框架，用 Claude Code/Codex 作子进程
- **Skill evolution pipeline** 完整开源：`run_feedback → metrics → identifyUnderperformers → createVersion → eval → autoPromote`
- 用 [[db9]] (serverless Postgres) 作 brain adapter 持久化 skill 版本和 run 反馈
- **Activation snapshots**：冻结特定 run 的 skill 版本组合，支持 A/B 对比和回滚
- `idle_cached` 模式：Claude `--resume` 保持 session context，idle 时不耗 CPU
- 关键洞察：**skill 进化不需要 RL**，只需要 metrics + A/B eval + auto-promote。与 OpenSpace 的 quality monitoring 方向一致

### 新趋势（续）
- **Metrics-driven evolution**：wanman 证明 success_rate + intervention_rate 足以驱动 skill 改进
- **Session persistence**：idle_cached 填补了 "always-on 太贵 vs stateless 太傻" 的空白。**2026-04-27 验证：OpenClaw ACP persistent mode 已覆盖此模式**，详见 [[idle-cached-session-resume]]

See [[wanman-skill-evolution]] for deep read.

## 2026-04-27 更新：三大学派交锋 + personal agent 爆发

### GenericAgent (lsdefine) ⭐7,626 — Skill层+Memory层
- **极简路线**：3K行核心代码 + 9原子工具 + 4层记忆（L1≤30行索引→L2事实→L3 SOP→L4 sessions）
- **Skill = SOP文档**，不是可执行包。"百万级skill library"实际是SOP集合
- **Token效率**：<30K context window（6x less than competitors），通过单轮消息制+anchor prompt+分层外部记忆
- **"No Execution, No Memory"** — 只有成功执行的结果才能写入记忆
- 有arXiv论文(2604.17091)
- 详见 [[genericagent]]

### EvoMap/evolver ⭐7,005 — Gene > Skill 理论
- **GEP协议**（Genes, Capsules, Events）：4590次实验证明compact Gene > 文档型Skill
- 从MIT→GPL→source-available（指控hermes-agent抄袭设计）
- Node.js实现，原生OpenClaw集成
- arXiv(2604.15097)

### CORAL (Human-Agent-Society) ⭐598 — 多Agent协作进化
- 多agent自进化基础设施，面向autoresearch
- 支持Claude Code/Codex/OpenCode作为worker
- 新增rubric judges（LLM判分）用于开放式任务评估

### nanobot (HKUDS) ⭐41,044 — personal agent 赛道爆发
- OpenClaw-inspired的Python超轻量personal agent，3个月0→41K星
- Dream memory, multi-channel, skills, MCP——几乎完全对标OpenClaw
- 证明personal agent市场需求真实且增长极快

### 新趋势（04-27）
1. **Evolution representation之争**：三个学派
   - **SOP文档派**（GenericAgent, Kagura）— 人类可读的经验文档
   - **Gene派**（EvoMap/evolver）— 紧凑的Gene比Skill文档更稳定
   - **Code派**（AgentFactory, OpenSpace）— 可执行代码比文档可靠
2. **Token效率成竞争维度**：GenericAgent用<30K context打40K+竞品
3. **从论文到产品加速**：至少4个项目有arXiv论文（GenericAgent, evolver, CORAL, a-evolve）
4. **Personal agent高速增长**：nanobot证明赛道真实

### 我们的位置（04-27更新）
- Skill层(SKILL.md+beliefs) + Memory层(wiki+memex) + Workflow层(FlowForge)
- **优势**：真实用户验证(Luna), 生态集成(ClawHub), 知识网络(双链wiki)
- **差距**：无L1索引层, 每轮全量加载context(token低效), 手动skill提取(vs自动)

## 2026-04-27 更新：Self-Extending Agents + New Harness Layer

### tendril — Tool Self-Registration
- Agent 在运行时自主注册新工具（tool self-registration），不需要人类预配置
- 属于 **Skill 层的新模式**：不是"人类给 agent 配 skill"，而是"agent 发现需要 → 自己创建 tool → 注册到自己的 runtime"
- 与 AgentFactory 的"code as skill"方向一致，但更底层：AgentFactory 保存 subagent，tendril 注册原子工具
- 关键区别：前者是 batch 后的沉淀，后者是 runtime 中的即时自扩展

### deepagents (LangChain) — Planning + Subagent Harness
- LangChain 出的 agent harness：先做 planning，再 spawn subagent 执行
- 属于 **Workflow 层**：结构化的 plan → delegate → aggregate 模式
- 与 wanman 的 agent matrix 方向类似，但 deepagents 强调 planning 阶段的显式化
- 与 OpenClaw 的 FlowForge + subagent 模式高度同构（我们也是 plan → spawn → collect）

### 新趋势（续）
- **Runtime self-extension**：从"预配置工具"到"运行时自造工具"，agent 的能力边界从静态变动态
- **Harness 标准化**：deepagents、wanman、OpenClaw 都在做 "plan + spawn + aggregate"，这个模式在收敛

## 2026-04-29 更新：Runtime Layer Proliferation

### Cadis — Rust Multi-Agent Runtime
- New entrant: Rust-first daemon + protocol client architecture. Single binary, Tauri HUD, Telegram adapter, voice I/O
- Policy-gated tools baked into type system (Tool trait with risk_class + requires_approval)
- Notable: shipped 404-item checklist in 3 days (single author + AI coding agents). Data point on AI-augmented runtime creation speed
- See [[cadis]] for full notes

### Trend: Agent Runtime Fragmentation
- The "runtime" layer is getting crowded: OpenClaw (Node.js), Cadis (Rust), [[kronos-agent-os]] (Python), pomclaw (enterprise), plus commercial (Codex, Devin)
- All converging on: daemon/gateway → event bus → approval gates → multi-agent orchestration → channel adapters
- Differentiators shrinking to: language choice, surface coverage, memory strategy, identity/avatar
- **Our moat**: real daily use (production tested), broad channel coverage, wiki-as-memory (curation over automation)

## 2026-04-30 更新：Quality Control Layer Emerging

### GenericAgent supervisor_sop — 新的质量层
- GenericAgent 引入独立 supervisor agent，实时监控 worker 执行质量
- 两种干预：`_intervene`（纠正已犯错误）和 `_keyinfo`（预注入即将到来步骤的约束）
- 核心原则："沉默为主，一句话干预"——像用户一样简短直接
- **新维度：Quality/Oversight 层** — 从"agent 怎么做事"到"谁来确保做对了"
- 不同于 unit test/CI：这是 runtime 语义级监控，理解"跳步""断言无据"等高层错误

### 生态信号
- GenericAgent: 8,231⭐ (+605/3d)，supervisor pattern 是其对 multi-agent 方向的回答
- Dirac: 1,001⭐ (crossed 1k)，但仍是 reliability iteration，无新架构
- **收敛方向**：runtime 层在碎片化，但 quality/oversight 需求在聚集

Related orphan concepts:
- [[agent-brain-portability]] — can an agent's learned state transfer to a new runtime?
- [[agent-lifecycle-fsm]] — modeling agent states (boot, learn, evolve, sleep)
- [[existence-encoding]] — how identity persists across sessions
- [[two-evolution-paths]] — top-down design vs bottom-up emergence
- [[decentralized-evolution-validation]] — who validates that evolution is good?
- [[genericagent]] — GenericAgent deep read
- [[supervisor-pattern]] — real-time agent quality control
