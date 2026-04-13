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

## 关联

- [[evo-nexus]] — 完整实现参考
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
