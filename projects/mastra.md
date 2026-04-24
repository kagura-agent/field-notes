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

## Lessons

- **2026-04-22**: PR #15622 closed by LekoArts — superseded by #14908 (merged 2026-03-31). Same issue (duplicate itemId), but #14908 fixed it 3 weeks earlier at the streaming pipeline level + sanitization. My PR came late. **Lesson: before submitting a fix, search closed/merged PRs for the same issue keyword.** `gh search prs --repo X "keyword" --merged` would have caught this.

## Caveats

- Very large repo — full clone may OOM on constrained machines. Use sparse checkout or GitHub API for file edits
- Fork sync via `gh repo sync` works

### PR #15709 — fix(core): match provider-executed tool results by toolName when toolCallId mismatches (2026-04-24)
- **Issue**: #15706 — file_search tool-results dropped when combined with any other tool → "Corrupted tool call context"
- **Status**: PENDING (submitted, CodeRabbit ✅ all 5 checks passed, CI running)
- **Root cause**: Google AI SDK assigns different `toolCallId` values to tool-call vs tool-result chunks when function declarations coexist with server tools. `updateToolInvocation()` only matched by exact `toolCallId`, so results were silently dropped.
- **Fix**: Added fallback in `updateToolInvocation()` — when exact `toolCallId` match fails, search for `providerExecuted: true` tool-invocation with same `toolName` still in `state: 'call'`. 3 new tests.
- **Changeset**: included
- **Note**: Implementation was partly pre-written from a previous session (Claude Code had written the diff but it was uncommitted). Committed, added changeset, ran tests, pushed.
- **Key insight**: Understanding the AI SDK's Google provider internals (`lastServerToolCallId` correlation mechanism in `@ai-sdk/google`) was essential for diagnosing the root cause. The fix is Mastra-side because the ID mismatch originates from how Google's API formats responses differently when function declarations are present alongside server tools.

## 跟进 (2026-04-24)
- PR #14486 merged (2026-04-23): **Modal as sandbox provider** — 深读完成，见下方架构分析
- PR #14824 merged: fix `.` root path resolution in GCS and S3 filesystem providers
- PR #15689 merged: fix browser_evaluate to return expression results (agent-browser package)
- Alpha releases continue daily (chore: version packages)
- PR #15709: PENDING — CodeRabbit ✅, CI pending

### PR #15718 — fix(core): stop agent loop when finishReason is 'length' with pending tool calls (2026-04-24)
- **Issue**: #15717 — `hasPendingToolCalls` overrides `finishReason === 'length'` → infinite loop
- **Status**: PENDING (submitted, CodeRabbit review addressed, CI passing)
- **Root cause**: In `llm-execution-step.ts` L1362-1364, `shouldContinue` uses `hasPendingToolCalls || !['stop', 'error', 'length'].includes(finishReason)`. When finishReason is 'length' but truncated tool calls exist, the `||` makes shouldContinue true
- **Fix**: Added `finishReason !== 'length'` guard: `(hasPendingToolCalls && finishReason !== 'length') || ...`
- **Tests**: 1 new test — streams truncated tool-call + `finishReason: 'length'`, asserts `isContinued === false`. All 11 tests pass
- **CodeRabbit feedback**: ToolStream constructor args (fixed), test dedup (optional, skipped per existing pattern)
- **Changeset**: included
- **Build note**: `packages/_internal-core` needs sparse checkout + build before core tests run

### Deep Read: Modal Sandbox Provider (PR #14486)

**What**: 新增 Modal 作为第 6 个 sandbox provider（alongside Local, Docker, [[e2b]], Blaxel, Daytona）

**Architecture Pattern — [[pluggable-sandbox-provider]]**:
- `MastraSandbox` 基类（`packages/core/src/workspace/sandbox/mastra-sandbox.ts`）提供：
  - Race-condition-safe lifecycle wrappers (`_start()`, `_stop()`, `_destroy()`)
  - 自动 logger 注入（extends MastraBase）
  - MountManager 自动创建（如果子类实现 `mount()`）
  - 默认 `executeCommand` 实现（spawn + wait）—— 子类只需实现 ProcessManager
  - Lifecycle hooks: `onStart`, `onStop`, `onDestroy`
- 子类只需实现 3 个核心方法: `start()`, `stop()`, `destroy()` + 提供 ProcessManager
- ProcessManager 也是抽象的: `SandboxProcessManager` → spawn/list/kill

**Modal-specific highlights**:
- **Stop-and-resume via filesystem snapshots**: `stop()` calls `snapshotFilesystem()` before `terminate()`, `start()` recreates from snapshot image. 这是 Modal 独有的——E2B/Docker 没这个
- **Reconnect by name**: `start()` 先尝试 `fromName()` 重连已有 sandbox，失败才创建新的
- **Dead-sandbox retry**: `retryOnDead()` wrapper 检测 sandbox 已死错误（NotFoundError, ClientClosedError, gRPC NOT_FOUND），自动重启一次并重试
- **Kill 的局限**: Modal JS SDK 没有 per-exec kill，`kill()` 只能 cancel stream readers，远端进程继续运行直到 sandbox timeout
- **stdin 不支持**: Modal exec() 不暴露 stdin

**Design tradeoffs**:
1. 每个 provider 是独立 npm 包（`@mastra/modal`, `@mastra/e2b` 等）—— 用户只装需要的
2. ProcessHandle 的 streaming 模型用 ReadableStream reader —— 现代、可取消，但 Modal SDK 的 reader 限制导致 kill 只是 local cancel
3. `retryOnDead` 策略只重试一次，避免无限循环 —— 实用但保守

**与 agent 生态关系**:
- Sandbox 正在成为 agent framework 的标准层（[[e2b]] 开创，现在 Daytona/Blaxel/Modal 都在竞争）
- Mastra 的策略是全都接入作为 pluggable providers —— 不绑定单一供应商
- 对 [[openclaw]] 的启示: 如果需要 remote execution，这个 provider pattern 值得参考

**Test quality**: 554 行单元测试 + 148 行集成测试，覆盖 lifecycle、streaming、timeout、dead-sandbox retry。Mock 模式用 vi.mock('modal') 替换 SDK

## 跟进 (2026-04-23)
- PR #14969 merged: custom language server registration in LSP config — 之前只支持内置语言（TS/JS/Python/Go/Rust），现在可以注册任意 LSP
- PR #15546 merged: preserve raw provider usage in onStepFinish/onFinish callbacks — 修复 agent.stream() 丢失 Anthropic cache metrics（cacheRead/cacheWrite）的问题
- 最新 release: @mastra/core@1.24.0 (2026-04-08)
