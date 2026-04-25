---
title: Agent Skill 标准收敛
slug: agent-skill-standard-convergence
tags: [agent-ecosystem, standards, skills, infrastructure]
created: 2026-04-25
---

# Agent Skill 标准收敛

2026年4月观察到的关键趋势：agent skill 格式正在从各自为政向统一标准收敛。

## 三层标准化

| 层 | 标准 | 解决的问题 |
|---|------|-----------|
| Agent 定义 | [[gitagent-protocol]] (GAP) | 怎么定义整个 agent |
| Skill 格式 | [[agentskills-io-standard]] | 怎么写一个 skill |
| Skill 分发 | ClawHub / npm | 怎么找到和安装 skill |

## 核心观察

1. **SKILL.md 是共识**：几乎所有方案都采用 SKILL.md + YAML frontmatter + progressive disclosure
2. **格式已经趋同**：OpenClaw/ClawHub、GAP、agentskills.io 的 skill 目录结构几乎完全一致
3. **分发层是空白**：标准定义了格式，但没有解决发现、版本管理、依赖解析
4. **Progressive disclosure 是通用模式**：metadata (~100 tokens) → instructions (<5K) → resources (按需)

## 类比

Skill 之于 Agent ≈ npm package 之于 Node.js app
- 格式标准 = package.json spec
- 分发平台 = npm registry
- 目前有了格式标准，缺分发平台（ClawHub 的机会）

## 战略含义

- 不要重新发明 skill 格式——拥抱已有共识
- 聚焦分发层的差异化（版本管理、安全审计、依赖解析）
- 合规层（[[gitagent-protocol]] 方向）是企业市场的入场券

## 链接

- [[agents-md]] — 另一个 file-based agent config 标准
- [[mercury-agent]] — memory 层的标准化尝试
