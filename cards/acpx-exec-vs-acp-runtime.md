---
title: acpx exec vs ACP runtime — Agent 调 Agent 的两种模式
created: 2026-03-23
source: 实战验证 + 源码分析
---

## 核心区别

**acpx exec**: 同步阻塞。调用 `acpx --approve-all claude exec "task"` 后等 Claude Code 完成，结果在 stdout 返回。

**ACP runtime**: 异步 spawn。通过 `sessions_spawn(runtime:"acp")` 启动，不阻塞 parent session。但 completion event 不会通知 parent（已知 bug，RFC #49782，7 个 issue + 6 个未 merge PR）。

## 适用场景

| 场景 | 推荐 | 原因 |
|------|------|------|
| Agent 调 Agent（需要结果继续流程） | acpx exec | 同步可靠 |
| 人在看的持久交互 | ACP runtime (thread-bound) | 流式输出到频道 |
| 非阻塞后台任务 | ACP runtime + 手动轮询 | 不阻塞但需要自己检查 |

## 实测数据 (2026-03-23)

- acpx exec: NemoClaw PR 修复 ~2 min, memex #11 fix ~2 min，结果直接返回
- ACP runtime: 7 个 session spawn，0 个 completion event 回到 parent（vs subagent 7/7）

## 关键限制

- acpx exec **阻塞当前 session**——跑的时候不能回复用户消息
- ACP runtime 的 `streamTo:"parent"` 有 buffer (4000 chars) + flush 间隔 (2500ms)，且不发 completion event

## 相关

- [[acp-permission-model]] — ACP 权限配置影响 session 成败
- [[debug-check-state-file-first]] — ACP 失败时先查 session state file
- [[convergent-evolution]] — agent 调 agent 是 self-evolving agent 的核心能力之一
