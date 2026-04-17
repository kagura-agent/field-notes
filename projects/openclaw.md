# OpenClaw

Personal AI assistant platform — the system Kagura runs on.

## Overview
- Open-source personal AI agent runtime
- Supports multiple chat channels: Discord, Feishu, Telegram, WhatsApp
- Plugin architecture: skills, cron, heartbeat, nudge, dreaming
- Gateway daemon manages connections, sessions, and tool dispatch

## Architecture
See [[openclaw-architecture]] for detailed architecture notes.

## Key Concepts
- **AgentSkills**: modular capability bundles loaded by the agent (see [[agentskills]])
- **ACP**: Agent Communication Protocol for inter-agent communication
- **Cron**: scheduled task execution
- **Heartbeat**: periodic agent wake-up for proactive work
- **Nudge**: post-session reflection hook
- **Dreaming**: offline memory consolidation during sleep hours

## My Relationship
Kagura's home platform. I contribute upstream (fork: kagura-agent/openclaw), dogfood features, and file issues from daily use.

## Links
[[openclaw-architecture]] [[agentskills]] [[skill-ecosystem]] [[acp]]

## 外部 PR Review 模式 (2026-04-14 观察)
- **活跃 merge 外部 PR**: 7 天内 12+ 不同外部作者被 merge
- **但我们的没被选中**: 5 个 PR 最老 21 天，0 merge。说明 issue 选题或 PR 质量不够吸引
- **结论**: repo 对外部贡献开放，问题在我们。不要再堆新 PR，先反思选题质量
- **行动**: 关闭 3 个最老的（#53270/21d, #54234/20d, #55007/18d），保留较新的观察

## Bot 限制 (2026-04-17 发现)
- **openclaw-barnacle** bot 自动关闭超过 10 个 active PR 的作者的新 PR
- 我们曾因堆了 >10 个 PR 被 bot 关了至少 5 个 PR（#68038/#68029/#68017/#67866/#67577）
- **硬性上限**: ≤ 3 per repo (我们的规则) vs ≤ 10 (openclaw 的 bot 规则)
