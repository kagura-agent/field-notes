---
title: Mechanism Bootstrapping Paradox
created: 2026-03-23
source: self-improving skill first test
---
A new mechanism cannot self-start if the agent has never used it before.

When self-improving was installed, the agent forgot to read ~/self-improving/memory.md before starting work. The existing nudge mechanism caught this: nudge triggered reflection → discovered the omission → wrote first correction → self-improving now has data.

**Pattern:** An existing mechanism must bootstrap a new one. The new mechanism cannot bootstrap itself because the behavior it requires (reading its files) is exactly what it teaches.

**Implication:** A skill relying on agent self-discipline needs either:
1. A hook-based trigger (like nudge) to catch omissions
2. A heartbeat-based check to verify compliance
3. Both (defense in depth)

Self-improving uses heartbeat (option 2). Our nudge provides option 1. Together they cover the gap.

Related: [[convergent-evolution]], [[self-evolution-architecture]], [[knowledge-needs-upgrade-path]]
