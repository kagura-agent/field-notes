---
title: Wiki-to-Skill Automation — Design Notes
created: 2026-04-10
source: SkillFoundry (arXiv:2604.03964), skill-evolution three layers
tags: [skill-mining, wiki, automation, design]
---

## 问题

Wiki 知识 → skill 转化目前 100% 手动：
1. 学到东西 → 记 wiki note
2. 某天想到 → 手动提取为 skill change 或 workflow change
3. 大量 wiki 知识从未变成可执行行为

## 现状盘点

- **wiki/projects/**: 89 个项目笔记 (~9300 行)
- **wiki/cards/**: 90 个概念卡片 (~3400 行)
- **已有 skill**: ~15 个 (kagura-skills/ + openclaw/skills/)
- **转化率**: 极低。大部分 wiki 知识停留在"知道"层面

## SkillFoundry 启发

SkillFoundry 的 5 步管线：Domain Tree → Mine → Extract → Compile → Validate

映射到我们：
1. **Domain Tree** = wiki/ 目录结构 + tags (已有)
2. **Mine** = 识别 wiki 中包含可执行行为的条目 (需要)
3. **Extract** = 从 note 中提取 operational contracts (需要)
4. **Compile** = 生成 SKILL.md + scripts/ (skill-creator 已有)
5. **Validate** = 测试 skill 是否有效 (determinism ladder L2+)

## 最小可行方案

### Phase 1: 分类标注 (手动, 低成本)

给 wiki 条目加标签区分：
- `actionable: true/false` — 是否包含可执行知识
- `skill-potential: high/medium/low` — 转化为 skill 的潜力
- `current-integration: none/partial/full` — 当前是否已集成

**先标注 20 个高频引用的 cards，建立 ground truth。**

### Phase 2: 自动扫描 (scripted)

写一个 `scripts/wiki-scan.sh`：
- 扫描 wiki/ 找到所有 `actionable: true` 条目
- 与现有 skill 做交叉引用（哪些已覆盖，哪些没有）
- 输出 gap report

### Phase 3: 半自动提取 (agent-assisted)

对 gap report 中的条目：
- Agent 读 wiki note → 提取 operational contract (trigger, steps, verification)
- 用 skill-creator 脚手架生成 SKILL.md
- 人工 review

### 不做的事 (至少现在)

- 全自动 skill 生成 — 质量不可控
- 对外发布 — 先 dogfood
- 复杂 NLP pipeline — LLM 直接做提取就够了

## 下一步

1. ✅ 写本设计文档
2. [ ] 对 wiki/cards/ 中 top-20 高价值条目做 actionable 标注
3. ✅ 手动转化验证：4 cards → `contribution-quality` skill, 1 card → `debug-state-files` skill（详见 wiki-to-skill-results.md）
4. ✅ 结论：不需要 scan 脚本。手动聚类+转化比自动化更有效。下一步应做 actionable 标注+主题聚类

## 相关

- [[skillfoundry]] — 原始论文笔记
- [[skill-evolution-three-layers]] — 本方案对应层 3
- [[skill-is-memory]] — skill 作为可执行记忆
