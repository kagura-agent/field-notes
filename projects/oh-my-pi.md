# Oh My Pi (can1357/oh-my-pi)

> AI Coding agent for the terminal — hash-anchored edits, optimized tool harness

## 基本信息
- Repo: can1357/oh-my-pi
- 语言: TypeScript + Rust (native crates)
- Stars: ~3,061
- License: MIT
- Runtime: Bun (1.3+)
- 包管理: bun workspaces (monorepo)

## 架构
- `packages/coding-agent/` — 主 CLI 入口 (`src/cli.ts`)
- `packages/utils/` — 工具库（env loading, dirs, etc.）
- `packages/ai/` — AI provider 层
- `crates/` — Rust native modules (pi-natives, brush-*)
- 入口: `#!/usr/bin/env bun` → `packages/coding-agent/src/cli.ts`

## 维护者
- **can1357**: 主维护者
- Merge rate 待观察
- 最近 merged PR 多来自不同贡献者（开放社区）
- 无 CONTRIBUTING.md

## 开发笔记
- 测试: `bun run test` (并行 TS + Rust)
- **⚠️ 仓库极大**: git clone 会 SIGKILL（OOM），必须用 `--filter=blob:none --depth 1` + sparse checkout
- Bun auto-loads `.env` 文件，omp 自己也在 `packages/utils/src/env.ts` 手动加载（冗余但有 try-catch）
- `.env` loading: `parseEnvFile()` 有 try-catch，graceful failure
- `getConfigRootDir()` / `getAgentDir()` 是纯路径计算，不读文件系统

## 我们的 PR
- PR #740: fix(cli): support --flag=value equals syntax for all CLI flags (Fixes #739) — PENDING
  - 2026-04-18: 通过 GitHub API 直接提交（本地无法 clone，OOM）

## 踩过的坑
- 2026-04-16: 尝试修 #709 (.env crash with fence sandbox)
  - 假设是 Bun auto-load 导致 crash → 实测 Bun 对 EPERM .env 处理 graceful（不 crash）
  - omp 自己的 `parseEnvFile` 也有 try-catch
  - 真实 crash 原因可能是 fence 直接 SIGKILL 进程而非返回 EPERM
  - 教训: 远程无法复现的 sandbox 相关 bug 不要轻易接
- 2026-04-18: git clone OOM (SIGKILL)
  - 仓库太大，即使 --filter=blob:none --depth 1 也会 OOM
  - sparse checkout 同样 OOM（fetch 本身就超内存）
  - 解决：改用 GitHub API 直接读写文件，不 clone
  - 教训：超大 repo 必须用 API 方式工作，不要尝试 clone

## 我们的 PR
- PR #740: fix(cli): support --flag=value equals syntax for all CLI flags (Fixes #739) — PENDING
  - 2026-04-18: 通过 GitHub API 直接提交（本地无法 clone，OOM）
- PR #752: fix(auth): let OAuth credentials override keyless provider flag from stale models.yml (#749) — PENDING
  - 2026-04-20: 3行改动，model-registry.ts 的 getApiKey/getApiKeyForProvider/peekApiKeyForProvider
  - 核心：keyless guard 加 `&& !this.authStorage.hasAuth(provider)` 让 OAuth 凭证优先
  - 无 CI checks，等 maintainer review

## 维护者模式
- **can1357**: 主维护者，无 CONTRIBUTING.md
- 无自动化 CI 对外部 PR（no checks reported）
- Merge rate 待观察（两个 PR 都在等）
- 社区活跃，多个贡献者的 PR 存在

## 下次注意
- clone 用 `git clone --filter=blob:none --depth 1` + sparse checkout（但实测仍 OOM）
- **必须用 GitHub API 方式工作**，不要尝试 clone
- 需要 Bun 运行时（本地测试不可行）
- 确认 issue 是否可远程复现再接
- 无 CI → 代码 review 靠人工，要确保逻辑正确
- `authStorage` 有 `hasAuth()` 方法可用于检查凭证存在性

Links: [[coding-agent-ecosystem]]
