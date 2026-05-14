# SPECA — Spec-to-Property Agentic Auditing

| Field | Value |
|-------|-------|
| Repo | [NyxFoundation/speca](https://github.com/NyxFoundation/speca) |
| Stars | 389 (2026-05-14) |
| Language | Python + TypeScript (Web UI) |
| License | — |
| Status | 🟢 Active — pivoting from CLI to platform |

## What It Does

Automated security audit pipeline that transforms specifications into formal program graphs, generates security properties, and performs proof-based formal audits against target code. Uses **Claude Code CLI as a batch worker** under an async Python orchestrator.

## Architecture

### Pipeline Phases (6-phase)

`01a` (Spec Discovery) → `01b` (Subgraph Extraction — Mermaid state diagrams) → `01e` (Property Generation — STRIDE + CWE Top 25) → `02c` (Code Pre-resolution via Tree-sitter MCP) → `03` (Audit Map — Map→Prove→Stress-Test) → `04` (Review — 3-gate FP filter: Dead Code → Trust Boundary → Scope Check)

Manual post-phases: `05` PoC Gen, `06` Bug Bounty Report.

### Orchestrator Pattern

`ClaudeRunner` invokes `claude --prompt-path --stream-json` per batch. Key components:
- **CircuitBreaker** — consecutive failure thresholds, total retries, empty result detection
- **CostTracker** — per-phase budget enforcement (hard stop on `BudgetExceeded`)
- **ResumeManager** — scans `PARTIAL_*.json` for incremental re-execution
- **ResultCollector** — lenient validation (warns but doesn't block) to preserve partial progress

This is an industrialized version of our subagent pattern. We spawn Claude Code ad-hoc; they have a formal runner with cost controls and circuit breakers.

### Optimization Insights

- **Early termination**: trivially safe code skips Prove/Stress-Test phases → 30-50% token reduction
- **Cache strategy**: batch similar items from same file → cache hit rate 50%→80%
- **Code pre-resolution**: Phase 02c resolves locations before audit → 70-80% fewer MCP calls

### Web UI Pivot (PR#62, 2026-05-14)

Massive 46K-line, 279-file PR adding full Web UI:
- Python backend (port 7411) + Vite frontend (React)
- Run dashboard, findings browser, per-finding evidence/proof traces
- **Read-only chat** with server-side tool allowlist enforcement (`tool_not_allowed` event for unauthorized tools)
- claude.ai OAuth login (reuses `~/.claude/credentials.json`)
- Dark/light/system themes, mobile-responsive

**Significance**: CLI audit tool → platform. Shows the pattern of agent-orchestrator tools growing into dashboards. The read-only chat guard is a nice security pattern — whitelist-only tool dispatch.

## Connections

- [[flowforge]] — our orchestrator uses YAML workflows; theirs uses Python + Pydantic schemas. Both solve "run multi-step agent work reliably"
- [[openclaw]] — their `ClaudeRunner` is analogous to our subagent spawning, but more formalized with cost budgets and circuit breakers
- [[mechanical-enforcement-via-topology]] — their 3-gate FP filter (Dead Code → Trust Boundary → Scope Check) is mechanical enforcement: each gate can only produce `DISPUTED_FP` (recall-safe design), no human judgment needed

## Relevance to Our Direction

1. **Orchestrator controls** — CircuitBreaker + CostTracker pattern worth studying if we ever need budget-constrained subagent runs
2. **CLI → Platform trajectory** — validates that agent tools inevitably grow UIs. Good signal for what OpenClaw might face
3. **Self-improvement foundation** (Issue #32) — they're thinking about reusing intermediate audit artifacts for model improvement, parallel to our beliefs-candidates pipeline
4. **Lenient validation** — their `ResultCollector` warns but doesn't block on schema mismatches, preserving partial progress. We should consider this for FlowForge (currently strict)
