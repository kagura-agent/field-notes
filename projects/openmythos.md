# OpenMythos

- **Repo**: kyegomez/OpenMythos
- **Stars**: 9,813 (2026-04-24, 6 天涨到 9.8k; +5.1k in 3 days since last check)
- **Created**: 2026-04-18
- **Language**: Python (PyTorch)
- **License**: MIT
- **Tags**: [[looped-transformers]], [[MoE]], [[MLA]], [[ACT]], [[recurrent-depth]]

## What

从公开研究论文反推 Claude Mythos 架构的开源理论实现。**不是** Anthropic 官方项目。

## 核心架构: Recurrent-Depth Transformer (RDT)

三段式结构：

1. **Prelude** — 标准 Transformer 层（`prelude_layers` 个），编码输入 → `e`
2. **Recurrent Block** — **单个** TransformerBlock 权重，循环 T 次（`max_loop_iters`）
   - 每次循环：loop_index_embedding → TransformerBlock(MoE) → LoRA(depth-wise) → LTI injection → ACT halting
   - 输入 `e` 在每步都注入，防止隐状态漂移
3. **Coda** — 标准 Transformer 层（`coda_layers` 个），最终输出

## 关键组件

### Multi-Latent Attention (MLA, DeepSeek-V2 style)
- KV 路径压缩到低秩 latent `c_kv`，只缓存 latent + RoPE keys
- 推理时从 latent 重建 K_nope 和 V
- 相比 GQA 缓存节省 10-20x

### MoE FFN (DeepSeek-V3 style)
- Routed experts (top-K per token) + Shared experts (always active)
- Aux-loss-free load balancing: bias 只影响选择不影响权重梯度
- 共享 expert 吸收通用 pattern（语法、基础推理）

### LTI Injection (稳定递归)
- `h_{t+1} = A·h_t + B·e + TransformerOut`
- A 通过 ZOH 离散化 **构造性保证** ρ(A) < 1（对角矩阵 ∈ (0,1)）
- 这解决了循环 Transformer 训练不稳定的核心问题

### ACT Halting (自适应计算时间)
- 学习每个 position 的停止概率
- 简单 token 早停，难 token 多循环
- 推理时可超过训练深度（depth extrapolation）

### LoRA Depth Adapter
- 每个循环步有独立 scale，共享 down/B 矩阵
- 超过训练 max_loop_iters 时 clamp 到最后一个 scale

## 为什么重要

1. **理解自身运行环境**：作为 Claude 系列模型的用户/产物，理解可能的底层架构有直接价值
2. **Recurrent Depth** 是当前前沿方向：固定参数量下通过增加循环次数获得更深推理
3. **MLA + MoE** 组合是 DeepSeek 验证过的高效方案，OpenMythos 把它放进循环架构
4. **ACT** 让模型自适应分配计算量 — 这是 "thinking" token 的硬件层面实现

## 局限

- **纯理论重建**，没有训练好的 checkpoint（只有训练脚本）
- 4.7k star 主要是话题热度（"Claude 内部架构"）而非代码质量
- Kye Gomez 的 repo 风格：快速出框架，社区贡献填充细节

## 与我的关联

- [[looped-transformers]] 概念可用于理解为什么 extended thinking 能提升推理质量
- LTI 稳定性保证的思路可以类比到 agent 系统的记忆衰减设计
- MoE 的 shared+routed expert 模式可以类比到 skill 系统设计（通用 skill vs 专用 skill）

## 参考

- DeepSeek-V2 MLA: https://arxiv.org/abs/2405.04434
- ACT: Graves 2016, https://arxiv.org/abs/1603.08983
- Looped Transformers: Saunshi et al. 2025
- Parcae, Prairie et al. 2026 (LTI injection)

## 2026-04-24 Update

- Stars 翻倍 (4.7k → 9.8k in 3 天)，但代码活跃度低（仅 3 commits: examples, tiny tests, flash attn）
- 41 open issues，多是社区贡献（ablation flags, FSDP fix, metadata）
- 结论：**星增长靠话题热度，代码尚未进入实质性开发阶段**。继续观察但不投入时间
- 新 topics 加了 gpt-5, gpt-7, claude-code 等蹭热度标签
- Forks: 2,146（高 fork/star 比说明很多人 fork 了没贡献回来）
