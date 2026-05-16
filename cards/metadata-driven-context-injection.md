# Metadata-Driven Context Injection

A pattern for making persistent state visible to the model across compaction boundaries.

## Problem

Agent systems compact conversation history to fit context windows. Any state stored only in messages gets lost. Goals, workflow state, and priorities disappear after compaction.

## Pattern

1. Store durable state in **session metadata** (key-value store outside message history)
2. At each turn, **inject** a projection of that state into the runtime context block
3. Model sees the state every turn regardless of compaction

```
Session metadata (durable) ──→ projection function ──→ runtime context (per-turn)
                                                          ↓
                                                      model sees it
```

## Key Properties

- **Compaction-safe**: state lives outside message history
- **Projection-controlled**: different projections for different consumers (runtime context vs WebUI vs API)
- **Single-writer**: tools write metadata, loop reads it — no race conditions
- **Truncation-safe**: projection function handles length limits

## Origin

[[nanobot]] PR #3788 (2026-05-15): `goal_state_runtime_lines()` injects active goal text into every turn's runtime context block via `supplemental_lines` parameter. Goal stored in session metadata as JSON blob.

## Applications

- **Active goals/objectives** → original use case (nanobot `/goal`)
- **Workflow state** → inject [[FlowForge]] current node + task into runtime context
- **Priority overrides** → inject top-N TODO items or active blockers
- **Identity context** → inject relevant SOUL.md fragments per conversation type
- **Safety boundaries** → inject active constraints for the current session type

## Contrast with Alternatives

| Approach | Compaction-safe? | Model-visible? | Maintenance |
|---|---|---|---|
| Store in messages only | ❌ | ✅ (until compacted) | None |
| Repeat in system prompt | ✅ | ✅ | Manual, static |
| **Metadata + injection** | ✅ | ✅ | Automatic, dynamic |
| External file (re-read) | ✅ | Only if tool called | Requires model initiative |

## Links

- [[nanobot]]
- [[write-ahead-session-persistence]]
- [[FlowForge]]
- [[session-state-isolation]]
