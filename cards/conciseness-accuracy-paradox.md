---
title: Conciseness-Accuracy Paradox
slug: conciseness-accuracy-paradox
tags: [llm, prompting, counterintuitive, token-economics]
created: 2026-04-26
---

# Conciseness-Accuracy Paradox

> Forcing LLMs to be concise doesn't reduce accuracy — it **improves** it.

## Evidence

- arxiv:2604.00025 (2026): conciseness constraints improve accuracy by 26pp on certain benchmarks
- [[caveman]] project: 75% output token reduction with 100% technical accuracy retention
- 46.6k stars in 22 days — viral adoption suggests practitioners confirm the effect empirically

## Mechanism Hypothesis

Verbose LLM output contains:
1. **Hedging** ("It's possible that...", "You might want to consider...")
2. **Filler** ("I'd be happy to help", "Let me explain")
3. **Qualifications** ("In most cases", "Generally speaking")
4. **Redundancy** (rephrasing the same point multiple ways)

These don't add information — they dilute signal density. Forcing conciseness forces the model to:
- **Commit** to its best answer rather than hedge
- **Prioritize** the most relevant information
- **Skip** social pleasantries that consume tokens

## Implications

### For Agent Design
- Agent-to-agent communication should default to terse mode (no social overhead)
- Human-facing output can selectively add warmth/context
- The "dual document" pattern: compressed for AI, readable for humans

### For Context Loading
- Memory files, SKILL.md, workspace files loaded every session → compress prose, keep code verbatim
- caveman-compress achieves 46% input savings on typical memory files
- Compounding: input compression + output compression = significant cost reduction

### For Skill Authoring
- SKILL.md files are read by AI more than humans → optimize for AI readability
- Potential: `ai_summary` frontmatter field for fast context loading

## Anti-Pattern
"More verbose prompt = more careful/thorough response" — **this is wrong**. More verbose prompt = more tokens to process, more noise to filter, less signal density.

## Links
- [[caveman]] — the project that popularized this
- [[agent-memory-research]] — memory compression as a related problem
- [[thin-harness-fat-skills]] — skill loading efficiency
