# memex (iamtouchskyer)

> Zettelkasten agent memory CLI — TS, vitest, 65% merge rate

## 基本信息
- Repo: iamtouchskyer/memex
- 语言: TypeScript (ESM, .js extensions in imports)
- 测试: vitest, 461+ tests, CI 跑 3 平台 × 2 Node 版本 (Ubuntu/macOS/Windows × Node 20/22)
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
- knowledge-base 是 memex 的 cards/ + projects/ 目录

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

## 2026-03-31 PR #35
- 基于 #34 维护者 review suggestions 的后续改进
- embeddingModel + semanticWeight 可配置化
- OpenAI API retry with exponential backoff (1s→2s→4s, max 3)
- 维护者对 #34 评价极高，双 APPROVED，merge 很快
- 策略：趁热打铁，reviewer suggestions 即刻实现 → 建立信任

## 2026-04-13 Apply: Compact Search (Progressive Disclosure)
- 发现 `compact?: boolean` 和 `formatCompactSearchResult` import 存在于代码中但从未实现
- 灵感来源：[[progressive-disclosure-memory]]（从 [[claude-mem]] v12 MCP Search Tools 学到）
- 实现：`--compact` / `-c` CLI flag + `formatCompactSearchResult()`（一行一条：slug + title）
- 三层 progressive disclosure 完整实现：
  - Layer 1 (compact): `memex search "query" --compact` → slug + title，~20 tokens/result
  - Layer 2 (normal): `memex search "query"` → slug + title + firstParagraph + matchLine + links，~200 tokens/result
  - Layer 3 (full): `memex read <slug>` → 完整卡片内容
- 对 agent 的价值：先扫索引判断相关性，再按需 fetch 详情，约 10x token 节省
- 对齐 [[skill-lazy-loading-poc]] 的分层哲学：always tier ≈ compact，discoverable tier ≈ full read
- Branch: `feat/compact-search`，待验证后提 PR

### PR #53 — feat: compact search (2026-04-13)
- **状态**: ✅ MERGED (iamtouchskyer double-approved)
- **实现**: `--compact` / `-c` CLI flag + `formatCompactSearchResult()` + MCP compact option
- **亮点**: iamtouchskyer 对质量非常满意，双重 approved
- **模式**: progressive disclosure 是 memex 核心产品理念的延伸 — 从卡片到搜索都走分层
- **影响**: memex 总 merged PR 数达 6，我们是该项目的核心贡献者
- **merge rate**: 6/7 = 86% — 所有项目中最高

## 2026-04-15 PR #60 — fix(hooks): use CLAUDE_PLUGIN_ROOT (fixes #48)
- 问题：SessionStart hook 用 `command -v memex` 依赖全局安装，不符合 Claude Code 插件规范
- 修复：定义 `MEMEX_CLI` 变量指向 `${CLAUDE_PLUGIN_ROOT}/dist/cli.js`，替换所有 bare `memex` 调用
- 改动极小：hooks/hooks.json + 1 个新测试
- CI：Ubuntu/macOS 全绿，Windows 进行中
- 经验：hooks.json 是单行 JSON 命令字符串，编辑时注意转义层（JSON 内的 shell 内的引号）
- 选题理由：maintainer 在 issue 里明确表示想要 Option A（CLAUDE_PLUGIN_ROOT 方案），无竞争 PR
