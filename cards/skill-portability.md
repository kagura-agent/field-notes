---
slug: skill-portability
title: Skill Portability — 跨模型跨 Harness 的 Skill 适配
created: 2026-04-19
tags: [agent-infra, skills, portability]
---

# Skill Portability

Agent skill 的可移植性问题正在成为独立赛道（2026-04 观察）。

## 两个维度

1. **跨 harness**：同一个 skill 在 Claude Code / Cursor / OpenClaw / Hermes 上都能用
   - [[agentic-stack]] 的方案：标准化文件结构（.agent/ 目录），adapter 层极简
   - 关键洞察：所有 harness 都能读 markdown，适配成本接近零

2. **跨 model**：同一个 skill 在 Opus / Sonnet / Qwen / GPT-4o 上效果一致
   - [[skvm]] 的方案：profile 模型能力 → AOT 编译 skill → JIT 优化
   - 关键洞察：skill 有隐含的"指令集假设"（长上下文、推理深度、工具调用格式），跨模型时这些假设可能不成立

## 与 [[mechanism-vs-evolution]] 的关系

skill portability 是 mechanism 派的典型产物 — 通过编译器/VM 这种精确机制解决适配问题。evolution 派的做法会是让 agent 在使用中自动适应模型（更像 JIT 部分）。

## 对我们的影响

我们的 14+ 个 skill 目前假设"一份 SKILL.md 通吃"。如果切换模型（Opus → GLM），skill 效果可能显著下降。SkVM 是潜在解决方案。
