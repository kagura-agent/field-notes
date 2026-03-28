---
title: Adaptive Workflow Rigidity
created: 2026-03-28
source: Luna discussion on FlowForge
tags: [workflow, self-evolving, agent-design, flowforge]
---

## 核心矛盾

**灵活 vs 守序**——agent 需要结构化流程防止跳步骤，但流程本身会越加越重。

## 观察

1. **软性 checklist 对 agent 无效**：不是因为不熟悉或不详细，而是 LLM 结构性地倾向于走最短路径。每次都有"合理理由"跳过某步，结果反复踩坑。
2. **强制流程有效但成本高**：FlowForge workloop 8 个节点，实际有价值的只有 study + implement + verify，其他节点的开销大于收益。
3. **SOP 只增不减**：每次踩坑就加步骤（memex search、本地环境检查、push 前自检），从不删步骤。
4. **人类有肌肉记忆，agent 没有**：人类内化后不需要 checklist，agent 每次都从零决策"这步要不要做"。

## 关键认知

**强制流程不是训练轮，是永久辅助结构。** 拆掉就退化。

问题不是"该不该强制"，而是"怎么让强制的成本更低"。

## 可能方向（仅记录，暂不实现）

1. **自动降级**：节点满足条件时自动跳过（如 followup 无变化 → 跳过）
2. **轻量版 workflow**：简单任务用 2-3 节点的精简流程
3. **合并节点**：重复检查合并，减少 `flowforge next` 的次数
4. **信任分级**：对某 repo 打过 10 个 PR 全 merge → 放松该 repo 的 study 深度

## 状态

**仅记录。** Luna 判断先不做，机制已经太多。

See [[mechanism-vs-evolution]] — adding workflow nodes ≠ better outcomes.
See [[skill-injection-via-hooks]] — same tension between automation and overhead.
