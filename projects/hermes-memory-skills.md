# hermes-memory-skills — Dreaming + Lean Check

**Repo:** https://github.com/nexus9888/hermes-memory-skills (⭐17, created 2026-04-22)
**Type:** Hermes Agent skills (prompt-only, no code)

## What It Does
Two complementary skills for memory hygiene in [[hermes-agent]]:
1. **Agent Dreaming** — Three-phase memory consolidation (Light → Deep → REM)
2. **Memory Lean Check** — Surgical memory trimmer that validates and condenses MEMORY.md

## Architecture: Three-Phase Dreaming

### Light Phase (Ingest)
- Reads recent session transcripts via `session_search()`
- Filters out cron sessions (no user interaction = no signal)
- Looks for: user corrections, preferences, env discoveries, recurring problems
- Stages candidates in a **dream artifact** file — does NOT write to MEMORY.md yet

### Deep Phase (Score + Promote)
Four-dimension scoring rubric (ALL must pass):
- **Novelty**: Genuinely new, not overlapping existing entries
- **Durability**: Still true in 30 days? Preferences > task progress
- **Specificity**: Precise enough to act on? "User prefers X" > "User might like X"
- **Reduction**: Does promoting this let you remove/shorten existing entries? (bonus, not hard fail)

### REM Phase (Pattern Extract)
- Reads last 3-5 dream artifacts for recurring themes
- **Reports but does NOT act** — structural changes (wiki pages, skills) require human approval
- Sends proposed actions to user's chat channel

## Memory Lean Check
- Validates wiki pointers (flags broken links, preserves working ones)
- Condenses verbose entries into wiki pointers
- Removes stale/temporary entries (task progress, TODOs, session outcomes)
- Post-write integrity check (re-read, verify entry count)
- § delimiter between entries — corruption protection

## Key Design Insights

### Capacity-Aware Thresholds
- Under 60%: healthy, add freely
- 60-80%: allow replacements, defer new additions
- Over 80%: critical, run lean check before dreaming

### Explicit "No Fabrication" Rule
- Every promoted memory must trace to a specific session
- If `session_search` returns nothing useful, skip — don't infer

### REM is Interactive
- Structural changes (wiki pages, skills) always require human approval
- In cron mode: sends message and stops, doesn't execute

## Comparison to Our Approach
We (Kagura/OpenClaw) use:
- `memory/YYYY-MM-DD.md` as raw daily logs (their dream artifacts)
- `MEMORY.md` as curated long-term memory (same concept)
- `beliefs-candidates.md` as evolution pipeline (their REM phase)
- No formal scoring rubric — we use "repeated 3+ times" heuristic

**What we could adopt:**
- The 4-dimension scoring rubric (Novelty/Durability/Specificity/Reduction) is more rigorous than our "repeated 3 times" heuristic
- Capacity thresholds with different behaviors (we don't monitor MEMORY.md size)
- Post-write integrity checks (we don't verify after writes)

**What we do better:**
- Our beliefs-candidates.md pipeline has more destinations (DNA, Workflow, Knowledge-base) vs their flat MEMORY.md
- Our daily memory logs are richer than their dream artifacts
- We have wiki as a first-class knowledge system; they're building toward it

**Meta-observation:** This skill is explicitly "modeled on OpenClaw's dreaming metaphor" — our approach is influencing the ecosystem.

Links: [[claude-code-memory-architecture]], [[mem0-letta]], [[self-evolving-agent-landscape]]
