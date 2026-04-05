---
title: AgentFactory — Self-Evolving via Executable Subagent Accumulation
created: 2026-04-05
source: arxiv 2603.18000, GitHub zzatpku/AgentFactory
tags: [self-evolving, skill, code-as-memory, subagent]
---

## 概述

AgentFactory 提出一个范式转换：把成功的任务解决方案保存为**可执行的 subagent 代码**，而不是文本经验（prompt/reflection）。

核心 insight：text descriptions of how to solve a task don't guarantee reliable re-execution in complex scenarios. **Code > Text** for skill preservation.

## 三阶段流程

1. **Install**：分解任务 → 从零构建 Python subagent → 保存为 .py + SKILL.md
2. **Self-Evolve**：遇到相似任务 → 检索已存 subagent → 执行反馈 → 修改代码 → 更健壮
3. **Deploy**：成熟的 subagent 导出为独立 Python module，带标准化文档，可跨系统使用

## 架构

- **Meta-Agent**: 顶层编排器，任务分解 + 工具分配 + 代码修改
- **Skill System**: 三层
  - Meta Skills: create_subagent, run_subagent, modify_subagent 等
  - Tool Skills: web_search, browser, shell 等
  - Subagent Skills: 动态创建的 Python 模块
- **Workspace Manager**: 隔离执行环境，防止 skill library 损坏

## 数据

- 30 个真实任务（两批），Opus 4.6 + Sonnet 4.6
- Batch 2 复用 subagent 时，orchestration token **减少 57%**（对比 ReAct）
- 即使 Batch 1 内部，Opus 也能识别复用机会

## 与我们的关系（极高相关性！）

| AgentFactory | Kagura/OpenClaw |
|---|---|
| Subagent code as skill | Skill files (SKILL.md + scripts) |
| Meta-agent orchestrator | FlowForge + subagent spawning |
| SKILL.md documentation | ClawHub skill specification |
| install → self-evolve → deploy | Manual skill creation → ClawHub publish |
| Automated code synthesis | Human-guided (Luna) + Claude Code |

**关键差异**：
1. AgentFactory 的 skill 是**自动生成**的（LLM 写代码），我们的是**手动/半自动**
2. AgentFactory 用**执行反馈**自动 refine，我们用 nudge + beliefs-candidates
3. AgentFactory 的 SKILL.md 跟 OpenClaw 的 SKILL.md 格式**高度同构**！

**启发**：
- 我们缺少自动 skill extraction 的 pipeline（从任务执行 → 自动沉淀为 skill）
- `install → self-evolve → deploy` 可以映射到 OpenClaw 的 skill lifecycle
- Workspace Manager 的隔离设计值得借鉴

See also: [[self-evolving-agent-landscape]], [[skill-type-taxonomy]], [[metaclaw]]
