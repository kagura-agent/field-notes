---
title: "SkillClaw Phase 0 — W16 Evaluation"
created: 2026-04-13
source: "study apply #182 — W16 eval checkpoint"
tags: [self-evolution, skills, evaluation, skillclaw, phase-0]
---

# SkillClaw Phase 0 — W16 Evaluation

## 背景

Phase 0 启动于 2026-04-12（study apply #150），目标是手动试跑 skill usage tracking 1 周，W16 评估数据价值以决定是否进入 Phase 1（nudge 自动化集成）。

## 数据收集情况

| 日期 | 数据? | 来源 |
|---|---|---|
| 04-12 | ✅ | 手动创建 skill-trajectories/2026-04-12.md |
| 04-13 | ✅ | 本轮 eval 补充创建 |
| 04-07~11 | ❌ | Phase 0 未启动（04-12 才开始） |

**实际试跑时间**: 2 天（非计划的 7 天），且第 2 天数据是 eval 时才补充的

**问题**: daily-review 流程没有被修改来包含 skill usage tracking，所以自然不会产生数据。Phase 0 的"手动记录"依赖人记得做，而 cron 流程没有提示——典型的"设计了但没接入执行链"。

## 数据价值评估 (基于 2 天数据)

### 有价值的发现

1. **Tier 信号清晰**: flowforge/github/pulse-todo 是 always 候选（两天都高频），coding-agent 是 burst 使用（discoverable）。这对 skill-lazy-loading PR（#65139 tier frontmatter）有直接指导意义

2. **失败模式可见**: gogetajob SIGKILL（04-13 新发现）、coding-agent OOM（04-12）、agent-memes 0 发送（两天一致）。手动统计确实能暴露问题

3. **使用趋势一致**: 2 天数据虽少，但 top-3 skill 使用排名完全一致（flowforge > github > pulse-todo），说明模式稳定

### 价值不足的方面

1. **2 天样本不够做统计**: 无法判断是否代表常态还是 high-density day bias（04-12 和 04-13 都是超高产日）
2. **手动记录不可靠**: 依赖"记得做"，没有流程保障，自然断档
3. **粒度粗糙**: "~20 invocations" 这种估算值无法做精确分析
4. **无法区分直接使用 vs 间接触发**: flowforge 是被 cron 触发的，不是人决策使用的

## 决策

### Phase 1 是否启动？ → **暂不启动，改进 Phase 0 先**

理由：
1. Phase 0 的失败不是"数据没价值"，而是"采集流程没接入"。没法从失败的执行中判断设计是否有效
2. 2 天数据已经产生了有用的 tier 信号和失败模式发现——说明方向对
3. 但 Phase 1（nudge 自动化）的 ROI 还无法判断：nudge 每 5 次触发一次，而 skill 使用可能更频繁，数据可能不完整

### 改进方案

**将 Phase 0 数据采集从"手动记得"改为"daily-review 标准步骤"**：
- 在 review.yaml 的 memory hygiene 节点加一个检查项："检查今天 memory 日志，统计 skill 使用情况，写入 skill-trajectories/YYYY-MM-DD.md"
- 这样 daily-review cron (03:00) 会自动提示统计

**延长 Phase 0 到 W18** (~04-27)：
- 需要至少 7 天有效数据才能做 Phase 1 决策
- W18 eval 时有 ~14 天数据（预期 ~10 天有效）

### Phase 1 启动条件 (W18 eval 时检查)

1. ≥7 天有效数据
2. Tier 信号是否跨天稳定（还是被 daily 任务类型主导）
3. 失败模式追踪是否实际导致了改进行动
4. 手动采集成本是否可接受（每天 <5 分钟）

## 已完成的 SkillClaw 应用

| 项 | 状态 | 输出 |
|---|---|---|
| Conservative editing protocol | ✅ 完成 | wiki/cards/conservative-skill-editing.md |
| PRM scoring eval | ✅ 完成 | wiki/cards/prm-scoring-nudge-eval.md（结论：轻量 session quality signal 可行，defer to Phase 1）|
| Phase 0 skill trajectory | ⏳ 延长 | 2 天数据，改进采集流程后延长到 W18 |
| SkillClaw Hermes support (#1) | 👀 观察 | 无进展（repo 04-10 初始化后无新 commit）|

## 上游 SkillClaw 状态

- Stars: 404 → 483 (+79, 3 天)
- Commits: 仅初始化 1 个 commit（04-10）
- Issues: 3 open（#1 Hermes support, #2 CI, #3 "有用过的没？效果咋样？"——社区也在问同样的问题）
- 判断：项目仍在早期，无实际用户反馈，观察

## 关联
- [[skill-trajectory-tracking]] — Phase 0 设计文档
- [[conservative-skill-editing]] — 已应用的编辑协议
- [[prm-scoring-nudge-eval]] — PRM 可行性评估
- [[skillclaw]] — 来源项目
