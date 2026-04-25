---
title: Memex 自动 Fact Extraction 设计方案
slug: memex-auto-extraction-design
tags: [memex, memory, fact-extraction, architecture, self-evolving]
created: 2026-04-25
evidence_count: 2
last_reinforced: 2026-04-25
modified: 2026-04-25
---

# Memex 自动 Fact Extraction 设计方案

基于 [[mercury-agent]] v1.0.0 "Second Brain" 架构研究，为 memex 设计的自动知识提取方案。

## 核心洞察

Mercury 证明了 **post-session LLM extraction**（~800 tokens/次，提取 0-3 facts）是可行且低成本的。但 Mercury 的弱点（FTS5 搜索、扁平 fact 列表、SQLite 存储）恰好是 memex 的强项（语义 embedding、wikilink 网络、markdown 文件）。

**最佳组合 = memex 语义搜索 + Mercury 式自动提取 + 生命周期管理**

## 设计方案

### 1. Post-session Extraction Hook

Session 结束时触发 background LLM 调用：
- 输入：session 摘要（compact 后的对话）
- 输出：0-3 个 fact candidates，每个带 `type`（identity/preference/goal/project/decision/insight）和 `confidence`（0-1）
- 成本：~800 tokens/次，对于日常 session 频率完全可承受

### 2. Fact → Card 路由

提取的 fact 不进 SQLite，而是：
1. **语义搜索已有 cards**（memex search）
2. **命中（similarity > 0.8）** → append 到已有 card，更新 `last_reinforced` 和 `evidence_count`
3. **未命中** → 创建 draft card（frontmatter 标记 `status: draft`，等人工或自动审核）

### 3. 生命周期管理

在 card frontmatter 新增字段：
```yaml
evidence_count: 3        # 被多少次独立 session 强化
last_reinforced: 2026-04-25
confidence: 0.85
status: active|draft|stale|archived
```

规则（借鉴 Mercury，调整参数）：
- `evidence_count >= 3` → 自动 promote 为 `active`
- 30 天未 reinforce → `stale`（比 Mercury 的 21 天宽松，因为我们的 session 频率不同）
- `stale` + 90 天 + `confidence < 0.5` → `archived`

### 4. 冲突检测

利用 `memex organize` 已有的 contradiction detection，加入：
- 新 fact 与已有 card 语义矛盾 → 标记为 conflict，不自动覆盖
- conflict 解决：按 evidence_count + recency 加权，或等人工裁决

## 对比 Mercury

| 维度 | Mercury | 本方案 |
|------|---------|--------|
| 存储 | SQLite 行 | Markdown 文件（人类可读）|
| 搜索 | FTS5 关键词 | Embedding 语义 |
| 知识结构 | 扁平列表 | [[wikilink]] 网络 |
| 提取方式 | 相同：post-session LLM |  |
| 生命周期 | 相同：reinforce/stale/prune |  |
| 冲突解决 | 自动覆盖 | 标记 + 等裁决（更安全）|

## 实现状态

### Phase 1 ✅ (2026-04-25)

已实现并合入 kagura-agent/memex main。

**新增 `memex lifecycle` 命令：**
- `memex lifecycle audit` — 扫描所有卡片，报告 status 分布、需要关注的卡片、近期 reinforce 记录
- `memex lifecycle reinforce <slug>` — 增加 evidence_count，更新 last_reinforced，触发 auto-promote
- `memex lifecycle init [--dry-run]` — 为所有缺少 lifecycle 字段的卡片初始化

**生命周期规则：**
- `evidence_count >= 3` → auto-promote 为 `active`
- 30 天未 reinforce → `stale`（高 evidence 卡片豁免）
- `stale` + 90 天 + `confidence < 0.5` → `archived`

**额外修复：**
- `stringifyFrontmatter` 现在正确处理 arrays、numbers、dates、booleans（之前全部 `String()` 化会丢失类型）
- `memex organize` 新增 Lifecycle Summary section

### Phase 2 ✅ (2026-04-25)

已实现并合入 kagura-agent/memex main。

**新增 `memex extract` 命令：**
- `memex extract < session.md` — 从 stdin 读取 session transcript
- `memex extract --file session.md` — 从文件读取
- `memex extract --dry-run` — 预览模式，不写入
- `memex extract --model <model>` — 指定 LLM 模型

**提取流程：**
1. 截取 transcript 前 6000 字符（控制 LLM 成本）
2. LLM 提取 0-3 个 facts（type: identity/preference/goal/project/decision/insight/pattern）
3. 语义搜索已有 cards（similarity > 0.78 = 命中）
4. 命中 → reinforce + append evidence section
5. 未命中 → 创建 draft card（带完整 lifecycle frontmatter）

**LLM 后端支持：**
- OpenAI-compatible API（复用 .memexrc 的 openaiApiKey/openaiBaseUrl）
- Shell command 模式（`llmCommand` config / `MEMEX_LLM_COMMAND` env）
  - 例：`"llmCommand": "openclaw capability model run --gateway"` 通过 OpenClaw gateway 调用

**新增 lib/llm.ts：**
- 轻量级 OpenAI chat completion client（纯 Node native http/https，零依赖）

### Phase 3 ⭕ (TODO)

auto-merge + conflict detection

## 链接

- [[mercury-agent]] — 原始灵感来源
- [[agent-memory-taxonomy]] — 记忆分类框架
- [[agent-skill-standard-convergence]] — 标准收敛趋势
