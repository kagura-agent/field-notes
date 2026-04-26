# Self-Audit: Defender/Tolerator Patterns (2026-04)

Applied [[cynical-deletion]] framework to our own codebase. Audited: nudge plugin, FlowForge engine, GoGetAJob CLI.

## Tolerators Found

### 1. GoGetAJob audit: empty catch blocks
**File:** `gogetajob/src/cli/commands/audit.ts:33,57`
```ts
catch { fileList = ""; }  // git ls-files fails → empty string, no warning
catch {}                   // git rev-list fails → recentCommits stays 0
```
**Impact:** Health report shows 0 commits / 0 files on git failure — user sees "clean" data that's actually missing. Classic silent data loss.
**Fix:** Log warning + mark field as "unknown" instead of 0.

### 2. GoGetAJob submit: 3-level try/catch cascade
**File:** `gogetajob/src/cli/commands/submit.ts:65-81`
Three nested try/catch blocks to check if there are commits ahead of upstream. Each catches the previous one's failure. Defense spiral risk — if upstream isn't set, falls through to a heuristic ("existing commits exist? proceed").
**Impact:** Could submit PRs from wrong state. Low probability but high consequence.
**Fix:** Single check: `git log --oneline HEAD ^$(git merge-base HEAD origin/main)` or fail explicitly.

### 3. Nudge loadState: silent reset on corruption
**File:** `openclaw-plugin-nudge/index.ts:22-26`
```ts
catch { /* Corrupted state file — reset */ }
```
**Impact:** Mild. Counter resets to 0, nudge fires slightly early. Acceptable tradeoff for a non-critical feature.
**Verdict:** Keep — this is pragmatic, not reckless.

## Defenders Found

### 4. FlowForge start() auto-close stale instance
**File:** `flowforge/src/engine.ts:start()`
When starting a workflow that already has an active instance, silently closes the old one and starts fresh.
**Impact:** If two cron jobs accidentally trigger the same workflow, the first one's in-progress state vanishes without trace. No error, no warning.
**Fix:** Log a warning with the closed instance ID. Consider adding a `--force` flag instead of always auto-closing.

### 5. GoGetAJob submit: pre-commit hook detector
**File:** `gogetajob/src/cli/commands/submit.ts:44-62`
Complex string matching on stderr to detect if commit failure was caused by pre-commit hooks (checks for "pre-commit", "hook", "husky", "lint", "eslint", "prettier").
**Impact:** Actually well-contained — gives actionable error messages. Not a spiral (yet). But the string list will rot as new tools appear.
**Fix:** Check exit code + presence of `.husky/` or `.pre-commit-config.yaml` instead of parsing stderr.

## Summary

| Pattern | Type | Severity | Action |
|---------|------|----------|--------|
| audit empty catches | Tolerator | Medium | Fix: log + mark unknown |
| submit try/catch cascade | Tolerator→Defender | Medium | Fix: simplify to single check |
| nudge state reset | Tolerator | Low | Keep |
| flowforge auto-close | Defender | Medium | Fix: add warning log |
| submit hook detector | Defender | Low | Monitor, fix if it rots |

## Insight

Our codebase is surprisingly clean — no deep defense spirals. The pattern is consistent: we tend toward **tolerators** (swallowing errors) rather than **defenders** (adding complex recovery). This matches our "ship fast" mode but means bugs hide longer.

The GoGetAJob audit command is the worst offender: empty `catch {}` is the exact [[cynical-deletion]] anti-pattern. The fix is trivial.

## Links

- [[cynical-deletion]] — the framework applied here
- [[claude-mem]] — where we learned this pattern (PR #2141)

---
*Created: 2026-04-26*
