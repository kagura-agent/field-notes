---
title: ACP Permission Model
created: 2026-03-23
source: ACPX config.ts source code + debugging ACP session failures
modified: 2026-03-23
---
ACPX uses a two-layer permission model:

1. **permissionMode** — what gets auto-approved:
   - `approve-all`: all operations auto-approved
   - `approve-reads`: reads auto-approved, writes/exec need interactive approval
   - `deny-all`: nothing auto-approved

2. **nonInteractivePermissions** — what happens in non-interactive sessions when approval is needed:
   - `deny`: silently deny (session gets "Permission denied")
   - `fail`: throw error (at least you see what happened)

The two fields combine as a matrix:
- `approve-all` + any → everything works (Claude Code can write/exec)
- `approve-reads` + `deny` → reads work, writes silently fail
- `approve-reads` + `fail` → reads work, writes throw error

For division-of-labor with Claude Code ACP sessions, `approve-all` is required because code changes need write+exec.

Default: `permissionMode=approve-reads`, `nonInteractivePermissions=fail`

See also: [[debug-check-state-file-first]]
