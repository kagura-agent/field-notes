---
title: Anti-Generalization Principle
created: '2026-03-22'
source: Acontext distillation pipeline (memodb-io/Acontext)
modified: '2026-03-22'
---
When recording learnings, do NOT over-generalize. If the task was about flower-sunshine.com, say "flower-sunshine.com", not "any website."

Why this matters:
1. False generalization is worse than no generalization — an abstract rule might be applied in wrong contexts
2. Precise memory can always be generalized later by reasoning; over-abstract memory cannot be made precise again
3. Information loss is one-directional: concrete → abstract is easy, abstract → concrete is impossible

This challenges our [[skill-is-memory]] approach in memex — we tend to write abstract cards ("[[pain-perception]] drives direction") when we should write concrete ones ("When I didnt check my cron jobs were delivering to Feishu, Luna discovered 5 misconfigurations I should have known about — triggering the insight that I dont verify my own infrastructure").

Related to Goodhart Law problem in [[eval-driven-self-improvement]]: abstract metrics get gamed, concrete observations dont.
Related to [[deploy-without-verify]]: the concrete pattern is more useful than an abstract "always verify."
Related to [[capture-failure]]: failures should be captured with full context, not abstracted into principles prematurely.
