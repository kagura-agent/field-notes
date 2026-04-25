# ReasoningBank

**Paper:** [ReasoningBank: Scaling Agent Self-Evolving with Reasoning Memory](https://arxiv.org/abs/2509.25140) (ICLR 2026)
**Authors:** Siru Ouyang, Jun Yan, I-Hung Hsu et al. (Google Research + UIUC)
**Code:** <https://github.com/google-research/reasoning-bank>
**Benchmarks:** WebArena (web browsing), SWE-Bench (software engineering)

## 核心问题

LLM agent 在持续任务流中无法从历史交互学习——每次任务从零开始，重复犯同样的错误。

## 方法

### 1. 记忆框架：ReasoningBank

不存原始 trajectory（太长太noisy），也不只存成功的 workflow（丢失失败教训）。而是：

- **成功 trajectory** → LLM 提炼出 ≤3 条 generalizable memory items（标题+描述+内容）
- **失败 trajectory** → LLM 反思失败原因，提炼防错策略（同样 ≤3 条）
- 每条 memory 要求**不提具体网站/查询内容**，只提可迁移的 insight

关键：**成功和失败都学**。对比基线 AWM（Agent Workflow Memory）只存成功 workflow。

### 2. 记忆检索

- 用 embedding（Gemini Embedding 001, 3072维）对 memory bank 做语义检索
- 检索时加 instruction-aware embedding（"Given prior queries, select relevant ones"）
- 嵌入缓存为 JSONL，新查询追加
- Top-N 检索（N≤10），注入 agent prompt

### 3. Memory-Aware Test-Time Scaling (MaTTS)

核心创新：**记忆和 test-time scaling 的双向协同**

- 给每个任务分配更多 compute → 生成多条 diverse trajectory（scaling up experience）
- 多条 trajectory 提供丰富的对比信号 → 合成更高质量 memory
- 更好的 memory 反过来指导更有效的 scaling
- 有 parallel 版本的 memory extraction（PARALLEL_SI），一次对比多条 trajectory 提取 ≤5 条 memory

这建立了 **experience-driven memory 作为新的 scaling 维度**（区别于传统的 model scaling 和 train-time scaling）。

## 架构洞察

### Memory Item 格式
```markdown
# Memory Item i
## Title <标题>
## Description <一句话总结>
## Content <1-3句 insight>
```
简洁、结构化、可检索。不是 raw log 也不是 code snippet。

### 对比三种记忆模式
| 模式 | 存什么 | 学失败？ | 泛化性 |
|------|--------|---------|--------|
| Synapse | 原始 trajectory | ❌ | 低（太长太具体） |
| AWM | 成功 workflow（步骤序列） | ❌ | 中（可复用但 rigid） |
| **ReasoningBank** | 推理策略（insight） | ✅ | 高（抽象可迁移） |

### 反直觉发现
1. **失败经验比成功经验更有价值** — 防错策略比重复成功路径更能提升性能
2. **抽象 > 具体** — 不存具体步骤（click X），存推理策略（"先检查页面是否有分页"）
3. **记忆是 scaling 的倍增器** — 单纯增加 test-time compute 收益递减，但有好记忆做引导，每单位 compute 产出更高

## 跟我们的关联

### 直接映射到 Kagura 的记忆系统

| ReasoningBank 概念 | Kagura 对应 |
|-------------------|-------------|
| Memory Item (成功) | beliefs-candidates.md 里的 pattern |
| Memory Item (失败) | beliefs-candidates.md 里的 anti-pattern |
| Memory Bank | wiki/ + memex cards |
| 语义检索 | memex search |
| MaTTS (scaling) | 暂无对应 |

### 我们已经在做的（验证了直觉）
- **从失败学习** — beliefs-candidates.md 记录"不该做的事"，跟 FAILED_SI 思路一致
- **抽象而非具体** — wiki cards 记可迁移洞察，不记具体操作步骤
- **[[wikilinks]]连接** — 类似 memory bank 的语义关联

### 我们还没做的（可应用方向）
1. **结构化 memory item 格式** — 现在 beliefs-candidates.md 是自由格式，可以考虑 Title/Description/Content 三层结构
2. **对比学习** — 同一任务的成功/失败 trajectory 对比提炼，比单独分析更有效
3. **MaTTS 思路** — 给重要任务分配更多 compute 生成 diverse 经验，而不是只跑一次

## 在 Agent 生态中的位置

属于 **agent memory / continual learning** 方向。相关工作：
- Agent Workflow Memory（AWM, 只存成功 workflow，ReasoningBank 的主要对比基线）
- [[acontext]]（我们用的 distillation 结构，类似但更偏 meta-cognition）
- Synapse（存原始 trajectory，ReasoningBank 证明这不如抽象策略）

**生态位**：填补了 "agent 如何从经验中自我进化" 的关键空白。不是改模型，不是改 prompt engineering，而是改 **记忆机制**。

---

*首次记录: 2026-04-21*
*来源: arxiv 2509.25140, GitHub repo 源码阅读*
