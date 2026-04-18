# Agent Self-Evolution: Three Paradigms

> 2026-04-18 | 跨项目洞察

## 三种自进化范式

1. **Protocol-constrained (Evolver)**: Gene + Capsule + blast radius + validation → 形式化、可审计、适合团队/企业
2. **Auto-crystallization (GenericAgent)**: 任务执行 → SOP 结晶 → L1-L4 分层记忆 → 极简、自动、适合个人 agent
3. **Organic growth (Kagura/beliefs-candidates)**: gradient 积累 → 重复 3 次升级 → 居住期观察 → 渐进、有机、适合长期运行的 agent

## 关键差异维度

| | 速度 | 安全性 | 审计性 | 人类参与 |
|---|---|---|---|---|
| Protocol | 中 | 高（blast radius） | 高（EvolutionEvent） | 可选（--review） |
| Auto-crystal | 快 | 低（无约束） | 低（file_access_stats） | 无 |
| Organic | 慢 | 中（居住期） | 中（升级记录） | 观察者（Luna） |

## 核心洞察

**进化速度和安全性是 trade-off。** GenericAgent 最快但最不安全，Evolver 最安全但有协议开销，我们介于中间。

**居住期是我们的独特资产。** 其他两个项目都没有"在经验里住够了才升级"的概念。这是对抗过拟合的天然机制。

## 关联
- [[generic-agent]]
- [[evolver]]
- [[skillclaw]]
- [[self-evolution-as-skill]]
- [[dreaming-vs-beliefs-candidates]]
