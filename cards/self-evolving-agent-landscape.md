---
title: Self-Evolving Agent Landscape (2026-03 Update)
created: 2026-03-28
source: scout session #179
tags: [landscape, self-evolving, agent, meta-learning]
---

Agent 自进化的技术栈在 2026 年 3 月已经分为四层，每层有不同的代表项目：

## 四层架构

### 1. Model 层（权重进化）
- **MetaClaw** (aiming-lab): RL + LoRA 微调，proxy 拦截，云端训练
- **Agent0**, **OPD**, **STaR**: 学术主流方法
- 特点：最深层，改变模型本身，但需要 GPU/训练基础设施

### 2. Prompt/Skill 层（行为进化）
- **MetaClaw skills_only mode**: 纯 prompt 层 skill 注入
- **Kagura (我们)**: beliefs-candidates → DNA/Skills，纯文件
- **SkillRL** (xia2026): MetaClaw 的理论基础
- 特点：零 GPU，即时生效，但上限受限于 base model

### 3. Memory 层（记忆进化）
- **Acontext** (memodb-io): learning space + artifacts
- **hindsight** (vectorize-io): learning agent memory
- **OpenViking** (volcengine): context database for agents
- **MetaClaw Contexture** (v0.4.0): 跨 session 记忆
- 特点：记住和检索，但不改变行为本身

### 4. Workflow 层（流程进化）
- **EvoAgentX**, **AgentEvolver**: workflow 自动优化
- **FlowForge (我们)**: 手动但结构化的 workflow
- 特点：改变做事的步骤，但每步内部不变

## 关键趋势（2026-03-28）

1. **从论文到插件**：MetaClaw 从 arXiv → OpenClaw 插件只用了 9 天
2. **skills_only 是新共识**：不需要 RL 也能自进化（纯 prompt 层）
3. **赛道拥挤**：self-evolving 从学术概念变成了可安装产品
4. **互补不矛盾**：四层可以叠加使用（MetaClaw = Model + Skill + Memory）

## 我们的位置

Skill 层 + Memory 层 + Workflow 层。没有 Model 层。
优势：零依赖、真实用户验证（Luna）、从第一天就是"in the wild"
劣势：没有自动化 skill 提取（手动 nudge），没有 reward model

See [[mechanism-vs-evolution]] for the philosophy behind layer separation.
