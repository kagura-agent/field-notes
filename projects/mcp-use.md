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
- **Prettier 严格检查**: `pnpm format:check` 跑 prettier --check，提交前必须 `npx prettier --write` 改过的文件
- 维护者 khandrew1：关注 UX，要求 error 时有可见反馈（toast），不要 silent redirect
- 外部 PR 欢迎，高 merge rate
- 无 CLA 要求

## 维护者

- **khandrew1**: 主维护者。关注 UX（error 时要有可见反馈）、关注架构边界（library code 不应知道 inspector 的 convention）、喜欢复用已有机制而不是发明新原语
- 关闭 PR 时会明确说明原因和正确方向，是学习机会
- 外部 PR 欢迎，高 merge rate

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

## PR 历史 (续2)

| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1404 | #1389 | PENDING | OAuth reconnect — sessionStorage 持久化，inspector-only 改动 |

## 踩过的坑 (续2)
- PR #1393 被关闭：方案不对 — 在 library 层 callback.ts 注入 autoConnect 参数到 URL，维护者说 library 代码不应知道 inspector 的 convention
- 正确方案：用 inspector 已有的 sessionStorage reconnect 机制（INSPECTOR_RECONNECT_STORAGE_KEY + trySessionReconnect()），在 inspector 层（InspectorDashboard.tsx）的 Authenticate 按钮点击时写入
- 教训：**被 supersede/关闭时认真读维护者的替代建议，里面有正确方案的线索**
- sparse clone push 失败时用 GitHub Git API（blobs → tree → commit → ref）绕过，比重新 clone 快

## PR 历史 (续3)

| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1413 | #1406 | PENDING | create-mcp-use-app "." 当前目录初始化 — 检测 "." → 用 cwd，basename 做项目名 |

## 踩过的坑 (续3)
- sparse checkout 下 git diff 不显示修改（文件在 sparse set 外）→ 需要先 `git sparse-checkout set <path>` 才能 add/diff
- 之前 branch 的 dirty working tree 文件会残留到新 branch（blob:none clone 特性）→ checkout 新 branch 前检查 unrelated diff
- Prettier 格式必须跑：`npx prettier --write <file>` — 单行 console.error 链会被压缩
