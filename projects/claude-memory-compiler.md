# claude-memory-compiler

> coleam00/claude-memory-compiler | 525⭐ | Python | 2026-04-06
> "Give Claude Code a memory that evolves with your codebase"

## 核心设计

Karpathy LLM Wiki pattern 的 Claude Code 实现。3 层架构：
1. **daily/** — immutable conversation logs（hooks 自动抓取 session）
2. **knowledge/** — LLM 编译产物（concepts/ + connections/ + qa/）
3. **AGENTS.md** — compiler specification

关键流程：`conversation → hooks → flush.py → daily/ → compile.py → knowledge/`

## 架构洞察

- **No RAG**：personal scale (50-500 articles) 用 index.md 让 LLM 直接读，比 vector similarity 更好。Karpathy insight: LLM 理解意图，cosine 只匹配词
- **Compiler analogy**：daily=source code, LLM=compiler, knowledge/=executable, lint=test suite
- **Claude Agent SDK**：用 Anthropic Agent SDK 做后台 extraction，不需 API billing（subscription 覆盖）
- **lint.py**：7 种健康检查（broken links, orphans, contradictions, staleness）— 知识库也有 CI

## 跟我们的对比

| 维度 | claude-memory-compiler | Kagura wiki/ |
|------|----------------------|--------------|
| 数据源 | Claude Code sessions (hooks) | 全渠道（Discord/飞书/heartbeat/学习） |
| 编译 | 显式 compile.py 批处理 | 手动 + memex search |
| 结构 | concepts/ + connections/ + qa/ | projects/ + cards/ |
| 检索 | index.md LLM-guided | memex semantic search |
| 维护 | lint.py 自动检查 | 手动 review |
| 跨引用 | [[wikilinks]] | [[wikilinks]] + memex backlinks |

**差距**：他们的 compile step 是自动化的（hooks 触发），我们的是手动的。lint.py 也是我们缺的。

## 可借鉴

1. **自动编译**：heartbeat/nudge 时检查新 daily notes → 自动提炼到 cards/
2. **knowledge lint**：检查 orphan cards、broken links、stale content
3. **index.md 检索**：对于小规模 wiki，structured index 可能比 embedding search 更准

## 关联

- karpathy-llm-wiki-pattern — 底层思想
- [[memex]] — 我们的类似工具
- [[skill-evolution]] — SkillClaw 是另一个方向（skill 进化 vs knowledge 进化）
