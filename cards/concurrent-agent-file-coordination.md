# Concurrent Agent File Coordination

When multiple agents work on the same codebase concurrently, file edits can silently overwrite each other. This is a structural problem — not a rare edge case.

## Hermes's Solution (v0.11.0, PR #13718)

Three-layer defense:

1. **Batch-level** — before dispatching parallel tool calls within one agent turn, check for path overlap. Cheap, zero API cost.
2. **Registry-level** — `FileStateRegistry` singleton tracks read timestamps per agent and last writer per path. Warns (not blocks) when a write targets a file modified by a sibling since the reader's last read.
3. **Completion-level** — after a subagent returns, parent gets a note listing files the child modified that the parent had previously read ("re-read before editing").

Key design choices:
- **Warning-only, never hard-fail** — matches the project's "let the model decide" philosophy
- **Per-path threading.Lock** — prevents concurrent write interleave (physical corruption)
- **Sorted lock acquisition** for multi-file patches — classic deadlock avoidance
- **Opt-out via env var** (`HERMES_DISABLE_FILE_STATE_GUARD=1`)

## The Gap in OpenClaw

OpenClaw subagents sharing a workspace have no coordination mechanism. When two subagents edit the same file, the last writer wins silently. This works because:
- Most subagent tasks are scoped to different repos/directories
- When conflicts happen, git catches them at commit time

But for same-repo concurrent work (e.g., two agents fixing different issues in the same file), this is a real risk.

## General Pattern

The "stale read" problem is database concurrency 101 (optimistic locking). Hermes adapts it to agent file operations:
- Read = SELECT (record timestamp)
- Write = UPDATE WHERE version = last_read (check, warn if stale)
- Lock = row-level mutex (per-path)

## Related

- [[hermes-agent]] — source project
- [[async-agent-transport]] — different layer (connection lifetime vs file state)
- [[recursive-summarization-decay]] — another Hermes architecture pattern
