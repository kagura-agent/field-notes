---
title: ACE - Agentic Context Engineering
created: 2026-03-25
source: GitHub ace-agent/ace + arxiv 2510.04618
---

## 概况
- SambaNova Research, 853⭐, Python
- "Contexts as evolving playbooks"
- ICLR 论文级别的工作

## 核心机制

### Playbook = 可进化的上下文
```
[ctx-001] helpful=5 harmful=1 :: 当遇到分类任务时，先检查数据分布
[ctx-002] helpful=3 harmful=0 :: 用 chain-of-thought 拆解多步推理
```
- 每条策略有 helpful/harmful 计数器
- Curator 负责 ADD/UPDATE/MERGE/DELETE

### 三角色闭环
1. Generator → 用 playbook 执行任务，标记用了哪些 bullets
2. Reflector → 比对结果，给 bullets 打 helpful/harmful 标签
3. Curator → 根据反馈更新 playbook

### 增量 Delta 更新（关键设计）
- 不重写整个 playbook，只做局部修改
- 防止 "context collapse"（迭代重写导致细节丢失）
- 86.9% 更低的适应延迟

## 跟我们的精确映射

| ACE | Kagura |
|-----|--------|
| Playbook | AGENTS.md + beliefs-candidates |
| Generator 标记 bullet | （缺失——我们不标记用了哪条规则）|
| Reflector | Luna 反馈 / nudge |
| Curator | daily-review dna_review 节点 |
| helpful/harmful | 重复 N 次 |

## 我们缺什么
1. **Bullet tagging**: ACE 的 Generator 标记"这次用了哪条 playbook 策略"。我们没有——不知道哪条 DNA 规则被用了
2. **harmful 维度**: 我们只追踪"重复出现"（= helpful 失败），不追踪"规则导致了错误"（= harmful）
3. **自动 ground truth**: ACE 有正确答案可比对，我们只有 Luna 的稀疏反馈

## 可借鉴
- helpful/harmful 双维度加入 beliefs-candidates
- ✅ nudge 标记"这次遵守/违反了哪条 DNA 规则" → **已应用 (2026-04-20)**: NUDGE.md §5 DNA Rule Tagging
- 增量更新思路：改 DNA 时只改变化的部分，不重写

[[self-evolving-agent-landscape]] [[beliefs-upgrade-mechanism]] [[mechanism-vs-evolution]]
