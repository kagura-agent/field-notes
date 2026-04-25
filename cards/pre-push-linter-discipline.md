---
title: Always run project-specific linter before pushing PRs
slug: pre-push-linter-discipline
tags: [pattern, workflow, lint, ci, gogetajob, quality, auto-extracted]
created: 2026-04-25
modified: 2026-04-25
source: auto-extraction
evidence_count: 1
last_reinforced: 2026-04-25
confidence: 0.85
status: draft
---

# Always run project-specific linter before pushing PRs

phantom#87 CI failed due to biome formatting issues in chained method calls. The fix was trivial but required an extra commit cycle. Lesson reinforced: before pushing any PR, identify and run the project's linter locally (e.g. `npx biome check` for biome projects). Each project may use different tools (ESLint, biome, prettier) — check the project config first. This avoids unnecessary fix-up commits that make agent PRs look sloppy to maintainers.

## Related

- [[gogetajob]]
