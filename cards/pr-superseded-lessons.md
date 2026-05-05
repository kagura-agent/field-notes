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

### Phase 1: 选 Issue
1. `gh pr list --search` 有没有竞争 PR？
2. related issues 能不能合并成一个 PR？
3. CHECK_MAINTAINER_ACTIVITY: maintainer 是否已在 comment/commit？如果说了 "investigating" 窗口很窄
4. 外部 merge 历史: `gh pr list --state merged --limit 20` — 近 2 周有多少非 maintainer PR 被 merge？0 个 → 降优先级 (MAINTAINER_MERGE_GATE_CLOSED)

### Phase 2: 设计修复方案
5. 调用层/框架有没有内置解决方案？先查再自己写
6. 我是在修根因还是在绕症状？(symptom-vs-root-cause)
7. **看到 fallback 值不对时：是该改值，还是该改控制流？**
8. 能不能在源头拦截（FIX_SOURCE_NOT_CHECKER）？数据错 → 修写入端，不是修读取端
9. 修 duplicate/冗余类 → 能不能在源头标记 disabled/invalid？源头拦截一次 > 消费端到处过滤
10. 平台特定 bug → scope 到该平台，动态 guard > 无条件行为改变 (SCOPE_TOO_BROAD)
11. 共享层 vs 特定层：bug 只影响一个 provider/consumer → 在该层修，不改共享代码
12. 搜索/fallback → 用目标精准的查询（`git ls-files --ignored`），不用大范围 toggle（`--no-ignore-vcs`）(BROAD_TOGGLE_VS_TARGETED_QUERY)
13. 检测 vs 适应：不要只检测问题，要让系统动态响应（动态预算/比例 > 静态阈值）(ADAPT_NOT_DETECT)
14. 解耦 vs 节流：两个系统不该交互 → 架构分离，而非加限流 (DECOUPLE_NOT_THROTTLE)
15. 已有 retry/reconnect 机制？Prefer additive retry over behavioral deferral
16. Keep providers stateless — 用参数传数据，不用 module-level state
17. Respect abstraction boundaries — consumer 逻辑不要推到 library 层
18. 安全类 issue：考虑先私下报告(security@)再公开 PR。REDACT_VS_REMOVE: 凭证完全移除 > 遮掩

### Phase 3: 实现 & 提交
19. 我的 fix 保持向后兼容的 defaults 吗？新行为 = opt-in，不是 default (BREAKING_DEFAULT)
20. **写测试了吗？** 如果 maintainer 的替代方案测试量是我的 10x，说明我写太少 (NO_TESTS)
21. 处理了 disable/teardown/error path 吗？不能只覆盖 happy path (HAPPY_PATH_ONLY)
22. CLI flag fix → 测试所有语法变体：`--flag=val`、`--flag val`、`-f val`、`--flag` 单独 (CLI_FLAG_SYNTAX_COVERAGE)
23. 更新了用户文档吗？CLI fix 必须同步改 docs
24. 检查 main branch — fix 可能已经 merge 了
25. 搜 codebase 有没有现有 runtime context flag 该影响行为（如 RUNNING_FROM_BUILT_ARTIFACT）

### Quick Patterns Reference
| Pattern | 一句话 |
|---------|--------|
| FIX_AND_EXTEND | fix + extend 胜 fix only（尤其测试 PR）|
| FIX_SOURCE_NOT_CHECKER | 数据错 → 修写入端 |
| SCOPE_TOO_BROAD | 最小爆炸半径 |
| CHECK_MAINTAINER_ACTIVITY | maintainer 在看了就别花时间 |
| ADAPT_NOT_DETECT | 动态适应 > 静态检测 |
| DECOUPLE_NOT_THROTTLE | 架构分离 > 限流 |
| NO_TESTS | 没测试 = 没信心 |
| HAPPY_PATH_ONLY | 别忘 teardown/error path |
| BREAKING_DEFAULT | 新行为 opt-in |
| REDACT_VS_REMOVE | 凭证完全移除 |
| BROAD_TOGGLE_VS_TARGETED_QUERY | 精准查询 > 大范围 toggle |
| USE_RUNTIME_CONTEXT | 用已有 runtime flag 决定行为 > hardcode 固定顺序 |

## 相关
- [[kagura-work-patterns]] - 工作模式总集(暂未合并)
- [[memevolve]] - 经验提取的学术框架

### openclaw #73608 → f641691910 (2026-04-28)
**问题**: 多个 Discord account 解析到同一 bot token 时，gateway 启动多个重复 monitor，导致 double-response
**我的方案**: 在 monitor 创建阶段用 Set 去重 token，跳过重复的 account
**maintainer 方案**: 把 duplicate-token 检查移到 account enablement 路径（更早的生命周期），disabled account 直接不创建 monitor；同时修了 stale route binding 问题（额外 scope），加了完整测试
**教训**: 1) 在生命周期更早的位置拦截 > 在消费端过滤。我在 monitor 层去重，但 account 本身仍然 enabled，其他依赖 enabled accounts 的逻辑仍会受影响。2) maintainer 顺手修了 stale route binding — 同一次改动覆盖了相关但不同的 bug。
**通用 pattern**: 修 duplicate/冗余类 bug 时，问「能不能在源头标记为 disabled/invalid，而不是在消费端过滤？」源头拦截一次 vs 消费端每处都要过滤。

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

### VoltAgent/voltagent #1253 → superseded by #1257 (2026-04-28)
- **Issue**: WorkspaceSearch auto-index fails for tenant-aware filesystems needing `operationContext`
- **My approach**: Deferred auto-index entirely — moved from constructor-time to lazy execution on first `search()` or `init()`. Changed the architectural contract: constructor no longer auto-indexes.
- **Their approach**: Kept auto-index at init time but added retry-with-context logic — if initial auto-index fails (no context), retries on next `search()` call when context is available.
- **Why theirs won**: More conservative. My approach changed the constructor contract (callers expecting auto-index at construction time would see different behavior). Their approach preserves existing semantics while adding graceful recovery. Same end result, less behavioral change.
- **Pattern**: **Prefer additive retry over behavioral deferral.** When a constructor does eager work that sometimes fails, adding "retry with context on next call" is less disruptive than removing the eager behavior entirely. Maintainers prefer fixes that preserve existing contracts.

### openclaw/openclaw #73386 → superseded by db40ec404a (2026-04-28)
- **Issue**: Ollama discovered models lost thinking level support after discovery refactor
- **My approach**: Added module-level `Set` (`ollamaDiscoveredThinkingModels`) in the Ollama extension, populated during discovery. `isReasoningModel()` checked this set. Modified 3 files in `extensions/ollama/`.
- **Their approach**: Passed `catalog?: ThinkingCatalogEntry[]` parameter through existing function signatures in `thinking.ts` and related files. Touched 30+ files across the codebase to thread the metadata properly.
- **Why theirs won**: My approach introduced **stateful module-level state** in what should be a stateless provider. The maintainer comment: "keeps the Ollama provider stateless and instead passes the discovered catalog reasoning metadata through." Their approach required more changes but maintained architectural purity.
- **Pattern**: **Keep providers stateless.** When discovery data needs to reach downstream code, pass it through function parameters — even if it means touching many files. Module-level state in providers creates hidden coupling, testing difficulty, and concurrency risks. The extra diff is worth the architectural cleanliness.

### 2026-04-29: NemoClaw #2510 — Brave validation downgrade (timing race)
- **Issue**: Brave Web Search API key validation failure aborted non-interactive onboard (#2507)
- **My approach**: Downgrade to warning + return null in `validateBraveApiKey()` — nearly identical to the winning PR.
- **Their approach** (#2511 by @laitingsheng): Same approach (downgrade to warn + skip) + added dedicated test file `test/onboard-brave-validation.test.ts`.
- **Why theirs won**: Pure timing race. Both PRs were opened for the same issue; maintainer (@jyaunches) made a "direction call" between them. The winning PR included a test file.
- **Pattern**: **Always include tests when fixing bugs.** Even when the code fix is trivial, a test file demonstrates thoroughness and gives maintainers confidence. In a tie, tests tip the scale.

## 2026-04-30: openclaw #74877 — auto-reply fallback
- **My approach**: Added `messageToolAvailable` option at dispatch level, computed availability in auto-reply dispatcher
- **Maintainer's approach**: Fixed the resolution function (`resolveSourceReplyDeliveryMode`) directly — when `requested: "message_tool"` but tool unavailable, fall back to `"automatic"` right in the resolver
- **Pattern**: Fix at the lowest possible level. If a resolution function returns a mode that can't be fulfilled, the resolution function itself should handle the fallback, not the caller.
- **Positive**: steipete credited in CHANGELOG, code was largely correct just needed restructuring. The issue identification and fix direction were good.

## 2026-05-03: NemoClaw #2468 → superseded by #2900 (ericksoa)
- **Issue**: Dashboard URL token leakage — `#token=<auth-token>` printed in startup logs
- **My approach**: Wired existing `redact()` utility through all `console.log(url)` call sites (3 sites in agent-onboard.ts + onboard.ts). Minimal diff, reused existing function.
- **Their approach**: Completely removed token from displayed URLs. Added `gateway-token --quiet` CLI retrieval command as separate step. Updated docs + shell script + test assertions. Token never appears in any log or output — user must explicitly retrieve it.
- **Why theirs won**: Stronger security posture. Redacting (masking with `****`) still exposes token structure/prefix. Complete removal + separate retrieval channel is more secure for credentials. Also: docs + shell script changes = comprehensive fix vs my code-only fix.
- **Pattern**: **REDACT_VS_REMOVE** — for security-sensitive data (tokens, passwords), complete removal from output > redaction/masking. Redaction leaks structure (length, prefix). Provide a separate retrieval path (CLI command) rather than masking inline.
- **Maintainer note**: ericksoa acknowledged: "This was the right security direction and gave us the concrete starting point." Positive credit despite superseding.

## 2026-05-03: NemoClaw #2833 → superseded by #2890 (ericksoa)
- **Issue**: Stale malformed onboard.lock files blocking subsequent runs after abnormal exit (#2765)
- **My approach**: Age-based cleanup — `fs.statSync(mtime)` > 30s → remove malformed lock. Distinguished fresh malformed (possible mid-write) from stale debris. +14 code lines, +17 test lines.
- **Their approach**: Replayed my malformed-lock fix verbatim + added PID reuse detection. Read `/proc/<pid>/stat` to get kernel start time (field 22), compare against `btime` from `/proc/stat`. If start time doesn't match, the PID was reused by an unrelated process → treat as stale. 207 additions.
- **Why theirs won**: PID reuse is a real production failure mode for locks. My fix handled malformed locks but not the case where a valid-format lock references a PID that was recycled to a different process. Their fix closes both gaps.
- **Pattern**: **FIX_AND_EXTEND** — maintainer used my fix as a base and added the next failure mode. When fixing lock staleness: malformed content is one failure class, PID reuse is another. Production-grade lock cleanup needs both.
- **Lesson for lock PRs**: Check all dimensions of "stale" — malformed content, dead PID, PID reuse, age-based expiry. Each is a distinct failure mode.

## 2026-05-03: multica #1995 → superseded by #2017 (Bohan-J)
- **Issue**: `multica login --token mul_xxx` ignored supplied token, prompted interactively (#1994)
- **My approach**: Changed `--token` from Bool to String + `NoOptDefVal = "__prompt__"`. Three modes: `--token=val` → use directly, `--token` alone → prompt, absent → browser OAuth. Used `cmd.Flags().Changed("token")` for detection. Clean approach but only handles `=` form.
- **Their approach**: Same `NoOptDefVal` technique + handled `--token <value>` space-separated form by promoting positional `args[0]` when flag value is the sentinel. Updated CLI_AND_DAEMON.md, CLI_INSTALL.md, and Chinese docs reference.zh.mdx. Added regression test.
- **Why theirs won**: I missed that pflag's `NoOptDefVal` prevents the parser from consuming the next arg as the flag value — so `--token mul_xxx` (space-separated, the exact user expectation from the issue) would set flag to sentinel while `mul_xxx` becomes a positional arg. Their `len(args) == 1` promotion handles this.
- **Pattern**: **CLI_FLAG_SYNTAX_COVERAGE** — when fixing flag parsing, test all accepted syntaxes: `--flag=val`, `--flag val`, `-f val`, `--flag` alone. Cobra/pflag `NoOptDefVal` has a non-obvious interaction: it prevents space-separated value consumption. Always test the space-separated form separately.
- **Doc update lesson**: CLI fix PRs should always update user-facing docs that show the old syntax. I didn't check docs at all.

## openclaw #77247 → superseded by #77421 (2026-05-04)

**Issue**: npm channel plugin contract files not found (secret-contract-api in dist/)

**My approach**: Simple fallback — always search rootDir first, then dist/. Added 3 tests (dist-only, both-exist-prefer-root, existing).

**Maintainer approach (mogglemoss #77421)**: Context-aware search using existing `RUNNING_FROM_BUILT_ARTIFACT` constant. Built artifact → search dist/ first; source → search rootDir first. 1 test.

**Why theirs is better**: Runtime context determines the correct search order. When running from built artifacts, dist/ is the primary location. My naive root→dist fallback would work but the ordering isn't always correct.

**Pattern**: When resolving file paths with multiple possible locations, check if there's an existing runtime context indicator (like build mode flags) to determine search order, rather than hardcoding a fixed priority.

**Lesson**: Before adding a simple fallback, search the codebase for existing context flags that should influence the behavior.

## Applied: GoGetAJob pre-submit checks (2026-05-05)

Integrated 4 core checks into `gogetajob submit` as non-blocking warnings:
1. COMPETING_PR — `gh pr list --search` for same issue
2. MAINTAINER_ACTIVE — scan maintainer comments for "investigating"/"working on"
3. ALREADY_IN_MAIN — `git log upstream/main` for issue refs
4. MERGE_GATE_CLOSED — external merge count in recent merged PRs

These automate what was previously manual pre-PR diligence. See PR kagura-agent/gogetajob#78.
The checks are **shift-left** — catching issues at submit time rather than after rejection.
