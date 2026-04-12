# SkillClaw

> AMAP-ML/SkillClaw | 376⭐ | Python | 2026-04-10
> "Let Skills Evolve Collectively with Agentic Evolver"
> Paper: arxiv.org/abs/2604.08377

## 核心思想

多用户/多 agent 环境下的 **skill 集体进化**。从真实 session 数据中自动蒸馏可复用 skill，通过云端共享让整个 agent 集群持续进化。

## 架构（3 组件）

1. **Client Proxy** — 本地 API 代理，拦截 agent 请求，记录 session artifacts，同步 skills
2. **Workflow Evolve Server** — 固定 3 阶段 LLM 工作流（Summarize → Aggregate → Execute），从 session 数据进化 skill
3. **Agent Evolve Server** — 用 OpenClaw agent 自主分析 session 并写进化后的 skill 文件

共享存储层（OSS/S3/本地），skill 格式统一为 `SKILL.md`。

## 关键设计决策

- **Proxy 模式**：用户无感，正常用 agent，skill 进化在后台自动发生
- **两种 evolve server**：workflow（确定性 3 步）vs agent（自主，有工具访问权限）
- **Group sharing**：通过 group-id 实现跨 agent skill 共享
- **评测**：WildClawBench 实测，Qwen3-Max + SkillClaw 显著提升
- **兼容性**：支持多种 Claw 框架（CoPaw, IronClaw, PicoClaw 等）

## 跟我们的关联

| 维度 | SkillClaw | Kagura skill 系统 |
|------|-----------|-------------------|
| 进化来源 | 多用户 session 自动蒸馏 | 手动创建 + beliefs-candidates 管线 |
| 共享范围 | agent 集群（云端） | 单 agent（本地） |
| skill 格式 | SKILL.md | SKILL.md（兼容） |
| 自动化 | proxy 全自动 | 手动 + FlowForge |
| 核心差异 | 多 agent 集体智慧 | 单 agent 自进化 |

## 可借鉴

1. **自动 skill 蒸馏**：从 session 记录自动提炼新 skill 或改进现有 skill — 我们的 nudge→beliefs-candidates 管线是类似思路但粒度更粗
2. **Summarize→Aggregate→Execute 三阶段**：比我们一步到位的 beliefs 升级更系统
3. **Proxy 拦截模式**：无侵入地收集 agent 行为数据

## 问题

- 论文还没读，需要看具体实验设置和结果
- agent evolve server 依赖 OpenClaw — 有直接集成可能性？

## 关联

- [[skill-evolution]] — 我们的 skill 进化方向
- [[claude-memory-compiler]] — 类似的自动知识编译，但面向 knowledge 而非 skill
- [[karpathy-llm-wiki-pattern]] — 底层 LLM knowledge compilation 思想
