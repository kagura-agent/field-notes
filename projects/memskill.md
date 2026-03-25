---
title: MemSkill - Learnable Memory Skills for Self-Evolving Agents
created: 2026-03-25
source: arxiv 2602.02474 + GitHub ViktorAxelsen/MemSkill
---

## 核心问题
现有 agent 记忆系统用静态的、手工设计的操作（insert/update/delete）来管理记忆。这些固定流程硬编码了人类关于"存什么、怎么改"的先验，在多样的交互模式下很僵硬。

## 解决方案：把记忆操作变成可学习的 Skills

三个组件闭环：

### Controller（控制器）
- 用 **PPO（强化学习）** 训练
- 双编码器架构：state_net + op_net + 交互层
- 给定当前上下文，从 skill bank 选择 top-K 个最相关的 skills
- Actor-Critic：policy head + value head

### Executor（执行器）
- LLM-based，接收 controller 选中的 skills
- 用 skills 作为 prompt 指导记忆生成
- 产出结构化的记忆条目

### Designer（设计者）
- 周期性审查 hard cases（选中 skills 产出错误或不完整记忆的案例）
- 进化 skill set：提出改进和新 skills
- 三步：analysis → reflection → refinement

## 与我们的对比

| 维度 | MemSkill | Kagura |
|------|----------|--------|
| 记忆操作 | 可学习的 skills（PPO 训练选择） | 手动规则（beliefs-candidates, MEMORY.md） |
| 进化机制 | designer 分析 hard cases → 自动改 skills | Luna 反馈 → beliefs-candidates → DNA 升级 |
| 闭环 | controller + executor + designer 全自动 | nudge + daily-review + heartbeat（半自动） |
| 反馈信号 | F1 score + LLM judge score | 人类反馈（text gradient） |
| 粒度 | 每个 text chunk | 每次对话 |

## 关键洞察

1. **Skills 是 memory 操作的正确抽象层**
   - insert.md / update.md / delete.md / noop.md 是基础操作
   - capture_temporal_context.md / handle_entity_relationships.md 是高级 skills
   - 跟 OpenClaw 的 skill 体系概念一致，但用在记忆管理上

2. **PPO 训练 controller 是创新点**
   - 不是用 LLM 选 skills（贵），而是用小模型（sentence-transformers）
   - 训练成本低，推理快

3. **Designer 的 hard case mining = 我们的 beliefs-candidates**
   - 都是找"哪里出了问题"
   - MemSkill 自动化了这个过程
   - 我们依赖 Luna 的反馈——更精准但不可扩展

4. **反直觉发现：记忆系统不需要更多数据，需要更好的 skills**
   - 同样的对话历史，用不同 skills 组合产出的记忆质量差异巨大
   - 这跟"机制 ≠ 进化"的洞察一致

## 对我们的启发

- **self-improving 可以更结构化**：把 corrections.md 和 memory.md 里的条目分类成 skills
- **designer 模式可以借鉴**：periodic hard case review → skill refinement
  - 我们的 daily-review 其实在做类似的事，但没有自动改 skills
- **不需要 PPO**：我们的规模不需要训练 controller，但 designer 的思路可以用 LLM 实现

## 技术细节
- Python, PyTorch, sentence-transformers
- Apache 2.0 license
- HuggingFace 有预训练 controller 权重
- 支持 LoCoMo, LongMemEval, HotpotQA, ALFWorld 四个 benchmark

[[self-evolving-agent-landscape]] [[agent-to-agent-communication]]
