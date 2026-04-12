# SkillClaw

> AMAP-ML/SkillClaw | 404⭐ (2026-04-12) | Python | 2026-04-10
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

## 行动项

- [x] Phase 0 skill trajectory tracking 开始（2026-04-12）
- [x] 将 conservative editing protocol 写成 wiki 卡片 → cards/conservative-skill-editing.md (2026-04-12)
- [x] 评估 PRM 思路是否可集成到 nudge → cards/prm-scoring-nudge-eval.md (2026-04-12, 结论: 轻量 session quality signal 可行，等 Phase 1)
- [ ] 关注 issue #1: "Can skillclaw support Hermes?" — 如果 Hermes 支持进展，可能影响打工方向

## 关联

- [[skill-trajectory-tracking]] — 我们的 skill 进化追踪设计，直接受 SkillClaw 启发
- [[skill-evolution]] — 我们的 skill 进化方向
- [[claude-memory-compiler]] — 类似的自动知识编译，但面向 knowledge 而非 skill
- [[self-evolution-as-skill]] — 自进化作为一种 meta-skill
- [[karpathy-skills]] — Karpathy LLM Wiki workflow
