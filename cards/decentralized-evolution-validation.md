# Decentralized Evolution Validation

## 概念

进化结果的验证从单 agent 自判转向多 agent 交叉验证。类似 PoS 共识但应用在 AI agent 能力进化上。

## 来源

[[evolver]] v1.68.0-beta (2026-04-18): validator role, staked nodes, consensus-based promotion.

## 机制

1. Agent A 完成一轮进化（mutation + validation）
2. Hub 分发 validation task 给 staked validator nodes
3. Validators 在隔离 sandbox 中独立运行 asset validation
4. Hub 收集 PASS/FAIL，共识决定是否 promote
5. Promoted 的进化结果对网络中所有 agent 可用

## 为什么重要

- 单 agent 自验证有盲点（自己写的 test 验证自己写的代码）
- 多 agent 交叉验证 ≈ peer review，降低 hallucination 导致的虚假进化
- 开辟了 agent 间信任和协作的新模式

## 对比

| 模式 | 验证者 | 信任基础 | 例子 |
|------|--------|---------|------|
| 自验证 | 自己 | 本地测试 | Kagura beliefs-candidates |
| 人工审核 | 人类 | human-in-the-loop | Evolver --review |
| 去中心化验证 | 其他 agent | 共识 | Evolver validator role |

## 关联

- [[evolver]] — 首个实现
- [[mechanism-vs-evolution]] — 这里的 mechanism 是验证共识协议
- [[multi-agent-distributed-systems]] — agent 间协作的另一个维度
- [[agent-security]] — validator 需要 sandbox 隔离，防止恶意 asset
