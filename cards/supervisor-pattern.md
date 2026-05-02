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

---

## Update: Dirac Subagent Verifier (2026-05-02)

[[dirac]] (v0.3.14+) adds a narrow but significant variant: **completion verification subagent**.

Unlike GenericAgent's always-on supervisor, Dirac spawns a verifier *only at completion time*:
- Fresh `SubagentRunner` with role "verifier", no shared conversation history
- Has full tool access (can run `execute_command` to test)
- Returns binary verdict: "VERIFICATION: SUCCESS" or "VERIFICATION: FAILED" + details
- Falls back to inline self-check if disabled

**Key difference from GenericAgent**: not continuous monitoring, but **single-point verification at the claim boundary**. Much cheaper (one extra agent call vs continuous polling), targets the highest-risk moment (premature completion is the most common agent failure mode).

**Tradeoff**: catches false completion but can't prevent mid-task drift. Complementary to GenericAgent's in-flight monitoring, not a replacement.

**Positioning in the landscape:**

| Approach | Timing | Cost | Catches |
|----------|--------|------|--------|
| Supervisor (GenericAgent) | Continuous | High | Drift, skips, mistakes |
| Verifier (Dirac) | Completion only | Low | Premature completion |
| Nudge (OpenClaw) | Post-session | Minimal | Session-level patterns |

See [[genericagent]], [[dirac]], [[self-evolving-agent-landscape]], [[mechanism-vs-evolution]]
