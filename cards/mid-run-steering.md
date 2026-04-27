# Mid-Run Steering

Injecting user guidance into an agent's execution loop **between tool calls**, without interrupting the turn or creating a new user message.

## The Problem

When an agent is running a multi-step tool sequence, the user has limited intervention options:
1. **Wait** — let the agent finish (may waste tokens going wrong direction)
2. **Interrupt** — cancel the current run and start fresh (loses context)
3. **Queue** — schedule a message for the next turn boundary (too late for in-flight corrections)

None of these allow real-time course correction during a running turn.

## The Pattern

A `/steer` command injects text into the agent's context at the next natural seam (between tool result processing and the next LLM call). Key design constraints:

- **No new user turn** — the steer text is appended to existing tool result content, preserving role alternation invariants
- **Cache-safe** — tool result messages are already at the tail of the prefix and invalidate per turn
- **Explicit provenance** — marked as `[USER STEER ...]` so the model doesn't confuse it with tool output
- **Graceful fallback** — if agent finishes before the steer lands, it becomes a normal message in the next turn

## Implementations

### Hermes Agent (v0.11.0, PR #12116)
- `/steer <prompt>` — appended to last tool result's content
- Multiple steers concatenated with newlines
- Wired into CLI, gateway, and Ink TUI
- `clear_interrupt()` drops pending steers (no surprise late delivery)

### OpenClaw
- `subagents steer` — sends a message to a running subagent
- Different mechanism: creates a message rather than injecting into tool results
- Less elegant but more general (works across session boundaries)

## Design Insight

The choice of **where** to inject matters more than **whether** to inject. Appending to tool results is superior to injecting as a synthetic user message because:
1. It doesn't break prompt caching of earlier messages
2. It doesn't violate model-specific role alternation rules
3. It's naturally scoped to the current tool execution context

### wanman (2026-04-27)
- Steer-priority messages → SIGKILL current Claude/Codex subprocess → next loop iteration picks up steer message first (SQL ordering by priority)
- Most aggressive approach: kills the process entirely rather than injecting mid-stream
- Tradeoff: loses all in-flight context but guarantees the steer is acted on immediately
- Simpler implementation than Hermes (no need for injection seams), but context loss is significant
- See [[wanman]]

## Design Insight

Three distinct approaches now visible across the ecosystem:
1. **Inject into tool results** (Hermes) — minimal disruption, preserves context, but complex to implement
2. **Queue for next turn boundary** (OpenClaw subagent steer) — no context loss, but delayed
3. **Kill and restart** (wanman) — immediate but destructive, simplest to implement

The right choice depends on how expensive context loss is vs how urgent the steer is.

## Related

- [[nudge-over-workflow]] — nudges at session boundaries (between runs, not within)
- [[concurrent-agent-file-coordination]] — another Hermes v0.11.0 pattern for multi-agent coordination
- [[hermes-agent]] — source project
