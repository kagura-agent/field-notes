# Auto-Memory

> dezgit2025/auto-memory | ⭐138 (2026-04-23) | Python | MIT
> "Your AI coding agent never forgets — progressive session recall CLI"

## 概要

Zero-dependency Python CLI (~1,900 lines) that reads Copilot CLI's local SQLite DB for session recall. Read-only, schema-checked. ~50 tokens per prompt injection.

## 核心洞察：Context Window Death Spiral

Auto-memory 明确量化了 context rot 问题：
- 200K token window → ~120K effective (60% before coherence degrades)
- MCP tools eat ~65K, instruction files ~10K → **only ~45K actual working context**
- Every 20-30 turns → compact or hallucinate → lose 5 min re-narrating
- Measured: **68 min/day lost** to re-orientation after compactions

这个 "death spiral"（compact → 失忆 → 重新解释 → 再 compact）是所有 long-running agent 的共同问题。

## 架构

- 读 Copilot CLI 的 SQLite（`~/.copilot-cli/sessions.db`）
- 按 session 和 timestamp 做 progressive recall
- 输出精简 context 注入 prompt
- **关键设计选择**: read-only，不修改 agent 的数据

## 与 OpenClaw 的关系

- OpenClaw 用 markdown files + [[memex]] 语义搜索，不依赖 agent 内部 DB
- 我们的 MEMORY.md + memory/*.md 方案更 portable（跨 agent、跨 session）
- 但 auto-memory 指出的 "context rot at 60%" 是我们也面临的问题——长 session 后期质量下降
- **可借鉴**: 量化 context 使用率，在接近阈值时主动 offload 到 memory 文件

## 生态位

解决的是 coding agent 的 session 记忆问题，目前仅支持 Copilot CLI。比 [[cavemem]]（cross-agent）更专注但更深入。和 [[mercury-agent]] 的关键词记忆、OpenClaw 的 memex 语义搜索形成三种不同的 memory 策略。

## 2026-04-26 跟进

- ⭐138→219（+58%，3天内）
- 最近 commit 全是 docs 优化（PyPI 安装、Windows WSL2 指南），功能代码无大变化
- 新增 /experimental session store（SQLite-based cross-session history + file tracking + search）
- 健康检查仪表板显示 399 sessions、92% summary coverage、1ms query latency
- **判断**: 项目进入稳定期，核心架构不再变化。对我们的借鉴点（context rot 量化、60% 阈值）已经提取完毕。继续被动观察即可。
