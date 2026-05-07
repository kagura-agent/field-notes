# deepsec (vercel-labs/deepsec)

Agent-powered security scanner for codebases. Vercel Labs, Apache 2.0, TypeScript.

## Stats
- ⭐ 1,453 (05-07), was 1,222 on 05-06 (+231/day, explosive growth)
- Created: 2026-04-30 (7 days old)
- Commits: very active (multiple PRs/day)

## Architecture (05-07 deep read)

**5-stage pipeline**, each a CLI subcommand, each idempotent:
```
scan → process → revalidate → enrich → export
(regex)  (AI)     (TP/FP)    (+committers) (md/json)
```

- **On-disk data model**: `data/<projectId>/files/<path>.json` — one FileRecord per source file. Additive merge (never overwrites). Git-friendly.
- **INFO.md**: repo-specific context injected into every AI prompt. Written by agent (not human).
- **Two agent backends**: Codex (`gpt-5.5` default) and Claude (`claude-opus-4-7`). Same prompt + JSON schema, interchangeable. Can mix within a project.
- **Concurrency**: batched parallel processing, distributed to Vercel Sandbox microVMs for large repos.

## PR Review Mode (PR #57, merged 05-06)

`deepsec process --diff origin/main` — scoped scan of changed files only.

Key design decisions:
- 5 mutual-exclusive file sources: `--diff <ref>`, `--diff-staged`, `--diff-working`, `--files`, `--files-from`
- Regex scan still runs on changed files (prompt anchors), but agent reviews ALL changed files regardless of matcher hits
- PR comment rendering filters to **net-new findings only** (by `producedByRunId`). Pre-existing findings on touched files excluded
- Severity badges: CRITICAL/HIGH/MEDIUM/HIGH_BUG/BUG/LOW with color emojis
- Exit code 0 = clean, 1 = findings → natural CI gate

## Self-Dogfooding (PR #62, merged 05-07)

33K additions, 295 files — checked deepsec data into its own repo. Now runs on itself. Turned on sandbox for local agent execution.

## Key Insights

1. **Cost model is honest**: "scans can cost thousands or tens-of-thousands of dollars for large codebases" — not hiding behind freemium. Enterprise-grade positioning.
2. **Existing subscription piggybacking**: locally uses your Claude/Codex subscriptions. Smart for adoption friction.
3. **Additive merge model**: no destructive operations on data. Every re-run adds information. Good for iterative/incremental scanning.
4. **PR mode as CI gate**: exit code 1 on findings = natural GitHub Actions integration. This is the feature that will drive adoption.
5. **Regex as prompt anchoring**: candidates from regex matchers are "hints" for the AI, not the full analysis. Smart hybrid approach — cheap regex narrows attention, expensive AI does judgment.

## Relevance to Us

- **Agent security is a real market**: 1.4K⭐ in 7 days from Vercel Labs. The "coding agents introduce security risks" thesis has demand.
- **Pipeline pattern**: scan → process → revalidate is a good template for any multi-stage agent workflow with human-in-the-loop (similar to FlowForge).
- **PR mode architecture**: diff-scoped agent review with net-new-only filtering is worth borrowing for our own PR review workflows.

## Links
- Repo: https://github.com/vercel-labs/deepsec
- Docs: docs/ directory in repo
