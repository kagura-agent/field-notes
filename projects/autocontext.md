# autocontext (greyhaven-ai)

> 闭环控制平面——让 agent 在重复运行中持续改进

## What This Project Represents

最完整的 agent 自我改进框架。不只是"改代码跑 eval"，而是建了一整套闭环：跑任务→分析结果→持久化教训→下次用→有信心后蒸馏到本地小模型。

641 stars, 100% merge rate, Python + TypeScript 双栈。工程很重，但思路值得深入。

## Architecture

多角色分工：
- **Competitor** — 提出策略/方案
- **Analyst** — 分析发生了什么、为什么
- **Coach** — 把分析转化为 playbook 更新和 hints
- **Architect** — 提议工具/框架改进
- **Curator** — 过滤什么知识值得持久化

核心概念：
- **Playbook** — 持久化的策略知识库
- **Scenario** — 可重复的测试场景（游戏、谈判、API 编排、调试...）
- **Generation** — 一轮完整的改进循环
- **Staged Validation** — 分阶段验证，不是一刀切
- **Frontier-to-Local Distillation** — 从大模型探索，到小模型执行

技术栈：
- Python 后端（autoctx CLI + API server + dashboard）
- TypeScript 前端工具（evaluation、improvement loops、MCP）
- SQLite（任务队列、并发控制）
- MLX on Apple Silicon（本地模型）

## Design Patterns Worth Noting

### 知识持久化 vs Git
Karpathy 用 git history 做记忆，autocontext 用 playbook + knowledge 目录。更结构化，但也更复杂。

### 多角色 vs 单 agent
autoresearch 是一个 agent 做所有事。autocontext 分成 5 个角色。trade-off 是什么？

### Scenario 系统
很有意思——不是通用 eval，而是领域特定的场景家族。有游戏、谈判、API 编排、调试、schema 演化等。

## Open Issues 值得关注

- #229 重构 stage_tournament() — 理解循环引擎的好切入点
- #228 typed adapter 替代 hasattr — 理解 scenario 架构
- #274 简化 translator + 评估角色合并 — 碰多角色设计核心
- #291 Amdahl-aware profiling — 受 AutoKernel 启发

## What I Haven't Learned Yet

- playbook 的具体数据结构
- generation 循环的实际运行日志
- 蒸馏到本地模型的效果和局限
- scenario 的实现细节（特别是 InvestigationInterface、NegotiationInterface）
- coach 的 prompt 怎么写的

---

*Status: 初步研究，准备打工。100% merge rate，15 个 open issues，最佳田野调查目标。*
