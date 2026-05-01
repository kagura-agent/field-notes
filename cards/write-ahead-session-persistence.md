# Write-Ahead Session Persistence

> Pattern: Persist user input before processing, use metadata flag as transaction marker for crash recovery.

## Problem
Agent runtimes typically save the full turn (user + assistant messages) at the end of processing. If the process dies mid-turn (OOM, SIGKILL, container eviction), the user's prompt is silently lost — only the interrupted assistant state may be checkpointed.

## Pattern
```
1. Receive user message
2. Append to session + set "pending" flag → flush to disk  (write-ahead)
3. Run agent loop (may crash here)
4. Save complete turn → clear flag → flush               (commit)
5. On recovery: flag present + last=user → inject error   (rollback/close)
```

## Key Design Decisions
- **Flag, not WAL**: Uses a single boolean metadata key instead of a separate write-ahead log file. Minimal overhead, works with existing session storage.
- **Explicit error injection**: On crash recovery, doesn't silently delete the orphaned user message. Instead injects `"Error: Task interrupted"` as an assistant response — preserving the question in history and signaling the interruption.
- **Scope limitation**: Only text content gets early persistence. Media blocks that need sanitization still go through end-of-turn path. Pragmatic tradeoff: most user messages are text, and media sanitization is complex.
- **Dedup via skip offset**: `_save_turn()` increments its skip offset by 1 when the user message was early-persisted, avoiding double-writes without re-reading from disk.

## Implementation (nanobot, 2026-04-13)
- `_mark_pending_user_turn()` / `_clear_pending_user_turn()` — metadata flag operations
- `_restore_pending_user_turn()` — called on session load, closes interrupted turns
- Coordinates with existing `runtime_checkpoint` mechanism (which handles in-flight assistant/tool state)
- Source: commits ea94a9c, 6484c7c (HKUDS/nanobot)

## Complementary Mechanisms
- **Auto-compact protection**: Don't archive sessions with active tasks (prevents context truncation mid-turn)
- **Provider defensiveness**: Recover trailing assistant messages as user messages when removal leaves only system messages (prevents empty-request provider errors)

## Applicability
- Any agent runtime with session persistence (OpenClaw, [[hermes-agent]], Workshop)
- Particularly important for: cron/unattended execution, long-running tasks, environments prone to OOM
- Also relevant for: database-backed session stores (the flag pattern maps to transaction BEGIN/COMMIT)

## Tradeoffs
- Extra disk flush per turn (typically negligible vs LLM API latency)
- Error injection message may confuse models that don't handle it well (but preserves conversation coherence)
- Text-only limitation means media messages can still be lost on crash

## See Also
- [[nanobot]] — Session Resilience Sprint section
- [[loop-detection-comparison]] — Related nanobot safety mechanisms
- [[startup-credential-guard]] — Another defensive pattern from the agent framework ecosystem
- [[session-state-isolation]] — Complementary pattern: isolating mutable tool state across concurrent sessions
