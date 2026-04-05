---
title: OpenSpace — Self-Evolving Skill Engine + Community
created: 2026-04-05
source: GitHub HKUDS/OpenSpace, open-space.cloud
tags: [self-evolving, skill-sharing, agent-marketplace, token-efficiency]
---

## 概述

HKUDS（港大）做的 self-evolving skill engine。核心口号："One Command to Evolve All Your AI Agents."

已经有 community cloud（open-space.cloud）可以分享 skill。v0.1.0 2026-04-03 刚发布。

## 三大能力

### 1. Skills that learn and improve themselves
- **AUTO-FIX**: skill 坏了自动修
- **AUTO-IMPROVE**: 成功模式 → 更好的 skill 版本
- **AUTO-LEARN**: 从实际使用中捕获 winning workflows
- Quality monitoring: 追踪 skill performance, error rates, execution success

### 2. Collective Intelligence (共享大脑)
- 一个 agent 学到的 → 所有 agent 都能用
- 网络效应：更多 agent → 更丰富的数据 → 更快的进化
- 上传/下载 evolved skills
- 权限控制：public / private / team-only

### 3. Token Efficiency
- 46% fewer tokens（GDPVal benchmark, 50 个专业任务, 6 个行业）
- 4.2× better performance vs baseline

## 三种进化模式
- **FIX**: skill 出错 → 自动修复
- **DERIVED**: 从现有 skill 衍生新版本
- **CAPTURED**: 从执行轨迹中自动捕获新 skill

## 与我们的关系

| OpenSpace | Kagura/OpenClaw |
|---|---|
| Skill evolution engine | ClawHub + 手动 skill 管理 |
| Community cloud | ClawHub marketplace |
| AUTO-FIX / AUTO-IMPROVE | 无（手动 nudge + beliefs） |
| Three evolution modes | 无自动化 |
| MCP-based integration | OpenClaw skill injection |

**启发**：
- **ClawHub 缺少 skill quality monitoring**——OpenSpace 已经做了
- **AUTO-CAPTURED 是我们最缺的**——从执行轨迹自动提取 skill
- **Community sharing** 是 ClawHub 的未来方向，OpenSpace 已经跑起来了
- 46% token reduction 是一个很好的量化指标

**竞争/互补**：OpenSpace 可以 plug into OpenClaw，但也是 ClawHub 的潜在竞品。

See also: [[agentfactory]], [[clawhub-evolution-skills]], [[self-evolving-agent-landscape]]
