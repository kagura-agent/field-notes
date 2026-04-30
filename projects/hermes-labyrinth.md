# hermes-labyrinth

Read-only observability plugin for [[hermes-agent]].

- **Repo**: stainlu/hermes-labyrinth (210★, 2026-04-25)
- **License**: MIT
- **Author**: stainlu (hackathon build)
- **Language**: Python backend (FastAPI) + vanilla React frontend (no bundler)
- **Status**: v0.1.0, active (pushed 2026-04-29)

## What It Does

Turns autonomous agent work into a navigable map. Not a chat UI — a **black-box recorder** for agents.

Core concepts:
- **Journeys** = sessions (Hermes sessions mapped 1:1)
- **Crossings** = individual events within a journey (prompts, tool calls, tool results, assistant responses, subagent spawns/returns, approvals)
- **Guideposts** = auto-generated observations about journeys (warnings for failures, notices for long durations, delegation boundaries, context compression)
- **Threads** = crossings grouped by lane (main, tools, delegation, thresholds)

## Architecture

### Backend (plugin_api.py, 693 lines)
- FastAPI router mounted at `/api/plugins/hermes-labyrinth/`
- **Read-only by design** — never creates, stops, or mutates sessions
- Reads from Hermes `state.db` via `SessionDB` (existing Hermes infra)
- Normalizes Hermes messages → crossings via `_message_to_crossings()`
- Auto-generates guideposts from crossing patterns (rule-based, not LLM)
- Secret redaction via Hermes's own `redact_sensitive_text()`

### Endpoints
| Route | Purpose |
|-------|---------|
| `/health` | Plugin health check |
| `/journeys` | List sessions with pagination |
| `/journeys/{id}` | Journey detail + crossings + guideposts |
| `/journeys/{id}/crossings` | Raw crossings |
| `/skills` | Skill inventory (bundled/user/optional/external) |
| `/cron` | Cron job inventory with next/last run |
| `/guideposts` | Recent global guideposts across journeys |
| `/reports/{id}.json` | Exportable journey report |
| `/reports/{id}.md` | Redacted markdown report |

### Frontend (src/parts/*.js, ordered browser chunks)
- SVG-based **map visualization** with 3 lanes (delegation ← main → tools)
- Inspector panel for selected crossing (inputs/outputs/duration/evidence)
- Skill atlas with source categorization
- Cron gate with schedule/status/next-run
- No build tool — numbered files concatenated in order

## Key Design Decisions

1. **Read-only principle**: Zero mutation of Hermes state. This is observability, not control.
2. **Inference-based crossings**: Instead of requiring agents to emit structured events, it infers crossings from existing message history. Clever but lossy — durations and model switches depend on what Hermes already records.
3. **Rule-based guideposts**: Pattern matching over crossings (failure counts, duration thresholds, tool repetition, delegation boundaries). Not LLM-powered — deterministic and cheap.
4. **Redaction-first**: All previews go through Hermes's `redact_sensitive_text()` before display. Reports are redacted by default.

## Guidepost Patterns (what it detects)

| Pattern | Severity | Trigger |
|---------|----------|---------|
| Failed crossings | warning | Any crossing with status=failed |
| Repeated failing tool | warning | Same tool fails >1 time |
| Long journey | notice | Duration > 30 min |
| High tool-call journey | notice | ≥10 tool calls |
| Context compression | info | end_reason=compression |
| Delegation boundary | info | subagent_spawn crossing |
| Approval boundary | info | approval-type crossing |
| Model switch | info | Multiple models in sequence |

## Ecosystem Position

- **Companion to** [[hermes-hudui]] (joeynyc's web dashboard, different approach — real-time state monitoring vs journey mapping)
- Both read from `~/.hermes/` state, but different angles:
  - hermes-hudui = "what is the agent doing now" (13 tabs: identity, memory, sessions, costs, live chat)
  - hermes-labyrinth = "what did the agent do and what went wrong" (journey → crossings → guideposts)
- Uses Hermes's **dashboard plugin system** (`~/.hermes/plugins/` + `/api/dashboard/plugins/rescan`), making it zero-config after clone

## Relevance to Us

### What We Can Learn
1. **Crossing abstraction**: Breaking sessions into typed events (prompt, tool_call, tool_result, subagent_spawn, approval) is a clean model for agent observability. Our cron sessions could benefit from similar decomposition.
2. **Guideposts as cheap anomaly detection**: Rule-based pattern matching over crossings is surprisingly effective for the 80% case. No LLM needed — just "if tool X fails >N times, flag it."
3. **Read-only as principle**: The plugin never mutates state. This makes it safe to install on any Hermes agent. We should consider similar constraints for any OpenClaw observability tooling.
4. **Journey ≠ Session**: Reframing "session" as "journey" is more than naming — it implies a path through unknown territory with crossings and guideposts. Better mental model for autonomous work.

### What It Can't Do (and we might need)
- **No real-time streaming** — reads state after the fact (roadmap item)
- **No cross-journey correlation** — can't detect patterns across journeys (e.g., "this tool always fails on Tuesdays")
- **No cost tracking** — reads `estimated_cost_usd` if Hermes has it, but doesn't aggregate or trend
- **No alert/notification** — purely visual, no webhook/push when anomalies detected

### Comparison with [[cron-observability-metrics]]
Our existing analysis concluded we don't need external observability yet (trajectory JSONL has all data). Hermes-labyrinth validates that conclusion — it's useful for Hermes users but adds a UI layer we don't currently need. The **guidepost pattern** is the transferable insight: cheap rule-based anomaly flags on top of existing data.

## See Also
- [[hermes-hudui]] — web dashboard (real-time monitoring angle)
- [[cron-observability-metrics]] — our observability evaluation
- [[agentic-stack]] — data-layer skill comparison

## Applied: FlowForge Stats (2026-04-30)

Applied the guidepost pattern to [[FlowForge]]:
- Built `flowforge stats` command — workflow summary, per-node breakdown, anomaly detection
- Three anomaly types: low completion rate, slow nodes (>10min avg), stalled/abandoned nodes
- Also shows top branch choices for decision pattern visibility
- All read-only on existing history DB (1105 instances, 5436 history records)

Key insights from running stats on real data:
- `study` workflow: 509 runs, 99.6% completion, avg 17.2 min — the `apply` node is slowest (14.7 min avg)
- `evolve` and `daily-audit` workflows have very long avg durations (1300-1500 min) because instances aren't always completed in the same session
- `workloop-night → done` node averaging 76.7 min suggests the done/reflect steps often sit uncompleted
- The stall data (💀) shows which nodes get abandoned — useful for workflow design improvement
