# agent-skills-eval — Test Runner for Agent Skills

- **Repo**: [darkrishabh/agent-skills-eval](https://github.com/darkrishabh/agent-skills-eval)
- **Stars**: 204 (2026-05-08, created 05-06)
- **Language**: TypeScript
- **License**: MIT
- **npm**: `agent-skills-eval`

## What It Does

A/B testing framework for [agentskills.io](https://agentskills.io) skills. Runs the same prompts twice — once with `SKILL.md` injected as system context (`with_skill`), once without (`without_skill`) — then has a judge LLM grade both outputs against defined assertions. Produces a pass_rate delta: does the skill actually help?

```
npx agent-skills-eval ./skills --target gpt-4o-mini --judge gpt-4o-mini --baseline --strict
```

## Architecture Insights

- **Two grading systems**: (1) LLM judge for free-form rubric assertions (2) deterministic tool-call assertions (local, no LLM). Smart split — tool behavior is verifiable, text quality needs judgment.
- **Fail-closed grading**: unparseable judge response → all assertions fail. No false positives from broken judges.
- **Worker pool**: bounded concurrency (default 4) across skills×evals. Cross-skill parallelism with per-eval ordering preserved.
- **Artifact layout**: `iteration-N/eval/mode/` mirrors agentskills.io spec. Static HTML report generator included — zero-infra sharing.
- **Provider abstraction**: OpenAI-compatible API as default. `completeChat` for system+user split when provider supports it, fallback to flat `complete`.

## Key Design Decisions

1. **Baseline comparison is opt-in** (`--baseline` flag) — without it, only `with_skill` runs. Pragmatic: most users just want pass/fail, advanced users want delta.
2. **Judge retry with error context**: if judge returns unparseable JSON, re-prompts with the bad response. One retry, then fail-closed.
3. **Strict mode**: validates SKILL.md frontmatter against agentskills.io naming requirements. Off by default for legacy compatibility.
4. **Tool assertions are first-class**: `tool-called`, `tool-arg-equals`, `tool-arg-contains`, `tool-arg-matches`, `tool-call-count`. For agents that act via tools, this is more reliable than judging text.

## Relationship to Our Direction

- **Directly relevant to [[skill-distribution-convergence]]**: as skills proliferate, quality verification becomes critical. This is the "testing layer" the ecosystem was missing.
- **Validates our approach**: we build skills for OpenClaw (SKILL.md format). This tool could test our skills against the agentskills.io spec — but we'd need to adapt our format slightly (add `evals/evals.json`).
- **Contrast with [[addyosmani/agent-skills]]**: Addy's repo is the skill content; this is the skill quality infra. Complementary, not competitive.
- **ClawHub angle**: if ClawHub eventually hosts skills with evals, this could be the CI backbone for skill quality gates. [[clawhub]] + agent-skills-eval = tested skill marketplace.

## Tradeoffs

- **Cost**: every eval = 2 LLM calls (target + judge) × 2 modes = 4 calls. Large skill suites get expensive fast.
- **Judge reliability**: LLM-as-judge has known issues (position bias, verbosity bias). The fail-closed approach mitigates but doesn't eliminate.
- **No incremental runs**: no caching or diffing between iterations. Every run re-evaluates everything.
- **agentskills.io dependency**: tightly coupled to the Anthropic skill spec. If the spec changes or alternatives emerge, this needs updating.

## Verdict

**Track** — 204⭐ in 2 days, well-structured codebase, solves a real gap. The "prove your skill works" thesis is strong. Revisit 05-14 for adoption patterns and whether it gets integrated into CI pipelines.
