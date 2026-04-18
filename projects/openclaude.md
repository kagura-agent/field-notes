# OpenClaude (Gitlawb/openclaude)

Open-source coding-agent CLI. 22k+ stars. Fork of Claude Code with multi-provider support.

## Repo 基本信息
- **语言**: TypeScript (Bun)
- **运行时**: Bun 1.3+
- **默认分支**: `main`
- **构建**: `bun install && bun run build`
- **测试**: `bun test` (uses bun:test)
- **本地环境**: ❌ 太大无法 clone（sparse checkout 也超时）。用 GitHub API 读文件 + 提交

## PR 模式
- CONTRIBUTING.md 要求简单：focused, well-tested, easy to review
- 大改先开 issue
- 无 changeset 要求，无 CLA
- 有 bun:test 测试框架

## 代码架构
- 工具系统: `src/Tool.ts`（基础），`src/tools/` 各工具实现
- MCP: `src/services/mcp/client.ts`（MCP 客户端，schema 传递点）
- API: `src/utils/api.ts`（`toolToAPISchema` 将 Tool 转 API 格式，含 strict mode 判断）
  - `inputJSONSchema`（MCP 工具直传）vs `inputSchema`（Zod 转 JSON Schema）
  - `filterSwarmFieldsFromSchema` 过滤 swarm 字段
  - 新增 `sanitizeSchemaRequired` 确保 required 与 properties 同步
- Feature flags: GrowthBook (Statsig) 控制 strict tools、swarms 等

## PR 记录
- **#754** (2026-04-18) — fix(mcp): sync required array with properties in tool schemas. Fixes #525. Pending review.
  - MCP tool schema `required` 包含不在 `properties` 中的 key → API 400
  - 修复：添加 sanitizeSchemaRequired() + 修复 filterSwarmFieldsFromSchema
  - 经验：repo 太大不能 clone，用 GitHub API 直接编辑

## 踩过的坑
- sparse checkout 超时 — 即使 --filter=blob:none 也不行（repo 文件数太多）
- 必须用 GitHub API 工作流（下载文件 → 编辑 → PUT 回去）

## 下次注意
- 直接用 API 工作，不要浪费时间尝试 clone
- 测试用 `bun:test`，import 路径带 `.js` 后缀
