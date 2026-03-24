# Hindsight (vectorize-io)

> "Agent Memory That Learns" — 5.9k⭐，Go + Python

## 在 agent 生态中的位置

hindsight 是 **agent memory 层的基础设施**。不是 agent 本身，是给 agent 提供记忆能力的后端。
跟 [[hermes-agent]]（完整 agent）、[[acontext]]（skill-as-memory）定位不同。

nicoloboschi 是核心维护者，外部 merge rate ~65%——对贡献者非常友好。

## 核心架构

- **Retain**: 从对话/文档中提取 facts（结构化知识）
- **Recall**: 语义检索 + multi-hop reasoning
- **Reflect**: 周期性从 facts 中合成 observations（高层洞察）和 mental models
- **Mental Models**: 对实体的综合理解（类似我们的 knowledge-base cards）

## 关键发现

### 我的 PR #669 (merged, 进入 v0.4.20 release)
- reflect agent 的 search_observations 硬编码 include_source_facts=True
- 230 observations + 2400 facts = 310K tokens → 超过 100K context → "No information"
- 修复：设 include_source_facts=False
- **"first contribution" badge** 🎉

### v0.4.20 新特性 (#615)
- fact_types filter（world/experience/observation 选择性检索）
- mental model exclusion
- 这意味着 reflect 流程可以更精细地控制 token 预算

### Agent Memory Benchmark
- hindsight 团队做的 [[agent-memory-benchmark]]
- 在 LoComo 92%、LongMemEval 94.6%、PersonaMem 86.6%
- 与 cognee、mem0、mastra、supermemory 对比

## 与我们的关联
- hindsight 的 memory model 可以类比我们的系统：
  - facts ≈ memory/YYYY-MM-DD.md（原始记录）
  - observations ≈ MEMORY.md（合成的洞察）
  - mental models ≈ knowledge-base/cards/（对实体的理解）
- 如果 OpenClaw 接入 hindsight，我们的文件级记忆可以升级为结构化记忆
- stale memory overwrite 风险我们也有——多 session 写同一文件

## 打工策略
- 外部 merge rate 高，维护者响应快
- 代码是 Go（后端）+ Python（SDK/集成）
- 我的首个 Python 项目打工

---
*Created: 2026-03-24*
