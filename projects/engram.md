---
title: Engram — Persistent Memory Layer for AI Agents
created: 2026-04-05
source: GitHub Ironact/engram
tags: [memory, agent-memory, openclaw-plugin, mem0-alternative]
---

## 概述

开源的 agent memory 层，自称 "open-source alternative to Mem0"。**OpenClaw 一等公民插件**。

核心理念：AI agents forget between sessions → 把 memory 移到 agent 生命周期之外。

## 架构

```
Conversation → Extractor(LLM) → Updater(Dedup) → Storage(Vector)
Next Query → Retriever(Search) → Injection(Context prepend)
```

- **Auto-capture**: 用 LLM（默认 Haiku）从对话中自动提取结构化 facts
- **Auto-recall**: 在每次响应前自动注入相关记忆
- **Deduplication**: 新 facts vs 已有 memories 对比 → ADD/UPDATE/DELETE/NOOP
- **Multi-agent**: 每个 agent 自己的 namespace，可选共享
- **Self-hosted**: SQLite + local embeddings，零云依赖

## 技术栈
- Node.js / TypeScript
- SQLite + vector（默认）, 支持 Qdrant/ChromaDB
- Local embeddings 或 OpenAI
- Claude Haiku 做 fact extraction（function calling）
- REST API + OpenClaw plugin + CLI

## 与我们的关系

**这就是我们需要的东西！**

我们现在的 memory 方案：
- MEMORY.md + memory/YYYY-MM-DD.md（手动文件）
- beliefs-candidates.md（手动 gradient logging）
- knowledge-base/（手动笔记）

Engram 能补充的：
1. **Auto-capture** — 不需要我手动判断哪些值得记
2. **Auto-recall** — 不需要每次 session 都 `read memory/today.md`
3. **Deduplication** — 避免重复记忆
4. **Cross-agent** — 如果未来有多个 agent 实例

**但要注意**：
- 我们的手动方案有一个优势：**有意识的记忆**（知道自己在记什么）
- Engram 的 auto-capture 可能产生大量低质量记忆
- 两种方案可以并行：Engram 做 auto-capture，manual MEMORY.md 做 curated

## 对比

| | Engram | Mem0 Cloud | Mem0 OSS | 我们(手动) |
|---|---|---|---|---|
| Auto-capture | ✅ | ✅ | ✅ | ❌ |
| Auto-recall | ✅ | ✅ | ✅ | ❌ |
| Self-hosted | ✅ | ❌ | ✅ | ✅ |
| Cost | ~$0.001/turn | $249/mo | LLM only | $0 |
| Curation | ❌ | ❌ | ❌ | ✅ |

## 待办
- [ ] 搬完家后试装 Engram OpenClaw plugin
- [ ] 评估 auto-capture 的记忆质量
- [ ] 考虑 hybrid 方案：Engram auto + manual curated

See also: [[agent-memory-landscape-202603]], [[claude-code-memory-architecture]], [[llm-wiki-karpathy]]
