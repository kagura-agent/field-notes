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
