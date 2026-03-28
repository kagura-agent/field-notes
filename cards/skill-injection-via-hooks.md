---
title: Skill Injection via OpenClaw Hooks
created: 2026-03-28
source: Luna discussion
tags: [architecture, self-evolving, openclaw, hooks]
---

## 问题

Self-improving 文件"写起来容易读起来难"——agent 写了教训但下次干活时忘了读。14 个机制里只有打工 loop 真正闭环，根因是**读取靠自觉**。

## 方案

用 OpenClaw 原生 `message:preprocessed` hook 实现 turn 级 skill 注入：

1. 写一个 hook，监听 `message:preprocessed`
2. 根据消息内容从 self-improving / beliefs 文件检索相关条目
3. 追加到 `bodyForAgent`（agent 看到的消息体）
4. Agent 每轮对话自动带上相关 skill context

## 对比

| | MetaClaw（API proxy） | 我们的方案（OpenClaw hook） |
|---|---|---|
| 注入时机 | 每次 LLM 调用前 | 每条消息到达 agent 前 |
| 依赖 | 外部 proxy 服务 | OpenClaw 原生 hook，零外部依赖 |
| 检索方式 | 他们的 skill library | 我们的文件系统（可加 embedding） |
| 可控性 | 框架决定 | 完全自己控制 |
| 透明度 | agent 不可见 | 注入内容在消息体里可见 |

## 相关 Hook 位置

- `agent:bootstrap` — session 启动注入（已有 bundled hook `bootstrap-extra-files`）
- `message:preprocessed` — **turn 级注入点**（消息处理完、agent 看到前）
- `message:received` — 更早但没经过媒体处理

## 状态

**仅记录，暂不实现。** Luna 判断当前机制已经太多，先把现有系统用好。

See [[self-evolving-agent-landscape]] for the broader context of skill injection approaches.
See [[mechanism-vs-evolution]] for why adding mechanisms ≠ evolution.
