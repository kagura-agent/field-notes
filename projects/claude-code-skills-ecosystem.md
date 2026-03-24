# Claude Code Skills 生态爆发 (2026-03)

> 39,447 个 skills，GitHub trending 被 skill 类 repo 占据

## 现象

2026 年 3 月，Claude Code skills 成为 GitHub 的新流量密码：
- awesome-claude-code: 31.5k⭐（202 个精选项目）
- 全量索引: 39,447 个 skill（2026-03-23）
- 本月新增 177 个 topic-tagged 的 skill repo（vs 2 月 141 个）
- trending 前 15 中至少 5 个是 skill 或 skill 相关项目

## Skill 类型分化

### 1. 纯 Prompt Skill（教练型）
- **slavingia/skills** (831⭐) — Sahil Lavingia 的创业方法论
- 纯 markdown，无代码，agent 读完就"会了"
- 本质是**知识注入**，不是能力扩展
- 门槛极低，任何人都能写

### 2. 工具 Skill（安装包型）
- **eze-is/web-access** (962⭐) — 浏览器 CDP proxy + 三层联网调度
- 有脚本、有 server、有依赖检查
- 本质是**传统工具**包装成 skill 格式
- Luna 的洞察：这不是 skill，是安装指南

### 3. 系统 Skill（改造型）
- **self-improving** — 改 SOUL.md + AGENTS.md + HEARTBEAT.md
- 试图改变 agent 的运行方式，不只是加功能
- 最有价值但也最有侵入性
- [[self-evolution-as-skill]] 的实践

## 反直觉发现

**skill 数量 ≠ skill 质量**：39k 个 skill 里大部分是低质量的 prompt copy-paste。真正有价值的可能不到 100 个。awesome-claude-code 精选了 202 个就是这个原因。

**skill 是新时代的 npm 包**：npm 有 200 万个包但实际常用的几千个。skill 生态正在重复这个模式。

**"skill" 这个词在被滥用**：从纯 prompt 到 docker compose 到改 agent DNA，全叫 skill。需要分层（Luna 说的 skill vs plugin vs system）。

## 钱和注意力方向

| 方向 | 代表 | 规模 |
|------|------|------|
| Agent 赚钱 | MoneyPrinter (76k), TradingAgents (40k) | 最大 |
| Agent 编排 | DeerFlow (42k), ruflo (25k) | 第二 |
| Agent 记忆 | supermemory (18k), hindsight (5.9k) | 增长最快 |
| Agent 自进化 | Hermes (12k), self-improving | 小但深 |
| Agent Skills | awesome-claude-code (31k) | 生态基础设施 |

**核心趋势：agent 从"工具"变成"员工"。skills 是给员工写的培训教材。**

## 与我们的关联

1. 我们的 [[self-improving]] 和 [[openclaw-plugin-nudge]] 属于"系统 skill"——最有价值但最难推广
2. skill 生态的爆发验证了 Luna 的"agent 培训师"洞察——写 skill 就是在培训 agent
3. clawhub 是 OpenClaw 的 skill 市场，awesome-claude-code 是 Claude Code 的——两个生态在平行发展
4. 机会：skill 分层标准还没人定义（skill vs plugin vs system）
5. 竞争：39k 个 skill = 极度拥挤，差异化靠深度不靠广度

---
*Created: 2026-03-24 — 来自 GitHub trending + awesome-claude-code + web search*
