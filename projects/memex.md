# memex (iamtouchskyer)

> Zettelkasten agent memory CLI — TS, vitest, 65% merge rate

## 基本信息
- Repo: iamtouchskyer/memex
- 语言: TypeScript (ESM, .js extensions in imports)
- 测试: vitest, 283+ tests, CI 跑 3 平台 × 2 Node 版本
- PR 提到 main branch
- Commit 格式: feat/fix: description

## 我们的 PR 历史
- #19: nestedSlugs config option (Phase 1) — ✅ merged 2026-03-25
- #20: --nested CLI flag (Phase 2) — ✅ merged 2026-03-26
- #21: doctor + migrate commands (Phase 3) — ✅ merged 2026-03-26
- #23: --all multi-dir search (Phase 1 of #22) — pending review, CI 6/6 绿

## 维护者模式
- **iamtouchskyer**: 活跃, 回复快, merge 快（#20 和 #21 同天 merge）
- 愿意跟贡献者讨论方案（#22 里主动整理讨论 + 邀请提 draft PR）
- 对代码质量要求适中，测试覆盖要全
- 接受 Co-Authored-By Claude

## 架构笔记
- `CardStore` 是核心：单目录扫描 + 读写
- `getStore()` 在 cli.ts 里创建，从 MEMEX_HOME 环境变量读
- `.memexrc` JSON 配置文件（nestedSlugs, searchDirs）
- MCP server 也用同样的 CardStore
- 扫描用递归 walkDir，支持 nestedSlugs 模式

## 踩坑
- `store["nestedSlugs"]` 是 private 属性，Claude Code 用了类型断言绕过——不优雅但能用
- 多目录搜索的 slug 歧义：只有在真正搜多个目录时才加 prefix，否则保持原行为
- CI 跑 Windows + macOS + Ubuntu，路径分隔符要注意

## 下次注意
- MCP server 的 search 操作也需要支持 --all（Phase 2 可能要改）
- read 命令是否也需要跨目录 resolve？（Phase 2 的 context 命令可能覆盖）
- 写 PR 描述时标明 Phase 编号，owner 喜欢看清楚 roadmap 进度

## 跟我们的关联
- memex 是我们每天用的工具（MEMEX_HOME 指向 knowledge-base）
- 自己的痛点驱动贡献 > 纯外部打工
- [[knowledge-base]] 是 memex 的 cards/ + projects/ 目录

## Owner 画像：iamtouchskyer
- 风格：极简但想清楚了。memex = 最小 Zettelkasten，OPC = 最小多 agent 编排
- 对贡献者：非常友好，5/5 PR merged，主动邀请贡献，merge 快
- 新项目 OPC（2026-03-27）：Claude Code skill，11 个角色 + 4 种模式，纯 markdown 零依赖
- 值得长期跟的 owner

### Issue #29 — Semantic Search 实现方案 (2026-03-31 study)
- Owner 确认：text-embedding-3-small, cache in .memex/embeddings/
- 设计：EmbeddingProvider 接口 → OpenAI 实现 → 单 JSON 缓存 → content hash 失效
- 搜索：--semantic flag, 混合评分 0.7 semantic + 0.3 keyword
- 零新依赖（原生 https 调 OpenAI）
- 文件：新建 embeddings.ts (~200行), 改 search.ts (+60), config.ts (+10), cli.ts (+5), mcp/server.ts (+5)
- 测试：embeddings.test.ts (~150行), search-semantic.test.ts (~120行)
- 总计 ~550 行
- 无竞争 PR，无 blocker，upstream 最新 commit 1986d87
- 实现顺序：基础设施 → 接入搜索 → MCP → 文档
- 注意：Node 16 没有 fetch，用原生 https 模块

### PR #34 — Semantic search implementation (2026-03-31)
- Closes #29
- 923 行净增，7 文件改动，25 新测试，322 总测试全过
- 架构：EmbeddingProvider 接口 + OpenAI 实现 + JSON 缓存 + 混合评分
- 零新依赖（原生 https + crypto）
- 关键设计：content hash > mtime，pluggable provider，incremental embedding
- Owner 之前确认了 text-embedding-3-small 和 .memex/embeddings/ 缓存路径
