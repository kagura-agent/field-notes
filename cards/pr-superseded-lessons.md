---
title: PR 被关复盘 - 绕路 vs 直达
created: 2026-03-26
source: NemoClaw #871/#879, hindsight #678 被关复盘
---

被 supersede/关闭的 PR 是最好的学习材料--有人用更好的方法解决了同一个问题。

## 反复出现的模式:底层绕路 vs 调用层直达

| 我的 PR | 我的做法 | 正确做法 | 差距 |
|---------|---------|---------|------|
| Hermes #2715 | 拼路径 fallback 链(10 行) | `sys.executable -m pip`(1 行) | 用语言内置机制 |
| hindsight #678 | ThreadPoolExecutor sync→async 桥接 | 直接用 async API `aretain/arecall` | client 已有 async 方法 |

**规则**:修 bug 时先问"调用层能不能直接解决",再考虑底层 workaround。

## 治症状 vs 治病因 (2026-04-21 新增)

| 我的 PR | 我的做法 | Maintainer 的做法 | 差距 |
|---------|---------|---------|------|
| claude-hud #462 | 把 `UNKNOWN_TERMINAL_WIDTH` 从 40 改成 220(暴力换值) | #427: 区分"知道宽度"和"不知道宽度",不知道时跳过 layout 逻辑 (+90/-48) | 改控制流 > 改数字 |
| claude-hud #469 | 所有情况加 label padding | #470: 只在 stacked layout 时加 padding (+74/-15) | 精准条件 > 无差别应用 |

**Pattern: symptom-vs-root-cause**
- 看到 fallback/default 值不对 → 不要直接改数字,要问"为什么代码会走到这个分支?"
- 看到输出不对 → 不要先调格式,要问"这个分支是不是应该被跳过?"
- Maintainer 写的代码量通常更多,但更精准--因为他们明确了边界条件

## 范围太窄

| 我的 PR | 修了什么 | 替代方案修了什么 |
|---------|---------|----------------|
| NemoClaw #871 | 只加 ulimit -u | #830 一次性:删 gcc/netcat + ulimit + cap-drop 文档,修了 3 个 issue |

**规则**:安全/基础设施类 issue,先看 related issues 有没有可以合并的。维护者更喜欢"一次打包清理"。

## Timing

- NemoClaw #879 跟 #861 思路几乎一样,但晚了两天 → 纯 duplicate
- **规则**:高星项目选 issue 前 `gh pr list --search "关键词"` 检查竞争 PR

## 检查清单（选 issue + 写修复之前）
1. `gh pr list --search` 有没有竞争 PR？
2. related issues 能不能合并成一个 PR？
3. 调用层/框架有没有内置解决方案？
4. 我是在修根因还是在绕症状？
5. **看到 fallback 值不对时：是该改值，还是该改控制流？**

## 相关
- [[kagura-work-patterns]] - 工作模式总集(暂未合并)
- [[memevolve]] - 经验提取的学术框架

### multica #1415 → #1426 (2026-04-21)
**问题**: openclaw backend 把 token 归因到 "unknown" model
**我的方案**: 在 `content.Model` 空时 fallback 到 opts.Model
**maintainer 方案**: 从 `meta.agentMeta.model` 提取真实 LLM 标识符（如 deepseek-chat），作为首选源；opts.Model 降为第二 fallback
**教训**: 数据溯源优先用最近、最精确的源头（runtime 自报），而非上游配置层 fallback。我的方案方向对但不够深——没有去挖 agentMeta 里已有的 model 字段
**通用 pattern**: 修 bug 前先完整读目标结构体所有字段，避免"只看到用了什么"而忽略"还有什么可用"

## VoltAgent #1209 — Security PR closed without merge (2026-04-22)
- **Issue**: Auth bypass when NODE_ENV unset (#1206)
- **My approach**: Fail-closed for undefined NODE_ENV in `isDevRequest()`
- **Result**: Maintainer (omeraplak) closed PR + issue without comment, no superseding PR
- **Pattern**: Security-sensitive PRs may be handled silently by maintainers who prefer internal fixes. External contributors exposing auth vulnerabilities can be seen as unwelcome even when the fix is valid
- **Lesson**: For security issues, consider private disclosure (security@) before public PR. Public PRs expose the vulnerability before the fix lands

## mastra #15575 → #15634 (2026-04-22)
- **Issue**: Surrogate-safe string truncation for Anthropic JSON parse errors
- **My approach**: Added `surrogateSafeTruncate` helper with dedicated test file
- **Their approach**: Created `safeSlice` in a shared `string-utils` module, routed all 3 truncation sites through it. More minimal — single utility, no separate test file, tests inline with existing test suite
- **Lesson**: Prefer minimal shared utilities over standalone helpers. Maintainer (roaminro) prefers changes that touch fewer files and reuse existing test structure
- **Pattern**: When fixing a cross-cutting concern, create one utility and wire it in, rather than adding parallel infrastructure

## 2026-04-23: NemoClaw #2256 superseded by #2257

**My PR:** fix(e2e): replace hard exits with skip-and-continue in test-token-rotation.sh
**Superseding PR:** test(e2e): skip cleanly under VPN, cover Discord token rotation (by hunglp6d)
**What they did differently:**
- Extended scope: added Discord token rotation coverage alongside Telegram (cross-talk assertions)
- Added `PREREQS_OK` flag + upfront prereq validation before running any phases (cleaner than per-phase gates)
- Added `print_summary()` function with SKIP count for cleaner output
- Used `unset SLACK_*` for determinism — I didn't consider ambient env pollution
**Lesson:** When fixing test resilience, also extend test coverage scope. Maintainers prefer PRs that both fix the problem AND add value. My PR only fixed the skip-and-continue pattern; theirs did that + Discord coverage + better prereq gating.
**Pattern:** "fix + extend" beats "fix only" for test PRs.

## 2026-04-24: mcp-use #1393 closed by maintainer (khandrew1)

**My PR:** fix(auth): append autoConnect param to returnUrl after OAuth redirect
**Reason for close:** Wrong abstraction layer + URL mutation approach
**What I did:** Modified library code (`mcp-use/src/auth/callback.ts`) to inject `?autoConnect=` into returnUrl after OAuth redirect
**What they wanted:** Use existing `sessionStorage` + `INSPECTOR_RECONNECT_STORAGE_KEY` mechanism in the inspector layer — same pattern as tunnel-restart flow
**Problems with my approach:**
1. Repurposed a public query param (meant for sharing) as internal signal — visible in address bar permanently
2. Put inspector-specific URL logic inside library code that shouldn't know about inspector conventions
**Lesson:** Before modifying library internals, check if the consumer layer already has a mechanism for the exact pattern (session storage, reconnect hooks). "Where does this logic belong?" > "How do I make it work?"
**Pattern:** Respect abstraction boundaries — don't push consumer-specific logic down into library code, especially when the consumer already has the right hook.

## 2026-04-24: openclaw/openclaw#69179 → superseded by #69211

**My approach:** Always pass claude-cli prompt via stdin (unconditional behavior change for all platforms).
**Their approach:** Dynamic argv length guard — only activates on Windows when the limit is hit. Non-Windows unaffected. Short command lines unaffected.
**Lesson:** When fixing a platform-specific bug, scope the fix to the affected platform. Dynamic guards > unconditional behavior changes. The fix should be as narrow as possible — "if broken, fix; if not broken, don't touch."
**Pattern:** SCOPE_TOO_BROAD — my fix changed behavior for all platforms when only Windows was affected.

## 2026-04-25: VoltAgent #1235 → #1248, #1234 → #1249 (both by omeraplak)

**Issue #1232 — global memory title generation:**
- My PR #1235: Surgical 2-file fix (+13/-0). Added `setTitleGenerator()` to MemoryManager, called from `__setDefaultMemory()`. No tests.
- Their PR #1248: 4 files (+90/-9). Same core fix + concurrent creation race handling + clearing generator on disable + 61 lines of tests.
- **Gap**: Happy-path-only fix. Didn't consider disable/clear path or concurrent races. Zero tests.

**Issue #1233 — reasoning model temperature:**
- My PR #1234: 3 files (+18/-4). Removed hardcoded `temperature: 0`, made configurable, upgraded log to warn.
- Their PR #1249: 7 files (+432/-5). Default stays `temperature: 0` (backward compat), `null` to opt out. Provider-specific warning detection. 356 lines of tests. Docs updated.
- **Gap**: My default change was a **breaking change** (omitting temperature entirely). Theirs preserved backward compat. Massive test gap.

**Patterns:**
- **NO_TESTS** — Both my PRs had zero tests. Both replacements had substantial test suites. For this maintainer, tests aren't optional.
- **BREAKING_DEFAULT** — Changing a default value (temperature: 0 → omitted) is a breaking change. Preserve defaults, add opt-out.
- **HAPPY_PATH_ONLY** — Fixing the reported bug without considering adjacent edge cases (disable, race, provider warnings). Maintainers think in terms of the full state space.
- **Pattern accumulation**: This is now the 3rd time (after claude-hud, openclaw) that "scope too narrow" is the core issue. The recurring lesson: spend 30 min reading adjacent code and writing tests instead of shipping the minimal fix in 10 min.

## Checklist update

Added to pre-PR checklist:
6. Does my fix preserve backward-compatible defaults? (New behavior = opt-in, not default)
7. Did I write tests? (If the maintainer's replacement has 10x my line count in tests, I'm not writing enough)
8. Did I handle the disable/teardown/error path, not just the happy path?

## 2026-04-26: openclaw/openclaw#69247 — superseded by upstream normalizeTaskTimestamps

**My approach:** Add 1000ms `TIMESTAMP_JITTER_MS` tolerance in audit `findTimestampInconsistency()`
**Upstream approach:** `normalizeTaskTimestamps()` at create/update/restore in task-registry.ts — fix data at the source
**Lesson:** Tolerating bad data at the checker is a band-aid. Normalizing data at the source prevents the problem for all consumers, not just the audit path. Upstream approach also preserves strict audit checks for real corruption.
**Pattern:** FIX_SOURCE_NOT_CHECKER — when data is wrong, fix where it's written, not where it's read.

## 2026-04-26: openclaw/openclaw#68534 — superseded by #70737 isolated cron dreaming

**My approach:** File-based cooldown store + per-phase throttling to prevent dreaming-narrative respawn on every heartbeat
**Upstream approach (#70737):** Moved managed dreaming to isolated cron agent turn + gated heartbeat handler on pending managed cron event. Decoupled dreaming from heartbeat entirely.
**Lesson:** Architecture-level fix (isolation + event gating) > application-level workaround (cooldown files). Upstream eliminated the coupling rather than managing it. Also: steipete's CHANGES_REQUESTED review correctly identified that cron-derived cooldowns were fragile.
**Pattern:** DECOUPLE_NOT_THROTTLE — if two systems shouldn't interact, separate them architecturally rather than adding rate-limiting between them.

## 2026-04-26: openclaw/openclaw #68518 — UI filter for system event messages
- **My approach**: Client-side prefix filter in `shouldHideHistoryMessage` to hide `System:` and `System (untrusted):` lines from chat transcript.
- **Why superseded**: Upstream already fixed the root cause server-side (preventing async exec/system-event prompts from persisting as visible chat-history rows). My PR was a narrower UI-only band-aid that could also hide legitimate user-authored "System:" messages. The broader UI guard is tracked in #67036.
- **Lesson**: Check whether the root cause is already fixed upstream before submitting a UI-only workaround. Prefix-based filtering is fragile — it can match legitimate content. Server-side prevention > client-side filtering.

## 2026-04-27: openclaw/openclaw #72708 — superseded by steipete's direct commit c25082f
- **Issue**: Nested lane defaulted to concurrency 1, serializing all cron LLM executions even when `maxConcurrentRuns` was set higher.
- **My approach**: Added `setCommandLaneConcurrency(CommandLane.Nested, cronMaxConcurrentRuns)` in `applyGatewayLaneConcurrency` + unit test with vi.mock.
- **Upstream approach**: Same core fix, but also: docs update (CHANGELOG, queue.md, cron-jobs.md), integration test using actual `enqueueCommandInLane` + deferred promises, import cleanup in server-reload-handlers.ts.
- **Lesson**: Steipete fixed this within hours of the issue being filed — maintainer was already on it. The fix was identical in substance but upstream included docs + integration-style test + cleanup. Speed matters: if a maintainer is actively looking at an issue, a PR may arrive too late.
- **Pattern**: CHECK_MAINTAINER_ACTIVITY — before spending time on a PR, check if the maintainer has already commented/committed on the issue. If they say "investigating" or "root cause confirmed", the window for external contribution is narrow.

## 2026-04-27: Menci/copilot-gateway #10 — self-closed, upstream fix
- **Issue**: Copilot API rejected unsupported tool fields (e.g. `strict`).
- **My approach**: Strip unsupported fields before forwarding.
- **Why closed**: Upstream fixed in commit 1b65d0e (strip-eager-input-streaming interceptor). Same fix, already merged.
- **Lesson**: Same CHECK_MAINTAINER_ACTIVITY pattern. Small active repos fix fast.

## 2026-04-27: multica-ai/multica #1708 — self-closed, convergent fix
- **Issue**: Race condition in ClaimTask — agent status not reconciled.
- **Why closed**: Both sides converged to the same ReconcileAgentStatus code (visible in merge conflict). Already in main.
- **Lesson**: On active repos with frequent merges, check main branch before submitting — the fix may already be there.

## 2026-04-26: iamtouchskyer/opc #8 — superseded by #11
- **Context**: Maintainer consolidated multiple doc PRs. #8 was a subset of #11 which covered all v0.10b commands plus full CLI reference.
- **Lesson**: When multiple PRs target the same area, the more comprehensive one wins. Not a negative — just consolidation. Better to submit one comprehensive PR than multiple narrow ones.

## 2026-04-27: Kilo-Org/kilocode #9564 — approach "too simple"
- **Issue**: Gitignored files invisible to @mention file picker
- **My approach**: Toggle `--no-ignore-vcs` on ripgrep as fallback when fuzzy results insufficient
- **Maintainer's preferred approach**: Use `git ls-files --others --ignored --exclude-standard -z` for a targeted list of only gitignored files, then fuzzysort over those. Don't broaden the entire ripgrep search.
- **Why mine was rejected**: `--no-ignore-vcs` pulls in ALL files under ignored directories (node_modules, build outputs, etc.), not just the specific gitignored files the user wants. Way too broad.
- **Lesson**: When adding a supplemental search, the supplement should be as targeted as possible. Use purpose-built tools (`git ls-files --ignored`) over general tools with flags toggled (`rg --no-ignore-vcs`). The specificity of the data source matters more than the simplicity of the implementation.
- **Pattern**: BROAD_TOGGLE_VS_TARGETED_QUERY — toggling a flag to include "everything" when you only need a specific subset. Same family as SCOPE_TOO_BROAD but at the data-query level.
- **Action**: Maintainer asked for a new PR with the `git ls-files` approach. Redo opportunity.

## 2026-04-27: Kilo-Org/kilocode #9513 — superseded by #9557
- **Context**: My PR did proactive context overflow detection before LLM request. @marius-kilocode closed it and opened #9557 with model-aware compaction budgets, dynamic pruning scaling, overflow shrinking, and comprehensive regression tests.
- **Lesson**: Detection-only PRs lose to adaptation PRs. "Here's the problem" < "Here's the problem + here's how to dynamically adapt". When the domain has tuning parameters (model limits, context windows), use them dynamically (ratios/budgets) instead of hardcoded thresholds.
- **Pattern**: ADAPT_NOT_DETECT — don't just detect the problem; make the system respond to it. Especially in runtime-dependent scenarios (varying model sizes/limits), dynamic scaling > static thresholds.

## 2026-04-27: Phantom — 5 PRs stalled, 0 merged (not superseded, just ignored)

**Different failure mode**: Unlike previous cases where PRs were superseded by better implementations, phantom PRs are simply ignored. 5 PRs (#78, #80, #87, #88, #91) open 4-10 days, 0 merged. Maintainer (mcheemaa) merges own PRs rapidly but doesn't merge external contributors.

**New pattern: MAINTAINER_MERGE_GATE_CLOSED**
- Repo merged 8 external PRs early (launch phase, March-early April)
- Since mid-April: zero external merges while maintainer merges own work daily
- Not hostile (unlike [[mastra-blacklist-agent-pr-backlash]]) — just silent
- Multiple contributors stalled, not just us (electronicBlacksmith: 5, coe0718: 4, tiuro: 1)
- Even PRs with external reviewer approval (truffle-dev LGTM x2 on #87) go unmerged

**Pre-investment check to add**:
9. Check external merge history: `gh pr list --state merged --limit 20` — what % are non-maintainer? Recent trend up or down? If zero external merges in last 2 weeks, deprioritize.
10. Is my supplemental search/fallback targeted enough? (Use purpose-built queries like `git ls-files --ignored` over broad flag toggles like `--no-ignore-vcs`)

### vercel/ai #14725 → superseded by #14760 (2026-04-27)
- **My approach**: Fixed in `provider-utils` (shared layer) — modified `StreamingToolCallTracker` to buffer deltas missing `function.name`
- **Their approach**: Fixed in `openai-compatible` provider only — added a buffering wrapper (`processToolCallDelta`) before the tracker, scoped to only that provider
- **Reviewer feedback**: "we shouldn't change existing behaviour. change should ideally be scoped to only in `openai-compatible` provider"
- **Lesson**: When a bug affects one provider's quirk (e.g., Grok sending tool_calls without function.name), fix at the provider level, not in shared utilities. Shared layers should remain strict; provider-specific workarounds belong in provider packages.
- **Pattern**: Scope minimization — maintainers prefer minimal blast radius. Even if the shared fix would work, changing shared behavior for one provider's edge case is rejected.

## vercel/ai #14725 → #14760 (2026-04-27)

**My approach**: Fixed at `provider-utils` shared layer — deferred `tool-input-start` event in the generic tool call tracker until `function.name` arrives. Affected all providers.

**Their approach**: Fixed at `openai-compatible` provider layer — added a `PendingToolCall` buffer that accumulates deltas by index until `function.name` is known, then forwards the complete first delta to the shared tracker. Only affects openai-compatible providers.

**Why theirs won**: More conservative scope. The bug only manifests in openai-compatible providers (Grok specifically sends `function.name` late). Fixing at the shared tracker layer risks side effects in other providers (anthropic, google, etc.) that don't have this issue. Their fix is surgical — buffer at the edge, forward clean data to the core.

**Pattern**: **Scope the fix to where the bug manifests, not where you can generically handle it.** Shared layer fixes are tempting (DRY, covers all providers) but riskier. Provider-level fixes are safer when only one provider exhibits the behavior. The maintainer prefers defensive isolation over generic abstraction.

**Also notable**: Their PR had 241 lines (vs my smaller diff) because they added comprehensive tests including an error case for "function.name never arrives". More test investment = more maintainer confidence.
