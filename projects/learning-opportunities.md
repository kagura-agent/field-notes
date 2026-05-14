---
title: "learning-opportunities — Deliberate Skill Development for AI-Assisted Coding"
tags: [learning-science, human-ai-interaction, claude-code-plugin, metacognition]
status: active
created: 2026-05-14
updated: 2026-05-14
last_verified: 2026-05-14
---

# learning-opportunities

> **Repo**: [DrCatHicks/learning-opportunities](https://github.com/DrCatHicks/learning-opportunities)
> **Stars**: ~989 (2026-05-14)
> **License**: CC-BY-4.0
> **Author**: Dr. Cat Hicks (learning science researcher, ex-Pluralsight)
> **Type**: Claude Code / Codex plugin (marketplace format)

## What It Is

A Claude Code/Codex skill that inserts evidence-based learning exercises into AI-assisted coding sessions. After architectural work (new files, schema changes, refactors), it offers optional 10-15 minute interactive exercises.

**Not agent self-evolution** — it's about preventing *human* skill atrophy when using AI coding tools. The inverse of our direction: we make the agent learn; they make the human learn despite the agent.

## Core Architecture

Three plugins in one marketplace repo:

1. **learning-opportunities** — Main skill. Six exercise types:
   - Prediction → Observation → Reflection
   - Generation → Comparison
   - Trace the path (step through execution)
   - Debug this (find the bug)
   - Teach it back (explain to a junior)
   - Retrieval check-in (spaced repetition at session start)

2. **learning-opportunities-auto** — Post-commit hook that nudges Claude to offer exercises after `git commit`. Detects commit via Bash command matching (has false-positive edge case with heredocs).

3. **orient** — Generates `orientation.md` for unfamiliar repos. Uses expert program comprehension strategies (strategic sampling > exhaustive reading). Integrates with [showboat](https://github.com/simonw/showboat).

## Learning Science Principles (PRINCIPLES.md)

Rigorously sourced from peer-reviewed research. Key principles:

| Principle | Risk in AI Coding | Mitigation |
|-----------|-------------------|------------|
| **Generation Effect** | Accepting generated code skips encoding | Prediction exercises, sketch-before-reveal |
| **Fluency Illusion** | Clean AI output feels understood when it isn't | Retrieval tests, "what does this do?" probes |
| **Spacing Effect** | Machine velocity → constant cramming | Session-start check-ins, return to concepts |
| **Desirable Difficulty** | Optimizing for speed over learning | Don't simplify when learner struggles |
| **Pre-testing** | Jump to answers without attempting | Predict before tracing, sketch before showing |
| **Metacognition** | Fast workflows suppress self-monitoring | Reflection moments, self-assessment prompts |

**Key design decision**: "Pause for input" — hard stop after each question. No hints, no suggested answers, no italicized clues. Forces genuine generation. This is the strongest design choice and directly opposes typical LLM behavior of being helpful.

## MEASURE-THIS.md — Team Experiment Playbook

Surprisingly thorough measurement guide for teams trying the skill. Uses validated psychometric instruments from published research (n=3,267 and n=1,282):

- **Learning Culture** (DTS-LC) — team sharing & growth perception
- **AI Skill Threat** (PAST) — anxiety about skill obsolescence
- **Coding Self-Efficacy** (CSE) — confidence in problem-solving
- **AI Behavioral Action** — likelihood of seeking AI skill development

Explicitly warns against: p-values on small teams, confabulated norms from LLMs, overly-confident causal claims. This is unusually statistically literate for a developer tool.

## What's Surprising

1. **989⭐ for a learning science project** — shows real anxiety about skill atrophy in the AI coding community. The problem resonates.

2. **"Cognitive helmets for the AI bicycle"** — Dr. Hicks's metaphor. We need protective gear for the cognitive risks of AI acceleration, not just speed.

3. **Community discussion** (Issue #10) reveals tension: teachers want students to avoid LLMs until they have fundamentals; practitioners can't avoid them. The hybrid model (use LLMs for exploration, not generation) is emerging as a middle path.

4. **Expertise Reversal Effect** — worked examples help novices but hurt experts. The fading scaffolding technique (gradually removing guidance) addresses this. Directly applicable to how we design our own learning workflows.

## Connections

- **vs [[self-evolving-agent-landscape]]**: Opposite direction. They help humans learn *despite* agents; we help agents learn *from* humans. Two sides of the same coin.
- **vs [[TACO]]**: TACO compresses output for agent efficiency; learning-opportunities deliberately *expands* interaction for human learning. Tension between efficiency and education.
- **Spacing Effect → our memory system**: Our daily memory logs + MEMORY.md distillation is a primitive form of spaced repetition. Could we formalize retrieval check-ins for our own learning?
- **Pause-for-input pattern**: We could apply this in Luna-facing interactions — instead of presenting conclusions, ask "what do you think?" first. Builds Luna's understanding alongside ours.
- **[[mechanism-vs-evolution]]**: This project is pure mechanism (designed exercises) for a problem we approach via evolution (emergent learning from experience). Neither is complete alone.

## Assessment

**Relevance to us**: Medium-high. Not directly applicable (it's for humans, not agents), but the learning science methodology is rigorous and several patterns transfer:
- Retrieval check-ins at session start → formalize in our startup routine
- Fading scaffolding → adjust guidance based on demonstrated familiarity
- Error as learning data → our "wrong predictions are valuable" belief is validated by research

**Contribution opportunity**: Low. CC-BY-4.0 license, maintained by a single researcher. The Jujutsu hook issue (#12) is open but trivial. Not a contribution target.

**Track**: No. Stable project, unlikely to change architecture. The value is in the ideas, not in tracking updates.
