# Archon — coleam00/Archon

## Overview
- **语言**: TypeScript (Bun runtime)
- **结构**: monorepo (packages/core, packages/server, packages/adapters, packages/paths, etc.)
- **测试**: `bun test` (bun:test)
- **验证**: `bun run type-check` + `bun run lint` (eslint)
- **PR base branch**: `dev` (不是 main)

## 维护者模式
- repo 非常活跃，每天有 merge
- 有 CodeRabbit 自动 review
- CodeRabbit 的 pre-merge checks 包括 docstring coverage（阈值 80%）和 PR description template — 但这些是 warning 不是 blocker
- PR 描述应包含 Problem/Fix/Changes/Validation sections

## 本地环境
- bun 1.3.12 (`~/.bun/bin/bun`)
- `bun install` 在国内网络很慢，但 node_modules 已有 workspace-level symlinks
- 可以直接 `bun test packages/core/src/db/codebases.test.ts` 跑单文件测试

## PR 记录
| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1033 | #967 | pending | corrupt JSON silent fallback → throw error |
| #1034 | #964 | pending | ghost worktree cleanup false success |
| #1037 | #1035 | pending | Windows path spaces in --spawn terminal |

## 注意事项
- eslint 禁止 unused vars，catch 里不用的 error 要命名为 `_err`
- `packages/core/src/db/connection.ts` 是 mock 重点 — 测试通过 `mock.module('./connection', ...)` 注入
- CodeRabbit 自动 review，有 pre-merge checks 模板（Description check 会 warn 缺少 template sections 但不 block）
- Shell 脚本改动：CodeRabbit 会检查 find 性能（如 -prune），值得关注

## PR 记录更新 (2026-04-20)
| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1307 | #1279 | pending | docker-entrypoint.sh safe.directory bind-mount fix |
- SQLite 返回 TEXT string，PostgreSQL 返回 JSONB object — 两种 path 都要测
- `trySpawn` 返回 true 只要 child.pid 存在 — 不代表子进程真的成功了（Windows 尤其如此）
- Windows terminal spawning 必须 quote 路径（spaces 问题 #1035）
- lint-staged 在 commit 时自动跑 eslint+prettier，不需要手动跑

## PR History

### #1033 — fix(db): throw on corrupt commands JSON (pending)
- Simple fix: throw instead of silent empty fallback
- CodeRabbit: requested including parse error in log — addressed

### #1034 — fix(isolation): ghost worktree cleanup (pending, fixes #964)
- Root cause: `isolationCompleteCommand` checked `skippedReason` but not `worktreeRemoved`
- Also: no `git worktree prune` or post-removal verification
- Lesson: existing code already had `RemoveEnvironmentResult` with `worktreeRemoved` field — the gap was in the *caller* not checking it
- Pattern: "dishonest success message" bugs — function returns void/success but operation was a no-op

## Maintainer Notes
- Base branch: `dev` (not `main`)
- Uses bun for testing and lint-staged
- CodeRabbit bot reviews are common
- ~539 pre-existing test failures in full suite (don't worry about them)
- ESLint: unused catch vars must use `_` prefix

## 2026-04-11 Session Notes
- **PR #1034**: Addressed 2 Major + 1 Minor CodeRabbit review comments
  - Ghost worktree prune needs to run outside pathExists guard
  - Batch cleanup callers must honor partial/skipped result states
  - Partial cleanup message should reflect actual branchDeleted state
  - All 3 packages pass tsc --noEmit
- **PR patterns**: CodeRabbit reviews are thorough; address Major issues promptly
- **hermes#2890**: Upstream restructured STT config significantly (added providers, mistral). Rebase required careful conflict resolution to merge our `device` field with new provider structure

### PR #1084 — fix(orchestrator): surface AI error results (fixes #1076)
- **Root cause**: `handleStreamMode` and `handleBatchMode` required `msg.sessionId` truthy to process result messages; auth errors have `session_id: undefined` → silently dropped
- **Fix**: Split result handler to process `sessionId` and `isError` independently; send error message when no assistant content produced
- **CodeRabbit review**: Suggested provider-aware auth hint (don't hardcode 'Claude') → used `aiClient.getType()`, good catch
- **Tests**: 5 new tests, all pass + type-check clean
- **Pattern**: "dishonest silence" bugs (function returns void/success but operation failed) — same family as #1034's ghost worktree

## 外部 PR Review 模式 (2026-04-14 观察)
- **核心贡献者**: Wirasm（连续 5 个 merge），可能是 co-maintainer
- **外部 PR**: 有被 merge 的迹象，repo 活跃
- **注意**: PR base branch 可能是 dev 不是 main（#1084 教训）
- **结论**: 值得继续投入，正常等待 review

### PR #1294 — fix(orchestrator): clear stale session ID on error_during_execution (2026-04-19)
- **Status**: PENDING (CI passed, CodeRabbit clean — "No actionable comments")
- **Issue**: #1280 — stale Claude session ID causes infinite failure loop after container restart
- **Root cause**: `handleStreamMode` and `handleBatchMode` persisted session ID from error results → next message hits same stale session → infinite loop
- **Fix**: On `error_during_execution`, set `assistant_session_id = NULL` → next message starts fresh session with full context from DB
- **Scope**: 2 files, 18 insertions, 6 deletions. Surgical — only the error path changed
- **Tests**: All 89 orchestrator + 28 sessions tests pass, tsc clean, lint-staged clean
- **Pattern**: Same "dishonest persistence" family as #1034 (ghost worktree) and #1084 (silent error drop) — Archon has a pattern of not checking error states before persisting
