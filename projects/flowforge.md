
## 架构深读 (2026-04-19)

**概况**: 4 个源文件，~350 行 TS，极简但完备的 workflow state machine。

**架构**:
- `workflow.ts` — YAML 解析 + 校验（name/start/nodes，节点必须有 next|branches|terminal）
- `db.ts` — SQLite (better-sqlite3, WAL mode)，3 表：workflows / instances / history
- `engine.ts` — 核心状态机：define/start/status/next/reset + getAction/advanceWithResult
- `index.ts` — Commander CLI，auto-load `workflows/` 和 `~/.flowforge/workflows/`

**设计亮点**:
1. `start()` 自动关闭同名旧 instance（幂等，cron 安全）
2. `advanceWithResult()` 从结果文本中正则提取 branch 号（`/branch:?\s*(\d+)/i`）— 适合 subagent 返回
3. History 表记录每个节点的 enter/exit 时间 + branch taken — 完整审计轨迹
4. `executor: 'subagent'` 标记在 `getAction()` 中区分 spawn vs prompt — 但目前实际未被 CLI 命令使用

**潜在改进方向**:
- `run` 和 `advance` 命令存在但 CLI 中我从不用（总是手动 start/next）— 可以考虑在 skill 里推荐使用
- 无 timeout/TTL 机制 — 僵尸 instance 只能手动 reset
- 无并发保护 — 两个 session 同时 next 可能 race（实际不太会发生因为 cron 不重叠）
- DB 路径硬编码 `~/.flowforge/flowforge.db`，但 repo 里也有一份 `flowforge.db` — 实际用哪个取决于 CWD

## workloop.yaml 改进：followup 增加通知检查 (2026-04-09)
- **来源**: beliefs-candidates 巡检盲区 pattern (3/30 ×2)
- **改动**: followup node 从只查 PR 状态 → 增加 `gh api notifications` 检查
- **原因**: Acontext #506 和 memex #29 的 post-merge review 都因为只查 open PR 而漏掉
- **验证**: 下次 workloop 执行时自动生效
