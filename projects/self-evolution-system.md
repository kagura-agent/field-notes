# Self-Evolution System — 全貌文档

> 概念索引见 [[self-evolution-architecture]] 卡片。本文是完整的实现细节。

## 一、触发层

| 触发器 | 频率 | 做什么 | 状态 |
|--------|------|--------|------|
| **nudge** | 每 5 次 agent_end | 4 步轻量反思：记事→记错→记反馈→记笔记 | ✅ 运行中 |
| **daily-review** | 每天 3:00 AM cron | 7 步深度审计：工具→战略→DNA→审计→修正→日志→提案 | ✅ 已配 |
| **reflect workflow** | session 重置 / 手动 | 3 步：review→think→act | ✅ FlowForge |
| **heartbeat** | 每 30 分钟 | 读 HEARTBEAT.md 执行 | ❌ bug #47282 |
| **Luna 对话** | 随时 | TextGrad：反馈→gradient→beliefs-candidates | ✅ 手动 |

## 二、进化管线

```
Luna 反馈 / 犯错 / 打工经验 / 学习洞察
              ↓
     ┌────────┴────────┐
     ↓                 ↓
  行为级              知识级
     ↓                 ↓
beliefs-candidates   knowledge-base/
     ↓               ├── projects/  (项目笔记，[[wikilinks]])
  重复 3 次            ├── cards/    (概念卡片，[[wikilinks]])
     ↓                └── grep 全库搜索
  DNA 升级
  (SOUL/AGENTS/NUDGE/HEARTBEAT)
```

## 三、知识层

| 仓库 | 存什么 | 写入时机 | 读回时机 |
|------|--------|---------|---------|
| **knowledge-base/projects/** | 项目级笔记（架构、坑、maintainer 风格） | study note / workloop reflect | workloop study 开始前先读 |
| **knowledge-base/cards/** | 原子概念（双链，理论框架） | study reflect / reflect act | study deep_read 先 grep 全库 |
| **beliefs-candidates.md** | 行为 gradient（待升级） | nudge step3 / workloop reflect | daily-review dna_review 检查 |
| **DNA 文件** | 核心信念和规则 | 重复 3 次后升级 | 每次 session 启动读 |
| **memory/日期.md** | 日志（发生了什么） | 随时 | session 启动读当天+昨天 |
| **evolution-log/** | 审计原始记录 | daily-review write_log | daily-review 回顾 |

## 四、工作流（FlowForge 强制）

| Workflow | 节点数 | 核心路径 | 沉淀产出 |
|----------|--------|---------|---------|
| **workloop** | 9 | followup→find→study→implement→submit→verify→reflect→done | projects/ + beliefs-candidates |
| **study** | 9 | entry→scout/followup/apply→deep_read→note→reflect→done | projects/ + cards/ + beliefs-candidates |
| **review** | 7 | tool→strategy→dna→audit→fix→log→propose | evolution-log + 提案给 Luna |
| **reflect** | 4 | review→think→act / silent | cards/ + memory + DNA |

## 五、质量保障

- **审计员**：daily-review 的 audit 节点 spawn 独立 agent 校验 review 结论
- **fix 步骤**：逐条处理审计反馈（认可附数据，不认可附证据）
- **数据纪律**：所有数据陈述标注 `[已验证]` / `[未验证]`（写入 AGENTS.md）
- **propose 模式**：review 只发现和提案，Luna 确认后才执行进化动作

## 六、工具链

| 工具 | 用途 | 实际使用的功能 |
|------|------|-----------------|
| **FlowForge** | 强制工作流节点顺序 | start / next --branch N |
| **memex CLI** | 概念卡片管理 | write（创建卡片）+ links（双链分析） |
| **gogetajob** | 打工记账 + PR 追踪 | scan/feed/start/submit/sync/stats |
| **grep** | 全库知识搜索 | grep -rl "关键词" knowledge-base/ |
| **git** | 版本控制 + 同步 | knowledge-base、evolution-log、dna |

## 七、关键设计决策

- **nudge 从 10 步精简到 4 步**（2026-03-23）：回归 Hermes 的简单触发初衷，重活留给 daily-review
- **field-notes + memex 合并为 knowledge-base**（2026-03-23）：分离是因为工具不同，不是知识需要分离
- **所有笔记用 [[wikilinks]]**（2026-03-23）：Obsidian 理念，知识是网不是树
- **grep 替代 memex search**（2026-03-23）：memex search 只搜 cards/，grep 搜全库。已提 issue #10
- **进化动作需 Luna 确认**（2026-03-23）：review 只发现和提案，不自动执行

---

See also [[self-evolution-architecture]], [[mechanism-vs-evolution]], [[knowledge-needs-upgrade-path]]

## Eval Pipeline (2026-03-23 新增)

从 [[hermes-self-evolution]] 学到的核心 gap：**evolution without eval is random mutation**。

### Minimum Viable Eval
不需要建 GEPA。只需要**计数已有数据**：

| 指标 | 数据源 | baseline (2026-03-23) | 趋势预期 |
|------|--------|----------------------|----------|
| PR merge rate | gogetajob stats | 73% | ↑ |
| Audit findings | evolution-log (daily-review) | ~15/day | ↓ |
| Repeat gradients | beliefs-candidates.md | 2 | ↓ |
| Total gradients | beliefs-candidates.md | 14 | 观察 |
| DNA graduations | AGENTS.md commit history | 1 | ↑ slowly |

### 记录时机
- daily-review write_log 节点自动记录（已加入 review.yaml）
- 每天 3:00 AM cron 执行

### 与 [[hermes-self-evolution]] 的差异
- Hermes: execution traces → GEPA optimizer → candidate variants → eval → PR
- 我们: Luna feedback → beliefs-candidates → repeat 3x → DNA upgrade → daily-review verify
- Hermes 是自动化的（$2-10/run），我们是半手动的（Luna 驱动 + cron 辅助）
- 但我们有他们没有的：**adversarial audit**（独立 agent 审计 review 结论）

See also [[evolution-needs-eval]], [[convergent-evolution]]
