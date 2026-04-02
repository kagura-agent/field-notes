---
name: subagent-usage-patterns
description: OpenClaw subagent 使用模式——什么任务适合 subagent，什么不适合
type: reference
---

# Subagent 使用模式

> 来源：2026-04-01 实操教训（连续 3 次超时）+ OpenClaw 官方文档

## 核心原则

每个 subagent 有**独立的 context 和 token 消耗**。不共享 prompt cache。
所以：任务越重、读取量越大，subagent 效率越低。

## 适合 subagent 的

| 场景 | 原因 |
|---|---|
| 并行多任务（不阻塞主 session） | subagent 异步，主 session 可响应 Luna |
| 代码实现（subagent → Claude Code CLI） | 分层委托，subagent 调度，CC 写码 |
| 写文件/笔记（内容已准备好） | 轻量任务，不需要大量读取 |
| 打工 workloop 各节点 | 每个节点独立，spawn 后不阻塞 |
| 后台监控/检查 | cron 和 heartbeat 的延伸 |

## 不适合 subagent 的

| 场景 | 原因 | 替代方案 |
|---|---|---|
| 大量源码阅读/研究 | 每个 read 占 token，几个大文件就 90k+ | 自己读 or Claude Code CLI |
| "读文件内容然后汇报" | 太低级，官方文档明确说不要这样用 | 自己读 |
| 需要即时结果的任务 | subagent 异步，无法 yield 等待 | 直接做 |
| 上下文极重的分析 | 没有 prompt cache 共享 | 主 session 做 |

## 超时配置

- 默认 `runTimeoutSeconds: 0`（无超时）
- 全局默认：`agents.defaults.subagents.runTimeoutSeconds`
- 轻量任务（写文件、检查状态）：120-300s 够了
- 涉及 Claude Code CLI 的任务：600-900s
- 研究类：不设超时 or 900+

## 分层委托模式（推荐）

```
主 session（调度 + 响应 Luna）
  → subagent（调度 + 非代码任务）
    → Claude Code CLI（代码读写）
```

subagent 不自己手写代码，代码交给 Claude Code。
subagent 的价值是：不阻塞主 session + 隔离执行环境。

## Copilot API 流式超时（2026-04-01 确认）
- GitHub Copilot API 有 ~60s stream idle timeout
- 大 context（>3000行源码）让模型思考时间超过 60s → 连接断开 → 子 agent "超时"
- OpenClaw runTimeoutSeconds 只用于 parent wait，不传给 child embedded run
- 解决：拆分任务，每次 ≤1000 行源码；或用主 session 交互式读
