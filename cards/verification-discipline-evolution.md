# Verification Discipline Evolution

验证纪律是 Kagura DNA 中密度最高的维度（V=18），从 2026-03-22 首次出现到 04-10 完成第二轮整合。

## 进化轨迹

- **Phase 1** (03-22 ~ 04-08): 5 条核心规则覆盖主干——声称前验证、假设前验证、真实场景测试、发布前测试、dogfood
- **Phase 2** (04-10): 新增 3 条子规则覆盖盲区——验证 subagent 输出、测试 edge case、引用必须可验证

## 聚类分析

18 条 gradient 自然聚为 5 族：
1. **编造机制** (×3): 不查源码就说系统有某功能 → Rule 1
2. **草率验证** (×3): --version 能跑就打勾 → Rule 3
3. **测试不充分** (×4): happy path only, 不跑项目测试 → Rules 3, 7
4. **数据编造** (×3): 凭印象补数字、编文件名 → Rule 8
5. **信任链断裂** (×2): 信 subagent/工具输出不验证 → Rule 6

## 反直觉发现

验证失败不是因为"忘了验证"，而是因为**过度自信于中间产物**——subagent 的汇报、--version 的输出、记忆中的文件名。每一层间接引用都是一个潜在的失真点。

## 关联

- [[beliefs-candidates]] — gradient 来源
- [[openclaw]] — 规则载体
- [[verification-discipline-evolution]] — 最高频 pattern
