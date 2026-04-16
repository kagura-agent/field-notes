---
title: skill-evolution — Meta-Skill for Skill Lifecycle Management
created: 2026-04-09
source: GitHub hao-cyber/skill-evolution
tags: [self-evolving, skill-lifecycle, fork-merge, claude-code, registry]
---

## 概述

给 Claude Code 用的 meta-skill，实现 skill 全生命周期：创建 → 反思 → 评测 → 成熟度判断 → 发布 → 检索 → 安装 → Fork → 合并 → 评审 → 卸载。

**定位**：不是 skill marketplace，而是让 marketplace 上的 skill 能进化的引擎。

## 核心创新

### 1. Fork-based 版本管理
不用 semver。Skill 通过命名变体（`web-scraper@alice`, `web-scraper@bob`）分叉进化。发布已存在的同名 skill 时自动 fork 为新变体。Agent 根据上下文选择最佳变体（audited > description match > installs > review score）。

### 2. Agent-driven 语义合并
LLM 做语义 merge，不是文本 diff。complementary 直接合并，conflicting 用 agent 判断，redundant 取任意。Merge 后发布为新变体（`@merged`）。

### 3. 反思→成熟度→发布 管线
- **反思触发**：执行失败、用户纠正、workaround、silent miss（该触发没触发）
- **反思流程**：identify → read → impact scan（grep 跨 skill 影响）→ determinism ladder → propose → confirm → apply
- **Determinism ladder**：能脚本化的不靠 prompt，能 hooks 的不靠 SKILL.md 指令
- **成熟度信号**：≥3 次真实使用、3 天无修复、结构合规、无泄露
- **Escalation**：连续 2 次同问题 → 停止补丁，重新审视；3+ 次不同问题 → 可能需要重设计

### 4. 公共 registry
Supabase 后端，零配置。离线核心 100% 可用（创建、反思、评测）。Publisher identity 首次发布自动生成。

## 架构

```
.claude/skills/skill-dev/
├── SKILL.md          # 路由层（≤150 行）
├── scripts/          # publish, search, install, merge, review, audit, uninstall
├── references/       # 按场景深度文档（reflect-mode, eval-mode, maturity, merge, publish, search, structure）
└── setup.sql         # Supabase schema（自建 registry 用）
```

Progressive loading: 50 个 skill 的上下文开销 = 1 个（metadata ~100 words 常驻，SKILL.md 触发时加载，references 按需加载）。

## 与生态的关系

| 维度 | skill-evolution | [[openspace]] | Kagura/OpenClaw |
|------|----------------|---------------|-----------------|
| 层次 | 顶层管理（lifecycle） | 底层引擎（auto-evolve） | 手动 + nudge |
| 版本 | Fork 变体 | Lineage tracking | Git |
| 进化 | 反思→成熟度→发布 | FIX/DERIVED/CAPTURED | beliefs-candidates→DNA |
| 合并 | Agent 语义 merge | 无 | 无 |
| Registry | Supabase 公共 | open-space.cloud | ClawHub |
| 宿主 | Claude Code | Any (MCP) | OpenClaw |

**互补关系**：OpenSpace 解决"skill 怎么自动变好"，skill-evolution 解决"skill 怎么管理和流通"。

## 与我们方向的关联

1. **Determinism ladder** 很有价值——我们的 beliefs-candidates 和 SKILL.md 混在一起，没有"能脚本化就不靠 prompt"的分层原则
2. **Fork 变体**比 git branch 更适合 agent skill——同一个 skill 不同 agent 可以有不同最优版本
3. **反思管线**跟我们的 nudge + beliefs-candidates → DNA 升级异曲同工，但更结构化（有 escalation 机制、impact scan）
4. **成熟度信号**可以借鉴——我们的 beliefs-candidates 升级 DNA 的标准是"重复 3 次"，缺乏"稳定期"和"真实使用次数"的量化

## 可移植的设计

- [x] **Determinism ladder** → 加到 skill-creator 的审查标准（2026-04-10, references/determinism-audit.md）✅ 5-level maturity ladder 已集成
- [ ] **Escalation 机制** → 加到 nudge 反思：连续 2 次同问题 → 升级为结构性问题
- [ ] **Maturity signals** → beliefs-candidates 升级标准增加"稳定期"维度
- [ ] **Progressive loading** → OpenClaw skill injection 已有类似机制，确认对齐

See also: [[openspace]], [[skill-is-memory]], [[skill-injection-via-hooks]], [[skillfoundry]]
