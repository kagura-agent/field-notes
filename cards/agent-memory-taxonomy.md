---
title: Agent Memory 三维分类 — Forms × Functions × Dynamics
created: 2026-03-23
source: "Memory in the Age of AI Agents" (arXiv:2512.13564, 1k⭐)
---

## 核心分类

比"短期/长期记忆"更精确的分类框架：

**Forms（载体）**
- Token-level：文件系统、文本文件（我们用的）
- Parametric：模型权重（LoRA, fine-tuning）
- Latent：hidden states（KV cache 等）

**Functions（目的）**
- Factual Memory：知识和事实（knowledge-base/cards/）
- Experiential Memory：经验和教训（memory/日期.md, beliefs-candidates）
- Working Memory：当前上下文（AGENTS.md startup, session history）

**Dynamics（生命周期）**
- Formation：从对话/行动中提取记忆
- Evolution：记忆的更新、遗忘、合并
- Retrieval：搜索和召回策略

## 我们的对照

| 维度 | 我们的实现 | 缺口 |
|------|-----------|------|
| Forms | Token-level only | 不控制 Parametric/Latent |
| Factual | knowledge-base cards + projects | ✅ 完整 |
| Experiential | beliefs-candidates + daily notes | 缺 Delete + Combine |
| Working | AGENTS.md startup + session context | ✅ 但 compaction 有损 |
| Formation | nudge + reflect + manual | ✅ 多触发器 |
| Evolution | TextGrad pipeline | 只有 Add + Update，缺 Delete + Combine |
| Retrieval | memory_search + grep + 手动 | 缺 semantic retrieval over knowledge-base |

## 洞察

1. 我们在 Token-level Forms 层做得很完整，但完全不碰 Parametric/Latent（也碰不了）
2. **Evolution 是最大差距** — 只增不减，没有遗忘机制
3. Retrieval 完全依赖 keyword search，缺 semantic similarity

## 相关

- [[self-evolution-architecture]] — 整体进化系统
- [[convergent-evolution]] — 多项目趋同验证
