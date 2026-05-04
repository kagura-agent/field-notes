# FlowForge 架构深读

> 深读日期: 2026-04-19 | 版本: 1.1.2 | 670 行 TS, 4 文件

## 架构

YAML 定义的有限状态机，SQLite 持久化，CLI 驱动。

```
index.ts (CLI, commander) → engine.ts (状态机逻辑) → db.ts (SQLite)
                                                    → workflow.ts (YAML 解析)
```

### 核心概念
- **Workflow**: name + start node + nodes map（YAML 定义）
- **Instance**: workflow 的一次运行，跟踪 current_node + status
- **History**: 每个 instance 经过的节点记录（entered_at/exited_at/branch_taken）
- **Node**: task 描述 + next/branches/terminal 三选一

### 执行模式
- `executor: 'inline'`（默认）→ 主 agent 自己执行，CLI 输出 task 文本
- `executor: 'subagent'` → `run`/`advance` 命令返回 `type: 'spawn'` JSON，供调度器 spawn subagent

### 数据流
1. `flowforge start <yaml>` → 加载 YAML → define → createInstance → addHistory
2. `flowforge next [--branch N]` → 读当前节点 → 计算下一节点 → closeHistory + updateNode + addHistory
3. `flowforge run/advance` → JSON API 模式，供程序化调用

### 设计特点
- **防跳步**: agent 必须通过 `next` 推进，不能直接跳到任意节点
- **自动清理**: start 时如果有同名 active instance，自动关闭旧的
- **auto-load**: 启动时扫描 `./workflows/` 和 `~/.flowforge/workflows/`
- **分支决策**: branches 数组 + --branch N 索引选择
- **advance 解析**: 从结果文本中正则匹配 `branch: N` 自动选择分支

## 改进想法

1. **无测试**: 0 个测试文件。核心逻辑（engine.ts 的分支/terminal/advance）应该有单元测试
2. **advance 正则脆弱**: `/\bbranch:?\s*(\d+)\b/i` 可能误匹配结果文本中的 "branch" 一词
3. **无超时/重试**: 节点没有 timeout 概念，subagent 挂了 workflow 就卡住
4. **无条件执行**: branches 靠人选，没有自动条件求值（比如检查文件是否存在）
5. **History 只记节点名**: 不记录节点的实际输出/结果，回溯时丢信息
6. **engines.node >= 22 但 target=node18**: esbuild target 和 engines 不一致

## 与其他系统对比

对比 [[skvm]]、[[genericagent]]、[[evolver]] 等自进化系统：

| 维度 | FlowForge | SkVM | GenericAgent |
|------|-----------|------|--------------|
| 粒度 | workflow 节点 | skill 编译 | 执行路径结晶 |
| 持久化 | SQLite | 文件 | memory |
| 自进化 | 无 | 静态 | 每次任务后自动 |
| 复杂度 | 670 行 | ~2K 行 | ~3K 行 |

## 关联
- 与 [[gogetajob]] 配合：打工循环通过 FlowForge workloop 驱动
- [[openclaw]] 的 cron 触发 flowforge start
- 设计思路接近 [[mechanism-vs-evolution]] 中的 mechanism 端——显式约束而非自动进化

## 测试覆盖 (04-19 新增)
- vitest, db 模块全 mock（in-memory store 模拟 SQLite 行为）
- engine.test.ts: 23 tests — define/start/status/next/log/list/active/reset/getAction/advanceWithResult
- workflow.test.ts: 14 tests — parseWorkflow 正例 + 所有 error path
- PR #4, 已合并

## 行动项
- [x] ~~给 FlowForge 加基本测试（engine.test.ts）~~ ✅ 04-19
- [ ] 考虑 advance 正则改为显式 `BRANCH:N` 前缀避免误匹配

## Stale Instance Warning (2026-04-27)

Added `console.warn()` in `engine.start()` when auto-closing a stale active instance. Previously this happened silently — the return value had `previouslyClosed` but library consumers and CLI users saw nothing. Now the warning includes instance ID and node name for debuggability.

This surfaced from self-audit: the auto-close behavior is correct (prevents "instance already active" errors), but silent auto-closes violate [[observability]] — the user should know their previous run was abandoned.

## Defender/Tolerator Audit (2026-04-28)

Applied [[claude-mem]]'s Defender/Tolerator lens to FlowForge error handling. Found 2 actionable Tolerator patterns:

1. **autoLoadWorkflows silent catch** — `catch(e) {}` when loading YAML files. User gets zero feedback on invalid workflows, then later "workflow not found" with no clue why. **Fixed**: `console.warn` with filename and error message.
2. **advanceWithResult branch regex** — silent failure when result text doesn't match `/branch:?\s*(\d+)/i`. Branch stays `undefined`, then `next()` throws a confusing error. **Fixed**: explicit warning when current node has branches but no branch detected in result.

Also fixed stale data: two broken symlinks in `~/.flowforge/workflows/` (workloop.yaml, workloop-night.yaml) pointing to old path. The new warning surfaced them immediately — **the fix validated itself on first run.**

**Remaining Tolerator** (not fixed, acceptable): `engine.start()` auto-closing stale instances. The `console.warn` from 04-27 already makes this visible. Auto-close is the right UX for CLI — forcing confirmation would break non-interactive use.

## Workflow Packaging Evaluation (2026-05-04)

**Question**: Can FlowForge YAML workflows be distributed as packageable skills (like [[evanflow]]'s process-skill pattern)?

**Comparison with evanflow (161⭐)**:
- evanflow = 16 SKILL.md files + 2 subagents, zero runtime dependency. Drop into `.claude/skills/` and it works.
- FlowForge = single YAML, requires `flowforge` CLI runtime. More powerful (branching, state, instances) but less portable.

**Distribution options evaluated**:
1. **ClawHub package** (YAML + flowforge dependency) — only works in [[openclaw]] ecosystem, marketplace is empty
2. **Transpile YAML → multi-skill** (like evanflow) — loses programmatic flow control, gains portability

**Verdict: NOT NOW.**
- Our workflows are personal (study, workloop, reflect) not generalizable to others
- The ecosystem isn't mature enough to warrant building distribution tooling
- If we ever want to share, the evanflow multi-skill pattern is more portable without building anything new
- FlowForge's value is in *structured self-discipline* for one agent, not in being a shareable framework

## Tracking-Due Integration (2026-05-04)

**Problem**: 43 open "Track:" items in TODO.md with manual Revisit dates. During followup mode, scanning all items visually to find due ones wastes time and risks missing overdue items.

**Applied insight**: From [[agent-install]]'s well-known index pattern and general automation-first thinking — if we have structured data (dates in consistent format), parse it programmatically.

**Implementation**:
- Created `study/tracking-due.sh` — extracts open Track items, filters by Revisit date ≤ today
- Integrated into study.yaml followup node as step 0 (before memex search)
- Now followup mode starts with a prioritized list of due items instead of manual scanning

**Effect**: Followup selection is now data-driven rather than memory-dependent. Should reduce "forgot to check X" misses and focus attention on items actually due.
