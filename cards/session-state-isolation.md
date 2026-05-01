# Session State Isolation

When multiple agent sessions share a single process, mutable state stored at module/global scope leaks across sessions. This creates confusing bugs where session B sees stale artifacts from session A.

## Pattern: ContextVar Binding

Python's `contextvars.ContextVar` provides async-safe per-task state (unlike `threading.local` which breaks with asyncio):

```python
from contextvars import ContextVar, Token

_current_state: ContextVar[MyState | None] = ContextVar("_current_state", default=None)

def bind(state: MyState) -> Token:
    return _current_state.set(state)

def reset(token: Token) -> None:
    _current_state.reset(token)

# Usage in agent loop:
token = bind(session_state)
try:
    await run_tools(...)
finally:
    reset(token)
```

## Why Not Alternatives?

- **Pass state through every call**: Invasive, requires refactoring all tool signatures
- **Per-session tool instances**: Wasteful memory, breaks shared initialization
- **Thread-local storage**: Broken with async/await (multiple sessions on same thread)
- **Global dict keyed by session ID**: Works but pollutes every function with session_id parameter

## Real-World Example

[[nanobot]] PR #3576 (2026-05-01): `ReadFileTool` file-read cache was module-level dict. Session A reads file → session B gets "File unchanged since last read" dedup stub. Fixed by wrapping state in `FileStates` class bound via ContextVar.

## Relevance

Any multi-session agent framework (OpenClaw, [[nanobot]], [[hermes]]) needs to audit tool state for cross-session leaks. Common culprits:
- File read/write caches
- Browser session state
- Conversation context accumulators
- Rate limiter counters

Links: [[nanobot]], [[write-ahead-session-persistence]], [[agent-memory-research]]
