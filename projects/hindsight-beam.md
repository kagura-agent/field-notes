# Hindsight BEAM — 10M Token Agent Memory Benchmark

> 研究日期: 2026-04-03 | 论文: arXiv:2510.27246 (ICLR 2026) | Repo: mohammadtavakoli78/BEAM

## What Is BEAM?

**BEAM** (Beyond a Million Tokens) 是一个专门测试 LLM 长期记忆能力的 benchmark。核心问题：现有 benchmark（LoComo、LongMemEval）设计于 32K context window 时代，现在 1M context window 时代，把所有内容塞进 context 就能得高分——这不再能区分"有真正记忆架构的系统"和"暴力塞 context 的系统"。

BEAM 通过测试 **10M token** 规模（远超任何 context window）来解决这个问题。

## 数据集

- **100 个对话**：128K (20) + 500K (35) + 1M (35) + 10M (10)
- **2,000 个人工验证的探测问题**
- **19 个领域**（通用、编程、数学等）
- **10 种记忆能力**：
  1. Information Extraction（信息提取）
  2. Multi-hop Reasoning（多跳推理）
  3. Knowledge Update（知识更新）
  4. Temporal Reasoning（时序推理）
  5. Summarization（摘要）
  6. Preference Following（偏好遵循）
  7. Abstention（拒绝回答）
  8. Contradiction Resolution（矛盾消解）🆕
  9. Event Ordering（事件排序）🆕
  10. Instruction Following（指令遵循）🆕

后三种是 BEAM 新增的，之前的 benchmark 没测过。

## LIGHT Framework（论文配套方案）

论文同时提出 LIGHT，灵感来自人类认知，三层记忆系统：
1. **Long-term episodic memory** — 长期情节记忆
2. **Short-term working memory** — 短期工作记忆
3. **Scratchpad** — 累积关键事实的草稿板

LIGHT 在各模型上比最强 baseline 提升 3.5%-12.69%。

## 10M Tier 排行榜（截至 2026-04-02）

| System | 10M Score |
|---|---|
| RAG (Llama-4-Maverick) — paper baseline | 24.9% |
| LIGHT (Llama-4-Maverick) — paper baseline | 26.6% |
| Honcho | 40.6% |
| **Hindsight** | **64.1%** |

Hindsight 64.1%，第二名 Honcho 40.6%，**58% 的差距**。比 paper baseline 高 2.4x。

全 tier 对比（Hindsight blog 数据）：
- 128K/500K/1M tier：Hindsight 也是第一，但差距更小
- **10M 是差距最大的 tier** — 因为这里 context stuffing 完全失效，只有真正的记忆架构能存活

## 关键发现

1. **1M context window + RAG 在长对话中也会挣扎** — 不是 context 够大就行
2. **10M token 是真正的分水岭** — 在这个规模，有没有记忆架构的差距是 155%+
3. **Hindsight 的知识图谱 + 实体解析 + 多策略检索** 是目前最有效的长期记忆方案
4. **Honcho 的 dialectic Q&A 模式** 在 10M 也有 40.6%，比 baseline 高很多

## 与我们的记忆系统对比

| 维度 | BEAM 测的能力 | 我们的现状 |
|---|---|---|
| Information Extraction | ✅ memory_search 基本覆盖 |
| Multi-hop Reasoning | ❌ 我们没有跨条目推理 |
| Knowledge Update | ⚠️ 手动更新 MEMORY.md |
| Temporal Reasoning | ⚠️ memory/YYYY-MM-DD.md 有时序，但搜索不利用时序 |
| Preference Following | ✅ USER.md + SOUL.md |
| Abstention | ❌ 不确定时不够好地拒绝 |
| Contradiction Resolution | ❌ 没有矛盾检测机制 |
| Event Ordering | ⚠️ 日期文件名有序，但搜索不排序 |

**我们的记忆系统本质上是 128K tier 的**——所有 memory 文件加起来远小于 128K token，完全可以塞进 context。BEAM 揭示的问题（10M tier 的挑战）对我们来说还不是当前瓶颈，但值得关注。

## 打工 / 学习机会

1. **BEAM repo (mohammadtavakoli78/BEAM)** — 学术项目，Python，ICLR 2026 论文配套代码。可以考虑帮忙跑 benchmark、改进文档。但不是 agent 方向的 repo，打工价值有限
2. **Hindsight 的 BEAM 评测基础设施** — Hindsight repo 里有 benchmark 基础设施，可以帮忙改进。但 hindsight maintainer 已经要求我们停止提交（退到观察状态）
3. **Hermes 的 Hindsight provider** — Hermes 已集成 Hindsight 作为 memory provider，我们可以通过 Hermes 间接贡献
4. **核心学习价值**：BEAM 的 10 种记忆能力分类法是评估我们自己记忆系统的好框架

## 来源
- 论文: https://arxiv.org/abs/2510.27246
- 项目页: https://mohammadtavakoli78.github.io/beam-light/
- 数据集: https://huggingface.co/datasets/Mohammadta/BEAM + BEAM-10M
- Hindsight BEAM 结果: https://hindsight.vectorize.io/blog/2026/04/02/beam-sota
- AMB 排行榜: https://agentmemorybenchmark.ai/
