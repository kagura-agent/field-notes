# deepsec (vercel-labs/deepsec)

Agent-powered security scanner for codebases. Vercel Labs, Apache 2.0, TypeScript.

## Stats
- ⭐ 1,512 (05-07), was 1,453 on 05-06, 1,222 on 05-05. Growth slowing (+41/day → +18/day, was +231/day at launch)
- Created: 2026-04-30 (8 days old)
- Commits: very active (multiple PRs/day), now monorepo (self-dogfooding)

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

## PR Review Mode — Implementation Details (05-07 followup)

Read the full implementation after PR #57 merge. Key takeaways:

### File Source Resolution (`file-sources.ts`)
- 5 mutually exclusive sources: `--diff <ref>`, `--diff-staged`, `--diff-working`, `--files <csv>`, `--files-from <path>`
- Uses `git diff --name-only --diff-filter=AMRC` — only Added/Modified/Renamed/Copied (no Deleted)
- `--diff-working` combines tracked changes + `git ls-files --others --exclude-standard` (untracked but not gitignored)
- Path normalization: dedupes, rejects escaping paths (`../`), filters through scanner's `IGNORE_DIRS` globs (test files, dist/, node_modules/) to avoid burning AI budget
- All files resolved relative to rootPath — no absolute path leaks

### Direct Mode Lifecycle (`process.ts:processDirectMode`)
```
1. Resolve file list (git diff or explicit)
2. Auto-create project on disk (ensureProject) if not in config
3. scanFiles() — regex matchers on changed files → FileRecords with candidates as "signals"
4. process() — AI agent investigates ALL listed files, using regex candidates as prompt anchors
5. renderPrComment() → markdown output (--comment-out)
6. Exit code: 0 = clean, 1 = findings OR agent batch errors
```

### PR Comment Rendering (`pr-comment.ts`)
- **Net-new only**: filters by `Finding.producedByRunId === runId`. Old findings on touched files excluded — prevents CI noise
- Resolved findings (fixed/false-positive/accepted-risk) also excluded even if from same run
- Severity ordering: CRITICAL → HIGH → MEDIUM → HIGH_BUG → BUG → LOW with color emoji badges
- Returns `null` when no findings → caller skips commenting entirely
- Truncates long descriptions (600 chars) and recommendations (400 chars)

### Error Handling
- Agent batch errors → hard exit(1). "A silent agent crash masquerading as green CI" is explicitly prevented
- Conflicting sources → throws immediately, no silent fallback
- No files after filtering → exit 0 with clear message (not a failure)

### Design Patterns Worth Borrowing
1. **Regex as prompt anchoring**: cheap regex pre-scan narrows LLM attention, but LLM still reviews all files. Hybrid approach balances cost and coverage
2. **`producedByRunId` attribution**: every finding is stamped with which run created it. Enables precise net-new filtering for incremental CI
3. **Exit code as CI gate**: binary clean/dirty signal. Simple, composable with GitHub Actions
4. **Auto-project creation**: no `init` step needed for direct mode. Reduces friction for one-off CI usage

### Update (05-07)
- Stars: 1,453 → 1,471 (growth slowing from explosive +231/day to ~+18/2days)
- PR #59: switched default model from Codex to GPT-5.5 ("better for discovering existing codebases")
- PR #62: self-dogfooding — 33K LOC checked into own repo, sandbox enabled for local agents
- Claude agent now available as `--agent claude` alias

## Composable Prompt Assembly (PR #53, merged 05-06)

Major architectural upgrade: prompts now adapt per-batch to the repo's tech stack.

### Tech Detection Pipeline
```
detectTech(rootPath) → walk lockfiles/manifests/sentinels → normalized tag list
  → persisted to data/<id>/tech.json
  → gates which matchers run (MatcherGate: { tech: ["laravel"] })
```

### Prompt Composition
```
assemblePrompt({ detectedTags, batchSlugs, batchLanguages, projectInfo, promptAppend })
  → [core] + [tech highlights] + [slug notes] + [INFO.md] + [promptAppend]
```

Key design decisions:
- **Language-scoped highlights**: Python batch in polyglot repo gets Django highlights but NOT Next.js. Filters by `batchLanguages` intersection with each highlight's declared `languages`
- **Hard char budget** (6000 chars): when too many frameworks → polyglot fallback (one-line summary instead of full highlights). "Better to say less than crowd the prompt"
- **Per-slug reviewer notes**: only included for slugs flagged in current batch. Prompt scales with what scanner actually found
- **64 frameworks across 13 ecosystems**: from Next.js to Salesforce Apex. Each gets: matcher (gated), threat highlight, slug note
- **Deterministic prompt samples**: 11 committed fixtures verified by vitest against assembler output (`UPDATE_PROMPT_SAMPLES=1 pnpm test:unit`)

### Regex Hardening
- Audited all matchers for catastrophic backtracking
- Worst case: XSS matcher went from 662ms → 0.1ms on adversarial input (6600× faster)

### Match-Rate Warning
- Scanner reports per-language stats (files/hits/rate)
- Yellow warning when ≥50 source files but <1% match rate → suggests custom matchers

### Pattern Worth Borrowing: [[composable-prompt-assembly]]
The idea of composing prompts from detected context (tech stack, batch content, project-specific notes) with hard token budgets and graceful fallbacks is applicable to any agent that processes heterogeneous codebases. Similar to how [[FlowForge]] could compose task prompts from project context.

## Other Updates (05-07 followup)

- **PR #58**: Concurrent processing merge — properly merges runs data when multiple agent instances process batches in parallel
- **PR #59**: Default model switched from Claude to Codex GPT-5.5 (Melkeydev)
- **PR #62**: Self-dogfooding — checked deepsec's own scan data into repo (33K additions, 295 files). Runs on itself.
- **PR #56**: Vercel OIDC token conditional — if OIDC present in env, use it (serverless deployment signal)

## Updates (05-09 followup)

- **Stars**: 1,899 (05-09 PM). Growth settling: ~+12/day now. Typical post-hype stabilization.
- **PR #68**: provenance turned on (public repo milestone)
- **PR #67**: sandbox download path bug — good paths were being rejected. Safety vs usability tension.
- **PR #66**: quota handling — gracefully handles out-of-quota situations (LLM cost management)
- **PR #65**: typecheck fix for `.deepsec` directory config
- **PR #69 (open)**: agent skills folder — `npx` skills ecosystem integration (@BankkRoll). Community feature.
- **PR #70 (open)**: Ollama support (@soultellegend). Local LLM story.
- 23 open issues (up from ~12). Community engagement growing.

## Growth Trajectory Assessment

Growth slowing: +231/day (launch) → +41/day (05-06) → +18/day (05-07) → +12/day (05-09). Typical hype curve. BUT sustained development velocity (cramforce shipping daily) means the product is maturing fast. The GPT-5.5 default switch suggests Vercel alignment (Codex partnership?). Worth continuing to track — the composable prompt pattern is genuinely novel. Community PRs (Ollama, skills folder) signal the project is attracting contributors, not just stars.

## Relevance to Us

- **Agent security is a real market**: 1.5K⭐ in 8 days from Vercel Labs. The "coding agents introduce security risks" thesis has demand.
- **Pipeline pattern**: scan → process → revalidate is a good template for any multi-stage agent workflow with human-in-the-loop (similar to FlowForge).
- **PR mode architecture**: diff-scoped agent review with net-new-only filtering is worth borrowing for our own PR review workflows.
- **`producedByRunId` pattern**: applicable to any incremental agent analysis — attribute outputs to runs, filter downstream by recency. Could apply to [[wiki-lint]] or FlowForge quality checks.
- **Composable prompt assembly**: the tech-detection → per-batch prompt composition pattern is broadly applicable. Any agent processing diverse inputs benefits from context-aware prompt assembly with budget caps.

## Links
- Repo: https://github.com/vercel-labs/deepsec
- Docs: docs/ directory in repo
