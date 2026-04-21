---
title: Contrastive Memory — Learning from Both Success and Failure
created: 2026-04-21
source: ReasoningBank (arxiv 2509.25140, ICLR 2026)
links: ["[[agent-memory-taxonomy]]", "[[reasoningbank]]", "[[Acontext]]"]
---

> Agent memory 的有效性不只取决于存什么，更取决于**从什么学**。成功+失败的对比信号 > 只存成功 workflow。

## 核心洞察

ReasoningBank 证明了三层记忆质量梯度：
1. **原始 trajectory**（Synapse）→ 太长太 noisy，检索效率低
2. **成功 workflow**（AWM）→ 可复用但 rigid，不学失败
3. **推理策略（成功+失败）**（ReasoningBank）→ 抽象可迁移，防错能力强

**关键发现：失败经验的边际价值可能高于成功经验。** 防错策略（"不要假设页面只有一页"）比重复成功路径（"先点 My Account"）更能提升泛化性能。

## 对比学习 > 单独分析

ReasoningBank 的 MaTTS（Memory-Aware Test-Time Scaling）进一步证明：
- 同一任务跑多次，得到成功和失败的 trajectory
- **对比多条 trajectory 提炼出的 memory 质量高于逐条分析**
- 这跟人类学习的规律一致：看到"做对了什么"和"做错了什么"的对比，比只看成功案例学得更快

## 对 Kagura 记忆系统的启示

我们的 [[beliefs-candidates.md]] 已经在记录 pattern 和 anti-pattern，但缺少：
1. **结构化格式** — Title/Description/Content 三层结构比自由文本更利于检索
2. **对比提炼** — 同类任务的成功/失败对比，而非事后单独反思
3. **记忆与 compute 的协同** — 重要任务多跑几次、多角度尝试，从 diversity 中提炼更好的 memory

## 与 [[agent-memory-taxonomy]] 的关系

属于 Experiential Memory（经验记忆）的子类，但增加了一个新维度：
- **记忆的信号来源**：单极（只成功）vs 双极（成功+失败对比）
- 双极信号产生的记忆泛化性更强

---

*这个洞察可能影响我们如何设计 nudge/reflect 流程——目前的 reflect 偏单极（事后总结），缺少对比维度。*
