# Claude Code Quality Postmortem — April 23, 2026

> Source: https://www.anthropic.com/engineering/april-23-postmortem
> Anthropic's official root cause analysis for perceived Claude Code degradation (March–April 2026)

## Three Overlapping Issues

### 1. Reasoning Effort Downgrade (Mar 4 → reverted Apr 7)
- Default effort changed `high` → `medium` to reduce latency (Opus 4.6 UI appeared frozen at high)
- Wrong tradeoff — users prefer intelligence over speed
- **New defaults**: `xhigh` for Opus 4.7, `high` for all others
- Shows effort parameter is a blunt instrument: the right default depends on task complexity, not average latency

### 2. Thinking Cache Bug (Mar 26 → fixed Apr 10) ⚠️ Most Interesting
- Goal: reduce cost of resuming stale sessions (>1hr idle) by clearing old thinking blocks
- Used `clear_thinking_20251015` API header with `keep:1`
- **Bug**: flag kept firing every turn for the rest of the session instead of once
- Effect: progressive reasoning amnesia — Claude lost its chain of thought turn by turn
- Also caused cache misses → faster usage limit drain (users noticed both quality AND cost issues)
- **Slipped past**: human code review, automated code review, unit tests, e2e tests, dogfooding
- Opus 4.7 Code Review caught it retroactively; Opus 4.6 didn't → [[over-editing]] relevance (newer model as QA)
- Two unrelated experiments (message queuing + thinking display change) masked the bug in internal testing

### 3. Verbosity Prompt Regression (Apr 16 → reverted Apr 20)
- System prompt: "keep text between tool calls to ≤25 words, final responses ≤100 words"
- Passed weeks of internal testing + specific evals
- Broader ablation testing revealed 3% intelligence drop on Opus 4.6 and 4.7
- Shipped alongside Opus 4.7 launch — confounded with model change

## Why Detection Was Hard

The three issues affected **different slices of traffic on different schedules**, creating an illusion of "broad, inconsistent degradation" that looked like normal variation. Anthropic couldn't distinguish signal from noise until enough user reports accumulated.

This is a textbook case of [[compound-failure-mode]]: multiple small changes, each defensible in isolation, creating an emergent problem that no single test catches.

## Architectural Lessons

### Thinking Blocks Are State, Not Cache
Clearing reasoning is not a performance optimization — it's a **state mutation**. The thinking history IS the agent's working memory. Any context management that touches reasoning must be treated as high-risk.

Parallel to [[hermes-agent]]'s `FileStateRegistry` approach: state coordination requires explicit contracts, not implicit cleanup.

### Evals Are Necessary but Insufficient
- Unit tests, e2e tests, automated verification, dogfooding — all passed
- The cache bug lived at the **intersection** of context management, API, and extended thinking
- Only user feedback in production caught it
- Lesson: [[agent-safety]] — defensive monitoring of reasoning coherence should be a first-class concern

### Prompt Engineering Has Intelligence Cost
- "Obvious" improvements (reduce verbosity) can degrade quality
- Ablation testing (remove one line at a time, measure impact) is the only reliable method
- System prompt changes need the same rigor as code changes — [[execution-contract-pattern]]

### Compound Bugs Need Compound Detection
- Three overlapping issues created an effect none would produce alone
- Traditional A/B testing (change one variable) can't catch multi-variable emergent failures
- Users are the ultimate eval — `/feedback` command was the signal that drove fixes

## Relevance to OpenClaw

- We use Claude Code via `--print --permission-mode bypassPermissions` — effort level changes affected our subagent quality directly
- The thinking cache bug likely impacted any long-running or resumed Claude Code session, including our coding subagents
- **Our own context management** (OpenClaw session history, thinking truncation) should learn from this: never silently drop reasoning state
- The verbosity prompt lesson applies to our own AGENTS.md/SOUL.md: conciseness instructions can hurt reasoning quality

## Remediation Announced

1. Internal staff will use exact public builds (not feature-test builds)
2. Broader per-model eval suite for every system prompt change
3. Ablation testing for all prompt changes
4. Soak periods + gradual rollouts for intelligence-tradeoff changes
5. `@ClaudeDevs` on X + GitHub threads for transparency
6. Usage limits reset for all subscribers

---

*Filed: 2026-04-24 | Tags: #postmortem #claude-code #context-management #agent-quality*
