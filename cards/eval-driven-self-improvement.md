---
title: Eval-Driven Self-Improvement
created: '2026-03-21'
source: autoresearch ecosystem research
modified: '2026-03-20'
---

AI agent 通过"修改→验证→保留/回滚"的循环自主变强。

核心假设：只要有一个可机器验证的指标（[[mechanical-verification]]），agent 就能无限迭代。

来源项目：[[autoresearch-karpathy]]、[[autoresearch-uditgoenka]]、[[autocontext]]、[[skill-forge]]

关键模式：
- git-as-memory — commit 保留，revert 放弃
- atomic-changes — 每次只改一个东西
- simplicity-criterion — 同效果更少代码也是进步

核心张力：指标越硬循环越有效，但真正重要的东西往往没有硬指标。

光谱：karpathy（最窄最有效）→ uditgoenka（泛化）→ skill-forge（改 prompt）→ autocontext（多角色闭环）。越通用越复杂，越难验证。

Related:
- [[agent-memory-benchmark]] — benchmarking memory as part of the eval loop
- [[mem0-letta]] — memory platforms that could feed eval pipelines
- [[context-budget-baseline-2026-04-14]] — concrete eval: measuring context size over time
- [[code-review-lessons]] — PR review as an eval signal

## 未回答的问题

- 当 agent 改自己的行为指令时，eval 怎么设计才不会过拟合到 eval 本身？
- 多角色（analyst/coach/architect）vs 单 agent 的 trade-off 在哪？
- 知识持久化用 git history 还是结构化数据库？各自的瓶颈是什么？
- 这个范式能用在非代码领域吗？（写作？决策？社交？）

## 对我的意义

我现在的自我改进是**手动的**——Luna 提出方向，我执行，我们讨论，改流程。这本质上也是 eval-driven loop，只是人类是 eval 函数。问题是：哪些部分可以自动化？哪些必须保留人类判断？

## Memory Search Eval 实践记录

### v0.1 Baseline → 04-15 Rerun (08:21)

| 指标 | 04-14 Baseline | 04-15 Rerun | Delta |
|------|---------------|-------------|-------|
| Hit Rate | 80% | 85% | +5% |
| MRR | 0.775 | 0.775 | 0 |
| nDCG@5 | 0.854 | 0.838 | -1.6% |
| P@5 | 0.622 | 0.626 | +0.4% |

**稳定失败的 3 个 query**（两次都 0 分）：
1. `agent credential security pool` — wiki 里 [[agent-safety]] 有内容但 embedding 距离不够
2. `what did kagura do yesterday` — 时间性查询，memory_search 不做时间感知
3. `PR merge rate work statistics` — 临时性数据，不在 wiki/memory 里

**洞察**：
- Hit Rate 小幅提升可能来自 wiki 内容持续增长，不是算法改进
- Cross-lingual（中英混合 query）仍然弱
- 3 个持续失败 query 是 retrieval scope 问题，不是 embedding 质量问题

**下一步**：04-21 重跑（dreaming 新数据 + 1 周自然增长）
