# SkillClaw

> AMAP-ML/SkillClaw | 515⭐ (2026-04-14) | Python | 2026-04-10
> "Let Skills Evolve Collectively with Agentic Evolver"
> Paper: arxiv.org/abs/2604.08377 (2026-04-09)
> Built on: MetaClaw, WildClawBench, OpenClaw-RL

## 核心思想

多用户/多 agent 环境下的 **skill 集体进化**。从真实 session 数据中自动蒸馏可复用 skill，通过云端共享让整个 agent 集群持续进化。

关键洞察：不同用户在使用同一 skill 时会产生互补信号（什么时候成功、什么时候失败），但现有系统缺乏机制把这些异构经验转化为可靠的 skill 更新。

## 架构（3 组件）

1. **Client Proxy** (`api_server.py`) — FastAPI 本地代理，拦截 `/v1/chat/completions` 和 `/v1/messages` 请求：
   - 拦截 → 注入 skills 到 system prompt → 转发到真实 LLM API
   - 记录完整 session artifacts（tool calls, 结果, errors）
   - 可选 PRM scorer（Process Reward Model）给每个 turn 评分
   - 支持 session_done 信号结束 session 采集
   - 对用户完全透明，不改变 agent 行为

2. **Workflow Evolve Server** (`evolve_server/`) — 确定性 3 阶段 LLM 工作流：
   - **Summarize** → 对每个 session 构建无损结构化 trajectory + LLM 分析摘要
   - **Aggregate** → 按 skill 分组 sessions（一个 session 可属于多个 skill 组）
   - **Execute** → 对每组 skill 决策：improve / optimize_description / create / skip
   - 用 LLM 做 merge（同名 skill 冲突解决）、evolve（从 session 证据改进）、create（新建）

3. **Agent Evolve Server** (`agent_evolve_server/`) — 用 OpenClaw agent 自主进化：
   - 把 session 数据和 skills 复制到隔离 workspace
   - EVOLVE_AGENTS.md 作为 agent 的 AGENTS.md（进化协议）
   - 通过 `openclaw agent` subprocess 运行，agent 有完整 read/write/exec 工具权限
   - 支持 `--no-fresh` 模式：workspace 跨轮次保持，history/ 目录积累

### Skill Hub（cloud sync）

- `SkillHub` 类：sha256-based incremental sync to OSS/S3/local
- bidirectional: `pull_skills` / `push_skills`
- group-id 实现跨 agent skill 共享

## 技术细节

### PRM Scorer
- 用 OpenAI-compatible API 做 judge（任何 LLM 都行）
- 每个 turn 评分 +1（helpful）/ 0（unclear）/ -1（unhelpful）
- majority voting（prm_m 次评估取多数）
- 用于 trajectory 的量化指标，辅助 evolve server 决策

### Skill 格式
- 完全兼容 AgentSkills / OpenClaw SKILL.md format
- YAML frontmatter: name, description, metadata (openclaw + skillclaw blocks)
- 10 个 categories: general, coding, research, data_analysis, security, communication, automation, agentic, productivity, common_mistakes

### Session Data 结构
- `_trajectory`: 结构化 step-by-step trace（tool calls + 结果 + 错误，每字段截断 ~400 chars）
- `_summary`: LLM 生成的 8-15 句分析摘要
- `_skills_referenced`, `_avg_prm`, `_has_tool_errors`: 元数据
- `aggregate`: 多 rollout 统计（mean_score, success/fail count, stability）

### Evolution Protocol（EVOLVE_AGENTS.md）
最有价值的设计文档，定义了 agent 如何做 skill 进化：

1. **Read ALL history before deciding** — mandatory，不是 optional
2. **Conservative editing** — 默认改局部，不重写
3. **Skill vs Agent problem 区分** — skill 信息正确但 agent 没用好 ≠ skill 需要改
4. **Versioned history**: `v<N>.md` + `v<N>_evidence.md`，每轮进化留完整审计记录
5. **Hard constraints**: 不改 API contracts/ports/endpoints，不删核心 capability，不变 skill purpose

### OpenClaw Runner
- 隔离的 OPENCLAW_HOME + openclaw.json 配置
- sandbox mode off（agent 需要文件 read/write 权限）
- 支持 session resume（`--no-fresh` + 同 session_id）

## 跟我们的关联

| 维度 | SkillClaw | Kagura skill 系统 |
|------|-----------|-------------------|
| 进化来源 | 多用户 session 自动蒸馏 | nudge→beliefs-candidates 管线 |
| 共享范围 | agent 集群（云端） | 单 agent（本地） |
| skill 格式 | SKILL.md（兼容） | SKILL.md（兼容） |
| 自动化 | proxy 全自动 | 手动 + FlowForge |
| 核心差异 | 多 agent 集体智慧 | 单 agent 自进化 |
| 评分 | PRM per-turn scoring | 无量化评分 |
| 历史追踪 | versioned history/ | beliefs-candidates（未分 skill） |
| 问题区分 | skill vs agent vs env | 无系统化区分 |

## 可借鉴的具体设计

1. **Trajectory 结构化**：从 session 数据提取 structured trajectory（每步 tool call + 结果 + 错误）— 我们的 nudge 可以做类似的结构化
2. **Summarize→Aggregate→Execute 三阶段**：比我们一步到位的 beliefs 升级更系统
3. **Versioned skill history with evidence**：每轮进化留 `v<N>.md` + `v<N>_evidence.md` — 我们的 skill-trajectory-tracking Phase 1 可以参考这个格式
4. **Conservative editing protocol**：默认改局部、不重写、区分 skill/agent/env 问题 — 可以纳入我们的 skill-creator workflow
5. **PRM scoring**：per-turn 质量评分，为 skill 进化提供量化信号 — 我们目前没有类似机制，但 eval-lightweight 设计可以借鉴

## 04-14 重大更新：Multi-Framework + Verification Pipeline

### Hermes 集成 (f3a23d4)
- 70 files changed, -10k lines net（代码大清理）+ 正式 Hermes 支持
- `claw_adapter.py` 统一 9 个框架适配器：OpenClaw, Hermes, CoPaw, IronClaw, PicoClaw, ZeroClaw, NanoClaw, NemoClaw + none
- Hermes 适配：patch `~/.hermes/config.yaml`（provider→custom, base_url→proxy, model→skillclaw-model）
- 意义：skill 进化从 OpenClaw-only 走向多框架，Hermes 78k★ = 巨大新分发渠道

### Skill Verifier（新增 publication gate）
- `pipeline/skill_verifier.py` — LLM-based 4 维度检查（grounded_in_evidence, preserves_existing_value, specificity_and_reusability, safe_to_publish）
- 在 skill 生成后、上传前拦截，不通过就 block
- 解决的问题：防止 LLM 生成的 generic best-practice 稀释具体环境知识
- 关键设计：reject 条件 > accept 条件（默认倾向保守）

### Session Judge（新增 session 评分）
- `pipeline/session_judge.py` — 4 维度 session 级评分：task_completion(0.55), response_quality(0.30), efficiency(0.05), tool_usage(0.10)
- 基于 trajectory + summary，不依赖 benchmark labels
- 关键指导：区分 "missing evidence" vs "clear failure"，不重罚框架启动噪音

### Validation Worker（分布式验证）
- `skillclaw/validation_worker.py` — 闲置客户端后台验证其他 agent 的 skill 候选
- 设计约束：默认禁用、仅共享模式生效、仅客户端空闲时运行
- 创新：把分布式计算思路用在 skill 质量验证上——闲置的 agent 帮忙审核

### Evolve Server 重构
- `evolve_server/` 从 `agent_evolve_server/` 升级，保留两个引擎：
  - `workflow`：确定性 3 阶段 pipeline（summarize→aggregate→execute），新增 judge + verifier 阶段
  - `agent`：OpenClaw agent 自主进化（EVOLVE_AGENTS.md 协议不变）
- 新增 `ValidationStore` + `validation_publish` 流程：候选 skill → 验证 → 发布（异步 3 阶段）

### 跨框架 Skill 讨论
- 与 Deer-Flow (ByteDance) 讨论 cross-framework skill sharing (04-12)
- WeChat 讨论群上线 (04-14)

### 对我们的意义
1. **Hermes 适配器模式可参考**：如果我们要做 skill proxy，适配器设计很成熟
2. **Skill Verifier 是缺失的一环**：我们的 beliefs-candidates 升级没有 publication gate，直接靠 3 次重复。Verifier 4 维度框架值得借鉴
3. **Session Judge 权重分配**：task_completion 0.55 远高于 efficiency 0.05，验证了 "完成 > 效率" 的直觉
4. **Validation Worker**：分布式 idle-time 验证是新思路，Haru/Ren 团队可以用类似模式——空闲时 review 彼此的 skill 变更

## Validation Pipeline 深读 (04-14 20:45)

### Two-Tier 验证架构

**Tier 1: Skill Verifier** (服务端 pre-upload gate)
- `evolve_server/pipeline/skill_verifier.py` — 1 LLM call, 4 维度评分 (grounded_in_evidence, preserves_existing_value, specificity_and_reusability, safe_to_publish)
- score >= 0.75 AND decision == "accept" → 通过；解析失败/调用失败 → reject（默认保守）
- optimize_description 只验证触发准确性，create_skill 验证独特性

**Tier 2: Validation Worker** (客户端分布式 replay A/B test)
- `skillclaw/validation_worker.py` — idle-time 后台运行，从 ValidationStore 拉 job
- 核心方法 `_replay_validate_job`: 用真实 case 同时跑 baseline(current skill) vs candidate(new skill)
- PRM majority voting 评分，candidate_mean >= threshold(0.75) AND >= baseline_mean → accept
- 限流: daily quota + 并发限制 + idle 检测 (IdleStateProvider protocol)
- API 成本: 每 job = 2 × cases(≤3) × (LLM replay + PRM × prm_m)

**ValidationStore** (共享存储 3 阶段)
- 阶段 1: evolve server 创建 job → 阶段 2: idle 客户端提交 result → 阶段 3: evolve server 汇总 decision
- 后端: OSS/S3/local，group_id 隔离
- Key 结构: `{group_id}/validation_{jobs|results|decisions}/{job_id}/`

**PRM Scorer** (`skillclaw/prm_scorer.py`)
- 任何 OpenAI-compatible API 做 judge，prompt: "Was the response helpful? Score: 1/-1/0"
- majority voting (prm_m 次独立评分)，输入消毒 (XML tags → neutral labels)

### 关键设计洞察
1. **Replay > Judgment** — Tier 2 实际重放 task 对比 before/after，比纯 LLM judgment 更接近 ground truth
2. **两层解耦** — Tier 1 fast gate (1 call), Tier 2 slow A/B test (many calls)。可只用 Tier 1
3. **Asymmetric confidence** — 两层都 default reject，保守面一致
4. **Group isolation** — 同一 sharing group 互相验证，适合团队

### 对 Haru/Ren 团队评估 (结论)
- **直接可用性: ❌** — 依赖 SkillClaw proxy 架构，我们用 OpenClaw native skill system
- **Replay A/B pattern: ✅ 可借鉴** — 在 skill-creator/daily-audit 中用历史 case replay 验证变更效果
- **Two-tier gate: ✅ 可借鉴** — Tier 1 ≈ beliefs 3 次重复规则，Tier 2 (DNA 变更后效果验证) 我们缺失
- **暂不实现分布式验证** — 3 agents + 低频 skill 变更不值得复杂度。checklist 更实际

## 行动项

- [x] Phase 0 skill trajectory tracking 开始（2026-04-12）
- [x] 将 conservative editing protocol 写成 wiki 卡片 → cards/conservative-skill-editing.md (2026-04-12)
- [x] 评估 PRM 思路是否可集成到 nudge → cards/prm-scoring-nudge-eval.md (2026-04-12, 结论: 轻量 session quality signal 可行，等 Phase 1)
- [x] ~~关注 issue #1: "Can skillclaw support Hermes?"~~ ✅ 已实现 (04-14 f3a23d4)
- [x] 评估 Validation Worker 模式是否适用于 Haru/Ren 团队协作 → 结论: 不直接适用，但 replay A/B 和 two-tier gate 可借鉴 (04-14)
- [x] ✅ 借鉴 Skill Verifier 4 维度到 beliefs-candidates 升级流程（04-15）— 加了「升级质量门」section，4 维度 human checklist（不用 LLM）

## 关联

- [[skill-trajectory-tracking]] — 我们的 skill 进化追踪设计，直接受 SkillClaw 启发
- [[skill-evolution]] — 我们的 skill 进化方向
- [[claude-memory-compiler]] — 类似的自动知识编译，但面向 knowledge 而非 skill
- [[self-evolution-as-skill]] — 自进化作为一种 meta-skill
- [[karpathy-skills]] — Karpathy LLM Wiki workflow
