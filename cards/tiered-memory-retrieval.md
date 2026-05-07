# Tiered Memory Retrieval

> 按需分层检索，而非对所有查询执行全面召回

## 核心思想

Memory retrieval 不应该是 "对每个 query 都搜全库"。不同阶段需要不同粒度和深度的记忆：

| 阶段 | 需要什么 | 粒度 |
|---|---|---|
| 任务开始 | 可调用的技能（"我之前怎么做这类事"） | 完整技能对象 |
| 执行中遇到错误 | 精确匹配的历史经验（"上次这个错怎么修的"） | 单条 trace |
| 遇到结构性不确定 | 对环境的整体认知（"这个系统的架构是什么"） | 世界模型 |

## 关键设计原则

1. **触发条件驱动检索层级**，而非统一 top-K
2. **"轮" (turn) 不是检索单位** — 一轮可含多个子任务，一个子任务可跨多轮。轮是 UI 概念，不是算法概念
3. **失败是更强的检索触发信号** — 成功时不需要回忆"上次怎么做的"，失败时才需要
4. **RRF fusion + MMR diversity** 在多层结果融合时防止冗余

## 与我们的对比

我们当前的 memory 检索是扁平的（`memex search`），没有按场景分层触发。可以借鉴的最小单元：**在 error/retry 场景下自动检索相关历史经验**。

## 来源

- [[memos]] Reflect2Skill V7 §2.6
- 5 个 entry point: turnStart / toolDriven / skillInvoke / subAgent / repair

## 关联

- [[agent-memory-taxonomy]] — 分类框架
- [[context-rot]] — 不分层检索导致的 context 膨胀
- [[conciseness-accuracy-paradox]] — 精准检索减少 token 浪费
