---
title: Community Health as Tracking Signal
tags: [study-method, tracking, community, evaluation]
created: 2026-05-09
updated: 2026-05-09
---

# Community Health as Tracking Signal

Stars and commits are not enough to evaluate a project's health. **Community adoption** — issue activity, contributor diversity, external PRs — is the missing dimension.

## The Gap

Our tracking process (via [[tracking-health.sh]]) evaluated projects on:
- Star count + growth rate
- Commit recency
- Revisit date compliance

But missed:
- **Issue activity**: Are real users reporting bugs/requesting features?
- **Contributor diversity**: Is it one person or a community?
- **External PRs**: Are people contributing, or just starring?
- **PR merge openness**: Does the maintainer merge external contributions?

## The Fix

Created `tracking-community.sh` — a script that checks these signals via GitHub API and outputs a health verdict:

| Verdict | Score | Signal |
|---|---|---|
| 🟢 THRIVING | 5-6 | Active issues, external PRs, multi-contributor |
| 🟡 GROWING | 3-4 | Some community engagement |
| 🟠 NASCENT | 1-2 | Mostly solo/small team |
| 🔴 SOLO | 0 | No external engagement |

Scoring weights external PRs (2 points) highest — they're the strongest adoption signal.

## Real Data (2026-05-09)

| Project | Stars | Community Health |
|---|---|---|
| [[mirage-vfs]] | 1,449 | 🟢 THRIVING (5/6) — 8 issue authors, 1 external PR |
| [[oh-story-claudecode]] | 903 | 🟡 GROWING (3/6) — 4 issue authors, solo PR |
| [[skillplus]] | 174 | 🟠 NASCENT (1/6) — 0 issues, 0 external PRs |

**Key finding**: skillplus has active daily commits and growing stars but zero community engagement. Stars alone would overvalue it.

## Integration

Wired into [[flowforge]] `study.yaml` followup node as step 0b. Run before deciding which projects to deep-read.

## When to Use

- During followup: assess whether a tracked project is worth continued investment
- During scout: quick health check before adding a new project to tracking
- Drop decisions: 🔴 SOLO + low stars + stale = strong drop signal

## Anti-pattern

Don't use community health as the ONLY signal. Some excellent projects are intentionally solo (research projects, personal tools). Community health helps prioritize, not eliminate.

## Related

- [[scout-saturation-signal]] — complementary tracking pattern
- [[mechanical-preflight-check]] — same philosophy (script > prose instruction)
- [[bash-as-agent-interface]] — mirage (our first real data point) is THRIVING
