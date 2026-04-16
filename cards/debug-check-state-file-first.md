---
title: Debug Check State File First
created: 2026-03-23
source: ACP session debugging — error was in sessions.json all along
modified: 2026-03-23
---
When debugging any system with persistent state, **check the state file first**.

Pattern:
1. Something is not working (ACP session, cron job, nudge trigger)
2. Temptation: guess, wait, retry, ask someone
3. Better: find the state file, read it, look for error/status fields

Examples:
- `~/.openclaw/agents/claude/sessions/sessions.json` → ACP session has `state: "error"`, `lastError: "Permission denied..."` — the answer was right there
- `~/.openclaw/workspace/.nudge-state.json` → `turnCount` tells you exactly where you are
- `~/.openclaw/cron/jobs.json` → `lastStatus`, `delivered` fields

This is a special case of 数据纪律: dont guess when you can look.

See also: [[acp-permission-model]]
