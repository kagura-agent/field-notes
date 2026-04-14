# Multi-Agent Coordination as Consensus

> 类型: 理论框架
> 来源: kirancodes.me (2026-04-14), FLP/Byzantine 经典论文
> 关联: [[claude-code-coordinator]], [[process-hang-watchdog]], [[multi-agent-distributed-systems]]

---

## 核心概念

多 agent 协作编写软件本质上是分布式共识问题：

1. **Prompt 欠定** → 合法实现空间 |Φ(P)| > 1
2. **多 agent 并行** → 每个 agent 在不同的 φ_i 上工作
3. **需要达成共识** → 所有 φ_i 必须 refine 同一个 φ

## 不可能性定理

| 定理 | 适用条件 | 结论 | Agent 映射 |
|------|----------|------|-----------|
| FLP (1985) | 异步 + crash failure | Safety + Liveness + FT 三选二 | Agent timeout/OOM = crash; 来回 revert = liveness 失败 |
| Byzantine (1982) | 同步 + f 个故障节点 | n > 3f+1 才能达成共识 | 误解 prompt ≈ Byzantine; 4 个 agent 最多容忍 1 个误解 |

## 实用缓解策略

- **串行管线** (Coordinator 模式): 避开并行共识，代价是速度
- **Failure Detector** (Chandra-Toueg): 检查 agent 存活状态，提高共识可能
- **减少歧义**: 更精确的 spec (具体文件路径、预期行为) 减少 Byzantine failure 概率
- **外部验证**: 测试/lint 作为协议外的正确性检查

## 反直觉发现

- 更聪明的模型**不能**解决协调问题——FLP 对参与者能力不变
- 单一 supervisor 不是解法——rebase conflict 意味着已完成的工作可能丢失
- 投票机制在软件空间不适用——实现空间太大，majority vote 无意义
