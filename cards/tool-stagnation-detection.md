# Tool Stagnation Detection

> Agent safety pattern: detect and break infinite tool call loops

## Problem

LLMs can get stuck calling the same tool with identical arguments repeatedly, burning through all `max_iterations` without producing useful output. Common scenario: "what happened recently?" → 15+ identical `read_file(history.jsonl, limit=50, offset=1)` calls.

This wastes tokens, time, and leaves users without responses. Especially dangerous in cron/unattended contexts where no human is watching.

## Pattern (from nanobot PR #3077)

Three components:

### 1. Deterministic Signature
```python
def tool_call_signature(name: str, args: dict) -> str:
    return f"{name}:{json.dumps(args, sort_keys=True, default=str)}"
```
- `sort_keys=True` ensures argument order doesn't matter
- Different args = different signature → reading 10 different files is fine

### 2. Counter + Threshold
```python
def repeated_tool_call_error(name, args, seen_counts, max_repeats=3):
    sig = tool_call_signature(name, args)
    count = seen_counts.get(sig, 0) + 1
    seen_counts[sig] = count
    if count <= max_repeats:
        return None
    return f"Error: you have already called {name} with identical arguments {max_repeats} times. Summarize what you have and respond."
```
- Threshold 3: generous enough for retries, strict enough to catch loops
- Counter scoped to single `run()` invocation → resets per turn

### 3. Integration Point
- `tool_call_counts: dict[str, int]` maintained in run() scope
- Checked in `_run_tool()` before execution, alongside existing guards
- Layered with domain-specific guards (e.g., web_search max=2 fires first)

## Design Decisions

| Choice | Rationale |
|---|---|
| Per-run reset | Cross-turn persistence would block legitimate repeated access in new context |
| Threshold 3 | Saves 12+ wasted iterations in typical loop while allowing retries |
| Instructive error | Guides model to summarize + respond, not just "blocked" |
| Layered guards | Domain-specific (web=2) fires first, general (all=3) is second line |

## Applicability

- **Any agent runner** with tool loops (OpenClaw, Workshop, custom)
- **Cron/autonomous contexts** benefit most (no human to interrupt)
- **Not needed** when human is watching and can cancel manually
- Complements but doesn't replace `max_iterations` (which catches diverse-arg loops)

## Related

- [[berkeley-benchmark-gaming]] — tool behavior deviating from expected patterns
- [[cron-progress-suppression]] — another cron safety mechanism
- [[nanobot]] — source implementation

## Source
- nanobot PR #3077 (2026-04-13): `nanobot/utils/runtime.py` + `nanobot/agent/runner.py`
- 57 lines code + 165 lines tests
