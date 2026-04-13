# Provider Hang Dead Zones

## Problem
Agent frameworks with multi-layer retry architectures (streaming → non-streaming fallback → credential rotation → provider fallback → global timeout) have **gaps between layers** where no progress monitoring occurs. Users experience "no response for 580+ seconds" despite the framework having 5 active retry layers — because each layer's timeout is sequential and additive with no global deadline.

## Pattern
**Eliminate dead zones by:**
1. **Activity heartbeating in every recovery phase** — not just during normal operation, but during backoff sleeps, connection rebuilds, stale detection cycles, and error recovery entries
2. **Error propagation over inline fallback** — let the outermost retry loop decide strategy (it has the richest recovery options: credential rotation, provider fallback, backoff). Inline fallback within a layer hides errors from the global strategy
3. **Stale-call detection for non-streaming** — non-streaming calls return nothing until complete; without a stale detector, they hang for the full transport timeout (e.g., 1800s httpx default)
4. **Context-adaptive timeouts** — scale stale thresholds based on estimated context size (larger context → longer allowed wait), disable for local providers (no network uncertainty)

## Design Decisions
- **Poll-count intervals vs wall-clock check** for activity touch: simpler, deterministic (e.g., 100 × 0.3s = 30s)
- **Session-level `_disable_streaming` flag**: once a provider says "no streaming", stop trying for the whole session — per-attempt retry wastes one full timeout cycle each time
- **Token estimation heuristic**: `sum(len(str(msg)) for msg in messages) // 4` — rough but cheap, only used for timeout scaling
- **Stale timeout defaults**: 300s base → 450s for 50K+ tokens → 600s for 100K+ → disabled for local providers

## Implementations
- **hermes-agent #8985** (2026-04-13): 162+/140-, 7 test rewrites. Three targeted changes: remove non-streaming fallback from streaming path, add `_touch_activity` to 6 recovery dead zones, stale-call detector for non-streaming
- **OpenClaw**: Has `_touch_activity` pattern but no non-streaming stale detector. Gateway inactivity monitor can't see agent during recovery phases

## Relationship to Other Patterns
- Extends [[partial-stream-recovery]]: stream recovery handles content preservation, dead zone elimination handles the detection/monitoring that triggers recovery
- Complementary to [[execution-contract-pattern]]: execution contracts prevent stalls at the model behavior level, dead zone elimination prevents stalls at the infrastructure level
- Related to [[cron-runaway-safety]]: both are about "agent systems that appeared to work but produced nothing under specific conditions"

## Applicability
- Any agent framework with multi-layer retry architecture
- Especially critical for: long-reasoning models (o3, GPT-5), proxy environments with strict idle timeouts (our Copilot API 60s), GHE/enterprise environments with extra auth layers
- The "5 layers but still hung" failure mode is counterintuitive — more retry layers can make hang detection *harder* because each layer trusts the inner layer to handle it
