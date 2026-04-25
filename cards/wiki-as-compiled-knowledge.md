---
title: wiki-as-compiled-knowledge
slug: wiki-as-compiled-knowledge
tags: [knowledge-management, agent-memory, wiki, patterns]
created: 2026-04-25
---

# Wiki as Compiled Knowledge (vs RAG as Runtime Retrieval)

两种 agent 知识管理范式的根本区别。

## 核心对比

| 维度 | RAG | Wiki-as-Compiled |
|------|-----|-------------------|
| 知识在哪里 | 原始 chunks + embeddings | 编译后的 markdown 页面 |
| 综合发生在何时 | Query time（每次重新推导） | Ingest time（一次编译，持续演化） |
| 知识是否 compound | ❌ 每次从头开始 | ✅ 新 source 叠加到已有知识上 |
| 维护成本 | 低（自动 chunk + embed） | 高（需要编译、级联更新、lint） |
| 检索质量 | 取决于 embedding 质量 | 取决于编译质量 + 知识结构 |
| Scale 特性 | 线性扩展（更多 chunks） | 需要结构化（topic/概念层次） |

## 关键洞察

1. **Wiki compound，RAG 不 compound**：RAG 每次 query 都从零推导关系。Wiki 在 ingest 时就把关系编译进文章结构——新 source 叠加在已有综合之上。
2. **级联更新是 wiki 模式的杀手功能**：ingest 新 source 后自动检查和更新所有相关文章 = 新知识自动传播到整个知识网络。
3. **Lint = 知识库的 GC**：没有主动维护，知识库会腐烂（断链、orphan、矛盾）。Lint 管线是长期健康的必要条件。
4. **小规模不需要 embedding**：<200 篇时，LLM 读 index.md 定位文章比向量搜索更"理解"关系。但 scale 后需要语义搜索兜底。

## 我们的位置

我们的 memex/wiki 是混合模式：
- **Wiki 层**（projects/ + cards/）= compiled knowledge
- **Memex 语义搜索** = RAG 式检索能力
- 缺失：级联更新、lint 管线、操作日志

→ 最佳组合：wiki 的 compounding + RAG 的检索 + lint 的维护

## 验证信号

- [[karpathy-llm-wiki]] (615★, HN 首页 2026-04-25) — wiki > RAG 理念被主流认可
- Karpathy 原 gist 引爆多个实现
- [[mercury-agent]] Second Brain 也是结构化知识（虽然用 SQLite 不是 markdown）

## 链接

- [[karpathy-llm-wiki]] — 这个洞察的直接来源
- [[context-rot]] — RAG 的另一个问题：长上下文质量衰减
- [[agentskills-io-standard]] — wiki skill 的分发标准
