# SkVM — Skill Virtual Machine

> SJTU-IPADS/SkVM | 85★ | TypeScript | 2026-04-19 深读
> Paper: https://arxiv.org/abs/2604.03088

## 核心定位

**把 agent skill 视为可编译产物**。不同模型有不同能力，skill 应该针对目标模型编译和优化，而非一份 SKILL.md 通吃所有模型。

## 解决什么问题

同一个 skill 在 Claude Opus 上效果好，换到 Qwen 或 GPT-4o 就不行了。原因是 skill 假设了特定能力（长上下文、工具调用格式、推理深度等）。SkVM 通过 profiling + compilation 自动适配。

## 架构（四阶段）

```
1. Profile    — 测量 model+harness 的基础能力（~20min）
2. AOT-Compile — 按 profile 重写 skill（编译器模型做翻译）
3. JIT-Optimize — 用合成任务或日志做 edit→rerun→score 循环
4. Benchmark   — 对比 original vs compiled vs optimized
```

### 关键概念
- **Primitive capabilities**: 模型的基础能力矩阵（可量化）
- **Compilation passes**: 多轮编译，每轮适配一个维度
- **Proposals**: 编译/优化结果存为候选方案，人可以 review
- **Agent-facing skills**: skvm-jit（post-task 自动优化）和 skvm-general（手动操作）

### 支持的 harness
openclaw, opencode, hermes, jiuwenclaw, pi, bare-agent

## 与我们的关联

1. **反直觉洞察**：我们假设"一个 SKILL.md 对所有模型"，SkVM 说这是错的。不同模型需要不同版本的 skill
2. **直接可用**：我们有 14+ 个 skill，SkVM 能自动优化。特别是跨模型切换时（Opus → Sonnet → GLM）
3. **与 [[agentic-stack]] 互补**：agentic-stack 做 portable brain，SkVM 做 portable skills。都在解 agent 跨 harness 问题，但从不同角度
4. **学术基础**：有 arxiv 论文，不是纯 hobby 项目。SJTU-IPADS 是系统方向强组

## 架构洞察

### 1. Skill 是代码，不是文档
把 SKILL.md 类比为源代码，profile 类比为 ISA spec，compilation 类比为交叉编译。这个类比强大且准确 — skill 确实有"指令集"假设（你得会用工具、你得能长推理）

### 2. JIT vs AOT 的分工
AOT 解决结构性适配（模型不支持的能力用 workaround 替换）；JIT 解决运行时质量（根据实际执行效果迭代改进）。两者正交。

### 3. Proposal-based 更新
编译/优化结果不直接覆盖原 skill，而是写到 proposals/ 目录供人 review。跟 [[agentic-stack]] 的 REVIEW_QUEUE.md 思路一致 — 机械工作自动化，判断留给人/agent。

## 在 Agent 生态中的位置

- **层级**：Agent 基础设施（skill 编译/优化）
- **竞品**：无直接竞品。DSPy 做 prompt 优化但不做跨 harness 编译
- **互补**：[[agentic-stack]]（portable brain）、各 skill 系统（OpenClaw skills、Hermes skills）
- **上游**：需要 LLM API 做编译和优化（compiler-model 参数）
- **下游**：各 harness 的 skill 目录

## 待跟进

- [ ] 试用 SkVM 优化我们的一个 skill（比如 github skill），看效果
- [ ] 读论文 arxiv 2604.03088，理解 capability profiling 的理论基础
- [ ] 观察社区增长和 issue 活跃度
