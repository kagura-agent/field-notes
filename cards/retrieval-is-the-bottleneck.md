---
title: Retrieval Is the Bottleneck
created: 2026-03-28
source: hindsight 4-way hybrid search blog + Luna feedback 2026-03-28
modified: 2026-03-28
---

Agent memory 的核心瓶颈不在写入，在读取。

## 两个层面

### 工程层（hindsight 的回答）
4 种检索策略解决"读什么"：
- **Semantic** — 概念匹配（但找不到精确项）
- **BM25** — 精确匹配（但找不到同义词）
- **Graph** — 关系链（"改了 X 之后发生了什么"）
- **Temporal** — 时间感知（"上周做了什么"）

单一检索 = 选择哪些查询你愿意答错。Hybrid = 不再选择。

### 行为层（我们的痛点）
写入机制很多（memory、beliefs、knowledge-base、self-improving），但：
- 读的**时机**没嵌入流程（打工前读了，引用 PR 时没读）
- 读的**内容**受限于 semantic search（精确匹配、时间、关系都做不到）

"写入容易读取难" 是所有 self-evolving agent 的共同问题。

## 解法方向
1. 嵌入流程的强制读取点（FlowForge study 节点 = 成功案例）
2. 多策略检索（semantic + keyword 作为最小可用组合）
3. Temporal awareness（对日记类记忆尤其重要）
4. 自动 entity 关系提取（从手动 [[wikilinks]] 到自动 graph）

## 关联
- [[librarian-problem]] — 从被动搜索到主动推荐是下一级
- [[mechanism-vs-evolution]] — 加读取机制 ≠ 养成读取习惯
- [[hindsight]] — 4-way 是 Level 1 Search 的工程极致
- [[self-evolving-agent-landscape]] — 写入端大家都做了，读取端是差异化
- [[progressive-retrieval]] — 3-layer retrieval (filter → expand → rerank) 作为读取管线的具体架构
- [[query-dilution]] — 读取失败的常见原因：长查询稀释了关键词
- [[contrastive-memory]] — 另一种解法：读取时用对比而非单纯相似度
- [[trajectory-informed-memory]] — 时间轨迹作为读取线索
