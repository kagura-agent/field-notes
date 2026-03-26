---
title: Memory Volume Control > Retrieval Technology
created: 2026-03-26
source: MemEvolve lightweight_memory code analysis
---

反直觉发现：解决"读比写难"的第一步不是更好的搜索算法，而是控制记忆总量。

## MemEvolve 的证据
- lightweight_memory 只存 30 条 strategic + 30 条 operational（硬上限）
- retrieve 方法：把 60 条全部展示给 LLM，让 LLM 选 top-5
- 没有向量搜索、没有标签过滤、没有语义匹配
- 性能并不差——在某些任务上赢过复杂架构

## 为什么有效
- LLM 的 context window 是天然的"全量读取 + 智能选择"引擎
- 60 条 * ~50 tokens ≈ 3000 tokens，对现代模型不算什么
- 剪枝机制保证总量可控（`_intelligent_prune_memories` + `success_rate` 排序）

## 优先级
```
manage（控制总量）> retrieve（搜索技术）> store（存储结构）> encode（写入格式）
```

直觉上以为 retrieve 最重要，实际上 manage 才是前置条件。
如果总量小到可以全量读，retrieve 就退化为"让 LLM 选"——最简单也最可靠。

## 对我们的启示
- 不需要 hindsight/embedding 做记忆后端
- 需要把 patterns 控制在 30-50 条
- 每条 pattern 有 usage_count 和 success_rate → 低效的可以剪枝
- self-improving 的"全量读 + 选最相关"做法是对的，问题是没执行

## 相关
- [[write-read-gap]] — 这是根问题
- [[begin-vs-in-phase-memory]] — retrieve 的时机
- [[memevolve]] — 源自 MemEvolve 代码分析
