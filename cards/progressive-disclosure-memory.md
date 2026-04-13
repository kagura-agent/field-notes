# Progressive Disclosure for Memory Retrieval

> Pattern: 分层检索，先索引后详情，按需加载

## 核心思路

检索不应该一次返回所有详情。分层：
1. **Index layer** — 紧凑摘要（~50-100 tokens/result）
2. **Context layer** — 时间线/关联（可选中间层）
3. **Detail layer** — 完整内容（~500-1,000 tokens/result）

用户（或 agent）先看索引判断相关性，再按需 fetch 详情。约 10x token 节省。

## 来源

[[claude-mem]] v12 的 MCP Search Tools（search → timeline → get_observations）。

## 适用场景

- wiki/memory 检索（memex search 目前是一步到位，缺索引层）
- skill context 注入（先 name+description，按需加载 SKILL.md — 即 [[skill-lazy-loading-poc]]）
- observation/日志回顾（先标题列表，再选择性深入）

## 与其他概念的关系

- [[llm-wiki-karpathy]]: Karpathy 用 index.md 做第一层（类似 index layer）
- [[skill-lazy-loading-poc]]: always tier = index layer, discoverable = defer to detail layer
- [[cron-observability-metrics]]: metrics summary = index layer, full trace = detail layer

## 反面模式

全量注入所有 context（token 浪费）。claude-mem Knowledge Agents 有趣的是，它在 corpus query 时反而用全量注入（因为已经经过 build 阶段的过滤），progressive disclosure 只在 search 阶段使用。

## 应用状态

- ✅ **memex search `--compact`**: 实现中（feat/compact-search branch）—— Layer 1 (index) + Layer 2 (normal) + Layer 3 (`memex read`)
- ✅ **skill lazy loading**: [[skill-lazy-loading-poc]] PR 已提交（openclaw #65139）—— always tier ≈ compact, discoverable ≈ deferred load
- ⏳ **memory_search**: OpenClaw 内置，未改（但 dreaming system 的 light sleep → REM 已是类似模式）
- ⏳ **cron observability**: [[cron-observability-metrics]] 概念卡已有，未实现

---
*Created: 2026-04-13 | Source: [[claude-mem]] MCP Search Tools*
*Updated: 2026-04-13 | Applied to memex compact search*
