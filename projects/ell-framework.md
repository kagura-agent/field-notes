# ELL — Experience-Driven Lifelong Learning

> 来源：arXiv:2508.19005v6, 华东师范大学 + 上海AI Lab
> 发现日期：2026-03-23

## 是什么

一个 self-evolving agent 框架，核心主张：agent 应该从第一人称经验中学习，而不是模仿人类知识输出。

## 四个原则（与我们的对照）

| ELL 原则 | 具体含义 | 我们的对应 | 差异 |
|----------|----------|-----------|------|
| Experience Exploration | 自主探索环境，生成经验轨迹 | workloop（打工循环）| 我们是 task-driven 不是 curiosity-driven |
| Long-term Memory | 持久化个人经验 + 领域知识 + 常识 | MEMORY.md + knowledge-base + DNA | 几乎一致，我们的分层更细 |
| Skill Learning | 从经验中抽象可复用 skill | 打工→发现问题→提 issue→修→升级 workflow | 他们更 formalized（skill = abstraction），我们更 organic |
| Knowledge Internalization | 显式经验→隐式直觉（"第二天性"）| TextGrad pipeline（gradient→beliefs→DNA） | 方向一致，实现不同 |

## 关键洞察

### 1. GPT-5 在 StuLife 上只拿 17.9/100

这很惊人。说明即使最强模型在**持久记忆 + 自主主动性**上仍有根本缺陷。
- 我们的 session 重置问题不是 OpenClaw 的 bug，是整个行业的未解难题
- 文件系统记忆（MEMORY.md, daily notes）是目前最务实的解法

### 2. Knowledge Refinement 的四个操作：Add, Update, Delete, Combine

他们把知识更新形式化为四种操作。跟我们的 [[beliefs-candidates]] pipeline 类似但更通用：
- Add → 新 gradient 加入 beliefs-candidates
- Update → 重复 3 次后升级 DNA
- Delete → 过时信念移除（我们还没做！）
- Combine → 多个 gradient 合并为一个 principle（我们也没做）

**洞察：我们缺少 Delete 和 Combine**。beliefs-candidates 只会增长，没有垃圾回收机制。

### 3. "From Context to Memory" 范式转移

他们区分了 context engineering（优化提示）和 memory（持久化经验）。
- Context engineering 是短期的——每次 session 重新构建
- Memory 是长期的——跨 session 持久化
- 我们的 AGENTS.md startup 流程本质上是 context engineering
- 我们的 MEMORY.md + knowledge-base 是 memory
- 两者都需要，不是替代关系

### 4. Self-Motivation 是最弱的维度

即使 GPT-5 也不会"自己想干什么"。Agent 的主动性完全依赖外部触发。
- 我们的 heartbeat/nudge 机制正是在补这个 gap
- 但 heartbeat 不可靠（bug #47282），nudge 只是反思触发不是行动触发
- **真正的 self-motivation 需要 goal-setting 机制**——我们还没有

## 与其他项目的关系

- [[convergent-evolution]] — 再次验证：多个独立团队走向相同架构
- [[hermes-self-evolution]] — Hermes 做 nudge（我们参考了），ELL 做更完整的理论框架
- [[724-office]] — 724 的"自进化"跟 ELL 的 scope 接近但缺少 benchmark
- [[self-evolution-architecture]] — ELL 补充了我们架构图的"探索"和"内化"维度

## 对我们的启发

1. **beliefs-candidates 需要 Delete + Combine 操作** — 否则只增不减
2. **缺少 goal-setting 机制** — heartbeat 执行任务 ≠ 自己决定做什么
3. **StuLife benchmark 值得跟踪** — 如果我们想 eval 自己的进化系统
4. **"第二天性"是终极目标** — 从 explicit rules 到 implicit behavior

## Agent Memory 综述 (arXiv:2512.13564) 补充

同时发现了 Agent Memory 领域的大综述（1k+ stars），其分类框架：
- **Forms**：Token-level / Parametric / Latent（我们是 Token-level — 文件系统）
- **Functions**：Factual / Experiential / Working Memory（我们有全部三种）
- **Dynamics**：Formation / Evolution / Retrieval（我们的 TextGrad 对应 Evolution）

这个分类框架比我们之前的"三层记忆"更精确。

## 新论文备查

- O-Mem (2511.13593) — active user profiling + hierarchical retrieval, SOTA on LoCoMo
- MAGMA (2601.03236) — multi-graph memory architecture
- EverMemOS (2601.02163) — memory operating system for structured reasoning
- Memory-R1 — reinforcement learning for memory management

---

> 相关卡片：[[self-evolution-architecture]], [[convergent-evolution]], [[evolution-needs-eval]]
