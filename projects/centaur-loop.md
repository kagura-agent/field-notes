---
title: "Centaur Loop — Human-Governed AI Feedback Loop Workbench"
created: 2026-05-10
source: https://github.com/finewood2008/centaur-loop
stars: 17
status: tracking
revisit: 2026-05-17
tags: [agent-infrastructure, human-governance, feedback-loop, state-machine]
---

# Centaur Loop

Open-source workbench for **human-governed AI feedback loops**. TypeScript/React, MIT, created 2026-05-08.

## Core Idea

Most agent systems are one-shot: user asks → AI answers → done. Centaur Loop structures this as a **repeating cycle with human gates**:

```
Plan → Human approves → Execute → Human reviews → Publish → Collect feedback → AI reflects → Human confirms memory → Next cycle
```

The "centaur" metaphor from chess: human judgment + AI execution.

## Architecture

**Nine-stage state machine** (`LoopStage`):
- `planning` → `awaiting_plan_review` → `generating` → `awaiting_review` → `awaiting_publish` → `awaiting_feedback` → `reviewing_auto` → `awaiting_memory` → `cycle_complete`
- Every `awaiting_*` stage is a **human gate** — the loop pauses and notifies.
- Explicit `switch` state machine, not event bus. Fixed loop order → easier to debug.

**Key components:**
- `loopPlanner.ts` — goal → structured plan + task list (feeds tool registry + owner prefs + memories)
- `loopExecutor.ts` — task → draft. Failures become draft annotations, not crashes.
- `loopReviewer.ts` — analyzes outputs + feedback → `MemoryCandidate[]` + `nextSuggestion`
- `loopNotifier.ts` — multi-channel human gate notifications
- `loopStore.ts` — localStorage persistence (MVP)

**Memory model:**
- `MemoryCandidate` with categories: preference, fact, lesson, correction
- Human confirms which candidates become long-term memory
- `nextSuggestion` carries forward planning guidance

## What's Interesting

1. **Explicit human gates as first-class concept** — not an afterthought "approval step" but architecturally baked into the state machine. Every `awaiting_*` stage has notification + timeout logic.

2. **Memory-as-reviewed-output** — the reviewer proposes memory candidates, human curates. Similar to our [[beliefs-candidates]] pipeline but formalized as a stage. We do `gradient → Triple Verification → DNA upgrade`; they do `AI review → MemoryCandidate → human confirm → long-term memory`.

3. **Loop improvement is structural** — `nextSuggestion` feeds back into the next cycle's planner. The loop literally gets better each cycle, not through prompt tweaking but through accumulated reviewed experience.

4. **Failure tolerance** — executor writes failures into drafts rather than aborting. Human decides what to do with failed tasks. Pragmatic.

## Comparison to Our Approach

| Aspect | Centaur Loop | Our approach (OpenClaw/Kagura) |
|--------|-------------|-------------------------------|
| Governance | Explicit gates in state machine | AGENTS.md rules + Luna as observer |
| Memory curation | `MemoryCandidate` → human confirm | `beliefs-candidates.md` → Triple Verification |
| Feedback loop | Structured 9-stage cycle | Organic (nudge/heartbeat/reflect) |
| Scope | Content growth loops (MVP) | General agent operations |
| Runtime | Browser-based UI | CLI + chat channels |

**Key insight**: Their approach is more **structured** but more **rigid**. Ours is more **organic** but risks missing feedback signals. The `MemoryCandidate` pattern with human confirmation is worth studying — it's a formalization of what we do informally with beliefs-candidates.

## Relevance

- [[mechanism-vs-evolution]]: Centaur Loop is mechanism-heavy (explicit state machine). Whether it evolves beyond its initial structure is the real test.
- [[self-evolving-agent-landscape]]: Sits in the "agent infrastructure" layer, specifically the governance/oversight niche.
- [[supervisor-pattern]]: Human-as-supervisor with structured gates.

## Verdict

Small (17⭐) and early (v0.2.0), but architecturally thoughtful. The state machine approach to human-AI feedback loops is cleaner than most. Worth revisiting in a week to see if it gains traction. The `MemoryCandidate` → human confirmation pattern is the most transferable idea.
