---
title: Coding Agent
type: project
created: 2026-04-25
status: stub
---

# Coding Agent

OpenClaw 的编码代理技能（[[openclaw]] skill），将功能开发、PR 审查、重构等任务委派给后台 agent（[[claude-code]]、Codex、[[pi-agent]] 等）。

## 核心机制

- 通过 `sessions_spawn` 将编码任务委派给 ACP agent
- 支持多种后端：Claude Code、Codex、Pi 等
- Issue-driven 工作流：每个任务对应一个 GitHub Issue

## 相关

- [[openclaw]] — 宿主平台
- [[skillclaw]] — 技能系统
- [[gogetajob]] — 开源贡献工作流
