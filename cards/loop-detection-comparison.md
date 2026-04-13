# Loop Detection: OpenClaw vs nanobot

> Comparing two approaches to detecting infinite tool call loops in agent runtimes

## OpenClaw (`tool-loop-detection.ts`, ~400 lines)

**Architecture:** Session-scoped sliding window (default 30 calls) with hash-based pattern matching.

**Detectors:**
| Detector | What it catches | Threshold (default) |
|---|---|---|
| `genericRepeat` | Same tool + same args | warn=10, critical=N/A |
| `knownPollNoProgress` | Same poll tool + same result | warn=10, critical=20 |
| `pingPong` | A-B-A-B alternation with no progress | warn=10, critical=20 |
| `globalCircuitBreaker` | Any tool repeating with identical results | 30 |

**Hash method:** SHA-256 of stable-serialized params (sort_keys). Outcome hash includes details + text content, with special handling for process/poll tools.

**Known gaps (from issues #34574, #64500):**
1. **Exec volatile fields**: `durationMs`, `pid`, `cwd` in details make every exec call unique → escape detection (partially fixed via #34687 stripping volatiles)
2. **Result-only similarity**: Model tries N *different* approaches, gets same error N times → not caught because args differ (heavensea's SSH scenario: 49 tool calls, 28 identical `Permission denied`)
3. **Per-tool circuit breaker**: Blocks tool A but not paired tool B → ping-pong restarts
4. **High defaults**: 10/20/30 thresholds let loops burn many iterations before triggering

## nanobot (PR #3077, 57 lines)

**Architecture:** Per-run counter dict, signature = `name:json(args, sort_keys)`.

| Component | Details |
|---|---|
| Signature | `f"{name}:{json.dumps(args, sort_keys=True, default=str)}"` |
| Threshold | 3 (hard-coded) |
| Scope | Single `run()` invocation (resets per turn) |
| On trigger | Injects error: "you have already called X with identical arguments 3 times. Summarize what you have and respond." |
| Layered | Domain-specific guards (web_search=2) fire first |

**Strengths:**
- Extremely simple, easy to audit
- Low threshold catches loops early (saves 12+ wasted iterations)
- Instructive error message guides model to self-correct
- Per-run reset prevents cross-turn false positives

**Limitations:**
- Args-only comparison (same gap as OpenClaw genericRepeat — different args escape)
- No result comparison
- No ping-pong detection
- Hard-coded threshold (not configurable)

## Gap Analysis: What Both Miss

**The "creative retry" pattern** (heavensea's report): model varies arguments but gets identical failure results. Neither system detects this because both primarily match on argument signatures.

**Proposed solution: result-similarity detector**
```
Track last N results per tool (regardless of args).
If the same result hash appears K consecutive times for a tool,
trigger warning/critical.
```

This would catch:
- SSH with different flags → same `Permission denied`
- API calls with different params → same `401 Unauthorized`
- File reads with different paths → same `ENOENT`

**Threshold suggestion:** warn at 3, critical at 5 (per-tool, args-independent).

## Applicability to Workshop

Workshop's cron runner doesn't execute tool calls directly — it sends prompts to external LLM agents. Tool stagnation detection belongs in the agent runtime layer (OpenClaw/nanobot), not the orchestration layer (Workshop).

However, Workshop could benefit from a **cron-level stagnation detector**: if the same cron produces identical output N consecutive times, flag it. This is a different pattern (output stagnation vs tool stagnation) but the same principle.

## Source
- OpenClaw: `src/agents/tool-loop-detection.ts` (read 2026-04-13)
- nanobot: PR #3077 (read 2026-04-13)
- OpenClaw issues: #34574 (exec loop), #64500 (ping-pong circuit breaker)

## See Also
- [[tool-stagnation-detection]] — nanobot-specific deep read
- [[cron-observability-metrics]] — related: monitoring cron behavior
