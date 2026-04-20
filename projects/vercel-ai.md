# vercel/ai (AI SDK)

- **Stars**: 23.6k
- **语言**: TypeScript (monorepo, pnpm workspace)
- **测试框架**: vitest
- **环境要求**: pnpm v9+, Node v22
- **首次贡献**: 2026-04-20

## PRs

| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #14636 | #14634 | PENDING | fix multi-region endpoint for Vertex Anthropic |

## 开发环境

- monorepo 非常大，shallow clone + sparse checkout 是必须的
- `git clone --depth=1 --no-checkout` → `git sparse-checkout set packages/<target>` → `git checkout`
- pnpm install 在 kagura-server 上 OOM，需要更大内存或用 CI 跑测试
- 本地无法跑 pnpm install，依赖 CI 验证测试

## 维护者模式

- 待观察（首次 PR）
- PR 模板无特殊要求，CONTRIBUTING.md 简洁
- 有 Socket Security check（依赖安全扫描）
- Vercel deploy 对外部 PR 需要授权（正常）

## 踩坑

- repo 太大无法全量 clone，必须 sparse checkout
- fork sync 后再 push branch

## 项目结构

- `packages/google-vertex/src/anthropic/` — Vertex Anthropic provider
- `packages/google-vertex/src/` — Vertex native provider（也有类似 multi-region 问题，但未在 issue 中报告）
- URL 构建在 provider 的 `getBaseURL()` 函数中

## 相关知识

- Google Vertex multi-region endpoints (`eu`, `us`) 使用 `aiplatform.{location}.rep.googleapis.com` 格式
- 普通 regional endpoints 使用 `{location}-aiplatform.googleapis.com` 格式
- global 使用 `aiplatform.googleapis.com`
