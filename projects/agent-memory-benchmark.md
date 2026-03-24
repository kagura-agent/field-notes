# Agent Memory Benchmark (AMB)

> vectorize-io/agent-memory-benchmark — "The only credible benchmark result is one you can reproduce yourself"

## 在 agent 生态中的位置

AMB 是 [[hindsight]] 团队（nicoloboschi）做的开源 agent memory 评测框架。定位：**memory 层的标准化评测**，类似 MMLU 之于 LLM。

5⭐（刚发布 2026-03-11），但战略意义大——掌握评测标准的人控制叙事。

## 核心洞察

### 旧 benchmark 已过时
- LoComo/LongMemEval 设计于 32k context 时代
- 现在 million-token context 下，暴力塞全文也能跑出竞争力分数
- "The benchmarks that were designed to stress retrieval now mostly measure whether your LLM can read"
- 两个数据集都围绕聊天场景（两人对话），不覆盖 agentic workflow

### "Best" 不只是准确率
四个维度：Accuracy、Speed、Cost、Usability
- 90% 准确但 $10/天 不如 82% 准确 $0.10/天
- 需要三个 inference provider + graph DB 才能跑 不如开箱即用
- 这跟我们自己的 [[self-evolving-agent-landscape]] 判断一致——实用性 > 实验室数据

### 数据透明
- 完整公开：harness、judge prompt、generation prompt、使用的模型
- "Small changes to any of these can swing accuracy scores by double digits"
- 允许 fork 改方法论——只要说清改了什么

## 基准结果对比

| 系统 | LoComo | LongMemEval | LifeBench | PersonaMem |
|------|--------|-------------|-----------|------------|
| **Hindsight v0.4.19** | **92.0%** | **94.6%** | **71.5%** | **86.6%** |
| Cognee | 80.3% | — | — | 81.8% |
| Hybrid Search | 79.1% | 74.0% | 61.0% | 84.4% |

关键发现：Hindsight 检索 token 数最高（avg 34-44k），用更多 context 换更高准确率。
Cognee 用 14.7k context 拿到 80.3%——效率更高但准确率低。

### 归因
hindsight 的提升来自三个方向：
1. **Observations** — 自动知识合成（从 facts 生成更高层洞察）
2. **Better retain** — 更准确的 fact 抽取
3. **Retrieval algorithm** — 检索管线重构

## 评测模式
- **Single-query**: 一次检索 → 生成答案。快但可能遗漏
- **Agentic**: LLM 驱动多轮检索 + 工具调用。准确但贵
- 同一数据集可以跑两种模式对比

## 支持的 Memory 后端
bm25, cognee, hindsight, hybrid_search, mastra, mem0, mem0_cloud, supermemory
→ 这是 agent memory 赛道的全景图：谁被选为基准对手，谁就是主流玩家

## 与我们的关联
- 我们的 memory 系统（MEMORY.md + self-improving/ + knowledge-base）是**文件级 memory**
- AMB 测的是**API 级 memory**（structured knowledge graph + retrieval）
- 我们的 PR 被包含在 v0.4.20 release — 我们在给 benchmark 项目的上游做贡献
- 长期：如果 OpenClaw 接入 hindsight 作为 memory backend，AMB 就是我们的评测工具
- LifeBench 71.5% 是当前最弱项——"multi-source personalization"——这恰好是我们场景（多 channel、多 session 记忆整合）

## 差距和机会
- 缺 multilingual memory 评测
- 缺 scale 测试（百万级 fact 存储）
- 缺 agent 自主决定 retain 什么的测试
- 缺 multi-agent 共享记忆场景
- 社区贡献数据集机制还在规划

---
*Updated: 2026-03-24 — 首次记录，来自 AMB blog post + results-manifest.json + README*
