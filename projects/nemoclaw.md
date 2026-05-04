# NemoClaw

> NVIDIA sandbox orchestrator for OpenClaw. 18.8k⭐, 79% merge rate.

## Repo Structure (post-TS migration, 2026-04)
- `src/lib/` — core library (gateway-state.ts, onboard.ts, preflight.ts)
- `src/commands/` — CLI commands (slash.ts, migration-state.ts)
- `src/onboard/` — onboard config
- `test/` — vitest tests (root level, not `nemoclaw/test/`)
- `nemoclaw/` — npm package subdirectory (has own package.json, tsconfig)
- `bin/` — old JS CLI (being replaced by TS)
- TS migration (#1673) happened ~Apr 2026, replaced `bin/nemoclaw.js` with compiled `dist/`

## Test & Lint Commands
- `npm test` — run all vitest tests (root level)
- `npx vitest run test/<file>.test.ts` — run specific test
- `npx tsc -p tsconfig.src.json --noEmit` — typecheck src/lib
- `npx tsc -p tsconfig.cli.json --noEmit` — typecheck bin/scripts
- `npx eslint` — lint (config may not cover all paths)
- Pre-existing test failures: preflight tests may detect actual running gateway process

## Maintainers
- **cv**: responsive, asks for rebase, routes to specialists
- **brandonpelfrey**: COLLABORATOR, gives substantive UX/security feedback
- **ericksoa**: UX direction owner (cv routes UX decisions to them)
- **wscurran**: CONTRIBUTOR, auto-triage bot, adds related issue links
- **ColinM-sys**: writes regression tests, checks version pinning

## PR Patterns
- Title: conventional commits (`fix(scope): ...`, `feat(scope): ...`)
- Tests expected: vitest, unit tests in `test/` directory
- CI: `check-pr-limit` + CodeRabbit auto-review
- Maintainers value: security (token minimization), reuse of existing helpers, clean fallback paths
- TS migration means old JS PRs may become stale — check if target file still exists

## Our PRs
- #944 (gateway-token): waiting on ericksoa UX direction, TS migration made JS branch un-rebasable
- #1502 (skip prek hook): merged by cv ✅
- #1703 (enabledChannels → messagingChannels): rebased on main 2026-04-11, aligned with upstream naming
- #1723 (ARM64 health): wscurran approved ✅, waiting merge
- #2833 (stale onboard.lock #2765): **SUPERSEDED by #2890**. My malformed-lock age check replayed + PID reuse detection added. ericksoa credited.

## Build & Test Notes (2026-05-01)
- Root `npm install --include=dev --ignore-scripts` needed to get vitest (devDep)
- `npx tsc -p tsconfig.src.json` compiles src/ → dist/ (test imports from dist/)
- May need `git config --unset-all core.hooksPath` to avoid prek install failures
- `nemoclaw/` subdirectory has its own build (`cd nemoclaw && npm run build`), separate from root tsconfig.src.json
- Root tsconfig.src.json may show oclif import errors — these are pre-existing (oclif migration in progress), don't affect onboard-session compilation
- #1726 (dco-check skip): cv approved ✅, GPG signed 2026-04-11
- #1770 (debug tarball exit code): submitted 2026-04-11, CI pass, CodeRabbit nitpick adopted

## Gotchas
- TS migration (#1673) can supersede JS-based PRs — always check if file still exists in src/
- eslint config doesn't cover src/lib/ directly (warning, not error)
- Test suite has ~5 pre-existing failures in preflight tests when gateway is running locally
- Tests import from `dist/` not `src/` — must rebuild with `npx tsc -p tsconfig.src.json` before running tests
- `npm run check` = lint+format (run from `nemoclaw/` subdir), `npm test` = vitest (run from root)
- When renaming fields: check serialization (createSession), deserialization (normalizeSession), filterSafeUpdates, and the serialize export path

## Our PRs (continued)
- #2265 (check-docs normalization parity): submitted 2026-04-22, fixes asymmetric normalization in E2E CLI parity check. CI pass, CodeRabbit no issues. Pending review.

## PR #1784 — Telegram mention-only mode (2026-04-11)
- **Status**: PENDING, CI pass, awaiting CodeRabbit + maintainer review
- **Scope**: 3 files (Dockerfile, onboard.ts, onboard.test.ts), 165 additions
- **Pattern**: New B64 config arg (NEMOCLAW_TELEGRAM_CONFIG_B64) following Discord guilds pattern
- **Key fix**: Interactive prompt gate was `ch.requireMentionEnvKey && ch.serverIdEnvKey` — Telegram has no serverIdEnvKey, changed to `!ch.serverIdEnvKey || process.env[ch.serverIdEnvKey]`
- **Tests**: 3 new vitest tests (mention-only, open, empty config)
- **GPG**: Commit signed ✅
- **CodeRabbit feedback**: (1) Validate TELEGRAM_REQUIRE_MENTION — addressed in 04f2b988 (reject invalid values with error+exit). (2) Sandbox reuse ignores config changes — acknowledged as pre-existing, outside diff scope.

## PR #1771 — install.sh provider help text (2026-04-11)
- **Status**: PENDING, CI pass
- **Scope**: 1 line in install.sh — list all 9 valid NEMOCLAW_PROVIDER values
- **CodeRabbit**: Use canonical names (build/nim-local) not aliases (cloud/nim) — addressed

## PR #1770 — debug tarball exit code (2026-04-11)
- **Status**: PENDING, CI pass
- **CodeRabbit**: Return boolean from createTarball() — adopted

## PR #1944 — Gemini expired key (2026-04-16)
- **Status**: PENDING, CI pass, CodeRabbit clean
- **Scope**: 3 files (validation.ts, validation.test.ts, validation-recovery.test.ts), 38 additions / 3 deletions
- **Root cause**: classifyValidationFailure() checked HTTP 400 → model before credential message regex. Gemini returns HTTP 400 for expired keys
- **Fix**: reorder checks (credential message regex before HTTP 400), add 'api key expired' pattern
- **Tests**: 2 new validation tests + 1 recovery test, all 45 pass
- **Lesson**: HTTP status codes are ambiguous across providers — message-based classification should precede status-based for credential errors

## PR #2245 — TLS certificate error classification (2026-04-22)
- **Status**: PENDING, CI pass, CodeRabbit clean (no actionable comments)
- **Scope**: 3 files (validation.ts, validation-recovery.ts, onboard.test.ts), 23 additions / 2 deletions
- **Root cause**: classifyValidationFailure() had no pattern for TLS/certificate errors → fell through to 'unknown' → user got generic prompt instead of TLS-specific recovery message
- **Fix**: Add /ssl|tls|certificate|handshake/ regex → classify as transport; improve recovery message to mention proxy interference for HTTP endpoints
- **Tests**: 3 new test cases, all pass
- **Lesson**: Error classification gaps mean existing good recovery messages never fire — always check if the classifier routes to the recovery path

## PR #2338 — Brew preset TLS skip (2026-04-23)
- **Status**: PENDING, CI pass, CodeRabbit clean
- **Issue**: #2331 — git TLS verification fails in sandbox with brew preset
- **Scope**: 1 file (brew.yaml), 6 lines added
- **Root cause**: OpenShell v0.0.15+ auto-terminates TLS; brew preset had no `tls` field → proxy MITMs git → git can't validate proxy cert (`CAfile: none`)
- **Fix**: Add `tls: skip` to all 6 brew endpoints for L4 pass-through (same pattern as #2098 for Discord/Slack WSS)
- **Lesson**: Presets with `access: full` and no L7 rules should use `tls: skip` — TLS termination only needed when L7 inspection rules exist

## PR #2080 — Connect hint instructions (2026-04-20)
- **Status**: PENDING, CI pass, CodeRabbit feedback adopted
- **Scope**: 2 files (nemoclaw.ts, install.sh)
- **Fix**: Show agent-specific TUI command (`hermes` for hermes, `openclaw tui` for openclaw, agent name for others) and corrected exit hint (`/exit` then `exit`)
- **CodeRabbit feedback**: Generalize for non-hermes/openclaw agents — adopted with `case` in shell and ternary in TS
- **Lesson**: Simple UX text fixes are good entry points; CodeRabbit suggestions for generalization are often worth adopting

## Maintainer Insights (2026-04-11)
- cv: strict on commit signing (GPG required), responsive, will close stale PRs (closed #944)
- wscurran: thorough approver, positive feedback
- Feature parity PRs ("X has it, add to Y") are ideal for NemoClaw — clear spec, existing patterns

## PR #1723 — ARM64 gateway health (2026-04-16 update)
- **Status**: PENDING, CI was failing → fixed
- **CI issues found & fixed**:
  1. commit-lint: title "fix: ARM64..." flagged as sentence-case → changed to "fix: arm64..."
  2. dco-check: PR body Signed-off-by was present but still failed (may be position-sensitive)
  3. Test expectation bug: `getGatewayReuseState` test expected "active-unnamed" for a case where status reports Connected + Gateway: nemoclaw → should be "healthy" (primary path in isGatewayHealthy). Fixed in c752c401.
  4. Important: tests import from compiled `bin/lib/onboard` not src — must `npm run build:cli` before running tests locally
- **Lesson**: NemoClaw commit-lint enforces lowercase after `fix:` prefix — "ARM64" treated as sentence-case. Use "arm64".
- **Lesson**: Always rebuild before testing in NemoClaw — vitest runs against compiled dist, not src.

## PR #2256 — E2E test-token-rotation hard exit fix (2026-04-22)
- **Status**: PENDING, CI pass, CodeRabbit feedback addressed
- **Issue**: #2247 — test-token-rotation.sh exits hard on environmental failures
- **Scope**: 1 file (test/e2e/test-token-rotation.sh), ~110 insertions / 74 deletions
- **Fix**: Replace `exit 1` after install/onboard failures with skip-and-continue pattern
  - Added SKIP counter and skip() helper
  - PHASE0_OK and PHASE2_OK flags gate dependent phases
  - is_environmental_failure() detects network/preflight issues → SKIP instead of FAIL
  - Summary always prints
- **CodeRabbit**: 2 suggestions adopted (environmental→SKIP, Phase 3 gate on Phase 2)
- **GPG**: Commit signed ✅

## PR #2256 Superseded (2026-04-24)
- Issue #2247: e2e test-token-rotation.sh hard exits
- My approach: skip-and-continue with PHASE0_OK/PHASE2_OK gate flags
- Winning approach (#2257 by hunglp6d): same resilience fix + Discord rotation coverage expansion
- Takeaway: bundle test coverage expansion with infra fixes for higher value-per-PR

## PR #2510 — Brave validation skip in non-interactive mode (2026-04-27)
- **Issue**: #2507 — Brave Search API key validation failure aborts non-interactive onboard
- **Status**: PENDING, check-pr-limit pass, CodeRabbit review pending
- **Scope**: 1 src file (onboard.ts, 3 lines changed) + 1 new test file (brave-validation-skip.test.ts)
- **Root cause**: `configureWebSearch()` calls `process.exit(1)` on Brave validation failure in non-interactive mode
- **Fix**: Replace `process.exit(1)` with `console.warn` + `return null` — skip web search, continue onboard
- **Tests**: 2 new vitest tests (validation failure returns null, missing key returns null), all pass
- **Pattern**: Simple fix — downgrade optional integration failure from fatal to warning. Same return-null pattern already used for missing BRAVE_API_KEY.
- **Lesson**: `process.exit(1)` in library code for optional features is a smell — should always be a graceful fallback

## PR #2468 — Dashboard URL token redaction (2026-04-25) — SUPERSEDED by #2900
- **Issue**: #2467 — fix(security): route dashboard URL output through redact() (CWE-532)
- **Status**: CLOSED (superseded by #2900)
- **My approach**: Wired existing redact() into console.log() sites. 3 files, 34 additions.
- **Their approach** (#2900 by ericksoa): Completely removed token from displayed URLs + `gateway-token --quiet` retrieval + docs + shell scripts + tests. 7 files, 71 additions.
- **Maintainer feedback**: "This was the right security direction and gave us the concrete starting point."
- **Lesson**: REDACT_VS_REMOVE — for credentials, complete removal > masking. Provide separate retrieval path.
