# Doubt-Driven Development

In-flight adversarial review for non-trivial decisions, distinct from post-hoc code review. Catches wrong directions while course-correction is still cheap.

- **Origin**: addyosmani/agent-skills PR #139 (federicobartoli), merged 2026-05-09
- **Repo**: 40,382⭐ (05-13), the de facto skill reference repository

## Core Process

5-step bounded cycle: **CLAIM → EXTRACT → DOUBT → RECONCILE → STOP**

1. **CLAIM**: Name the decision in 2-3 lines + why it matters
2. **EXTRACT**: Isolate the smallest reviewable unit (artifact + contract). **Strip your reasoning** — if you hand over conclusions, you get validation of conclusions
3. **DOUBT**: Spawn fresh-context reviewer with **adversarial** prompt ("find what is wrong", not "is this good?"). **Do NOT pass the CLAIM** — only ARTIFACT + CONTRACT
4. **RECONCILE**: Classify each finding: contract misread > actionable > trade-off > noise. Re-read artifact text, don't rubber-stamp
5. **STOP**: When findings are trivial, after 3 cycles, or user override

## Key Non-Obvious Insights

- **Don't pass your hypothesis to the reviewer** — passing the CLAIM biases toward agreement. The reviewer must independently assess artifact vs. contract
- **Fresh context is the point** — long sessions accumulate assumptions that quietly become "facts". A reviewer without your context catches what you've normalized
- **3-cycle hard bound** — if 3 rounds still surface substantive issues, the artifact isn't ready. Escalate, don't grind a 4th cycle
- **"Doubt theater" detection**: if across 2+ cycles zero findings were classified as actionable, you're validating, not doubting
- **Cross-model escalation** — same model shares blind spots with the author. Different-architecture model catches different things. Always offer, never silently skip

## When to Apply

Non-trivial = at least one of: introduces branching logic, crosses module/service boundary, asserts unverifiable property (thread safety, idempotence), irreversible blast radius.

**When NOT**: mechanical ops, formatting, clear instructions, one-liners, pure tooling.

## Relationship to Other Patterns

- vs. [[code-review]]: /review = post-hoc verdict on finished artifact. DDD = in-flight per-decision
- vs. TDD: TDD's RED step is doubt made concrete — a failing test IS the doubt step for behavioral claims
- vs. [[source-driven-development]]: SDD verifies facts about APIs. DDD verifies reasoning about the artifact

## Relevance to Us

Our [[beliefs-upgrade-mechanism]] already includes verification gates, but DDD formalizes the adversarial stance. Key takeaway: when we verify beliefs-candidates, we should **not** pass our hypothesis about why the gradient matters — just the evidence and the criteria. Let the reviewer assess independently.

The "router persona" anti-pattern (from orchestration PR #86) is worth watching: a persona whose only job is routing to other personas = pure overhead. As our skill count grows toward 40+, the [[functional-area-resolver]] pattern (from [[gbrain]]) should be the solution, not a routing agent.

Links: [[agent-skill-ecosystems]], [[reversa]], [[mechanism-vs-evolution]], [[beliefs-upgrade-mechanism]]
