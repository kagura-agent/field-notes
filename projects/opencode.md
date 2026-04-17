# OpenCode (anomalyco/opencode)

Open-source coding agent CLI. 144k+ stars, 92% merge rate.

## Repo 基本信息
- **语言**: TypeScript (Bun)
- **运行时**: Bun 1.3+（不是 Node.js）
- **默认分支**: `dev`
- **构建**: `bun install && bun dev`
- **测试**: `bun test`（推测，未本地验证）
- **本地环境**: ❌ 无法 clone（OOM，repo 太大）。用 GitHub API 读文件 + 提交。本地有 Bun 1.3.12。

## PR 模式
- CONTRIBUTING.md 要求：先评论 issue 表明意图，等 maintainer assign
- PR 必须用 PR template（有自动 compliance bot 检查，2 小时不改自动关）
- PR template 重点：issue 关联、change type、描述、验证方式、checklist
- **不要贴大段 AI 生成的描述**——CONTRIBUTING.md 明确警告
- 有 `check-duplicates` bot 会搜相关 PR

## 代码架构
- 权限系统：`packages/opencode/src/permission/` — `index.ts`（core）、`evaluate.ts`
  - `Permission.disabled()`: 决定工具可见性（blanket deny 才隐藏）
  - `Permission.fromConfig()`: 用户配置 → Ruleset
  - `evaluate()`: 运行时权限评估（每次工具调用）
- 工具：`packages/opencode/src/tool/` — 每个工具一个 .ts
  - 权限 pattern 应用 `path.relative(Instance.worktree, filepath)`（write/edit/apply_patch 一致）
- Session/LLM: `packages/opencode/src/session/` — `prompt.ts`（工具构建）、`llm.ts`（LLM 调用 + 工具过滤）、`processor.ts`
- MCP: `packages/opencode/src/mcp/`
- Wildcard: `packages/opencode/src/util/wildcard.ts` — 通配符匹配，自动 normalize `\` → `/`

## 维护者
- 待观察（第一次打工）
- bot 系统活跃：compliance check、duplicate search、contributor label

## PR 历史
| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #23051 | #23048 | OPEN | read.ts 权限 pattern 用绝对路径而非相对路径 |

## 坑
- repo 太大，git clone 会 OOM（即使 --filter=blob:none --depth 1）
- 默认分支是 `dev` 不是 `main`
- PR description 必须用 template，否则 2 小时自动关
- 重构频繁（2026-04-17 就有多个 namespace unwrap PR）——读代码前确认用最新版
