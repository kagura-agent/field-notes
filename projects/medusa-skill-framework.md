---
title: Medusa Skill Framework
url: https://github.com/jtshow/Medusa
stars: 25
first_seen: 2026-05-11
status: noted
tags: [skill-quality, audit, rust, dreaming]
last_verified: 2026-05-11
---

# Medusa Skill Framework (MSF)

Rust CLI that scans a directory of markdown skill files and produces quality audits with a 9-tier ranking system. 3,322 lines, solo author (jtshow), created 2026-05-03.

## Architecture

**Core pipeline**: Walk directory → extract YAML frontmatter → regex-analyze content → score → rank → dream.

**Scoring** (weighted 60/30/10):
- **Complexity** (60%): content length, code blocks (biggest lever), step count, tech terms. All regex-counted. Max 100.
- **Value** (30%): base 50 + bonuses for length/code/steps/terms. Max 100.
- **Keywords** (10%): regex match against fixed list ("algorithm", "implementation", etc.)

**9 tiers**: Poor → Common → Uncommon → Rare → Ultra Rare → Epic → Mythic → Legendary → Unique → Godlike. Thresholds configurable via `medusa.toml`.

## Key Concepts

### Dreaming (cross-session pattern detection)
`.medusa_history.json` records skill snapshots per scan. `run_dream()` compares consecutive sessions to detect:
- Recurring gaps (same gap appears in ≥2 sessions)
- Improvements / declines (experience score changes)
- New skills / resolved gaps

Insights accumulate in `.medusa_dream.json`, consolidated via: merge duplicates → prune low-severity → cap at 200 (configurable).

**My take**: The "dreaming" metaphor is compelling but implementation is mechanical — it's diffing JSON snapshots, not doing inference. Maps directly to our [[beliefs-candidates]] pipeline concept: both accumulate observations over time → consolidate → promote. The key difference: ours uses LLM judgment for promotion (Triple Verification), Medusa uses threshold arithmetic.

### Multi-Agent Audit
4 sub-auditors (DocQuality 25%, CodeQuality 30%, DependencyHealth 20%, LearningValue 25%) each score 0-100. Not actual agents — just scoring functions with the agent metaphor. Weighted average synthesizes overall score.

### Procedural Memory
Auto-extracts step sequences from skill content (3+ consecutive numbered/bullet items), stores as reusable workflows in `.medusa_procedural.json`. Categorizes steps as Setup/Execution/Verification/Implementation/Learning/Documentation.

### Fusion Detection
FxHash-based similarity matching to find near-duplicate skills. Practical for large skill collections.

### Cross-Agent Memory
Export/import bundles (dream + procedural + outcomes) for sharing between Medusa instances. Source tracking on merge.

## Strengths
- Clear metaphors that map to real agent concerns (dreaming, procedural memory)
- Configurable via TOML
- Rust = fast scanning
- The fusion detection is genuinely useful for large skill collections

## Weaknesses
- **No tests** — zero test files in repo
- **Solo project** — 19 commits, 1 contributor, no issues, no community health
- **Surface-level analysis** — counting code blocks ≠ understanding quality. Regex for "algorithm" doesn't mean the skill teaches algorithms well
- **"Multi-agent" is cosmetic** — 4 scoring functions, not actual agents or LLM calls
- **No LLM integration** — purely static analysis, misses semantic quality

## Relation to Our Direction

| Medusa | Ours | Verdict |
|--------|------|---------|
| Dreaming (JSON diff) | [[beliefs-candidates]] (LLM-gated) | Ours is richer — LLM judgment vs arithmetic |
| Procedural memory (extract steps) | FlowForge (explicit YAML) | Different approaches — theirs is auto-detected, ours is authored |
| Multi-agent audit | Could apply to [[skill-trigger-eval]] | Pattern worth borrowing for skill quality CI |
| Fusion detection | No equivalent | Could add to [[clawhub]] for dedup |
| 9-tier ranking | No equivalent | Gamification layer, not necessary for us |

## Actionable Insight
The **4-sub-auditor pattern** (doc quality + code quality + dependency health + learning value) is a clean decomposition for skill quality assessment. If we ever build automated skill quality checks for [[clawhub]], this decomposition is a good starting template — but should use LLM scoring instead of regex counting.

## Tracking Decision
**Not tracking** — too small (25⭐), solo, no community health signals. The architectural patterns are noted above for reference. Revisit only if it crosses 100⭐ or gets external contributors.
