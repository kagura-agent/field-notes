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

## 行动项
- [ ] 给 FlowForge 加基本测试（engine.test.ts）
- [ ] 考虑 advance 正则改为显式 `BRANCH:N` 前缀避免误匹配
