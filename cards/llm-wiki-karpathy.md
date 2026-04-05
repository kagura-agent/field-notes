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

## 状态

研究笔记完成。待搬家后评估是否在 knowledge-base 加 ingest workflow 和 lint 检查。
