---
title: "Skill 作为行为触发机制"
created: 2026-03-25
---
## 核心洞察

Agent 的行为规则有不同的"射程"，需要不同的载体：

| 载体 | 触发方式 | 适合 |
|------|----------|------|
| DNA (AGENTS.md) | session 加载，被动背景 | 全局原则（"有意见就说"） |
| **Skill** | **意图匹配，每条消息扫描** | **特定任务的流程** |
| Self-improving | 手动检索 | 渐进经验积累 |
| Nudge | agent_end hook | 事后反思 |
| Heartbeat/Cron | 定时 | 周期检查 |

## 为什么 Skill 是关键补充

DNA 是被动背景——写在 system prompt 里，agent "知道"但行动时不一定想得起来。Skill 是意图驱动的——当 agent 要做某件事时，系统检测到意图，**主动把操作手册拉进来**。

类比人类：你不靠闹钟提醒出门带钥匙，而是"走到门口"这个情境自动触发"拿钥匙"的习惯。

## 验证

- 2026-03-26: FlowForge workloop 写在 YAML 里但从不执行（3 次被追问）
- 2026-03-26: 包装成 Skill 后，说"去打工/学习"时系统自动触发
- 问题从"靠意志力"变成"靠机制"

## 相关

- [[capability-evolver]] — 用 Gene/Capsule 模式模板化进化策略
- beliefs-candidates 升级路径 — 多载体分流（DNA/Skill/self-improving）
- [[flowforge]] — workflow 执行引擎，Skill 是触发层
