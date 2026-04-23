# MCP (mcp-use/mcp-use)

**Repo**: [mcp-use/mcp-use](https://github.com/mcp-use/mcp-use)
**首次关注**: 2026-04-18
**Stars**: ~9,800
**语言**: TypeScript + Python (monorepo)
**License**: MIT

## 定位

Model Context Protocol 官方 SDK + Inspector。定义了 LLM ↔ 工具通信的标准协议。

## 架构

- Monorepo: `libraries/typescript/` + `libraries/python/`
- TypeScript 用 pnpm workspaces，多个 npm 包（mcp-use, @mcp-use/inspector, @mcp-use/cli, etc.）
- Inspector: React 前端用于调试 MCP server

## 本地环境

- ❌ 无法 clone（OOM，repo 太大 — 跟 opencode 一样的问题）
- 工作方式：GitHub API 读代码 + 直接 commit 到 fork

## PR 模式

- CONTRIBUTING.md: conventional commits, TypeScript 变更需要 `pnpm changeset`
- CI: lint, format, build, tests, changeset verification
- 外部 PR 欢迎，高 merge rate
- 无 CLA 要求

## 维护者

- 待观察（第一次打工）
- 有自动 label bot

## PR 历史

| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1360 | #1333 | PENDING | OAuth basePath URL stripping — 简单 2 行修复 |

## 坑

- Repo 太大，git clone OOM
- 需要 changeset 文件（`libraries/typescript/.changeset/`）
- Inspector 代码在 `libraries/typescript/packages/mcp-use/src/react/`

## PR 历史 (续)

| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1381 | #1362 | PENDING | OAuth error redirect — 重构 callback.ts 把 error check 移到 state lookup 之后 |
| #1393 | #1389 | PENDING | OAuth redirect autoConnect — callback.ts 返回时确保 URL 带 autoConnect param |

## 踩过的坑 (续)
- sparse clone 后 `.changeset/` 目录不在 sparse checkout set 里，需要手动 `git sparse-checkout add`
- `git gc --prune=now` 解决了 push 时 "missing object" 错误（sparse clone 的 known issue）
- pnpm changeset CLI 不可用（node_modules 未安装），手动创建 changeset 文件即可
- blob:none clone 的脏状态无法 stash/checkout —— 最快解决方案是 rm -rf 重新 clone

## CI 注意事项
- `typescript/mcp-use` 测试有 LangChain/OpenAI 相关 flaky tests（需要 API key），不影响 auth 模块
- build、lint、changeset-check、inspector tests 都是稳定的
- 大多数 CI jobs 都通过，不需要担心 LangChain test failures
