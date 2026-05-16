---
title: tracking-health.sh
type: tool
created: 2026-05-05
status: active
last_verified: 2026-05-16
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

## Known Issues & Fixes

### 05-16: False positive on "flat" keyword
**Problem**: Bare `flat` in signal 1 grep matched "star growth flat" in observations about THRIVING projects (e.g., kiwifs/kiwifs 425⭐ 🟢 THRIVING). Flagged 05-14, reproduced and fixed 05-16.

**Root cause**: `grep -qiP "...flat..."` too broad — matched any line containing "flat" regardless of context.

**Fix**: Three changes:
1. Replaced bare `flat` with specific phrases: `flat growth`, `stars flat`, `growth flat`
2. Added THRIVING/HEALTHY negative gate — if line contains positive health signal, skip
3. Removed `flash` (typo, never a valid signal)
4. Aligned summary `drop_count` grep with detection grep

**Lesson**: Signal detection keywords need context-awareness. Bare adjectives ("flat", "slow") appear in many contexts — use 2-word phrases for precision. Negative gates ("but this line also says X") prevent false positives on mixed-signal entries.

## Links

- [[tracking-due-script]] (predecessor, date-only check)
- [[study-workflow]] (where it's used)
- [[genericagent]] (architectural inspiration)
