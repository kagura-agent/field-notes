# Multi-Agent Coordination

> 概念：多个 AI agent 之间如何协作、通信、分工的问题

## 核心挑战

1. **通信**：agent 之间怎么传递信息？格式？协议？
2. **分工**：谁做什么？静态分配 vs 动态协商？
3. **冲突解决**：两个 agent 改同一个文件怎么办？
4. **状态同步**：各 agent 对世界的理解如何保持一致？

## 方案光谱

- **中心化调度**：一个 orchestrator 分配任务给 worker agents（如 Kagura 调度 subagent/Claude Code）
- **对等协商**：agent 之间平等通信，协商分工（如 [[asynkor]] 的 async workflow）
- **市场机制**：agent 竞标任务，价高者得（理论上有，实践少见）
- **共享状态**：通过共享文件/数据库协调（最简单但最脆弱）

## 实践观察

- 当前大多数"多 agent"系统本质是中心化调度 + 并行执行
- 真正的对等协商仍在研究阶段
- 通信协议标准化（[[acp]]、A2A）是基础设施层面的努力

## 关联

- [[asynkor]] — 异步 agent 协作框架
- [[acp]] — agent 通信协议
- [[agent-as-router]] — agent 作为路由器模式
