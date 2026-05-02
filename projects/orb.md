# Orb — Claude Code Wrapper Framework

**Repo:** https://github.com/KarryViber/Orb (⭐52, created 2026-04-16)
**Language:** JavaScript/Node.js

## What It Does
Multi-profile messaging shell around Claude Code CLI. Routes messages from Slack to per-profile Claude Code workers, with:
- Per-thread Claude Code sessions (reuses via inject IPC)
- Holographic long-term memory (SQLite, trust scoring, decay)
- DocStore FTS5 search with project slug inference
- Cron scheduling per profile
- MCP permission relay (surfaces Claude Code approvals in Slack)

## Architecture
User (Slack) → Orb (routing + memory + cron) → Claude Code CLI (one worker per thread) → Reply

Orb stays **outside** agent runtime — doesn't replace Claude Code's loop, just wraps it.

## Comparison to OpenClaw
- Similar concept: persistent agent shell wrapping coding CLI
- OpenClaw is more mature: multi-channel, multi-provider, skill system, heartbeat, ACP runtime
- Orb's "holographic memory" (trust scoring + decay) is interesting — OpenClaw uses flat markdown files
- Orb is Claude Code-only; OpenClaw is provider-agnostic

## Interesting Ideas
- **Trust-scored memory**: Facts get trust scores, decay over time. Could inform our memory evolution.
- **Per-thread session reuse via IPC inject**: Efficient approach to follow-up turns.

## Update 2026-04-27 (brief)
- Now at v0.3.0 ("Event Stream Unification") — WeChat adapter added alongside Slack
- Multi-platform hardening: capability-driven typing, permission semantics per platform
- Growing fast: 52→53⭐ in a week, active daily commits
- Still Claude-Code-only, still JavaScript

## Deep Read: v0.3.0 Event Stream Unification (2026-04-27)

### What Changed
28 typed IPC message types between worker and scheduler → **6 types** (turn_start, turn_end, turn_complete, cc_event, inject_failed, error). The `cc_event` type carries raw Claude Code stream-json events; all UI rendering moved to platform-specific subscribers.

**Impact**: scheduler.js dropped 38% (2535→1575 LOC). Worker kept event *semantics* (what does this tool_use mean?) but shed event *presentation* (how to render in Slack).

### Architecture After v0.3.0
```
Claude Code CLI (stream-json NDJSON)
    ↓
worker.js — parse + emit cc_event{turnId, eventType, payload}
    ↓ (Node IPC, 6 types)
scheduler.js EventBus.publish(msg, ctx)
    ↓ (sequential fan-out)
┌─ QiSubscriber (task card streaming)
├─ PlanSubscriber (TodoWrite → plan card)
├─ TextSubscriber (debounced intermediate text)
├─ StatusSubscriber (tool_use → typing indicator)
└─ JSONL audit writer (worker-side, per-turn)
```

### Key Patterns

**1. EventBus with match/handle protocol**
- Subscribers: plain function (always match) or `{match(msg,ctx), handle(msg,ctx)}`
- Sequential fan-out (ordering > throughput) — deliberate for stream operations
- No middleware, no priority, no error boundaries — simple but fragile at scale
- Context object carries scheduler, adapter, turn state — no global state needed

**2. createCcSubscriber factory** (most interesting)
- Higher-order factory encapsulating per-turn state management for streaming cards
- Provides: per-turn state via `Map<turnId, State>`, start-promise mutex, serialized append chaining
- Concrete subscribers define only domain logic (~30 LOC each)
- Tradeoff: currently Slack-specific despite generic naming (in `adapters/slack.js`)

**3. Capability-driven platform abstraction**
- Method presence detection (`typeof adapter?.setThreadStatus === 'function'`) instead of `platform === 'slack'` checks
- Boolean capability flags (`supportsInteractiveApproval`)
- Same interface, different behavior per platform — scheduler doesn't care which
- vs [[openclaw]]: OpenClaw channel plugins have implicit capabilities; Orb makes them explicit

**4. EgressGate dedup**
- SHA1 fingerprint at delivery boundary prevents duplicate text delivery
- Plus `subtractDeliveredText` for prefix-overlap cases (turn_complete already delivered part of result)
- Two dedup layers for two different overlap scenarios

**5. JSONL audit at source**
- Written in worker (what Claude *did*), not scheduler (what was *delivered*)
- `profiles/{name}/data/cc-events/YYYY-MM-DD.jsonl` with turn_id + job_id correlation
- Better observability design than logging at delivery side

### Anti-Intuitive Findings
- Worker still 980 LOC despite "thin forwarder" framing — event semantics stayed, only presentation moved
- Sequential EventBus is a strength not weakness — stream ordering requires it
- Architecture doc stale (still lists removed types) — code is the reference
- 50 tests all passing — solid test culture for a 53⭐ project

### What OpenClaw Can Learn
1. **Capability-driven adapters** — explicit capability detection > implicit platform knowledge
2. **Per-turn state factory** — useful pattern for any multi-platform streaming UI
3. **Audit at source** — log what the agent did, not what was delivered
4. **Event semantics vs presentation split** — clear separation point for multi-channel systems

### Ecosystem Position
Orb is the most architecturally mature Claude Code wrapper in the [[coding-agent]] space. Its v0.3.0 refactor shows genuine software engineering (not just "it works"). Growing steadily. Main limitation: Claude-Code-only, JavaScript-only. [[openclaw]] is broader (multi-provider, multi-channel, skill system) but could learn from Orb's event architecture.

Links: [[openclaw]], [[coding-agent]], [[byob-browser]], [[self-evolving-agent-landscape]]

## Followup 2026-04-27 19:52
- **No new commits** since Apr 25 (v0.3.0 changelog + wechat fixes)
- Stars: 52→53 (slow steady growth)
- v0.3.0 not yet tagged as a release (latest release still v0.2.0)
- **Status: stable between releases**, existing deep read analysis is current

## Followup 2026-05-02 13:50
- **No new commits** since Apr 25 — full week of silence after v0.3.0 burst
- Stars: 51 (slight dip from 52-53 range)
- v0.3.0 still not tagged as a release (latest release still v0.2.0)
- **Status: dormant post-v0.3.0**, possibly regrouping for next feature
