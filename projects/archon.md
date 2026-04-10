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
