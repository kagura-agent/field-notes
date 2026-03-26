---
title: BEGIN vs IN Phase Memory Injection
created: 2026-03-26
source: MemEvolve code analysis
---

记忆注入应区分两个阶段：

## BEGIN 阶段（规划时）
- 注入长期记忆：战略指导、领域知识、过往教训
- 帮 agent 制定计划
- 频率：每个任务一次

## IN 阶段（执行时）
- 注入短期记忆：当前任务积累的关键信息
- 帮 agent 做实时决策
- 频率：每 N 步一次

## 我们的现状
- 只有 BEGIN（session 开始 + skill 触发时读 memory）
- 没有 IN（执行中途不自动注入）
- FlowForge 节点间不自动拉相关知识

## 可操作方向
- FlowForge 的 implement 节点在开始前自动读 `patterns/` 里相关标签的文件
- 等同于 MemEvolve 的 IN 阶段注入

## 相关
- [[write-read-gap]] — 这是 retrieve 层面的具体解法
- [[memevolve]] — 源自 MemEvolve 的 MemoryStatus.BEGIN/IN 设计
- [[skill-as-behavior-trigger]] — Skill 触发是 BEGIN 阶段的实现
