# Beliefs Candidates

梯度收集器——记录行为反馈和教训的候选管线。

## 机制
1. 发现 pattern/教训 → 写入 `beliefs-candidates.md`
2. 同一条重复 3+ 次 → 升级到最佳载体：
   - **始终适用** → DNA（AGENTS.md / SOUL.md）
   - **特定任务** → Workflow（workloop.yaml 节点描述）
   - **特定领域** → Knowledge-base（wiki cards/projects）
3. 不是所有东西都该进 DNA——被动知识在行动时没约束力

## 治愈追踪 (2026-04-17 引入)

借鉴 [[no-no-debug]] 的 "cured" 概念，给升级后的 gradient 加状态追踪：
- **Upgraded → Cured**: 升级后 ≥3 周无同类 pattern 复发
- **Upgraded → Recurring**: 升级后仍有复发，说明 DNA 规则未充分生效

首次审计结果：`skip-own-tools` 和 `check-before-invest` 已 CURED；`verify-*` 系列仍 RECURRING（04-10 升级后 5+ 次违反）。

启示：验证纪律写进 DNA 不够——可能需要更强的机制（如 [[reflexio]] 的三重门静默检查）。

## 相关
- [[beliefs-upgrade-mechanism]]
- [[self-evolution-architecture]]
- [[no-no-debug]]
- [[reflexio]]
