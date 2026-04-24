# Pluggable Sandbox Provider

Agent framework pattern where code execution environments are abstracted behind a common interface, allowing users to swap providers without changing application code.

## Pattern

```
MastraSandbox (base class)
├── LocalSandbox (host machine, execa)
├── DockerSandbox (containers)
├── E2BSandbox (cloud, E2B API)
├── BlaxelSandbox (cloud, Blaxel API)
├── DaytonaSandbox (cloud, Daytona API)
└── ModalSandbox (cloud, Modal API) ← 2026-04-23
```

**Core interface**: `start()`, `stop()`, `destroy()`, `executeCommand()`, `getInfo()`

**Key abstractions**:
- `SandboxProcessManager` — spawn/list/kill processes, each provider wraps its SDK's exec API
- `ProcessHandle` — stdout/stderr streaming, wait(), kill(), exitCode
- `MountManager` — file/dir mounts into sandbox (auto-created if subclass implements mount)
- Lifecycle hooks (onStart/onStop/onDestroy) for user-land setup/teardown

## Why It Matters

Sandbox is becoming a **standard layer** in agent frameworks (not a differentiator). The competitive advantage moved from "having a sandbox" to "which sandbox fits your constraints" (cost, latency, features).

Each provider has unique capabilities:
- **E2B**: Purpose-built for AI, fast spin-up
- **Modal**: Filesystem snapshots for stop-and-resume, good scale
- **Docker**: Self-hosted, no cloud dependency
- **Daytona**: Dev environment focus
- **Local**: Zero overhead, testing

## Design Insights

1. **Provider = npm package**: `@mastra/modal`, `@mastra/e2b` — users install only what they need
2. **Base class handles race conditions**: Lifecycle wrappers prevent concurrent start/stop conflicts
3. **ProcessManager decoupling**: Even within one provider, process management is a separate abstraction
4. **Kill semantics vary**: Modal can only cancel local stream readers (remote process continues). Docker/Local can SIGKILL. E2B can terminate. Framework must tolerate these differences
5. **Dead-sandbox retry**: Cloud sandboxes die unexpectedly. The retry-once pattern (detect dead → restart → retry) is simple and effective

## Tradeoffs

- **Lowest-common-denominator API**: stdin not supported on Modal. Filesystem snapshots only on Modal. Provider-specific features leak through `.modal` / `.e2b` escape hatches
- **Test complexity**: Each provider needs its own mock strategy (SDK-level mocking)
- **Not all providers support mounts equally**: Local mounts vs cloud file sync have very different performance characteristics

Links: [[e2b]], [[mastra]], [[openclaw-architecture]], [[coding-agent-ecosystem]]
