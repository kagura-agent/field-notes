---
title: "agent-skills-eval — Test Runner for Agent Skills"
created: 2026-05-10
source: https://github.com/darkrishabh/agent-skills-eval
stars: 265
star_history: "265 (05-10)"
status: tracking
revisit: 2026-05-17
tags: [skill-ecosystem, eval, testing, agentskills-io]
---

# agent-skills-eval

> "Write a SKILL.md, drop in some evals, and find out — empirically — whether your skill actually makes the model better at the task."

TypeScript CLI tool. MIT. By darkrishabh.

## What It Does

Runs a skill against prompts twice — once **with_skill** loaded into context, once **without_skill** (baseline) — uses a judge model to grade both outputs, then produces a side-by-side report.

```bash
npx agent-skills-eval ./skills \
  --target gpt-4o-mini --judge gpt-4o-mini --baseline --strict
```

Output: static HTML report with pass/fail per skill.

## Architecture

- Workspace-based: outputs to `agent-skills-workspace/iteration-N/`
- JSONL artifacts for each run
- OpenAI-compatible API for target and judge
- CLI-first, npm-published

## Why This Matters

### Skill Ecosystem Maturity Signal

This is the **testing layer** for the agent skills ecosystem. The progression:
1. Write skills (SKILL.md) ✅ (2025-2026, widespread)
2. Share skills (registries, ClawHub) ✅ (early 2026)
3. **Test skills empirically** ← we are here (May 2026)
4. Auto-evolve skills based on test results (next?)

The fact that someone built this and got 265⭐ in 4 days means the ecosystem feels the pain of "skills that don't provably help."

### Connection to Our Direction

- Could be used to validate our own skills before publishing to ClawHub
- The with/without testing paradigm could apply to our beliefs-candidates process — test whether a belief actually changes behavior
- [[agentskills-io-standard]] is referenced — the standard is getting tooling built around it

## Open Questions

- Does it handle non-text skills (e.g., tool-use skills)?
- How does the judge model handle subjective quality differences?
- 265⭐ in 4 days — growth trajectory? Will revisit.
