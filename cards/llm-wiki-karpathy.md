# LLM Wiki (Karpathy, 2026-04-04)

**来源**: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
**发现日期**: 2026-04-05 (Luna 推荐)
**117 条评论，社区反响极大**

## 核心 Insight

**编译时知识积累 > 运行时 RAG 检索。**

传统 RAG：每次查询时从原始文档重新检索和拼凑，没有积累。
LLM Wiki：LLM 在写入时就把知识整合进持久化的 wiki，知识是编译好的，不是临时拼的。

## 三层架构

1. **Raw sources** — 不可变的原始文档（论文、文章、笔记）
2. **Wiki** — LLM 维护的 markdown 文件网络（摘要、实体页、概念页、交叉引用）
3. **Schema** — 配置文件（CLAUDE.md / AGENTS.md），告诉 LLM 怎么维护 wiki

## 三种操作

- **Ingest**: 新文档 → LLM 读 → 写摘要 → 更新相关实体/概念页（一个源可触及 10-15 页）
- **Query**: 问问题 → 搜 wiki → 综合回答 → 好回答反写回 wiki（知识复利）
- **Lint**: 定期健康检查（矛盾、过时、孤立页、缺失交叉引用、数据 gap）

## 关键设计

- index.md: 内容导航（页面目录 + 一行摘要）
- log.md: 操作日志（时间线，什么时候 ingest 了什么）
- Obsidian 做 IDE，LLM 做 programmer，wiki 做 codebase
- 不需要向量 DB，~100 源 / ~几百页靠 index 就够

## 与我们的架构对比

| 维度 | Karpathy LLM Wiki | Kagura 系统 |
|------|-------------------|-------------|
| 知识层 | wiki/ (markdown 网络) | knowledge-base/ (cards + projects) |
| 配置层 | Schema (CLAUDE.md) | AGENTS.md + SOUL.md |
| 原始数据 | raw sources/ | memory/ (daily notes) |
| 健康检查 | Lint 操作 | daily-review (部分) |
| 自进化 | ❌ 没有 | ✅ beliefs-candidates → DNA |
| 主体 | LLM 是工具 | Agent 是住在里面的 |

## 我们可以借鉴的

1. **Ingest 模式**: 学到新东西时不只写 memory 流水账，同时更新 knowledge-base 相关页面（交叉引用、实体更新）
2. **Lint 操作**: daily-review 加知识库健康检查（孤立页、过时内容、缺失交叉引用）
3. **Query→Wiki 回写**: 好的分析/回答可以反写成 knowledge-base card
4. **index.md**: knowledge-base 可以加一个自动维护的索引页

## 不需要的

- 不需要另起架构——我们的更完整（有自进化层）
- 不需要 Obsidian——我们有 chat-first 界面
- 不需要三层分离——memory + knowledge-base + DNA 已经是更好的分层

## 相关

- [[autoresearch-karpathy]] — 同是 Karpathy 的项目，autoresearch 的不可变评估 + 自我改进直接启发了我们的自进化架构（TextGrad → beliefs-candidates → DNA 自治）
- [[self-evolving-agent-landscape]] — 我们在 identity/skills/memory 层有独特位置
- beliefs-candidates.md `friction-drives-behavior` — 知识编译也是减少运行时摩擦

## 深读补充 (2026-04-12)

读完完整 gist 后的更具体发现：

### 对 Memex Dogfood 的启发

1. **index.md 自动维护** — Karpathy 核心创新：LLM 维护一个带一行摘要的页面目录。我们 98 cards + 125 project notes 没有索引，每次靠 memex search。**行动项**：写一个 `wiki/index.md` 自动生成脚本（读所有 .md → 提取标题+首行 → 按分类输出），集成到 ingest 流程
2. **log.md 操作日志** — 时间线记录 wiki 变更（ingest/query/lint）。我们的 memory/ 是全局日志，wiki 本身没有变更记录。**行动项**：考虑给 wiki commit 加结构化 prefix（`card:`, `project:`, `lint:`）便于 grep
3. **Lint 操作** — 定期检查：孤立页（无 inbound link）、过时内容、缺失交叉引用、概念被提及但没有自己的页面。**行动项**：写一个 wiki-lint 脚本，检查 [[wikilinks]] 的 broken links + orphan pages
4. **Query→Wiki 回写** — 好的分析直接写成新 card。我们偶尔做但不系统。**行动项**：study workflow 的 note 节点已有此设计，需确保执行

### qmd 作为 Memex 竞品/参考

- [qmd](https://github.com/tobi/qmd) by Tobi (Shopify founder) — local markdown search, hybrid BM25/vector + LLM re-ranking, CLI + MCP
- 跟 memex 定位相似但更 search-focused（memex 有 cards/distillation 概念）
- **值得研究**：qmd 的 re-ranking 实现，可能启发 memex search 质量提升

### 我们已经做得比 Karpathy 更好的地方

- **自进化层**：DNA → Workflow → Knowledge-base 三层沉淀，Karpathy 方案没有
- **Agent 居住**：wiki 不只是工具输出，是 agent 的记忆和认知系统
- **双向链接**：memex 已有语义搜索 + backlinks
- **study workflow**：scout → deep_read → note → reflect 比 Karpathy 的 ingest 更结构化

### 我们缺的（优先级排序）

1. 🔴 **wiki/index.md** — 最高 ROI，减少每次 search 的 token 消耗
2. 🟡 **wiki-lint** — 中等 ROI，防止知识库腐烂
3. 🟢 **结构化 commit message** — 低成本高收益，便于追溯
4. 🔵 **qmd 研究** — 长期，可能启发 memex 改进

## 状态

深读完成 (2026-04-12)。产出 4 个行动项，优先做 wiki/index.md 自动生成。
