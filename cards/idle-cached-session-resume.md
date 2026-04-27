---
title: idle_cached Session Resume Pattern
created: 2026-04-27
tags: [agent-infrastructure, session-lifecycle, acp, pattern-comparison]
---

# idle_cached Session Resume Pattern

Agent process idles between triggers but preserves session context for continuity across activations. Falls back to cold-start on stale/expired sessions.

## Origin

[[wanman-skill-evolution]] defines three agent lifecycle modes:
- **24/7**: continuous respawn loop
- **on-demand**: stateless per trigger
- **idle_cached**: idle until triggered, preserves `session_id` via `claude --resume`

## OpenClaw ACP Already Has This

OpenClaw's ACP `persistent` mode implements the core pattern:

| Mechanism | wanman `idle_cached` | OpenClaw ACP `persistent` |
|-----------|---------------------|--------------------------|
| Session preservation | `claude --resume <id>` | `resumeSessionId` in `ensureSession()` |
| Fallback on stale | Cold-start new session | Fresh session retry + identity cleanup |
| State persistence | In-memory + supervisor | `createFileSessionStore({ stateDir })` |
| Trigger | JSON-RPC from supervisor | `sessions_send` / `sessions_spawn` |
| Recovery detection | Implicit | `isRecoverableMissingPersistentSessionError()` regex |

Key code path: `manager-C1Jx3l8a.js` line ~1537:
```
persistedResumeSessionId = mode === "persistent" ? resolveRuntimeResumeSessionId(previousIdentity) : void 0
```

## Gaps (potential improvements, low priority)

1. **No semantic distinction** between "keep warm" and "discard after use" — persistent always tries resume
2. **No TTL-based expiry** — relies on backend agent's own session expiry
3. **No resume success rate metrics** — just logs and retries, no structured tracking

## Verdict

No new development needed. The value of `idle_cached` is already captured by ACP persistent mode. If finer control needed later (TTL, metrics, explicit lifecycle labels), add session lifecycle hooks at the ACP manager layer.

## Related

- [[agent-lifecycle-fsm]] — explicit state machine for agent lifecycle
- [[wanman-skill-evolution]] — source of the idle_cached concept
- [[self-evolving-agent-landscape]] — broader context of agent lifecycle patterns
