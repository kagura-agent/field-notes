# Agent Isolation

The problem of preventing one agent from accessing resources, state, or credentials belonging to another agent in a shared runtime.

## Why It's Hard

Most agent frameworks start with single-agent assumptions:
- One set of credentials, one workspace, one session
- "Isolation" means separate API calls, not capability boundaries
- Performance and simplicity trade against real isolation

## Isolation Layers (from weakest to strongest)

1. **Software dispatch** — dispatcher checks permissions before routing (e.g., Mirage's `MountMode.READ`). Bypassed by any code execution within the same process.
2. **Per-session mount visibility** — session creation accepts allowed-prefix sets. Soft boundary but explicit attack surface.
3. **Scoped credentials** — each session gets narrower OAuth scopes or scoped API tokens. Requires resource authors to support fine-grained auth.
4. **Process isolation** — separate OS processes per agent with IPC. OS-level capability enforcement.
5. **Container/VM isolation** — Firecracker, gVisor, etc. Strongest but highest overhead.

## Key Insight

The gap between "works in a demo" and "safe for multi-agent" is almost always about isolation. Projects that grow fast on single-agent simplicity hit a wall when multi-agent use cases demand:
- **Filesystem isolation** — COW/overlay per session ([[mirage-vfs]] #16)
- **Credential scoping** — least-privilege per session ([[mirage-vfs]] #17)
- **Cache coherence** — write-through invalidation ([[mirage-vfs]] #18)
- **State portability** — reproducible snapshots including remote state ([[mirage-vfs]] #15)

## Relevance

OpenClaw's model: subagents run in separate sessions with isolated context by default. This is process-level isolation (layer 4). The workspace is shared but subagents can't access each other's session state. For credential isolation, we rely on the gateway's per-account scoping.

See also: [[supervisor-pattern]], [[thin-harness-fat-skills]]
