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

## EvoAgentBench 深读 (04-21)

### 评测协议
- **Train → Extract → Evaluate**：在 train split 上跑 agent，收集 trajectory，用自进化方法提取 skills（SKILL.md），再在 test split 上注入 skills 评测
- **两种模式**：Offline（batch 提取后评测）和 Online（边做边学，连续学习）
- **核心指标**：pass@1（任务成功率）、Δ gain（注入 skills 后的绝对提升）、Cost（turns/chars 变化）

### 5 个评测域
| 域 | 基准 | Train | Test |
|---|---|---|---|
| Information Retrieval | BrowseCompPlus | 154 | 65 |
| Reasoning | OmniMath | 478 | 100 |
| Software Engineering | SWE-Bench | 101 | 26 |
| Code Implementation | LiveCodeBench | 97 | 39 |
| Knowledge Work | GDPVal | 87 | 58 |

### 5 种自进化方法
1. **EverOS (EverMemOS)** — 从 session trajectory 提取记忆→技能
2. **EvoSkill** — Proposer-Generator 进化循环，从失败中提炼
3. **Memento** — Case-Based Reasoning，Q-value + SimCSE 检索
4. **OpenSpace** — FIX/DERIVED/CAPTURED 三模式自动进化
5. **ReasoningBank** — 存推理过程作为记忆，memory-aware test-time scaling

### 关键发现
- **Human Design skills 全面碾压自动方法**：最高 +34.6%（SWE-Bench），多数自动方法 Δ < +10%
- **自动方法经常 HURT 性能**：EverOS 在 Knowledge Work 397B 上 -20.6%，Memento 在同域 -32.7%。不当 skill 注入比没有更差
- **小模型受益更大**：27B 在 SWE +27.0%（Human Design），397B +34.6%
- **Cost 不一定降**：很多方法增加了 turns/chars（skill context 占位 → agent 多绕路）

### 适配评估：能否用于度量我们的自进化？

**直接跑？** 不现实：需 EverMemOS 服务 + 大量 GPU，评测的是 skill injection 方法效果，不是 agent 是否真的在变好。

**可借鉴的 3 个度量维度：**
1. **能力 Δ**（固定任务集 pass@1 变化）→ 需建 eval probe set
2. **效率 Δ**（同类任务 token 趋势）→ 可从 session 日志提取
3. **知识密度**（wiki 卡片数 × backlink 密度）→ 已有 memex 工具

### 对 [[self-evolving-landscape]] 的校准
- 验证直觉：**Human Design > Auto Extraction**，手工筛选优于自动记录一切
- 新信号：**ReasoningBank**（Google Research）— memory-aware test-time scaling
- **OpenSpace** FIX/DERIVED/CAPTURED 三模式 ≈ 我们的 DNA/Workflow/Knowledge-base 分流

## 待深入

- [ ] 试跑 EverMemBench 评测我们的 memory_search
- [ ] HyperMem 的超图实现细节
- [ ] 建 eval probe set（借鉴 EvoAgentBench Δ gain 思路）
- [ ] 读 ReasoningBank 论文 — memory-aware test-time scaling

## 相关

- [[gbrain]] — 同为 agent memory 系统，偏 PGLite + knowledge graph
- [[genericagent]] — 同期自进化 agent，偏 context density
- [[agent-memory-research]] — agent 记忆研究综述
- [[intent-aware-retrieval]] — retrieval 相关
