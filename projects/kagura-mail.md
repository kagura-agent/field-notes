# kagura-mail

📧 Personal email management — inbox patrol, importance classification, auto-archiving.

## Overview

| Field | Value |
|-------|-------|
| Repo | kagura-agent/kagura-mail (private) |
| Local | `~/.openclaw/workspace/kagura-mail/` |
| Discord | #kagura-mail (1497023656055017563) |
| Accounts | kagura.chen28@gmail.com (primary) + kagura.agent.ai@gmail.com (agent) |
| Tests | 216 tests, 25 scripts |
| Issues | 1 open / 30 closed |

## Architecture

- **Gmail API** via Python + OAuth2 (credentials at `~/.config/gmail-api/`)
- **Token files**: `token.json` (primary), `token_agent.json` (agent account)
- **Proxy**: requires `http_proxy`/`https_proxy` for Gmail API access (httplib2 + pysocks)
- **Stats**: JSONL logging at `~/.config/gmail-api/patrol-stats.jsonl`

## Key Scripts

- `patrol.py` — Main patrol: classify, archive, summarize, alert
- `importance_classifier.py` — Rule-based classifier (security/billing/legal/@mention/personal)
- `token_health.py` — OAuth token validity pre-flight check
- `stats_report.py` — Trend analysis with ASCII charts
- `inbox_check.py` — Lightweight unread count check

## Cron Jobs

| Name | Schedule | What |
|------|----------|------|
| email-patrol | Every 8h (0/4/8/12/16/20 UTC) | Full inbox patrol + archive + alert |
| email-dev | 3x/day (02/10/18 CST) | Self-improvement — consume repo issues |

## Current Status (2026-05-08)

- ✅ Dual-account coverage restored (agent token re-authed today)
- ✅ 216 tests passing
- ✅ 30 issues closed, 1 open (#73: surface token revocation as actionable error)
- ✅ Features: importance classifier, auto-archive, GitHub noise reduction, per-repo breakdown, token health, multi-account, stats/trends
- 🔄 Self-improving via email-dev cron (3x/day)

## History

- 2026-04-24: Project created. Gmail API integrated, #kagura-mail channel + cron established
- 2026-04-25: Auto-archive feature (PR#5 merged, 45 emails archived)
- 2026-05-06: Per-repo breakdown, cross-reference fix, README overhaul
- 2026-05-07: Token auto-refresh, double-save fix, revocation surfacing
- 2026-05-08: Agent account OAuth token revoked → re-authed interactively by Luna
