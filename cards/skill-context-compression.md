---
title: Skill Context Compression Experiment
slug: skill-context-compression
tags: [experiment, token-economics, openclaw, caveman]
created: 2026-04-26
status: experiment-complete
---

# Skill Context Compression — Experiment Results

> Can we apply [[caveman]]-compress ideas to reduce OpenClaw skill loading token cost?

## Experiment: gogetajob SKILL.md

| Metric | Original | Compressed | Savings |
|--------|----------|-----------|---------|
| Bytes | 5,943 | 2,291 | **61.5%** |
| Words | 895 | 346 | **61.3%** |
| Est. tokens | ~1,163 | ~449 | **61.4%** |

### Compression Techniques Applied

1. **Eliminated prose bridges** — "Find GitHub issues, implement fixes, submit PRs, and track everything" → cut
2. **Tables kept but tightened** — column headers shortened, descriptions trimmed
3. **Code blocks preserved verbatim** — commands, paths, CLI examples untouched
4. **Rules compressed to fragments** — "Before creating any PR:" → merged into single-line rules
5. **Redundant context removed** — prereq descriptions, architecture explanations that AI already knows

### What Was Lost

- Motivation/explanation paragraphs (AI doesn't need "why")
- Detailed examples (one example per pattern sufficient)
- Verbose checklists (compressed to inline rules)

### What Was Preserved

- All commands and their semantics
- All rules and constraints
- Decision criteria (issue selection strategy)
- Architecture (main session vs sub-agent delegation)

## Total Skill Context Budget

| Skill | Bytes | Est. tokens | Compressible? |
|-------|-------|-------------|---------------|
| memos-memory-guide | 14,085 | ~2,300 | High (lots of prose) |
| seedling | 6,456 | ~1,050 | Medium |
| team-lead | 6,394 | ~1,040 | Medium |
| pulse-todo | 6,348 | ~1,030 | Medium |
| gogetajob | 5,943 | ~970 | **Proven 61%** |
| agent-memes | 5,103 | ~830 | Low (mostly tables) |
| self-portrait | 4,579 | ~750 | Medium |
| kagura-storyteller | 4,251 | ~690 | Medium |
| flowforge | 3,694 | ~600 | Medium |
| discord-ops | 2,708 | ~440 | Low |
| kagura-canvas | 2,559 | ~420 | Low |
| **Total** | **62,120** | **~10,120** | **~40-60% achievable** |

Note: Only 1 skill is loaded per task (on-demand read). So actual per-session savings = compression of the loaded skill.

## Implementation Options

### Option A: `ai_context` Frontmatter (Recommended)

Add compressed version as frontmatter field. Agent reads `ai_context` when available, falls back to full markdown.

```yaml
---
name: gogetajob
ai_context: |
  OSS contribution workflow. Main=dispatch, sub-agents=code.
  Commands: scan, feed, check, start, submit, followup, sync, stats.
  Rules: code via claude exec, max 3 PRs/repo, accurate tokens, pre-PR checklist.
  ...
---
```

Pros: Single file, self-contained. Cons: Frontmatter gets big.

### Option B: `SKILL.ai.md` Companion File

Separate compressed file alongside SKILL.md.

Pros: Clean separation. Cons: Two files to maintain, sync risk.

### Option C: Compression at Load Time

OpenClaw runtime compresses SKILL.md content before injecting into context. LLM-powered compression on first load, cached.

Pros: Zero author effort. Cons: Requires OpenClaw core change, LLM cost per first load.

## Verdict

**Option A is simplest for our current setup.** But honestly, the bigger win is applying this thinking to system prompt engineering — the `<available_skills>` block and workspace file injection are loaded every session, not on-demand. That's where compression ROI is highest.

## Links

- [[caveman]] — inspiration
- [[conciseness-accuracy-paradox]] — theoretical backing
- [[thin-harness-fat-skills]] — related architecture principle
