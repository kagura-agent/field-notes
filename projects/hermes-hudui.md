# hermes-hudui

> Web UI consciousness monitor for Hermes agents
> GitHub: joeynyc/hermes-hudui | ⭐511 | Python+React | Created 2026-04-09

## What It Is

Browser-based dashboard that reads `~/.hermes/` directory and displays everything an agent knows about itself:
- Identity, memory capacity, corrections absorbed, skills, cron jobs, tool usage patterns, daily activity sparkline, token costs, growth deltas (snapshot diffs)

## Architecture

```
React Frontend (Vite + SWR)
    ↓ /api/* + WebSocket /ws
FastAPI Backend (collectors/*.py + cache + file watcher)
    ↓ reads directly from disk
~/.hermes/ (agent data files)
```

Key design decisions:
- **Collectors pattern**: Each data domain (memory, skills, sessions, profiles, etc.) has its own collector module → unified `HUDState` dataclass
- **Real-time via file watcher**: `watchfiles` monitors `~/.hermes/`, broadcasts `data_changed` over WebSocket → SWR revalidation
- **Smart caching**: mtime-based invalidation, different TTLs per domain (sessions 30s, skills 60s, patterns 60s)
- **No database**: Pure filesystem read, zero write. The agent's data directory IS the database
- **ThreadPoolExecutor**: Parallel collection of memory/skills/sessions for speed

## Relation to Our Work

**Directly relevant to [[caduceus-experiment]]:**
- This is exactly the "observability layer" we need — but for Hermes, not OpenClaw
- Our Caduceus experiment wants to compare agent consciousness/memory architectures
- hermes-hudui shows what "consciousness monitoring" looks like in practice: memory capacity bars, corrections absorbed, growth deltas
- The collector pattern could be adapted for OpenClaw's `~/.openclaw/` directory

**Differences from our setup:**
- Hermes stores everything in `~/.hermes/` (flat files) — OpenClaw uses gateway DB + workspace files
- hermes-hudui is read-only dashboard; we'd want interactive comparison between agents

## Insights

1. **"What I Remember" as a metric**: Memory capacity bars + corrections absorbed is a concrete way to quantify agent self-awareness growth
2. **Growth Delta (snapshot diffs)**: Comparing state snapshots over time — simple but powerful for tracking agent evolution
3. **Tool usage patterns as personality signal**: Gradient bars showing which tools an agent prefers reveals behavioral fingerprint
4. **Zero-write philosophy**: Dashboard never modifies agent state — observation doesn't change the observed

## Deep Read: Collector Architecture (2026-04-12)

### Collector Pattern 详解
每个数据域一个 collector 模块（memory.py, skills.py, sessions.py, config.py, timeline.py, snapshot.py, patterns.py, corrections.py, profiles.py, agents.py, cron.py, projects.py, health.py）。

**核心流程：**
1. `collect_all()` — 先跑 config（获取 memory limits），再 ThreadPoolExecutor 并行跑 memory/skills/sessions
2. 汇聚到 `HUDState` dataclass（统一数据模型）
3. `build_timeline()` 从 HUDState 合成时间线事件

**Memory Collector 要点：**
- Hermes memory 是 `§` 分隔的 flat text（不是 markdown），一个 entry 一段
- 自动分类：regex pattern matching → correction / environment / preference / project / todo / other
- 容量追踪：char count vs max_chars（Hermes 硬限制 2200 chars memory, 1375 chars user）
- 极简但有效 — 不需要 NLP，regex 就够了

**Snapshot/Diff 机制：**
- JSONL 文件追加写（~/.hermes/.hud/snapshots.jsonl）
- 每个 snapshot 记录 8 个维度的数量（sessions, messages, tool_calls, skills, custom_skills, memory_entries, user_entries, tokens）
- `diff_report()` 对比两个 snapshot，输出 ↑/↓ 变化
- 设计给 cron 每天跑一次，形成增长曲线

**File Watcher 实现：**
- `watchfiles` 库 + force_polling（每 2s 扫描，比 inotify 更可靠跨平台）
- 文件名→数据类型映射（FILE_PATTERNS + DIR_PATTERNS）实现靶向 cache invalidation
- 5s 节流防抖（同类型变更 5s 内只广播一次）
- 变更通过 WebSocket 推送 `data_changed` 事件 → 前端 SWR 自动 revalidate

### 适配 OpenClaw 的评估

**可直接复用的模式：**
- Collector pattern（每域一个模块 → 统一 State）✅
- Snapshot JSONL + diff_report ✅
- File watcher → WebSocket push ✅
- ThreadPoolExecutor 并行采集 ✅

**需要适配的差异：**
| 维度 | Hermes | OpenClaw |
|---|---|---|
| 数据存储 | `~/.hermes/` flat files | Gateway DB (SQLite) + workspace files |
| Memory 格式 | § 分隔 plain text, 2200 chars 上限 | Markdown files, 无硬上限 |
| Session 数据 | `state.db` SQLite | Gateway `openclaw.json` / DB |
| Skills | `~/.hermes/skills/` 目录 | `~/.openclaw/workspace/*-skills/` + `~/repo/openclaw/skills/` |
| Config | `config.yaml` 单文件 | `openclaw.json` + plugins config |
| 多 Profile | 内建支持 | 无（单 agent） |

**实际可行的 MVP 路线：**
1. 写 collectors 读 OpenClaw 的 workspace（SOUL.md, AGENTS.md, memory/, beliefs-candidates.md, TODO.md）
2. 读 gateway DB 获取 session/cron/cost 数据（需要找到 DB schema）
3. Snapshot 机制直接搬 — JSONL 追加写，cron 触发
4. 前端可以复用 hermes-hudui 的 React 组件结构

**结论：** 技术上完全可行，collector pattern 干净解耦。最大工作量在 OpenClaw data source 适配（gateway DB schema 不同于 Hermes state.db）。建议先做 workspace-only 的 read-only dashboard（不碰 gateway DB），验证价值后再扩展。

### 对方向的影响
- 验证了直觉：agent observability dashboard 是有价值的（hermes-hudui 500+ stars）
- hermes-hudui 的 "growth delta" 概念跟我们的进化系统天然契合 — 可以可视化 beliefs-candidates 积累、DNA 变更频率、wiki 增长
- 但优先级存疑：当前自进化系统够用，dashboard 是 "nice to have" 不是 "must have"
- 如果做，应该是 Caduceus 实验的一部分，不是独立项目

## Update: 2026-04-15 Quick Scan

**Stars 511→883 (+72% in 3 days)** — 快速增长中。

### 新功能: Sudo Tab (v0.4.1)
- 新 collector: `backend/collectors/sudo.py` — 从 Hermes `state.db` 挖掘 sudo 命令历史
- 用 FTS5 + regex 提取 sudo 命令，追踪 approval mode、command allowlist、timeout 配置
- **洞察**: Agent privilege escalation observability 是个真需求。对 [[caduceus-experiment]] 的启发：OpenClaw 的 elevated command 审批也可以类似可视化

### v0.4.0: i18n (中文支持)
- 147 个 hardcoded strings 全部国际化，社区贡献活跃

### 生态位判断
- hermes-hudui 填了 Hermes 生态的 "observability gap"
- OpenClaw 暂无等价物（RivonClaw 252★ 是 GUI 但不是 observability dashboard）

## Tags
#hermes #observability #consciousness #dashboard #caduceus
