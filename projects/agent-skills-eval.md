---
title: agent-skills-eval
type: project
created: 2026-05-09
last_verified: 2026-05-09
status: tracking
stars: 250
repo: darkrishabh/agent-skills-eval
tags: [skill-ecosystem, testing, agentskills-io, eval]
---

# agent-skills-eval — Test Runner for Agent Skills

## What It Is

A CLI/SDK that empirically measures whether a SKILL.md actually improves model performance. Runs the same eval prompts twice — once `with_skill` (SKILL.md injected as system context), once `without_skill` (baseline) — then has a judge model grade both outputs side-by-side.

```bash
npx agent-skills-eval ./skills --target gpt-4o-mini --judge gpt-4o-mini --baseline --strict
```

Produces an HTML report with pass/fail per eval, grading details, and artifacts.

## Architecture

Single-purpose TypeScript CLI (~16 source files), zero framework deps:
- `discover.ts` — finds SKILL.md + eval YAML files in a directory tree
- `run-eval.ts` — runs each eval in `with_skill` and `without_skill` modes
- `grade.ts` — sends both outputs to a judge model for comparison grading
- `report.ts` — generates static HTML report
- `openai-compatible-provider.ts` — any OpenAI-compatible API as target/judge
- Produces `agent-skills-workspace/iteration-N/` with full artifacts

## Why It Matters

1. **First testing infra for the skill ecosystem** — until now "does my SKILL.md work?" was vibes-based
2. **Validates agentskills.io as a standard** — testing tooling = ecosystem maturity signal
3. **Judge-model grading pattern** — uses LLM-as-judge for eval, which is the emerging standard for skill quality
4. **250⭐ in 3 days** — strong demand signal for skill quality tooling

## Relation to Our Stack

- ClawHub skills could adopt this eval format for quality gates
- The `with_skill` / `without_skill` comparison methodology could inform our own skill development — proving a skill actually helps
- Currently only supports agentskills.io format (SKILL.md + evals/ YAML), but the concept is universal

## Borrowable Ideas

- [ ] Eval format for ClawHub skills — `evals/` directory with YAML test cases
- [ ] Judge-model grading for skill publish quality gate
- [ ] A/B skill comparison — test skill v1 vs v2

## See Also

- [[agentskills-io-standard]] — the format this tests
- [[agent-skill-standard-convergence]] — skill ecosystem maturity
- [[skills-as-packages]] — skill packaging landscape
