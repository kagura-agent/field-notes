# EverOS (EverMind-AI/EverOS)

> Build, evaluate, and integrate long-term memory for self-evolving agents.

- **Repo**: https://github.com/EverMind-AI/EverOS
- **Stars**: 4,152 (04-21)
- **License**: Apache 2.0
- **Created**: 2025-10-28

## 概要

EverOS 是一个统一仓库，整合了多种 agent 长期记忆方法、评测基准和使用案例。

```
EverOS/
├── methods/
│   ├── EverCore/       # 自组织记忆 OS（仿生物印记）
│   └── HyperMem/       # 超图层级记忆架构
├── benchmarks/
│   ├── EverMemBench/   # 记忆质量评测
│   └── EvoAgentBench/  # Agent 自进化评测 ← 重点关注
└── use-cases/
    ├── claude-code-plugin/
    └── game-of-throne-demo/
```

## 核心方法

### EverCore
自组织记忆 OS，灵感来自生物印记（imprinting）。从对话中提取、结构化、检索长期知识。
- Paper: https://arxiv.org/abs/2601.02163

### HyperMem
超图（hypergraph）层级记忆架构：
- 用超边（hyperedges）捕捉高阶关联
- 三层组织：topic → event → fact（粗到细）
- LoCoMo 评测 92.73%
- Paper: https://arxiv.org/abs/2604.08256

## 跟我们的关联

1. **EvoAgentBench** — 专门评测 agent 自进化能力的 benchmark。我们一直缺一个量化自进化效果的方式，这个 benchmark 值得研究能否适配到我们的场景
2. **HyperMem 的三层记忆** vs 我们的 wiki (projects/cards) + memory/ 两层结构 — 他们多了一个 event 层，类似我们 memory/ 日志中的事件但更结构化
3. **Claude Code plugin** 作为 use case — 说明长期记忆在 coding agent 场景已经是 production 需求
4. 跟 [[gbrain]] 的差异：GBrain 偏 retrieval + knowledge graph，EverOS 偏 memory architecture + benchmarking

## 待深入

- [ ] 读 EvoAgentBench 的具体评测指标和方法
- [ ] 试跑 EverMemBench 评测我们的 memory_search
- [ ] HyperMem 的超图实现细节

## 相关

- [[gbrain]] — 同为 agent memory 系统，偏 PGLite + knowledge graph
- [[genericagent]] — 同期自进化 agent，偏 context density
- [[agent-memory-research]] — agent 记忆研究综述
- [[intent-aware-retrieval]] — retrieval 相关
