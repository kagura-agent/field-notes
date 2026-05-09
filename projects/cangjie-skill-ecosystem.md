---
title: Cangjie-Skill Ecosystem (Book/Person → Skill Distillation)
created: 2026-05-09
source: github.com/kangarooking/cangjie-skill, alchaincyf/nuwa-skill, alchaincyf/darwin-skill
tags: [skill-distillation, knowledge-management, self-evolution]
---

# Cangjie-Skill Ecosystem

Three interlocking projects forming a **knowledge → skill → evolution** pipeline:

| Project | Stars (05-09) | Purpose |
|---------|--------------|---------|
| [nuwa-skill](https://github.com/alchaincyf/nuwa-skill) | 18,106 | Distill **people** — mental models, decision heuristics, expression DNA |
| [cangjie-skill](https://github.com/kangarooking/cangjie-skill) | 800 | Distill **books** — methodologies, frameworks, principles into executable skills |
| [darwin-skill](https://github.com/alchaincyf/darwin-skill) | 2,254 | **Evolve** any skill — 8-dimension rubric + hill-climbing + test-driven validation |

## How It Works

### cangjie-skill: RIA-TV++ Pipeline

A 6-stage pipeline that transforms book text into atomic SKILL.md files:

```
Stage 0: Adler analysis (structure/interpret/critique/apply) → BOOK_OVERVIEW.md
Stage 1: 5 parallel extractors (framework/principle/case/counter-example/glossary) → candidate pool
Stage 1.5: Triple verification filter → verified units only
Stage 2: RIA++ construction → SKILL.md per unit
Stage 3: Zettelkasten linking → INDEX.md with reference graph
Stage 4: Pressure testing (darwin-compatible) → test-prompts.json
```

### The Triple Verification (Stage 1.5) — Quality Gate

This is the core innovation. Every candidate must pass ALL three:

1. **V1 Cross-domain**: ≥2 independent contexts in the book support this idea
2. **V2 Predictive Power**: Can derive an answer to a question the book doesn't explicitly address
3. **V3 Exclusivity**: Not something any smart person would say — must be the author's unique insight

Pass rate: typically 30-50% for methodology-dense books, 5-10% for essay-style. This is what separates "skill distillation" from "book summarization."

### darwin-skill: Autonomous Optimization

Karpathy autoresearch-inspired: evaluate → improve → test → keep-or-revert → visual card.

- 8-dimension rubric (60pts structure + 40pts effectiveness)
- Effectiveness requires actual test execution, not just structural review
- Ratchet mechanism: only keep improvements, auto-revert regressions
- Independent scorer (sub-agent) to avoid "grading your own homework"

## Already Distilled (14 skill packs)

Notable: Buffett Letters (20 skills), 毛选 (25 skills), 穷查理宝典 (12 skills), system-prompt-skills (15 skills from 165 leaked system prompts).

Also community-contributed: 精益创业, 孙子兵法, 庄子, 易经, 缠论, 茶经.

## Architectural Insights

1. **Distillation ≠ Summarization** — the triple verification filter is the key differentiator. Most "book to AI" tools just compress; cangjie extracts transferable methodology units.

2. **Test-Driven Skills** — every skill ships with `test-prompts.json` including "decoy" prompts (scenarios where the skill should NOT be invoked). This is the same verification discipline our [[beliefs-upgrade-mechanism]] needs.

3. **Pipeline Composability** — nuwa (person) → cangjie (book) → darwin (evolution) form a clean pipeline. Each tool has a clear input/output contract. darwin's test format is the integration surface.

4. **Single Issue, One Enthusiastic User** — only 1 issue (a thank-you), suggesting the project is still creator-driven, not community-driven. The methodology is mature but the community loop isn't established.

## Relevance to Our Direction

### What We Can Learn

- **Triple Verification as upgrade quality gate**: Our [[beliefs-candidates]] already adopted Durability + Reduction from hermes. V2 (Predictive Power) is a strong addition — "can this belief help in scenarios we haven't encountered?" would filter out descriptive entries from truly prescriptive ones.

- **Test-driven skill validation**: darwin-skill's approach of running test prompts before/after changes maps directly to our SKILL.md evolution. We could adapt the 8-dimension rubric for our own skill quality checks.

- **Anti-pattern recognition**: The explicit "what cangjie is NOT" (not book reviews, not role-playing, not summarization) is a clean boundary definition pattern we should adopt for our skill descriptions.

### What Doesn't Apply

- The "book distillation" use case itself is tangential — we don't create skill packs from books.
- nuwa-skill's "person distillation" is interesting but not actionable for us.
- The parallel sub-agent extraction (Stage 1) assumes massive context windows for reading entire books — not our operational pattern.

## Ecosystem Position

This sits in the **skill creation toolchain** layer of [[self-evolving-agent-landscape]]. It's upstream of skill execution — focused on how skills get created and validated, not how they're run.

Connected to: [[skill-type-taxonomy]] (these are "methodology skills" — a type not well-covered in our taxonomy), [[agent-skill-standard-convergence]] (cangjie outputs SKILL.md format), [[self-evolution-as-skill]] (darwin-skill is literally evolution-as-skill).

## Tracking

- cangjie-skill: 800⭐, created 04-16, active (last push 05-04). Growth moderate. Revisit 05-16.
- darwin-skill: 2,254⭐, created 04-13, last push 04-21 (18 days ago — slowing). Creator focus may have shifted to cangjie.
- nuwa-skill: 18K⭐, viral. Not tracking closely (person distillation is adjacent, not core).
