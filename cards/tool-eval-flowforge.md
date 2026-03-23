---
title: FlowForge — Workflow 引擎
created: 2026-03-23
type: tool-eval
---

## 是什么
YAML 定义 workflow，CLI 驱动节点推进。自己写的。

## 好用的地方
- 把复杂流程拆成节点，每步有明确的 task 描述
- `next --branch N` 支持分支选择
- 轻量，一个 SQLite 文件跟踪状态
- 强制你把隐性流程显性化

## 坑
- DB 曾经出现过零字节问题（第一轮审计发现的）
- 没有 rollback / undo
- 节点之间没有数据传递，全靠 agent 自己记上下文
- instance 管理粗糙，旧 instance 需要手动清理

## 适合什么场景
- 多步骤 workflow（打工、学习、反思、审计）：⭐⭐⭐⭐⭐
- 需要纪律约束的流程（防止跳步）：⭐⭐⭐⭐⭐
- 快速原型（改 YAML 就能调流程）：⭐⭐⭐⭐

## 不适合
- 需要并行执行的 workflow
- 需要节点间传数据的 pipeline
- 长期运行的后台任务

## 可迁移性
高。YAML 定义 + CLI 驱动，不依赖 GitHub。换到任何场景只需要改 YAML 内容。

## 相关
- [[self-evolution-architecture]] — FlowForge 驱动反思和打工循环
