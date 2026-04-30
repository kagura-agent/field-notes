# COST OF NOT CALLING — Prompt Engineering Pattern

**Source**: [[stash]] v0.2.7 MCP prompt template (2026-04-30 deep read)

## What It Is

Every tool description ends with an explicit statement of what happens if the agent does NOT call the tool. This makes omission feel dangerous — the model internalizes that skipping the tool has consequences.

## Example

```
> **COST OF NOT CALLING:** Commitments vanish. Tasks promised in conversation
> are forgotten by next session. Every untracked promise is a trust debt.
```

## Why It Works

LLMs optimize for "doing the right thing" but also for "avoiding the wrong thing." A tool description that only says what the tool does gives the model a reason to call it. A "COST OF NOT CALLING" gives the model a reason NOT to skip it. The asymmetry matters — humans are more loss-averse than gain-seeking, and LLMs trained on human text inherit this bias.

## Where We Applied It

- **pulse-todo SKILL.md** — commitments get lost without tracking (2026-04-30)
- **flowforge SKILL.md** — ad-hoc execution skips steps (2026-04-30)

## Candidates for Future Application

- **gogetajob** — contribution pacing / PR quality degrades without workflow
- **self-portrait** — identity coherence drifts without periodic self-check
- Any skill with a history of being skipped (check [[beliefs-candidates]] for `skip-own-tools` pattern)

## Related

- [[stash]] — original source project
- [[agent-memory-landscape-202603]] — memory architecture survey
- [[hermes-memory-skills]] — related prompt engineering approaches
