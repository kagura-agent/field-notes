---
title: Lightweight Eval for Self-Evolution
created: 2026-04-10
source: wiki-to-skill Phase 3, cards eval-driven-self-improvement + evolution-needs-eval
status: design draft
---

## Problem
We mutate DNA files (AGENTS.md, SOUL.md, workflows) but have no systematic way to measure if mutations improve behavior. Luna's feedback is sparse and doesn't cover autonomous work.

## Minimum Viable Eval — 3 Proxy Metrics

### 1. PR Merge Rate (打工质量)
- **Source**: gogetajob history in memory files
- **Metric**: merged / total PRs per week
- **Baseline**: check last 4 weeks
- **Signal**: rate going up = contribution quality improving

### 2. Repeat Gradient Count (学习速度)
- **Source**: beliefs-candidates.md
- **Metric**: how many entries have repeat count ≥ 3 that haven't been upgraded
- **Signal**: decreasing = we're upgrading lessons faster; increasing = same mistakes persist

### 3. Daily Review Findings (执行纪律)
- **Source**: daily-audit workflow outputs in memory files
- **Metric**: number of actionable findings per audit
- **Signal**: decreasing = fewer gaps; stable high = systemic issues

## Implementation Options

### Option A: Cron job (simplest)
Weekly cron job that:
1. Greps memory files for PR outcomes
2. Counts beliefs-candidates entries by repeat count
3. Produces a markdown report in `wiki/eval/YYYY-WXX.md`

### Option B: FlowForge eval workflow
New `eval` workflow that runs weekly:
1. Collect metrics from files
2. Compare to previous week
3. If regression detected → flag for review
4. Update a running dashboard file

### Option C: Nudge hook integration
Add eval checks to the existing nudge plugin — every N turns, check if recent behavior matches or contradicts known patterns.

## Recommendation
Start with **Option A** — a simple cron job. It's the least infrastructure, produces visible artifacts, and can be upgraded later. The key insight from the cards: **any eval is better than no eval**.

## Next Steps
- [x] Write the eval script (shell + grep/awk) — `scripts/weekly-eval.sh` (2026-04-10)
- [x] Set up weekly cron job — `weekly-eval` cron, Mon 9:00 CST (2026-04-10)
- [x] Run first baseline measurement — W15 report: 54% merge rate, 2 unupgraded gradients, 12 audit findings (2026-04-10)
- [ ] After 4 weeks (W19, ~2026-05-11), decide if metrics are useful enough to keep
