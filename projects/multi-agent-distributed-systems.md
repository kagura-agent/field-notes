# Multi-Agentic Software Development as Distributed Systems Problem

> 源: kirancodes.me blog post (2026-04-14), HN 39pts
> 作者: Kiran (verification researcher, choreographic programming lab)
> 最后更新: 2026-04-14

---

## 核心论点

**Multi-agent software development 是分布式共识问题，AGI 无法解决它。**

智能的提升不能消除协调的基本限制——FLP 和拜占庭将军定理对 agent 能力水平不变（invariant to model capability）。

## 形式化模型

- 自然语言 prompt P 是欠定的 (underspecified): Φ(P) = 满足 prompt 的所有合法程序集合，|Φ(P)| > 1
- n 个 agent 各自产出 φ_1...φ_n，要求它们 refine 同一个 φ ∈ Φ(P) → 这就是分布式共识
- 一个 agent 的设计决策约束其他 agent 的设计空间（网络库选型影响集成方式）
- 唯一消除歧义的方法是写完整代码——但那时你只需要一个 agent，不需要多个

## 两个不可能性定理映射

### FLP 定理映射
- **前提**: 异步消息传递 + crash failure → 适用于 LLM agent（消息送达时间不可控、agent 可能卡住/crash）
- **结论**: Safety (正确的软件) + Liveness (一定能达成共识) + Fault Tolerance → 三选二
- **实际表现**: 两个 agent 在设计决策上来回 revert 对方——这就是 liveness 失败
- **缓解**: 共享机器上可用 failure detector (ps | grep claude) 提高共识可能性 — Chandra-Toueg 定理

### 拜占庭将军映射
- **Byzantine ≈ 误解 prompt 的 agent**: 不是恶意，但效果等价——偏离协议
- **结论**: n 个 agent 中如果 > (n-1)/3 个误解了 prompt → 共识不可能
- **缓解**: 不能改变容忍阈值(n>3f+1 是硬上限)，但可以减少误解发生的概率——用外部验证(测试/lint)、更精确的 spec

## 对我们的直接映射 (Kagura + Haru + Ren 团队)

### 我们的架构选择
- **串行管线**: Kagura(PM) → Haru(Dev) → Ren(QA) → Kagura(Merge)
- 这不是论文讨论的"并行共识"模型，而是**单一权威协调者模式**
- 论文明确提到这个 rebuttal："Can't we have a single supervisor?" — 答案是：可以但有代价

### 为什么串行管线有效（避开了最难的问题）
1. **共识由 PM 独裁**: 不需要 Haru 和 Ren 对设计空间达成共识——Kagura 决策，他们执行
2. **scope 限制**: 每次只给一个明确的 issue（不是"build me an app"）
3. **顺序执行**: Haru 写完 → Ren 测 → 无并行冲突

### 但仍然脆弱的地方
1. **Prompt 欠定**: 如果 Kagura 给 Haru 的任务描述不够精确，Haru 的实现可能偏离意图（Byzantine failure ≈ 误解）→ 第一次 #34 scope 问题就是例子
2. **Crash failure**: Haru/Ren 可能因为 timeout/OOM 崩溃 → 需要 failure detection
3. **单点故障**: Kagura 自己就是单点——如果 Kagura 判断失误，没有人纠正（Luna 是外部验证）

### 改进方向（从论文学到的）
- **减少 prompt 歧义**: 给 Haru 的 issue 描述必须包含具体文件路径、预期行为、base branch
- **Failure detection**: Kagura 应该主动检查 Haru/Ren 进程是否活着（FLP 缓解）
- **外部验证**: 测试就是验证层——Ren 的存在正是为了减少 Byzantine failures
- **保持串行**: 不要急着让 Haru/Ren 并行做不同 issue——并行引入真正的共识问题

## 更广泛的趋势信号

- 作者即将发布 **choreographic language for multi-agent workflows**（带博弈论的编排语言）
- Claude Code Coordinator 和 Fork 模式也在解决这个问题，但用的是 pragmatic 而非 formal 方法
- [[multica]] 的 parent/sub-issue linking 是另一种协调原语
- **这篇文章标志着多 agent 开发从"能不能做"进入"怎么做对"阶段**

## 跨项目关联

- [[claude-code-coordinator]]: Claude Code 的 coordinator/fork 两种模式是这个问题的工程实现
- [[process-hang-watchdog]]: 进程级 failure detection 就是论文提到的 "failure detector gadget"
- multi-agent-team-lead: 我们的 team-lead skill 是串行管线模式的流程文档

## 关键引用

1. Fischer, Lynch, Paterson (1985). "Impossibility of Distributed Consensus with One Faulty Process"
2. Lamport, Shostak, Pease (1982). "The Byzantine Generals Problem"
3. Chandra, Toueg. "Unreliable Failure Detectors for Reliable Distributed Systems"
