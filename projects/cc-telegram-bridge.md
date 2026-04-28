# CC Telegram Bridge

> **repo**: [cloveric/cc-telegram-bridge](https://github.com/cloveric/cc-telegram-bridge)
> **stars**: 153 (04-28) | **created**: 2026-04-08 | **lang**: TypeScript
> **last push**: 2026-04-28 | **version**: v4.5.3

## What It Is

Native CLI harness that puts real Claude Code and Codex CLI on Telegram — not an API wrapper. Each Telegram bot instance runs the actual CLI binary with native sessions, local files, and real tool use. Supports session resume, voice input, multi-bot instances, and budget control.

## Why It's Interesting

The standout feature is **Agent Bus** — a local HTTP IPC protocol for bot-to-bot communication between instances. This is a concrete, production-tested multi-agent orchestration pattern with structured error handling, retry semantics, and topology awareness.

## Agent Bus Architecture

### Transport
- **Loopback HTTP only** — `POST /api/talk` on localhost
- **Shared-secret auth** — Bearer token when configured
- **Health probes** — `GET /api/health` with fingerprint matching (prevents port reuse spoofing)
- **File-based registry** — `.bus-registry.json` tracks instance ports/PIDs/secrets, mutated under file mutex

### Protocol (v1)
- Envelope: `fromInstance`, `prompt`, `depth`, `protocolVersion`, `capabilities`
- Response: `success`, `text`, `errorCode` (stable string codes), `retryable` flag, `durationMs`
- Backward-compatible: parsers accept legacy unversioned payloads
- 20+ error codes with explicit retryable/terminal classification

### Orchestration Patterns

| Pattern | Command | Description |
|---|---|---|
| **Delegation** | `/ask <instance> <prompt>` | Point-to-point, result inline |
| **Fan-out** | `/fan <prompt>` | Parallel query to current + configured `parallel` peers |
| **Chain** | `/chain <prompt>` | Sequential pipeline, each stage receives previous output |
| **Verify** | `/verify <prompt>` | Execute, then auto-send to designated verifier |
| **Crew** | (config-driven) | Hub-and-spoke coordinator workflow with role assignment |

### Crew Workflow
Fixed hub-and-spoke: coordinator bot manages specialist instances through a predefined pipeline (e.g., `researcher → analyst → writer → reviewer`). Coordinator keeps run state and stage progress. Specialists never talk to each other directly — all context passes through coordinator explicitly. Supports revision rounds.

### Key Design Decisions

1. **Depth tracking** — each hop increments depth counter, `maxDepth` (default 3) prevents loops
2. **Bidirectional peer allowlists** — both sides must explicitly allow each other
3. **Budget enforcement at bus level** — each instance checks its own budget before processing delegated work
4. **Per-turn synthetic chat IDs** — bus turns get negative IDs to distinguish from real Telegram chats
5. **Timeline + audit events** — every bus interaction is logged for observability

## Comparison with OpenClaw ACP

| Aspect | CC Telegram Bridge Bus | OpenClaw ACP |
|---|---|---|
| **Transport** | Local HTTP loopback | stdio/HTTP, can be remote |
| **Discovery** | File registry (.bus-registry.json) | Configured agent list |
| **Auth** | Shared secret | Per-agent config |
| **Scope** | Single-machine multi-bot | Cross-machine, cross-runtime |
| **Orchestration** | Built-in patterns (fan/chain/crew) | Flexible via sessions_spawn |
| **Protocol** | Custom v1 with error codes | ACP standard |
| **Session model** | Each instance has own CLI session | ACP session management |

### What We Can Learn

1. **Structured error codes + retryable flag** — ACP could benefit from standardized error taxonomy instead of treating all failures the same
2. **Topology patterns as first-class** — fan-out, chain, and verify are common enough to deserve named abstractions. Currently in OpenClaw these are ad-hoc subagent patterns
3. **Budget enforcement at delegation boundary** — checking budget before accepting delegated work prevents wasted compute
4. **Health probing with fingerprint** — the fingerprint check on health endpoint prevents stale port reuse from causing phantom connections

## Limitations

- **Single-machine only** — loopback HTTP, no remote delegation
- **Telegram-specific** — deeply coupled to Telegram bot lifecycle
- **Fixed crew workflows** — predefined pipeline stages, not dynamic
- **Two engines only** — Codex and Claude Code, no other runtimes

## Relevance

Related to [[agentic-stack]] (multi-agent coordination), [[agent-session-resume]] (session management across surfaces), and the broader [[thin-harness-fat-skills]] pattern. The Agent Bus is essentially what happens when you need multi-agent but stay on a single machine — a pragmatic middle ground between monolithic and distributed.

The crew workflow pattern maps to OpenClaw's team-lead skill concept, but with a more rigid structure.

---
*Field notes: 2026-04-28, followup deep read*
