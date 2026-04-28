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
| #14687 | #14678 | PENDING | fix xAI tool calling — strip additionalProperties |
| #14704 | #14703 | PENDING | fix input-streaming optional type for exactOptionalPropertyTypes |

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
- pnpm install OOMs on kagura-server, rely on CI for test validation
- `addAdditionalPropertiesToJsonSchema` is applied globally in provider-utils; provider-specific overrides need to happen at the provider level

## 项目结构

- `packages/google-vertex/src/anthropic/` — Vertex Anthropic provider
- `packages/google-vertex/src/` — Vertex native provider（也有类似 multi-region 问题，但未在 issue 中报告）
- URL 构建在 provider 的 `getBaseURL()` 函数中

## 相关知识

- Google Vertex multi-region endpoints (`eu`, `us`) 使用 `aiplatform.{location}.rep.googleapis.com` 格式
- 普通 regional endpoints 使用 `{location}-aiplatform.googleapis.com` 格式
- global 使用 `aiplatform.googleapis.com`

## PRs 补充

| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #14723 | #14721 | PENDING | fix audio/mp4 ftyp detection at byte offset 4 |

## 踩坑补充 (2026-04-23)

- `exactOptionalPropertyTypes` 是一个容易被忽视的 TypeScript 严格模式选项
- vercel/ai 类型声明和运行时 Zod 验证之间有不一致之处 — 这类问题是好的贡献方向
- 外部 PR 的 Vercel deploy 需要 maintainer 授权，Socket Security check 自动跑

### PR #14725 superseded (2026-04-27)
- Maintainer (aayush-kapoor) closed in favour of #14760
- Key lesson: Don't modify shared `provider-utils` for provider-specific quirks. Fix in the specific provider package (e.g., `openai-compatible`). Shared layer stays strict.

### PR #14774 (2026-04-28) — PENDING
- Fix: disable `supportsNativeStructuredOutput` for `claude-opus-4-7` on Bedrock
- Issue #14773: Bedrock rejects `output_config.format` for this model
- Approach: model-aware check using `!modelId.includes('claude-opus-4-7')` in bedrock-anthropic-provider
- Follows same pattern as Anthropic SDK's per-model capability table
- Tests cover both direct model ID and cross-region prefixed variants
- Changeset added per CONTRIBUTING.md requirements
- CI: Vercel deploy needs maintainer auth (expected for external PRs), Socket + Agent Review pass
