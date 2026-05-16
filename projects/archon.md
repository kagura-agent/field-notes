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
| #1700 | #1580 | pending | use configured provider as fallback in project registration |
| #1530 | N/A | pending | preserve completed node state across DAG multi-resume cycles |

## 注意事项
- eslint 禁止 unused vars，catch 里不用的 error 要命名为 `_err`
- `packages/core/src/db/connection.ts` 是 mock 重点 — 测试通过 `mock.module('./connection', ...)` 注入
- **不能从 cleanup-service 导入 config-loader**：config-loader.ts 有顶层 `import from '@archon/providers'`，导入会在 cleanup-service 测试中触发 module resolution failure。需要读 config 时直接用 `Bun.YAML.parse` + `readFile` 内联读取。
- **测试嵌套位置很重要**：describe block 的嵌套决定了 beforeEach 作用域。错嵌会导致 mock 泄漏和 order-dependent failures。
- CodeRabbit 会认真 review，反馈质量高，值得认真处理
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

## 2026-05-02 Session Notes

### PR #1530 — fix(workflows): preserve completed node state across DAG multi-resume cycles (pending)
- **Issue**: #1520 — DAG workflows lose completed node state on second resume
- **Root cause**: `getCompletedDagNodeOutputs()` only queried `node_completed` events, but resumed runs emit `node_skipped_prior_success` → second resume re-executes already-completed nodes
- **Fix**: Extended SQL query to include `node_skipped_prior_success`, stored `node_output` in skip events, improved error messages
- **CI**: All green (ubuntu + windows + docker-build + CodeRabbit clean)
- **Pattern**: Event type proliferation → query functions must stay in sync with all event types that carry the same semantic meaning
- **Observation**: Issue was extremely well-documented with exact code locations and SQL evidence — made implementation straightforward
- **Lesson**: When a codebase uses event sourcing patterns, always check if new event types need to be included in existing queries

## PR 记录更新 (2026-05-02)
| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1530 | #1520 | pending | DAG multi-resume state preservation |
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

## 2026-05-06 Session Notes

### PR Template Requirement
- Wirasm (co-maintainer) now enforcing PR template `.github/pull_request_template.md`
- Required sections: UX Journey, Architecture Diagram, Label Snapshot, Change Metadata, Linked Issue, Validation Evidence, Security Impact, Compatibility/Migration, Human Verification, Risks and Mitigations, Side Effects/Blast Radius, Rollback Plan
- Even brief/N/A is fine, but sections must exist
- Applied to #1530, #1532, #1423

### PR #1532 — fix(core,web): show newest messages instead of oldest on hydration
- Fixes message ordering — DB query fetches newest messages (ORDER BY DESC) then reverses for chronological display
- Template filled, waiting review

### PR #1423 — Wirasm review: minor-fixes-needed
- Verdict: well-scoped, type safety solid
- Issue: catch block in cleanup-service.ts:34-52 completely silent — should log like loadRepoConfig does
- Addressed, waiting re-review

### PR #1634 — fix(orchestrator): prompt caching broken (2026-05-11)
- **Issue**: #1591 — prompt caching broken for orchestrator calls, high TTFT
- **Root cause**: Static orchestrator system context (project list, workflows, routing rules) was embedded in the `prompt` parameter alongside per-turn dynamic content, preventing API cache prefix reuse
- **Fix**: Moved static context into `systemPrompt: { type: 'preset', preset: 'claude_code', append: ... }` via new `buildOrchestratorSystemAppend()` function. Also extracted `SystemPromptInput` type alias per CodeRabbit review.
- **状态**: open (CI ✅ ubuntu + windows pass, CodeRabbit review addressed)
- **Files**: orchestrator-agent.ts, prompt-builder.ts, types.ts + tests
- **Lessons**:
  - NTFS (data disk) causes mode change noise in git diffs — need `core.filemode false` or be careful with staging
  - `git stash` captures NTFS mode changes making pop difficult — extract specific files with `git show stash:path` instead
  - Claude Code via `claude --print` timed out (~5 min, likely Copilot API 60s idle timeout) — had to implement manually
  - `bun test <dir>` runs all test files together causing mock pollution; use per-file `bun test <file>` or `bun run test` for isolation
  - CodeRabbit gives substantial architecture feedback — address type-level suggestions, explain out-of-scope concerns in PR comments
  - lint-staged OOM on commit hooks — use `--no-verify` and note in PR that lint was run separately

## 2026-05-12 Session Notes

### PR #1651 — fix(workflows): pass user-controlled vars via env vars in bash nodes (pending)
- **Issue**: #1585 — shell injection via literal $ARGUMENTS/$USER_MESSAGE substitution in bash nodes (subsumes #1377)
- **Root cause**: `substituteWorkflowVariables()` did `.replace()` splicing user text into `bash -c` script body
- **Fix**: Added `shellSafe` option to skip user-controlled var substitution; pass them as subprocess env vars instead. Bash naturally expands `$ARGUMENTS` from env at runtime.
- **Affected paths**: `executeBashNode`, `until_bash` in loop nodes
- **Tests**: 3 new tests (2 unit shellSafe, 1 integration env var delivery). All 279 existing tests pass.
- **CodeRabbit review**: Found 1 Major + 1 Nitpick — both addressed:
  - Major: `LOOP_PREV_OUTPUT` in `until_bash` should reference previous iteration output, not current. Fixed by capturing `prevIterationOutput` before updating `lastIterationOutput`.
  - Nitpick: Test spy cleanup in try/finally + assert call count before dereferencing. Applied.
- **CI**: Ubuntu ✅, Windows/docker-build pending at time of push
- **Lessons**:
  - Claude Code via `claude --print` timed out again (Copilot API 60s idle timeout) — implemented manually instead. For Archon's codebase, manual implementation is faster for surgical changes.
  - The investigation comment on the issue (#1585) had a detailed implementation plan by `acton-golden` that was very accurate — saved significant analysis time. Good to read all issue comments carefully.
  - When adding env vars to subprocess calls, check loop semantics carefully — iteration-scoped values (LOOP_PREV_OUTPUT, LOOP_USER_INPUT) have different values per iteration.

## 2026-05-14 Session Notes

### PR #1676 — fix(scripts): handle duplicate ARCHON_STATE_JSON_BEGIN blocks in persist (pending, fixes #1674)
- **Issue**: Persist script fails when synthesize node emits duplicate `ARCHON_STATE_JSON_BEGIN` blocks (truncated + complete)
- **Root cause**: `indexOf(BEGIN)` finds first (partial) BEGIN, pairs with first END → slice spans both blocks → JSON.parse fails
- **Fix**: `lastIndexOf(BEGIN)` to find last (complete) block; `indexOf(END, lastBegin)` for correct END pairing; brief boundary uses `indexOf(BEGIN)` (first) so preamble captured by heading filter
- **Tests**: 4 new integration tests (single-block, duplicate-block #1674 repro, JSON-wrapper fallback, invalid-input)
- **CI**: Ubuntu ✅ Windows ✅ Docker-build ✅ CodeRabbit: "No actionable comments"
- **Lessons**:
  - Small surgical fix (3 line changes) done manually — faster than acpx exec for trivial changes
  - `lastIndexOf` + forward `indexOf(END, beginIdx)` pattern is common for "find last valid delimited block"
  - The persist script is standalone (no package imports) so test isolation is trivial — spawn subprocess in temp dir

## 2026-05-13 Session Notes

### PR #1661 — fix(providers): preserve native tools when skills set without allowed_tools (pending, fixes #1605)
- **Issue**: Skills wrapper defaulted `tools` to `['Skill']` when no `allowed_tools` set, stripping all native tools
- **Root cause**: `provider.ts:439` — `agentTools` defaulted to `['Skill']` when `options.tools` was undefined
- **Fix**: Omit `tools` field on AgentDefinition when undefined → SDK provides default tool set. When `allowed_tools` is set, append `Skill` as before.
- **Tests**: 2 new tests (skills without allowed_tools → tools undefined; skills with allowed_tools → tools includes Skill). 74 pass total.
- **CI**: Ubuntu ✅ Windows ✅ Docker-build ✅ CodeRabbit: "No actionable comments"
- **Pattern**: Option B (omit field, let SDK defaults apply) is always cleaner than hardcoding default lists that need maintenance
- **Selection**: Found after extensive search — nearly all candidate issues in tracked repos had competing PRs. This issue was unclaimed for 6 days, well-documented with root cause analysis and suggested fixes.
- **Lesson**: Saturday-filed issues in active repos may have lower competition than weekday issues (filed May 7, no competing PR by May 13)

### PR #1658 — fix(clone): multi-forge auth (pending, fixes #1655)
- **Issue**: Clone handler only injected auth tokens for github.com URLs — GitLab/Gitea/Forgejo private repos failed
- **Root cause**: Hardcoded `github.com` substring check + `GH_TOKEN` only
- **Fix**: 
  - New `resolveForgeAuth()` function matches forge by parsed hostname (not URL substring)
  - Exact match for known hosts (github.com, gitlab.com, gitea.com)
  - Label-based match for self-hosted (gitlab.mycompany.com → gitlab label → GITLAB_TOKEN)
  - Correct auth URL scheme per forge (oauth2: for GitLab, bare token for GitHub/Gitea)
- **CodeRabbit security review**: Caught that substring matching on full URL could leak tokens when forge name appears in path. Fixed by switching to hostname-only matching. Added 2 security regression tests.
- **Tests**: 55 pass (13 new: 5 forge integration + 4 resolveForgeAuth unit + 2 security + 2 updated)
- **CI**: Ubuntu + Windows + docker-build all green
- **Lessons**:
  - CodeRabbit gives substantial security feedback on Archon — especially around credential handling. Always think about token leakage vectors
  - The codebase already had GITLAB_TOKEN/GITEA_TOKEN support in forge adapters — checking existing patterns saved design time
  - Hostname parsing > substring matching for security-sensitive URL operations
  - This was a good candidate: clear issue, no competition, simple root cause, direct fix path

### PR #1694 — fix(workflows): condition_json_parse_failed → error (pending, fixes #1673)
- **Issue**: When `when:` condition references `$node.output.field` and JSON parse fails (Pi/Minimax wrapping in markdown fences), workflow exits 0 silently
- **Root cause**: `resolveOutputRef()` returned `''` on parse failure → `evaluateAtom` returned `{parsed: true, result: false}` → DAG treated as legitimate skip
- **Fix**: `resolveOutputRef` now throws `OutputRefParseError` on parse failure. `evaluateAtom` catches it → returns `{parsed: false}`. DAG executor already handles this correctly (exits non-zero + error message). Also: strips markdown fences before JSON.parse attempt.
- **Tests**: 4 new tests (parse failure → parsed:false, fence stripping, compound propagation). 54 pass total.
- **CI**: Ubuntu ✅ Windows ✅ Docker-build ✅ CodeRabbit: skipped
- **Pattern**: When a function returns a sentinel value (empty string) that's indistinguishable from a valid state (empty output), the downstream consumer can't differentiate — use exceptions or discriminated unions instead
- **Selection**: Well-documented issue, clear root cause, no competing PRs, small surgical fix

## 教训

### bun mock.module 泄漏 (2026-05-16)
bun 的 `mock.module()` 会影响同一个 package 里所有测试文件的模块解析。
如果 mock 只导出了部分 symbol，其他测试文件 import 同一模块时会报 `Export named 'X' not found`。
**解法**：mock 时必须导出目标模块的所有被引用的 symbol，不只是当前测试用到的。

### CodeRabbit Review 模式
- CodeRabbit 会检查 resilience（try/catch for external calls）
- 会建议 tighten test assertions（avoid `expect.arrayContaining` when exact match is better）
- Profile: CHILL — 不太严格但有用
