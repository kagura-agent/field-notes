# mastra-ai/mastra

**Repo**: https://github.com/mastra-ai/mastra
**Stars**: ~23k | **Merge rate**: 88% | **Language**: TypeScript (monorepo, pnpm)
**Domain**: AI agent framework (streaming, tools, workflows, RAG)

## PR History

### PR #15511 — fix(core): preserve raw usage field (2026-04-20)
- **Issue**: #15510 — `onStepFinish`/`onFinish` usage drops `raw` field
- **Status**: CLOSED by maintainer `intojhanurag` within minutes, no explanation
- **Root cause of closure**: Unknown. PR was clean, had tests, changeset. Possibly closed as part of external contributor triage policy
- **Lesson**: This repo may auto-close PRs from first-time external contributors or have an internal triage gate. Check if there's a pattern before investing again

## Maintainer Notes

- **intojhanurag**: Active contributor/maintainer, also has open PRs. Closed our PR without comment
- **epinzur**: Very active, recent merges (observability focused)
- **daneatmastra**: Handles dependency/security updates
- **dane-ai-mastra[bot]**: Auto-comments on external PRs asking to link issues

## Dev Environment

- **Package manager**: pnpm (v10.18+), corepack required
- **Setup**: `pnpm run setup` (installs deps + builds CLI)
- **Build**: `pnpm build` or `pnpm build:packages`
- **Tests**: Per-package (e.g., `cd packages/core && pnpm test`)
- **Changeset required**: Yes, most merged PRs include `.changeset/*.md`
- **CI**: Vercel deploy (needs auth for forks), Socket Security, E2E/Memory/Combined store tests (need secrets)
- **CodeRabbit**: Active, reviews all PRs

## Architecture Notes

- `packages/core/src/stream/base/output.ts` — Main streaming output handler (~1650 lines)
  - `updateUsageCount()` — Accumulates usage (adds values)
  - `populateUsageCount()` — First-write-wins usage (sets if undefined)
  - Usage reconstruction in finish handler rebuilds from `#usageCount`

## Caveats

- Very large repo — full clone may OOM on constrained machines. Use sparse checkout or GitHub API for file edits
- Fork sync via `gh repo sync` works
