---
title: Agent Ecosystem Scout - March 25 2026
created: 2026-03-25
source: GitHub trending + web search + arxiv
---

## GitHub Trending 本周 Top 10

1. **everything-claude-code** (105k⭐, +22k/周) — agent harness 性能优化系统，skills/memory/security
2. **superpowers** (111k⭐, +19k/周) — agentic skills framework & 开发方法论
3. **project-nomad** (15.5k⭐, +12k/周) — 离线生存 AI 电脑
4. **deer-flow** (44k⭐, +10k/周) — 字节跳动的 SuperAgent harness（research + code + create）
5. **MiroFish** (42k⭐, +10k/周) — 群体智能引擎
6. **MoneyPrinterV2** (25k⭐, +9.3k/周) — AI 自动赚钱
7. **TradingAgents** (41k⭐, +7.8k/周) — 多 agent 金融交易框架
8. **claude-hud** (12.8k⭐, +7.3k/周) — Claude Code 插件，显示上下文/工具/进度
9. **unsloth** (58k⭐, +3.9k/周) — 本地训练/运行开源模型
10. **MoneyPrinterTurbo** (53k⭐, +2.1k/周) — AI 生成短视频

## 关键趋势

### 1. Skills 生态爆炸继续
- everything-claude-code 105k⭐ 就是 skills 集合
- superpowers 111k⭐ 也是 skills 方法论
- 两者合计 216k⭐ — **skills 是本周最热话题**

### 2. 字节跳动入场
- deer-flow 44k⭐ — "SuperAgent harness"，有 sandbox/memory/tools/skills/subagents/message gateway
- 跟 OpenClaw 的能力非常重叠，但用 Python

### 3. Agent 记忆成为学术热点
- **MemSkill** (arxiv 2602.02474) — 把记忆操作变成可学习的 skills
  - controller 学习选择 skills，executor 用 skills 生成记忆，designer 周期性进化 skill set
  - 跟我们的 self-improving 机制思路一致：learnable memory management
  - 代码: github.com/ViktorAxelsen/MemSkill
- **GitHub Copilot memory system** — 跨 agent 记忆（coding agent → code review agent）
  - 每次交互教 Copilot 更多关于 codebase 的知识
  - 重点：cross-agent memory，不是单 agent 记忆

### 4. NVIDIA 全力押注 agent
- NemoClaw = NVIDIA 版 OpenClaw（GTC 发布）
- OpenShell runtime = agent 安全沙箱（Apache 2.0）
- `openshell sandbox create --remote spark --from openclaw` 一条命令跑 OpenClaw/Claude Code/Codex
- 关键词：self-evolving agents + safety + policy-based guardrails

### 5. Agent = 新货币
- MoneyPrinter 系列持续火爆（2个项目合计 78k⭐）
- TradingAgents 41k⭐ — agent 做交易
- 钱在流向"agent 直接创造经济价值"

## 跟我们的对比

| 方向 | 业界 | 我们 |
|------|------|------|
| Skills 生态 | 爆发（105k⭐ everything-claude-code） | 有 self-improving skill，但不在生态里 |
| Agent 记忆 | MemSkill（可学习的记忆 skills）、Copilot cross-agent memory | beliefs-candidates + self-improving + MEMORY.md |
| Agent 安全 | NVIDIA OpenShell（沙箱 + 策略） | 没有 |
| Agent 通信 | AgentMail、lobster-post | lobster-post（最简方案） |
| Agent 经济 | TradingAgents、MoneyPrinter | gogetajob（概念验证） |
| 自进化 | MemSkill designer 进化 skill set | DNA 自治 + nudge + daily-review |

## 值得深入研究

1. **MemSkill** — 跟我们做的事最近：memory 操作变 skills，controller + executor + designer 闭环
2. **deer-flow** — 字节的 SuperAgent，看看它的 memory 和 skills 设计
3. **NVIDIA OpenShell** — agent 安全运行时，可能跟 OpenClaw 有整合机会

[[agent-marketplace-landscape]] [[self-evolving-agent-landscape]]
