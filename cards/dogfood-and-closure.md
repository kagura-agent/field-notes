# Dogfood & Closure Discipline

**Graduated from**: beliefs-candidates.md (5 entries merged, patterns: 不dogfood, merge≠在用, 观测闭环, GitHub承诺追踪)
**Date**: 2026-05-03

## Dogfood Rule
- Built a feature? Use it with your own data before calling it done.
- Merged a PR to someone's tool? Rebuild locally, run your use case. "merged" is not the finish line, "I'm using it" is.
- Tool feedback must come from real usage, not from glancing at code post-merge.

## Closure Rule
- Completed non-trivial work → immediately update all related status (GitHub issue comment, wiki project page, blocker marks). Don't wait for next review cycle.
- Said "I'll do X" on GitHub → that's a commitment. Record in memory/today.md TODO immediately, or it'll be forgotten.
- Closure = done + status updated + stakeholders notified.
- "做了为什么没告诉我" — proactively report external actions (resubmit PR, reply to review, close PR).

## Evidence
- memex: wrote semantic search but never used it on own knowledge-base
- memex issue #2: promised "I'll start Phase 1", didn't move for 8 hours
- gogetajob sync: only tracked open PRs, missed merged/closed confirmations
