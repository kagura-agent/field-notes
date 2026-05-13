# Functional-Area Resolver

Skill routing pattern from [[gbrain]] (v0.32.3.0+): instead of a generic "router agent" that dispatches to skills, use a `(dispatcher for: ...)` clause that maps functional areas to specific skill handlers.

Key insight: without the `(dispatcher for: ...)` clause, routing accuracy collapses. The clause is load-bearing, not decorative.

Relevant when skill count exceeds ~40-50 (currently ~25, not needed yet). Evaluated 05-12.

Links: [[doubt-driven-development]], [[thin-harness-fat-skills]], [[skill-explosion-2026-05]]
