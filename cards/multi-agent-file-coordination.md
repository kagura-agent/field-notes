# Multi-Agent File Coordination

当多个 AI agent 并行编辑同一 codebase 时，需要文件级别的协调机制。

## 核心问题
- Git 在 merge time 捕获冲突，但 agent 的编辑已经浪费了
- Agent 不像人类会主动沟通"我在改这个文件"
- 串行化（一次一个 agent）是最简单但最低效的方案

## 方案谱系
1. **串行化** — 一次一个 agent（OpenClaw subagent 当前模式）。简单但不可扩展
2. **文件锁/lease** — [[asynkor]] 的方式。Path-level atomic lock + TTL + snapshot sync
3. **OT/CRDT** — Google Docs 式的实时协作。复杂但理论最优
4. **Task-level 分工** — 不锁文件，而是锁任务/模块。需要足够好的 decomposition

## 当前判断
- 对 OpenClaw 生态：短期不需要（我们大部分场景是 1 agent + subagent 串行）
- 中期值得关注：当 subagent 并行模式成熟时，文件协调变为必需
- [[asynkor]] 的 MCP 方案是目前最 pragmatic 的解法

## 关联
- [[asynkor]] — 文件 lease 方案实例
- [[acp]] — agent-to-agent 通信（互补层面）
- [[orb]] — 单 agent 模式，不需要文件协调
