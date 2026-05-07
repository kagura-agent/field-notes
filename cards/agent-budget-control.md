# Agent Budget Control

Pre-execution cost estimation and budget enforcement for autonomous agents.

## Core Idea

Before an agent executes an operation, estimate its cost (tokens, network I/O, API calls, money) and compare against a budget. Reject or require approval if the estimate exceeds thresholds.

## Implementations

### Mirage Provision System
- `ProvisionResult`: network_read (low/high), cache_hits, read_ops, estimated_cost_usd
- Three precision levels: EXACT, RANGE, UPPER_BOUND
- Agent calls `provision()` before `execute()` — dry run with cost bounds
- See [[mirage-vfs]]

### thClaws /goal System
- Budget-enforced persistent objectives
- Audit trail for completion decisions
- See [[thClaws]] tracking in TODO

## Transferable Applications

1. **Subagent spawn cost** — estimate token usage before spawning (model × expected turns × avg tokens)
2. **API rate limit impact** — estimate how many API calls a command will make before executing
3. **Disk/network budget** — estimate file sizes before clone/download operations
4. **Time budget** — estimate wall-clock time for long-running operations

## Design Tradeoffs

- **Accuracy vs overhead**: Exact estimates require pre-scanning (expensive); range estimates are cheaper but less useful
- **Granularity**: Per-command vs per-session vs per-agent budget tracking
- **Enforcement**: Hard reject vs soft warning vs approval prompt

## Related

- [[mirage-vfs]] — provision system implementation
- [[skill-distribution-convergence]] — reducing agent API surface
