# Mechanical Preflight Check (Applied Pattern)

Source: [[apm-triage-panel-patterns]] batch allow-list pattern + [[verify-before-researching]]

## What

Created `flowforge/scripts/preflight-repo.sh` — a mechanical pre-flight validation script for the workloop `pr_gate` node.

**The pattern:** Compute scope constraints BEFORE reading untrusted content. The APM triage-panel computes `BATCH_ALLOW_LIST` before reading any issue body. We now compute pass/fail on repo eligibility before the agent reads issue bodies and potentially gets influenced.

## Checks (all metadata-only, no body reads)

1. Open PR count ≤ 3 per repo
2. Repo pushed within 14 days
3. No competing PRs for the target issue
4. Repo size ≤ 500MB (prevents large-clone waste, see [[contribution-depth-bottleneck]])
5. Wiki blocklist markers (repos known to not merge external PRs)

## Why This Matters

Before: 5 separate prose instructions in `pr_gate` that the agent executed manually. Each could be skipped, forgotten, or rationalized away.

After: One script, one exit code, one evidence requirement ("paste script output"). The script is faster than manual checks and can't be partially skipped.

## Design Decisions

- **Explicit blocklist markers** (`[BLOCKLIST]`, `⛔不提PR`, `DO NOT CONTRIBUTE`) instead of broad pattern matching on Chinese text — avoids false positives from positive statements like "活跃 merge 外部 PR"
- **Exit code 1 = FAIL** — workloop.yaml requires paste of output and checks exit code semantically
- **Warn ≠ Fail** — approaching-limit situations (2 open PRs, large but sub-500MB repo) produce warnings but still pass

## Related

- [[apm-triage-panel-patterns]] — source pattern
- [[verify-before-researching]] — same philosophy (check before acting)
- `flowforge/scripts/verify-claims.sh` — sibling script for post-implementation verification

---
*Created 2026-05-08 from apply session (study #1611)*
