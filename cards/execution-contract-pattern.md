# Execution Contract Pattern

## 定义
Agent 运行时根据 model identity 动态调整执行行为（prompt overlay + runtime enforcement），而非使用统一规则。

## 来源
OpenClaw #65597 (2026-04-13) — GPT-5.4 自动激活 `strict-agentic` 合约。

## 核心思想
不同 LLM 有不同的行为倾向：GPT-5 倾向「规划后停顿」，Claude 则更倾向直接行动。统一 prompt 无法同时优化两者。

## 实现层次
1. **Prompt overlay**（软约束）：添加 model-specific 系统提示段，引导行为倾向
2. **Runtime detection**（硬约束）：检测不良模式（如 single-action-then-narrative）并强制 retry
3. **Contract activation**：自动激活（model id → contract type），支持用户 opt-out

## 设计决策
- 用正则表达式检测意图（确定性、低成本），不用 LLM 判断（昂贵、不确定）
- Safe tool allowlist：只对无副作用工具（read/search/grep）允许自动 retry
- Provider-scoped：不同 provider（OpenAI vs Anthropic）可以有不同合约

## 跟我们的关系
- AGENTS.md 的 `Tool Call Style` 是 DNA 级自约束，OpenClaw 是 runtime enforcement——互补
- DNA 在长 context 下容易被淹没，runtime enforcement 更可靠
- 如果未来 Workshop 需要处理多 model，这个模式是参考架构

## 关联
- [[openclaw-architecture]] — GPT-5 Single-Action-Then-Narrative Detection
- [[loop-detection-comparison]] — 另一种 runtime enforcement（tool loop）
- [[tool-stagnation-detection]] — agent 行为退化检测
