---
title: Self-Evolution Architecture
created: 2026-03-23
source: Luna conversation — full system review
modified: 2026-03-23
---
Kagura 的自进化体系全貌。

## 触发层

| 触发器 | 频率 | 做什么 | 状态 |
|--------|------|--------|------|
| **nudge** | 每 5 次 agent_end | 4 步轻量反思：记事→记错→记反馈→记笔记 | ✅ |
| **daily-review** | 每天 3:00 AM cron | 7 步深度审计：工具→战略→DNA→审计→修正→日志→提案 | ✅ |
| **reflect workflow** | session 重置 / 手动 | 3 步：review→think→act | ✅ |
| **heartbeat** | 每 30 分钟 | 读 HEARTBEAT.md 执行 | ❌ bug #47282 |
| **Luna 对话** | 随时 | TextGrad：反馈→gradient→beliefs-candidates | ✅ |

## 进化管线

```
Luna 反馈 / 犯错 / 打工经验 / 学习洞察
              ↓
     ┌────────┴────────┐
     ↓                 ↓
  行为级              知识级
     ↓                 ↓
beliefs-candidates   knowledge-base/
     ↓               ├── projects/  (项目笔记，[[双链]])
  重复 3 次            ├── cards/    (概念卡片，[[双链]])
     ↓                └── grep 全库搜索
  DNA 升级
  (SOUL/AGENTS/NUDGE/HEARTBEAT)
```

## 知识层

| 仓库 | 存什么 | 写入时机 | 读回时机 |
|------|--------|---------|---------|
| **knowledge-base/projects/** | 项目级笔记 | study note / workloop reflect | workloop study 开始前先读 |
| **knowledge-base/cards/** | 原子概念（双链） | study reflect / reflect act | study deep_read 先 grep 全库 |
| **beliefs-candidates.md** | 行为 gradient | nudge / workloop reflect | daily-review dna_review 检查 |
| **DNA 文件** | 核心信念和规则 | 重复 3 次后升级 | 每次 session 启动读 |
| **memory/日期.md** | 日志 | 随时 | session 启动读当天+昨天 |
| **evolution-log/** | 审计原始记录 | daily-review write_log | daily-review 回顾 |

## 工作流（FlowForge）

| Workflow | 核心路径 | 沉淀产出 |
|----------|---------|---------|
| **workloop** | followup→find→study→implement→submit→verify→reflect→done | projects/ + beliefs-candidates |
| **study** | entry→scout/followup/apply→deep_read→note→reflect→done | projects/ + cards/ + beliefs-candidates |
| **review** | tool→strategy→dna→audit→fix→log→propose | evolution-log + 提案给 Luna |
| **reflect** | review→think→act / silent | cards/ + memory + DNA |

## 质量保障

- **审计员**：daily-review spawn 独立 agent 校验
- **fix 步骤**：逐条处理审计反馈
- **数据纪律**：标注 [已验证/未验证]
- **propose 模式**：Luna 确认后才执行进化动作

## 工具链

- **FlowForge**: 强制工作流（start / next --branch N）
- **memex CLI**: write（创建卡片）+ links（双链分析）
- **gogetajob**: 打工记账 + PR 追踪
- **grep**: 全库知识搜索
- **git**: 版本控制（knowledge-base、evolution-log、dna）

See also [[self-evolution-problem]], [[mechanism-vs-evolution]], [[knowledge-needs-upgrade-path]], [[eval-driven-self-improvement]]
