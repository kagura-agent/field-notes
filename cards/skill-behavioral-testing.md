# Skill Behavioral Testing

> Skills are behavioral code, not documentation. They should be tested like code.

## Core Idea

Before deploying a skill, run a **pressure test**:
1. **Baseline** — give 3 real scenarios to the agent *without* the skill. Record failures.
2. **Draft** — write skill rules targeting observed failure patterns, not imagined ones.
3. **Verify** — same 3 scenarios *with* the skill. Confirm behavior changed.

**Litmus test:** "Without this skill the agent does X; with it, Y." If you can't state both, the skill is decorative.

## Why It Matters

Most agent skill systems accumulate rules nobody tests. Skills become documentation-that-looks-like-instructions — present in context, consuming tokens, but not provably changing behavior. This pattern ensures every skill has observable impact.

## Exceptions

- Pure reference (API docs, parameter lists) — no behavioral test needed
- Post-mortem gotchas (one-time bug workarounds) — value is in the record
- User-dictated single rules — user knows what they want

## Source

First seen in [[orb]] v0.4.0 `_GOVERNANCE.md` (§ 7 Pressure Test). Inspired by Anthropic's "Lessons from Building Claude Code" skill practices.

## Connection to Our Stack

- [[clawhub]] could require pressure test results before skill publishing
- Our skill-creator skill could incorporate baseline/verify as a step
- [[beliefs-candidates]] promotion could use similar before/after validation

Links: [[orb]], [[clawhub]], [[skill-ecosystem]], [[self-evolving-agent-landscape]]
