# Supervisor Pattern

Multi-agent quality control through a dedicated monitor agent that watches worker execution in real-time.

## Core Principle

"挑刺的监工，不是干活的工人" — the supervisor **never executes**, only reads, judges, and intervenes.

## GenericAgent Implementation

File-based IPC as message bus:
- `_intervene` file → corrective injection into worker's next prompt (`[MASTER]` prefix)
- `_keyinfo` file → preventive injection into worker's working memory
- `consume_file()` → read-once-delete pattern prevents replay
- Supervisor polls `output.txt` for worker progress

**Seven intervention triggers**: skip step, miss constraint, talk-not-do, unverified claims, repeated failures, drifting, approaching critical step.

**Style**: silence by default, one-sentence interventions like a user would say.

## Comparison with Other Approaches

| Approach | Timing | Granularity | Example |
|----------|--------|-------------|---------|
| Supervisor (GenericAgent) | In-flight | Per-step | `_intervene` / `_keyinfo` |
| Nudge (OpenClaw) | Post-session | Whole-session patterns | beliefs-candidates |
| Iteration limits (nanobot) | In-flight | Hard cap | max_iterations sync |
| Plan verification (GenericAgent) | Per-assertion | Completion claims | `[VERIFY]` interception |

## Key Insight

The `_keyinfo` preventive injection is the most novel element — injecting constraints *before* the worker reaches a step, rather than correcting *after* mistakes. This is analogous to pre-flight briefings in aviation.

## Relevance to Us

Our [[flowforge]] workflow node descriptions serve a similar pre-briefing function, but without an independent monitor verifying execution. Our nudge system operates post-hoc. If subagent quality becomes a recurring issue, a lightweight supervisor mode could be valuable.

See [[genericagent]], [[self-evolving-agent-landscape]], [[mechanism-vs-evolution]]
