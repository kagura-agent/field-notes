---
title: "PRM Scoring for Nudge — 评估笔记"
created: 2026-04-12
source: "SkillClaw PRM scorer analysis + apply study #150"
tags: [self-evolution, nudge, evaluation, skillclaw]
---

# PRM Scoring for Nudge — 可行性评估

## SkillClaw 的 PRM 方案

Process Reward Model scoring：用 LLM 对 session 中每个 turn 评分 +1/0/-1（helpful/unclear/unhelpful），majority voting（prm_m 次取多数），作为 skill 进化的量化信号。

### 它解决什么问题
- 人类不可能给每个 turn 反馈，自动评分提供连续信号
- 从"binary feedback"（成功/失败）升级为"process feedback"（每步质量）
- 为 aggregate 阶段提供数据：同一 skill 在多个 session 的平均分

## 我们的 Nudge 现状

| 维度 | 当前 | PRM 能补充的 |
|------|------|-------------|
| 触发 | agent_end hook（每 5 次） | 每次 session 都评 |
| 粒度 | session 级（有/没有 gradient） | turn 级（每步打分） |
| 量化 | 无数字指标 | +1/0/-1 per turn → avg score |
| 信号类型 | 行为纠正（gradient） | 执行质量（客观度量） |

## 评估结论

### 👍 值得借鉴的思路
1. **Session 质量评分**：每个 session 结束后算一个 overall score（不需要 per-turn），作为 skill-trajectory 的数据源
2. **区分 skill/agent/env**：PRM 评分低不一定是 skill 的锅，SkillClaw 强调 attribution 很重要

### 👎 不值得现在做的
1. **Per-turn scoring**：我们是单 agent，每天 ~50 个 session。per-turn 评分的 LLM 调用成本太高（每个 turn 调 prm_m 次），数据量也不够做统计
2. **Majority voting**：同理，单 agent 不需要这么精确的评分
3. **自动化 evolve pipeline**：SkillClaw 的 Summarize→Aggregate→Execute 需要大量 session 数据，我们还在 Phase 0 手动阶段

### ✅ 可行的轻量方案

在 nudge 中增加一个**session quality signal**（不是完整 PRM，而是受 PRM 启发的简化版）：

```
## 6. Session Quality Signal
快速判断本 session 整体质量：
- ✅ 顺利完成，无浪费（score: +1）
- ⚠️ 完成但有弯路/重试（score: 0）
- ❌ 失败或严重浪费（score: -1）
记录到 memory：`[session-quality: +1/0/-1] 一句话原因`
```

这个信号：
- 零额外 LLM 调用（nudge 已经在分析 session，顺便判断）
- 可以 feed 进 skill-trajectory（哪个 skill 参与的 session 质量如何）
- 积累足够数据后可以做 skill 级别的质量分析

### 时机

**暂不改 NUDGE.md**。原因：
1. Skill-trajectory Phase 0 还在手动试跑（W16 才评估）
2. 没有消费端——session quality signal 现在记了也没地方用
3. 等 Phase 0 确认 trajectory 数据有价值后，Phase 1 一起加

**行动项**：
- [ ] W16 eval 时如果 trajectory 有价值，在 Phase 1 中把 session quality signal 加入 nudge
- [ ] 同时加入 conservative-skill-editing 协议到 nudge 的 skill 改进判断中

## 关联
- [[conservative-skill-editing]] — 配套的编辑协议
- [[skillclaw]] — 来源项目
- [[skill-trajectory-tracking]] — Phase 0 正在试跑
