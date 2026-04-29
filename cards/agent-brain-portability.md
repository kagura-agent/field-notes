---
title: Agent Brain Portability
slug: agent-brain-portability
created: 2026-04-17
tags: [agent, architecture, memory, portability]
---

# Agent Brain Portability

Agent 的知识和经验不应绑定在特定 harness（Claude Code、Cursor、Hermes）上。"大脑"（memory + skills + protocols）应该是可移植的。

## 实现光谱

| 方案 | 存储 | 复杂度 | 跨 harness |
|------|------|--------|-----------|
| 文件即一切（Kagura SOUL.md） | Markdown 文件 | 最低 | 需手动适配 |
| [[agentic-stack]] .agent/ | 结构化文件夹 + Python 工具 | 中等 | 7 种 harness adapter |
| [[gbrain]] | PGLite + dream cycle | 高 | 绑定 OpenClaw |
| [[reflexio]] | 独立服务 + SQLite + embedding | 最高 | API 集成 |

## 核心洞察

1. **Adapter 层可以极简**：agentic-stack 的 harness adapter 只是一个 AGENTS.md 文件。因为所有主流 harness 都能读 markdown，所以适配成本接近零
2. **标准化文件结构 > 复杂 API**：可移植性的关键不是协议，而是约定俗成的文件布局
3. **Dream cycle 不需要 LLM**：Jaccard 聚类 + canonical extraction 够用，零 API 依赖

## 与 [[mechanism-vs-evolution]] 的关系

Brain portability 属于 mechanism 层——它定义结构，但不自动产生进化。进化（学习、改进）需要 dream cycle / nudge / reflexio 这些 evolution 层。两层正交：好的 mechanism 让 evolution 的成果可以迁移。

Links: [[agentic-stack]], [[gbrain]], [[reflexio]], [[nudge-over-workflow]], [[mechanism-vs-evolution]], [[dirac]]

## Update: Intra-Tool Surface Portability (2026-04-29)

Dirac v0.3.4 adds VSCode↔CLI task history unification — migrating tasks, checkpoints, settings from VSCode globalStorage to a shared `dataDir`. This is a **lower-level variant** of brain portability: not cross-harness, but cross-surface within the same tool.

Expands the portability spectrum:

| Level | Example | Complexity |
|-------|---------|------------|
| Same tool, different surfaces | Dirac VSCode↔CLI | Trivial (file migration) |
| Cross-harness, same files | agentic-stack .agent/ | Low (markdown adapters) |
| Cross-harness, structured storage | gbrain/reflexio | High (service layer) |

The Dirac case validates that even intra-tool portability is non-trivial enough to need a migration system (versioned, folder-by-folder copy).
