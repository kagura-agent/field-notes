# OpenCode (anomalyco/opencode)

Open-source coding agent CLI. 148k+ stars (2026-04-23), 92% merge rate. Now under `sst/opencode`.

> ⚠️ **注意**: `opencode-ai/opencode`（Go 版本）已于 2025-09 归档。最后 commit 2025-09-18。这里记录的是 `sst/opencode`（TypeScript 版本），它仍然活跃。两者是不同项目。

## Repo 基本信息
- **语言**: TypeScript (Bun)
- **运行时**: Bun 1.3+（不是 Node.js）
- **默认分支**: `dev`
- **构建**: `bun install && bun dev`
- **测试**: `bun test`（推测，未本地验证）
- **本地环境**: ✅ fork 已 clone 到 `~/repos/forks/opencode`，可以 `bun install` + `bun test`。Bun 1.3.12。
  - ⚠️ 根目录有 `do-not-run-tests-from-root` 哨兵目录，必须 `cd packages/opencode` 再跑测试
  - electron postinstall 会 fail（无 GUI），不影响测试

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

## PR #23226 (2026-04-18)
- **Issue**: #23152 — shell mode `echo 'X${FOO}X'` expands variables inside single quotes
- **Fix**: Replace `eval ${JSON.stringify(cmd)}` with env var approach (`__OPENCODE_CMD` + `eval "$__OPENCODE_CMD"`)
- **Status**: PENDING (CI all passed ✅)
- **Root cause**: JSON.stringify wraps in double quotes → shell expands `${VAR}` before eval
- **坑**: repo uses Bun, can't easily typecheck locally (OOM on clone). Relied on CI
- **Note**: Changed type signature of invocations to include optional `env` property

## PR History

### #23412 — fix(ripgrep): use non-scoped temp directory to prevent premature cleanup (2026-04-19)
- **Status**: PENDING (CI all green ✅, compliance bot satisfied ✅)
- **Issue**: #23411 — ripgrep broken after upgrading to 1.14.18
- **Root cause**: `extract` function wraps `makeTempDirectoryScoped` with `Effect.scoped` → temp dir deleted when `extract` returns → caller can't find extracted binary
- **Fix**: Switch to `makeTempDirectory` (non-scoped), return `{executable, tempDir}`, manual cleanup in caller
- **Key learning**: Effect.scoped on `Effect.fnUntraced` closes the scope when the function returns — any scoped resources inside are finalized immediately
- **Approach**: GitHub API for code reading + direct file commits

### #23420 — fix(app): persist per-agent model selections across agent switches (2026-04-19)
- **Status**: PENDING (CI all green ✅, compliance passed ✅)
- **Issue**: #23369 — only current agent's model persists on session resume
- **Root cause**: Session state stores single `{ agent, model, variant }` — switching agents overwrites model, only last agent's model survives resume
- **Fix**: Added per-agent model map (`agents`) to State type. `agent.set()` saves outgoing agent's model before switching, restores target agent's saved model. Map carried through snapshot/promote/restore.
- **Key learning**: SolidJS persisted stores — adding optional fields is backward-compatible via `??` fallbacks, no migration needed
- **Approach**: GitHub API for code reading + direct file commits (repo too large to clone)
- **Note**: Also related to #21351 (same root cause)

### #23271 — fix(tui): defer --model validation until providers load (2026-04-18)
- **Status**: PENDING (CI all green, awaiting maintainer review)
- **Issue**: #23270 — TUI model validation race condition
- **Root cause**: `onMount` in `app.tsx` runs `model.set()` before `sync.data.provider` loads → `isModelValid()` always false. Also agent config overwrites CLI selection.
- **Fix**: Reactive `cliOverride` signal in `local.tsx` + removed eager `onMount` validation from `app.tsx`
- **Key learning**: SolidJS reactivity — `onMount` is not guaranteed to fire after async context providers resolve. Use `createEffect` for reactive timing.
- **Approach**: GitHub API for code reading + direct file commits (repo too large to clone locally)
- **CI**: check-duplicates, check-standards, check, add-contributor-label, check-compliance — all passed
- **Note**: Must use PR template or compliance bot flags the PR within minutes

### #23470 — fix(ripgrep): inline paths in PowerShell Expand-Archive command (2026-04-20)
- **Status**: PENDING (CI all green ✅)
- **Issue**: #23457 — Expand-Archive error on Windows PowerShell when loading skills
- **Root cause**: `$args[0]`/`$args[1]` in PowerShell `-Command` not reliably populated from trailing args (Windows PowerShell 5.x)
- **Fix**: Inline paths directly into command string with single-quote escaping (`'` → `''`)
- **Approach**: GitHub API (repo too large to clone)
- **Note**: 2-line change, very surgical. Same file as #23412 (ripgrep.ts — active area of refactoring)

## Session Compaction (v1.14.19, 2026-04-20)

opencode 的 session compaction 架构分三层：

### 1. Overflow Detection (`overflow.ts`)
- `usable()`: 计算可用 token = input_limit - reserved (默认 20k buffer)
- 当 total tokens ≥ usable 时触发 compaction

### 2. Tail Preservation (`compaction.ts`)
- **核心创新**: 压缩时保留最近 N 个 turn 的原始内容（默认 2 turns）
- `preserve_recent_tokens`: 预算 = min(8k, max(2k, usable * 0.25))，可配置
- 如果最后一个 turn 就超预算 → fallback 到全量摘要
- 逐 turn 从后往前累加，直到超预算为止

### 3. Pruning（独立于 compaction）
- 从后往前保护 40k tokens 的 tool call output
- 超过保护范围的旧 tool output 被清除（标记 `time.compacted`）
- "skill" 工具永远不被 prune
- 最少清 20k tokens 才执行（避免频繁小清理）

### 4. Compaction Prompt
- 模板化摘要：Goal / Instructions / Discoveries / Accomplished / Relevant files
- Plugin hook `experimental.session.compacting` 允许注入额外 context 或替换 prompt
- Overflow 时会 replay 最近的用户消息（让新 turn 在压缩后继续）

### #23630 — fix(grep): handle non-UTF-8 ripgrep output (2026-04-21)
- **Status**: PENDING (CI all green ✅, compliance passed)
- **Issue**: #23629 — Grep tool fails with non-UTF-8 (GBK) files
- **Root cause**: `Match` zod schema only accepts `lines.text`, but ripgrep emits `lines.bytes` (base64) for non-UTF-8 content → parse failure breaks all grep
- **Fix**: Added `TextOrBytes` zod schema that accepts either `text` or `bytes`, base64-decodes bytes variant. Applied to `lines` and `submatches[].match`
- **Approach**: GitHub API (repo too large to clone)
- **Test added**: Creates file with GBK bytes, verifies search doesn't throw
- **Lesson**: ripgrep JSON format has text/bytes duality for all string fields — always handle both

### #23681 — fix(tui): prevent model picker reset after first message in new session (2026-04-21)
- **Status**: PENDING (CI all green ✅, compliance passed ✅)
- **Issue**: #23666 — model picker silently resets to agent default after first message
- **Root cause**: `createEffect` in `local.tsx` tracks `agent.current()` reactively, fires on every `sync.data.agent` refresh (new object references), not just on actual agent name changes
- **Fix**: Added `prevAgentName` guard — effect only resets model when agent name actually changes
- **Approach**: GitHub API (repo too large to clone)
- **Key learning**: SolidJS `createEffect` without `on()` tracks all reactive dependencies including intermediate memos. Use deduplication guards for effects that should only fire on semantic changes, not reference changes.
- **Related**: #23420 (also model persistence, different root cause — agent switch vs sync refresh)

### #24234 — fix(config): detect non-object frontmatter data from gray-matter (2026-04-25)
- **Status**: PENDING (CI all green ✅, compliance passed ✅)
- **Issue**: #24181 — Invalid YAML in agent .md frontmatter silently ignored
- **Root cause**: gray-matter returns `md.data` as string/number/boolean/array for certain malformed YAML (e.g. `skill:true` without space after colon) without throwing. `...md.data` spread produces garbage properties, agent loads with degraded config silently.
- **Fix**: Added type guard in `ConfigMarkdown.parse()` after both initial parse and fallback sanitization. If `md.data` is not a plain object, triggers fallback or throws `FrontmatterError`.
- **Test**: 3 new tests — fixture with `skill:true`, parameterized test for number/boolean/array/string types
- **Approach**: Local clone + bun test (`~/repos/forks/opencode`). First PR done with local test run!
- **Key learning**: gray-matter's `js-yaml` parser can produce ANY scalar/sequence type for frontmatter — not just objects or throws. Always validate `md.data` type.

### 对我们的启发
- **preserve_recent_tokens 策略**值得借鉴：25% context 给最近对话保持连贯性 → 参考 [[context-budget-constraint]]
- **pruning vs compaction 分离**：轻量级清理（prune tool output）+ 重量级压缩（LLM 摘要）分开处理
- **compaction agent**: 用独立的 agent（可配不同模型）做摘要
- 跟 [[claude-code-plugins]] 的 PreCompact hook 互补：opencode 内建 tail preservation + plugin 级 context 注入；Claude Code 让外部 plugin 阻止压缩
- [[tokenjuice]] 解决的是 output 压缩，opencode compaction 解决的是 context 压缩——上下游互补

### #23641 — fix(shell): blacklist csh/tcsh to prevent bash-style syntax errors (2026-04-21)
- **Status**: PENDING (CI all green ✅, compliance fixed ✅)
- **Issue**: #23637 — Agent uses bash-style `2>&1` in csh/tcsh shell
- **Root cause**: BLACKLIST in `shell.ts` only had fish/nu, csh/tcsh not caught → used as-is → bash syntax fails
- **Fix**: Added `"csh"` and `"tcsh"` to BLACKLIST set (1-line change)
- **Test**: Added test verifying `Shell.acceptable()` rejects csh/tcsh paths
- **Approach**: GitHub API (repo too large to clone)
- **Note**: Related PR #15610 addresses sh/dash/ash (different issue — brace expansion), complementary not duplicate
- **Lesson**: check-duplicates bot uses LLM — may flag false positives, need to explain in PR description

## Session Compaction Architecture (2026-04-23 deep read, v1.14.21; updated 2026-04-24 v1.14.22)

OpenCode has a sophisticated session compaction system (`src/session/compaction.ts` + `overflow.ts`) for managing long conversations within context limits. Key design:

### Mechanism
1. **Overflow detection**: Triggers when total tokens ≥ `usable()` (context limit minus reserved buffer of 20k or max output tokens)
2. **Pruning** (lightweight): Walks backwards through tool outputs, marks old ones as compacted after protecting the most recent 40k tokens worth. Tool output truncated to 2k chars in compaction context. `skill` tool is protected from pruning.
3. **Summarization** (heavy): Uses a dedicated `compaction` agent to generate structured summaries with a fixed template (Goal / Constraints / Progress / Key Decisions / Next Steps / Critical Context / Relevant Files)
4. **Tail preservation**: Keeps recent N turns (default 2) uncompacted, with a token budget (2k-8k, or 25% of usable context). Can split a turn mid-way if it's too large.
5. **Anchored summaries**: When prior compactions exist, the new summary is built by updating the previous summary rather than starting fresh — "preserve still-true details, remove stale details, merge in new facts"

### Architecture Patterns
- Built on **Effect.ts** (functional effect system) — entire module is layered services with dependency injection
- **Plugin hooks**: `experimental.session.compacting` lets plugins inject context; `experimental.compaction.autocontinue` controls post-compaction behavior
- **Overflow replay**: When compaction is triggered by overflow, the system finds the last real user message, compacts everything before it, then replays that message after compaction
- **Auto-continue**: After compaction, injects a synthetic user message asking the agent to continue or clarify

### Relevance to [[openclaw]]
- OpenClaw doesn't have session compaction yet — long sessions just hit context limits
- The "anchored summary" pattern (incremental updates to a rolling summary) is elegant — avoids losing context from early in the conversation
- The tail preservation with token budgeting is smart — ensures recent context is always verbatim, not summarized
- Plugin extensibility for compaction is forward-thinking — allows custom context injection during compaction
- The pruning step (mark old tool outputs as compacted) is a lightweight optimization before the expensive summarization step

### v1.14.21-22 Improvements (PR #23870, 2026-04-22)

**Split tail turns**: Previously, if the most recent turn exceeded the tail budget, the system fell back to full summarization (losing verbatim recent context). Now it tries to split the turn mid-way — walks forward through messages within the turn until the remaining slice fits within the remaining budget. This means even a huge last turn preserves its tail portion verbatim.

**Stricter summary template**: Replaced the freeform template with a rigid Markdown structure with explicit sections: Goal / Constraints & Preferences / Progress (Done/In Progress/Blocked) / Key Decisions / Next Steps / Critical Context / Relevant Files. Added hard rules: "keep every section even when empty", "use terse bullets", "preserve exact file paths and identifiers".

**Prior compaction hiding**: `completedCompactions()` scans message history for successful compaction user+assistant pairs and filters them out before feeding history to the new compaction agent. This prevents the compaction agent from re-summarizing previous summaries (which would cause information loss through recursive summarization).

**Previous summary extraction**: The system now properly extracts the text content from the most recent successful compaction response and passes it as `<previous-summary>` to the anchored update prompt. Before this was less explicit.

**Configurable tool output truncation** (PR #23770): Tool output `MAX_LINES` (2000) and `MAX_BYTES` (50KB) are now configurable via `tool_output.max_lines` / `tool_output.max_bytes` in opencode config. Uses `Effect.serviceOption` for backward compatibility — tests without Config get the defaults. Also wired `bash.ts` to use `trunc.limits()` so the model-facing description matches the enforced limits.

**Pattern**: The split-tail approach is worth studying for [[openclaw]] — it maximizes verbatim recent context without sacrificing the compaction mechanism. The "hide prior compactions" logic prevents a subtle failure mode where recursive summarization progressively loses detail.

### Constants
- `PRUNE_MINIMUM`: 20k tokens (minimum savings to actually prune)
- `PRUNE_PROTECT`: 40k tokens (recent tool outputs protected)
- `TOOL_OUTPUT_MAX_CHARS`: 2k (truncation in compaction context)
- `DEFAULT_TAIL_TURNS`: 2
- `MIN_PRESERVE_RECENT_TOKENS`: 2k
- `MAX_PRESERVE_RECENT_TOKENS`: 8k
- `COMPACTION_BUFFER`: 20k (reserved for output during compaction)
