# Process Hang Watchdog

## Problem
When an agent platform spawns CLI agent processes (Claude Code, OpenClaw, Gemini), the process can hang on a tool call (e.g. accessing unreachable filesystem, network timeout in tool). The parent daemon's stdout/stderr scanner blocks indefinitely on `scanner.Scan()`, causing:
- Task permanently stuck in `running` state
- Daemon goroutine leak
- Ping deadlock (health check can't complete)

## Pattern: Three-Layer Defense in Depth

### Layer 1 — Pipe Close Watchdog (process-level)
```go
go func() {
    <-runCtx.Done()
    _ = stdout.Close()  // forces scanner.Scan() to return false
}()
cmd.WaitDelay = 10 * time.Second  // OS-level pipe cleanup after process exit
```
Applied uniformly to ALL backends (not just the one that triggered the bug).

### Layer 2 — Independent Drain Timeout (goroutine-level)
```go
drainTimeout := opts.Timeout + 30*time.Second
drainCtx, drainCancel := context.WithTimeout(ctx, drainTimeout)
select {
case result = <-session.Result:
case <-drainCtx.Done():
    // daemon never blocks forever even if backend fails to produce Result
}
```

### Layer 3 — Context-Aware Select (functional-level)
```go
select {
case result = <-session.Result:
case <-pingCtx.Done():
    reportFailed("context cancelled")
    return
}
```
Health checks and pings don't deadlock even if the agent backend stalls.

## Key Design Decisions
- **All backends, not just the broken one**: Apply watchdog to claude/opencode/openclaw/gemini uniformly — the bug is structural (any process can hang), not provider-specific
- **+30s buffer**: Drain timeout = backend timeout + 30s, giving cleanup time without infinite wait
- **Close pipe, don't kill process**: More graceful than SIGKILL — scanner unblocks naturally, process can clean up
- **WaitDelay as OS-level backstop**: Even if goroutine cleanup fails, Go's built-in WaitDelay catches it

## Implementations
- **multica #947** (2026-04-14): Three-layer fix across all 4 agent backends (claude/opencode/openclaw/gemini) + daemon executeAndDrain + ping path. 123+/-58 lines, 5 files.

## Relevance to OpenClaw
OpenClaw subagent exec has single-layer timeout (exec timeout parameter). Missing:
- Pipe close watchdog (process can hang scanner indefinitely)
- Independent drain timeout (no "timeout + buffer" pattern)
- Context-aware ping/status check

This pattern explains some of our observed SIGKILL issues: when a subagent's underlying process hangs, the exec timeout kills everything (SIGKILL) instead of gracefully closing pipes first.

## Related
- [[partial-stream-recovery]]: Handles content after connection dies (downstream). This pattern handles when the connection can't die (upstream process hung)
- [[tool-stagnation-detection]]: Detects when an agent is repeating useless actions. This pattern detects when it's not doing anything at all (hung)
- [[write-ahead-session-persistence]]: Protects user input from crashes. This pattern prevents the crash/hang in the first place
