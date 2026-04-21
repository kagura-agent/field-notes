---
title: "Skill Trajectory Tracking — 设计笔记"
created: 2026-04-12
source: "study apply — skillclaw.md + trajectory-informed-memory.md insights"
tags: [self-evolution, skills, tracking, design]
---

# Skill Trajectory Tracking

## 问题

我们的 self-evolution 系统有 beliefs-candidates（行为层 gradient）和 wiki（知识层），但**缺少 skill 级别的结构化反馈**。具体：

- 不知道哪个 skill 用得多、哪个 skill 经常失败
- beliefs-candidates 的 gradient 不按 skill 分组，难以定向改进
- 没有数据支撑 skill 的 tier 分配（always vs discoverable）
- 无法发现"该用 skill 但没用"的漏用模式

## 灵感来源

| 系统 | 做法 | 我们的对应 |
|---|---|---|
| SkillClaw | 结构化 trajectory per skill → agentic evolver | 无 |
| Trajectory-Tips (IBM) | 3 类 tip: task-specific / generalized / self-reflection | beliefs-candidates ≈ self-reflection only |
| 我们的 nudge | agent_end hook 分析 session → gradient | 不按 skill 分组 |

## 设计：轻量 Skill Usage Log

### 核心数据结构

```yaml
# wiki/skill-trajectories/YYYY-MM.yaml
github:
  invocations: 47
  outcomes:
    success: 41
    partial: 4
    failure: 2
  failure_patterns:
    - "gh auth token expired (×2)"
  last_used: 2026-04-12
  evolution_signals: []  # 积累到 3 条触发 skill review

coding-agent:
  invocations: 33
  outcomes:
    success: 28
    partial: 3
    failure: 2
  failure_patterns:
    - "Claude Code timeout on large codebase"
  last_used: 2026-04-12
```

### 记录时机

**不增加 runtime 开销**。利用已有的 hook：

1. **nudge (agent_end hook)** — 已有 session 分析逻辑，增加一步：识别本 session 用了哪些 skill，结果如何
2. **daily-review** — 月度汇总，更新 skill-trajectories/YYYY-MM.yaml
3. **手动标注** — 遇到 skill 明显失败时，在 memory 日志里标 `[skill:xxx:fail]`

### 应用场景

| 场景 | 用法 |
|---|---|
| **Skill tier 分配** | invocations 高 → always 候选 |
| **Skill 改进** | failure_patterns 重复 → 触发 skill-creator review |
| **进化盲区发现** | 长期 invocations=0 → 废弃候选或 description 需改进 |
| **SkillAnything eval** | 对比有/无 trajectory 信息时 skill 选择准确率 |

## 实施路径

### Phase 0: 手动试跑（本周）
- 在 daily-review 时手动统计当天 skill 使用情况
- 记录格式：`memory/YYYY-MM-DD.md` 加 `## Skill Usage` section
- 目的：验证数据是否有用，不值得就不自动化

### Phase 1: nudge 集成（如果 Phase 0 有价值）
- nudge 的 session 分析增加 skill 识别
- 自动追加到月度 yaml

### Phase 2: 闭环
- evolution_signals 积累 → 自动触发 skill review
- 与 skill-lazy-loading 的 tier 决策联动

## 与现有系统的关系

```
Session → nudge (agent_end)
              ↓
         skill 使用识别 → skill-trajectories/月度.yaml
              ↓                    ↓
    beliefs-candidates        skill tier 决策
    (行为层 gradient)      (lazy-loading PR)
              ↓
         DNA/Workflow/KB 升级
```

## 风险与取舍

1. **过度工程** — Phase 0 先手动验证，不值得就停
2. **识别准确率** — nudge 从 session 日志推断 skill 使用可能不准。缓解：只统计显式 `read SKILL.md` 的
3. **维护负担** — yaml 文件月度归档，不需要清理

## 决策

先做 Phase 0（手动试跑 1 周），下周 W16 daily-review 评估数据价值。

## Phase 1 Decision (04-21)

**SKIP / Deprioritize.** Phase 0 产出 2 天手动数据后自然停止。

理由：
1. 2 天数据确认了直觉（flowforge 主力、agent-memes 坏了），但未产生新行动
2. SkillClaw 的真正价值在设计 pattern，不在 tracking 数据——已全部吸收
3. Nudge 集成投入大，收益边际——我们只有 ~15 个 skill
4. Lazy-loading PR #65139 已关闭，tier 数据无消费端
5. 手动记录 2 天就停 = 数据价值不足以驱动持续投入

如果未来 skill 数量显著增长或 lazy-loading 重启，可重新评估。
