# cron-observability-metrics

Tracking token cost, success rate, and duration per cron job / routine.

## Pattern

每个 cron/routine 执行后记录：
- input/output tokens
- cost (USD)
- duration (seconds)
- success/failure
- cumulative stats (avg cost, success rate, total runs)

存储：单一 JSON 文件（metrics.json），按 routine name 做 key。

## 实现参考

- **evo-nexus**: `ADWs/runner.py` → `_save_metrics()` 写 `logs/metrics.json`
  - 每次 routine 完成后 append，支持 Claude CLI `--json` 输出解析
  - Dashboard 读 metrics.json 展示成本图表
- **nanobot**: 暂无类似功能
- **OpenClaw**: gateway DB 有 cron 执行历史，但无 token/cost 追踪

## 我们的现状

- FlowForge: 无 metrics（只有 state.json 记录节点进度）
- OpenClaw cron: gateway 记录 lastRunAt/consecutiveErrors，但无 token/cost
- memory/ 日志有定性记录，无定量数据

## 行动项

- [ ] 在 cron session 结束时记录 token usage（需要 gateway API 支持 or session_status 解析）
- [ ] FlowForge workflow 完成时记录 duration + node count
- [ ] 考虑 weekly-eval 时汇总 cron 成本数据

## 04-27 评估：OpenClaw 已有数据足够，无需外部方案

对比 [[agentic-stack]] v0.11 data-layer skill 后的结论：

### 发现
- OpenClaw **trajectory JSONL** (`*.trajectory.jsonl`) 已包含完整的 session 生命周期数据
- 每个 session 的 `trace.artifacts` 事件记录了 `usage: {input, output, cacheRead, cacheWrite, total}`
- `session.started` 事件包含 sessionKey（可解析 trigger 类型：cron/discord/subagent）、model、provider
- 50 行 Python 脚本 PoC 验证：可从 200 个 trajectory 文件提取出 cron 级别的 token 分布和成本估算

### PoC 数据（200 session 样本）
- 157 cron + 18 subagent + 9 discord + 1 main session
- Top cron jobs 的 cache hit rate 普遍 90%+（prompt cache 在起作用）
- 单 cron 最高 ~950K tokens/run（study/workloop 类），最低 ~20K（heartbeat/patrol 类）

### 决策
- **不采用** [[agentic-stack]] data-layer（9-harness 支持是 overkill，TUI/HTML 非刚需）
- **也不急着自建** — 数据在那里，需要时一行 grep + python 就能查
- **当以下条件满足时再投入**：(1) 月成本需要日常监控 (2) 需要跨 harness（ACP）聚合 (3) 需要自动异常检测（某 cron 突然 token 暴增）
- 参考 [[multica]] #824 的实现：Go + bytesContains 快速过滤 + 按 date/provider/model 聚合

## 04-29 补充：hermes-labyrinth "Guideposts" 模式

[[hermes-labyrinth]] 实现了一种轻量异常检测方法——**Guideposts**：
- 纯规则匹配（不用 LLM），从 crossings（session 事件流）中检测模式
- 检测项：repeated tool failures、long journeys (>30min)、high tool-call count (≥10)、context compression、delegation boundaries
- 每个 guidepost 带 severity (info/notice/warning) + evidence_refs（指向具体 crossing）
- **启示**：我们的 trajectory JSONL 同样可以跑类似规则（"某 cron token 暴增"、"某 tool 连续失败"），不需要 dashboard UI，一个 cron + 规则脚本 + Discord 通知就够了

## 关联

- [[evo-nexus]] — 完整实现参考
- [[hermes-labyrinth]] — guideposts 异常检测模式参考
- [[flowforge]] — 可加 metrics 的执行引擎
- [[cron-progress-suppression]] — cron 输出管理的另一面
- [[multica]] — #824 实现了跨平台 token usage 扫描（OpenClaw+Hermes+OpenCode session 文件解析），验证这个方向是 production 刚需

## multica 实现参考 (2026-04-13 #824)

multica daemon 从本地 session 文件扫描 token usage，不需要 API：
- OpenClaw: `~/.openclaw/agents/*/sessions/*.jsonl` — 解析 assistant messages 的 usage 字段
- Fast pre-filter: `bytesContains("usage")` + `bytesContains("assistant")` 避免 JSON 解析每行
- 按 date+provider+model 聚合 `mergeRecords()`
- 14 个单元测试，Go

这说明 OpenClaw session JSONL 已有完整数据，我们不需要新 API，只要解析现有文件就能做 cron cost tracking。
