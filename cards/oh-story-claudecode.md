---
title: oh-story-claudecode
tags: [agent-skill, claude-code, viral, deslop, skill-ci]
created: 2026-05-06
updated: 2026-05-09
---

# oh-story-claudecode

A viral Claude Code skill package by worldwonderer for Chinese web novel writing. First skill package to achieve widespread adoption (900+ ⭐ by 05-09, growing 8%+ between checks).

Demonstrates that **packaged agent skills** are a viable distribution format — users install a single skill and get structured storytelling/narrative capabilities inside Claude Code.

Relevant to [[skill-distribution-convergence]] as a data point for skill adoption patterns.

## Architecture (v0.4.1, 05-09)

12 skills in a mono-repo: story-setup, story-short-scan/analyze/write, story-long-scan/analyze/write, story-review, story-deslop, story-cover, story, browser-cdp.

### Cross-skill desymlinking

v0.4.0→v0.4.1 replaced all 16 symlinks with **real file copies** + CI consistency checks (`check-shared-files.sh`). Reason: symlinks break portability — when users install a single skill, symlinks point nowhere. Solution: copy shared files (e.g. `banned-words.md`) into each skill's `references/` dir, then CI checks content drift across copies.

This is the same lesson [[skill-distribution-convergence]] predicts: **skills must be self-contained**. Symlinks are a monorepo convenience that breaks at distribution time.

### Skill CI pipeline

`static-check.sh` runs 5 checks per skill:
1. Frontmatter (name + description required)
2. Referenced paths exist (markdown links + inline paths)
3. Dead files in `references/` (not referenced by SKILL.md)
4. Cross-references within `references/` files (new in v0.4.1 — added after a `banned-words.md` link was broken)
5. Agent references valid (subagent_type declarations map to template files)

`check-shared-files.sh` detects content drift: finds same-name files across skills, diffs them, flags mismatches. Has an `IGNORE_NAMES` list for intentional differences.

**Takeaway for us**: Our [[kagura-story]] skills don't have CI — if we ever distribute them, we should steal this pattern.

### 3-agent parallel verification

v0.4.1 release notes mention "48 项交叉核验全部通过（3 agent 并行验证）". They're using multi-agent review as QA — the same pattern as [[supervisor-pattern]] but applied to content/skill quality, not code correctness.

## Deslop: Quantified AI-text detection

The `story-deslop` skill is the most novel part. It defines a concrete, measurable approach to removing "AI flavor" from generated text.

### Quantified metric
- **Banned-word density**: hits per 1000 characters
- 3 tiers: ≤5 (light) / 6-15 (moderate) / >15 (heavy)
- "hits" = exact match against a curated banned-words list, not substring
- When quantitative score conflicts with qualitative judgment, qualitative wins (smart escape hatch)

### Banned-word taxonomy
- **Level 1 (always replace)**: 情态词 (仿佛/宛若), 动作词 (深吸一口气/缓缓), 表情词 (眼中闪过/嘴角勾起), 心理词 (心中一动), 判断词 (不容置疑)
- **Level 2 (replace when frequent)**: 总结句式 ("他终于明白"), 排比句式 (3+ parallel structures), 升华句式 ("这一刻")
- **Sentence-level patterns**: "...，带着..." (万能状语), "像XX一样" (cliché similes), "他/她感到..." (tell-not-show)

### Core philosophy (counter-intuitive)
> "AI写的不是不好，是太好了——好到假。人写东西有毛边、有口语、有跳跃，AI写的太圆滑、太工整、太正确。"

The insight: **deslop is not error correction, it's style correction.** The problem isn't bad writing — it's *too-perfect* writing. Human writing has rough edges, colloquialisms, jumps. AI writing is too smooth, too balanced, too thorough.

### Replacement strategy
The skill includes a human-writing baseline table (paragraph length, dialogue tags, emotion expression, metaphor style, filler words, omission, parallelism, endings) and concrete replacement patterns. Key principle: **show, don't tell** — replace abstract emotions with physical actions ("紧张" → "手在抖").

### Relevance to us
If we ever want to make [[kagura-story]] output less AI-sounding, this quantified approach is far superior to vague "write more naturally" instructions. The banned-words list is Chinese-specific but the methodology (tiered banned terms + density metric + qualitative override) is language-agnostic.

## Tracking updates
- 05-06: 800⭐, first noted in [[skill-distribution-convergence]]
- 05-07: 831⭐, v0.4.0 released
- 05-09: 901⭐ (+8.4%), v0.4.1. Major architecture evolution: desymlinking, CI pipeline, deslop quantification, 3-agent verification. 7 PRs in one release.
- 05-09: **Applied** deslop quantification to [[kagura-story]]: created `scripts/deslop-score.sh` (density metric + tiered severity), batch scanner, integrated into storyteller SKILL.md. Baseline scan: 379 files, all CLEAN. Methodology adapted (EN+ZH word lists, structural patterns), but my writing was already clean — the tool's value is as a **regression guard** for future output.
- 05-10: 946⭐ (+5%). 7 commits in 2 days. **Not stabilizing — accelerating.** Key new features:
  - **story-researcher**: Dedicated subagent for factual research during writing. Uses CDP browser (priority) with WebSearch fallback. Structured reference templates for historical verification, geographic detail, profession knowledge, cultural customs. Model: sonnet, 20 max turns.
  - **Scene routing** (PR#26): Route user intent to workflow — 开书 (full Phase 1-5), 日更/续写 (daily update: fast-load 3 files → write → progress summary), 大修 (revision: locate chapters → rewrite → cascade check). Smart entry point selection.
  - **Reference compression** (PR#29): Refactored reference files for smaller context windows. Terminology simplification.
  - **Layered summary protocol** + genre formula references (PR#28)
  - **Observation**: Project is evolving from "writing assistant" to **writing platform** — research, routing, revision, and quality assurance as distinct agent roles. The multi-agent specialization pattern mirrors [[supervisor-pattern]].
