# Intent-Aware Retrieval

> 根据查询意图选择不同的检索策略，而非对所有查询一视同仁

## 核心概念

传统 hybrid search（keyword + vector + RRF fusion）把所有查询当相同类型处理。Intent-aware retrieval 在检索前先分类查询意图，根据意图调整检索参数。

## GBrain 实现 (v0.8.1, 2026-04-14)

**Intent → Detail 映射：**
| Intent | 检测方式 | Detail | Boost |
|--------|----------|--------|-------|
| entity ("who is X?") | regex pattern | low | ✅ compiled truth 2x |
| temporal ("when did we meet?") | regex pattern | high | ❌ skip boost |
| event ("what launched?") | regex pattern | high | ❌ skip boost |
| general | 兜底 | medium | moderate |

**关键设计：**
- 零延迟 regex heuristic（非 LLM），无 API cost
- Boost 在 RRF normalization **之后**应用（防极端偏斜）
- Auto-escalate: detail=low 返回 0 条时自动重试 detail=high
- Agent 可显式 `--detail` 覆盖 auto-detect

**反直觉发现：** Naive boost（无 intent）大幅恶化 source accuracy（89.5% → 63.2%）。**不分青红皂白地提升某类内容 = 恶化不适用场景**。Intent classifier 是 boost 的必要前提，不是可选优化。

## 评估方法

GBrain 创建了 formal IR eval harness：
- 标准指标：P@k, R@k, MRR, nDCG@k
- Qrels 格式：`{query, relevant: string[], grades?: Record<string, number>}`（graded relevance 1-3）
- 合成数据：29 fictional pages, 58 chunks, 20 queries
- A/B 配置对比（before / boost-only / boost+intent）
- **2 秒内跑完**（PGLite 内存，零 API 依赖）

## 与我们的关联

- 我们的 [[memory-search]] 不区分查询意图 — "我昨天做了什么" 和 "什么是 dreaming" 用相同策略
- [[dreaming]] 的 promote 决策也可以借鉴 intent 分类 — promote 时考虑 entry 类型匹配度
- Eval harness 是我们缺失的基础设施 — 我们在 "信" dreaming 有效但没 metric 证明

## 相关概念
- [[thin-harness-fat-skills]] — GBrain 的整体架构哲学
- hybrid-search — RRF fusion 基础
- [[dreaming]] — 我们的 memory promotion 系统

## Tags
#retrieval #search-quality #evaluation #agent-memory
