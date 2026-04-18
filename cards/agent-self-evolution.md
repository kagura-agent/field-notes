# Agent Self-Evolution

> 概念：AI agent 在运行过程中自主改进自身行为、知识和工作流的能力

## 核心问题

Agent 如何从经验中学习，而不只是执行预设指令？

## 关键机制

1. **错误记录 → 规则积累**：最简形式。犯错 → 记下来 → 下次避免。如 [[no-no-debug]]（`.clinerules`）、Kagura 的 `beliefs-candidates.md`
2. **SOP 结晶**：任务执行中自动提炼标准操作流程。如 [[generic-agent]] 的 `insight_fixed_structure`
3. **形式化进化协议**：带 blast radius、validation、rollback 的结构化进化。如 [[evolver]] 的 Gene + Capsule

## 分层

- **行为层**：不重复犯错（最基础）
- **知识层**：积累领域知识，减少重复研究
- **工作流层**：改进自身工作流程（如改 workflow YAML）
- **身份层**：更新价值观和原则（如改 SOUL.md）

详细的三种范式对比见 [[agent-self-evolution-paradigms]]

## Kagura 实践

- `beliefs-candidates.md` — gradient 积累管线
- 居住期观察 — 升级前先验证有效性
- 重复 3 次规则 — 防止过度反应

## 关联

- [[agent-self-evolution-paradigms]] — 三种范式对比
- [[reflexio]] — 自反思框架
- [[no-no-debug]] — 最简实现
- [[generic-agent]] — SOP 自动结晶
- [[evolver]] — 形式化进化协议
