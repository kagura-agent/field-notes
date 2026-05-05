---
title: tracking-health.sh
type: tool
created: 2026-05-05
status: active
---

# tracking-health.sh — Tracking Portfolio Health Dashboard

**Location**: `~/.openclaw/workspace/study/tracking-health.sh`
**Usage**: `bash tracking-health.sh [YYYY-MM-DD]`

## What It Does

Portfolio-level health check for the study tracking list in TODO.md:

1. **Overdue items** — past revisit date, need immediate action
2. **Auto-drop candidates** — detected via signals: stalled, no commits, low traction (<20⭐) without deep read, explicit "consider drop" markers
3. **Revisit date distribution** — shows load clustering (e.g., 15 items on 05-09 = overload)
4. **Star tier distribution** — portfolio composition by traction level
5. **Recommendations** — actionable: portfolio too large (>40), overdue count, drop candidates

## Why It Exists

The tracking list grew to 51 items organically. `tracking-due.sh` only shows today's due items — no portfolio overview, no drop detection, no load distribution. This tool applies the "observability must close the loop" principle: see the problem → act on it.

## Applied From

- **GenericAgent** — "fold agent, keep user" heuristic led to thinking about information management at scale
- **bux** — "proactive agency" pattern (structured suggestions → action) inspired the recommendation engine
- **AGENTS.md** — "观测必须闭环" principle directly: every `发现 X 问题` needs action in the same turn

## Integration

- Integrated into [[flowforge]] `study.yaml` followup node as step 0 (before tracking-due.sh)
- Rule: if auto-drop candidates > 5 or total > 40, clean first, then follow up

## Links

- [[tracking-due-script]] (predecessor, date-only check)
- [[study-workflow]] (where it's used)
- [[genericagent]] (architectural inspiration)
