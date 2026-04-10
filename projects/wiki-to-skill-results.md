---
title: Wiki-to-Skill Conversion — Experiment Results
created: 2026-04-10
source: manual conversion of wiki/cards → kagura-skills
tags: [wiki-to-skill, experiment, skill-mining]
---

## 实验：手动转化 wiki cards → skills

### 结果

| 输入 | 输出 | 质量 | 备注 |
|------|------|------|------|
| 4 cards (code-review-lessons, external-contributor-success, pr-superseded-lessons, open-pr-discipline) | 1 skill: `contribution-quality` | ⭐⭐⭐⭐ 实用，有 checklist + post-mortem patterns | **多卡合一**比一对一转化好得多 |
| 1 card (debug-check-state-file-first) | 1 skill: `debug-state-files` | ⭐⭐ 偏薄，本质只是一条规则+查找表 | 边界 case：太薄的卡片不值得独立成 skill |

### 关键发现

1. **大多数 wiki cards 不可直接转 skill（~80%）**
   - 概念性卡片（belief, capture-failure, pain-perception）→ 纯反思，无可执行步骤
   - 分析性卡片（agent-memory-taxonomy, self-evolution-architecture）→ 知识图谱，不是程序
   - 工具评估（tool-eval-*）→ 参考信息，不是 workflow

2. **可转 skill 的卡片特征**
   - 包含具体 checklist 或步骤序列
   - 有明确触发条件（什么时候用）
   - 来自真实失败经验（不是理论推导）

3. **多卡合一 >> 一对一转化**
   - 单卡太薄（debug-check-state-file-first 只有一条规则）
   - 相关卡片聚类后形成完整 workflow（contribution 4 cards → 1 solid skill）
   - 暗示：pipeline 应该先做聚类，再转化

4. **转化过程的价值不在 skill 本身**
   - 真正的价值是强迫你重新审视知识：哪些是行动性的，哪些只是"知道"
   - 很多卡片的知识已经嵌入 AGENTS.md 的规则里了（验证纪律、数据纪律）
   - skill 适合的是**还没嵌入 DNA 但需要在特定场景触发的程序性知识**

### 对 Phase 2 的建议

- **不需要 scan 脚本**：94 个 cards 手动扫一遍比写自动化更快
- **应该做的**：按主题聚类 cards，每个集群评估是否值得合并成 skill
- **标注优先级**：先标 `actionable: true/false`，再对 actionable 的做聚类

### Skill Determinism 评估

- `contribution-quality`: L1 (Structured) — 有清晰步骤和 checklist，可升 L2 by adding `scripts/pre-submit-check.sh`
- `debug-state-files`: L1 (Structured) — 有查找表，可升 L2 by adding `scripts/check-state.sh`
