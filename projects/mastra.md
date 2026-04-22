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

### PR #15575 — fix(memory): surrogate-safe truncation (2026-04-21)
- **Issue**: #15573 — Observational memory truncation splits UTF-16 surrogate pairs → Anthropic rejects as invalid JSON
- **Status**: PENDING (submitted, CodeRabbit passed ✅, CI pending secrets)
- **Fix**: Added `surrogateSafeSlice()` helper to 3 truncation sites in memory package
- **Tests**: 4 new tests, all passing
- **Note**: Also identified same bug in `packages/core/src/processors/processors/token-limiter.ts` (line 407) — could be a follow-up PR
- **Changeset**: included (learned from PR #15511 closure)

### PR #15577 — fix(client-js): collect all tool invocations from streamed tool-calls step (2026-04-21)
- **Issue**: #15576 — `processStreamResponse` only picks one tool-invocation per step via `reverse().find()`
- **Status**: PENDING (submitted, CI passing except Vercel fork auth, CodeRabbit review addressed)
- **Fix**: Replaced `reverse().find()` with `filter()` to collect ALL pending tool-invocations (state === 'call'), dedup by toolCallId, execute all, patch all results into one message clone, make one recursive call. Fixed both v2 and legacy streaming paths.
- **CodeRabbit feedback**: Pointed out missing null guard on `lastMessage` in legacy path — fixed in follow-up commit
- **Changeset**: included

### PR #15571 — fix(core): preserve tool execution errors through history reload (2026-04-21)
- **Issue**: #15570 — Tool errors lost on reload, agent loops forever retrying
- **Status**: PENDING

### PR #15622 — fix(core): deduplicate all OpenAI itemIds (2026-04-22)
- **Issue**: #15617 — "Duplicate item found with id rs_..." with Observational Memory buffering
- **Status**: PENDING (CI pending secrets, CodeRabbit processing)
- **Root cause**: `mergeTextPartsWithDuplicateItemIds()` only handled text parts. Reasoning parts (`rs_*` itemIds) passed through unchanged. When OM buffering causes same response parts to appear multiple times, AI SDK generates duplicate `item_reference` entries → OpenAI rejects.
- **Fix**: Renamed function → `deduplicatePartsWithOpenAIItemIds()`. Extended to handle ALL part types. Added cross-message dedup via `globalSeenItemIds` in `sanitizeV5UIMessages`. Text parts still merge by concatenation; non-text parts keep first occurrence only.
- **Tests**: 5 new tests covering within-message and cross-message dedup for both text and reasoning parts
- **Changeset**: included
- **Key insight**: The bug spans TWO layers — within-message AND cross-message dedup needed. Memory can load non-merged assistant messages with identical `rs_*` IDs.

## Architecture Notes (extended)

### OpenAI itemId deduplication flow
- `output-converter.ts` → `sanitizeV5UIMessages()` is the single dedup gate
- Per-message: `deduplicatePartsWithOpenAIItemIds()` merges text, drops non-text dupes
- Cross-message: `globalSeenItemIds` Set tracks all seen itemIds across entire message array
- AI SDK (`vercel/ai`): `convert-to-openai-responses-input.ts` creates `item_reference` for each part with `store: true` — duplicates there cause the OpenAI error
- Buffering coordinator in OM can cause async re-insertion of same parts

## Caveats

- Very large repo — full clone may OOM on constrained machines. Use sparse checkout or GitHub API for file edits
- Fork sync via `gh repo sync` works
