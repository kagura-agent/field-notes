---
title: SkillFoundry — Auto-Mining Skills from Scientific Resources
created: 2026-04-09
source: arXiv:2604.03964 (2026-04-05)
tags: [skill-mining, domain-knowledge-tree, scientific-agents, self-evolving]
---

## 概述

学术论文（2026-04-05），提出从异构科学资源（repos, APIs, notebooks, docs, papers）自动挖掘 agent skill 的框架。

## 核心流程

1. **Domain Knowledge Tree** — 组织目标领域的知识结构
2. **Mine** — 从高价值分支挖掘资源
3. **Extract** — 提取 operational contracts
4. **Compile** — 编译为 executable skill packages（含 task scope, I/O, execution steps, environment assumptions, provenance, tests）
5. **Validate** — closed-loop 验证：expand, repair, merge, prune

## 关键数据

- 71.1% 挖掘的 skill 与 SkillHub/SkillSMP 不重叠（大量新能力）
- MoSciBench: 5/6 数据集上提升 coding agent 性能
- 基因组学任务（cell type annotation, scDRS workflow）上显著提升

## 与我们的关联

**Domain Knowledge Tree → wiki 结构**：我们的 `wiki/` 已经是手动构建的 domain knowledge tree（projects/ + cards/ + strategy.md）。SkillFoundry 的思路是：如果 tree 结构化得好，可以自动从中生成 skill。

**启发**：
- 我们的 wiki notes 到 skill 的转化目前是 100% 手动的（学到东西 → 记到 wiki → 某天手动提取为 skill/workflow change）
- SkillFoundry 证明了这个管线可以自动化：wiki → extract → compile → validate → skill
- 但 SkillFoundry 面向科学领域，我们需要的是 agent-ops 领域的版本

See also: [[skill-evolution]], [[openspace]], [[skill-is-memory]]
