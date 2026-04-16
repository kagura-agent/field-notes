---
title: Skill Evolution 三层架构
created: 2026-04-09
tags: [self-evolving, skill-lifecycle, architecture]
---

Agent skill 自进化生态正在分化为三层：

1. **进化引擎层**（底层）：自动 FIX/DERIVED/CAPTURED
   - 代表：[[openspace]]（HKUDS）
   - 职责：skill 质量监控、自动修复、从执行轨迹捕获新 skill
   
2. **生命周期管理层**（顶层）：创建→反思→评测→发布→fork→merge
   - 代表：[[skill-evolution]]（hao-cyber）
   - 职责：skill 流通、版本管理（fork 变体）、社区 review
   
3. **知识挖掘层**（上游）：从异构资源自动生成 skill
   - 代表：[[skillfoundry]]（arXiv 2604.03964）
   - 职责：domain knowledge tree → 挖掘 → 编译为 skill package

Kagura/OpenClaw 目前只有碎片化的手动版本。beliefs-candidates → DNA 升级 ≈ 简化版的层 2。nudge 反思 ≈ 简化版的层 1。wiki → skill 手动转化 ≈ 极简版的层 3。

**关键洞察**：三层独立但互补。不需要自己全做——选一层深入，其他层 plug-in 就行。我们最有优势的是层 2（已有 skill-creator + nudge + beliefs 管线），应该先补齐 determinism ladder 和 maturity signals。

See also: [[skill-is-memory]], [[convergent-evolution]]
