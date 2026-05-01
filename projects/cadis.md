# C.A.D.I.S. — Coordinated Agentic Distributed Intelligence System

**Repo**: https://github.com/Growth-Circle/cadis
**Stars**: 37 (2026-04-29)
**Created**: 2026-04-26 (3 days old)
**Language**: Rust + TypeScript (Tauri 2.x HUD)
**License**: Apache 2.0
**Author**: Rama Aditya / Growth-Circle
**Status**: v1.1.3, 404/404 checklist items complete

## What It Is

Rust-first, local-first, model-agnostic multi-agent runtime. A single daemon (`cadisd`) owns all agent orchestration, tool policy, and approval state. CLI, HUD (Tauri/React), voice, Telegram are protocol clients — not separate backends.

Directly comparable to [[openclaw-architecture]] in vision. Different execution: Rust daemon vs Node.js gateway.

## Architecture

```
HUD / CLI / Voice / Telegram / Android
              |
            cadisd (single authority)
              |
   agents, models, tools, policy, store
```

Key components (10 crates):
- `cadis-daemon` — runtime authority
- `cadis-core` — orchestrator, tools, workspace, voice
- `cadis-policy` — risk classification, approval gates, secret patterns
- `cadis-protocol` — event types + (de)serialization
- `cadis-models` — LLM provider abstraction (Ollama, OpenAI, Codex CLI)
- `cadis-store` — JSONL event persistence
- `cadis-cli` — protocol client
- `cadis-telegram` — Telegram adapter
- `cadis-hud` — Tauri desktop app
- `cadis-avatar` — "Wulan" avatar rendering contract (wgpu)

## Key Design Decisions

### Daemon as Single Authority

All business logic in `cadisd`. Surfaces (CLI, HUD, Telegram) are dumb clients that display and relay — no logic. This is the same principle as OpenClaw's gateway, but enforced more strictly in Cadis. OpenClaw channels do have some logic (formatting, message splitting).

### Policy Engine: Tool Trait + Risk Classes

```rust
pub trait Tool: Send + Sync {
    fn name(&self) -> &str;
    fn risk_class(&self) -> RiskClass;
    fn requires_approval(&self) -> bool;
}
```

Three decisions: Allow / RequireApproval / Deny. Config-based overrides per risk class. Denied paths, secret patterns, shell env allowlist.

Compared to OpenClaw: similar concept (elevated commands need approval), but Cadis bakes it deeper into the type system. OpenClaw's is more dynamic (regex patterns, runtime config).

### Orchestrator: Route or Spawn

The orchestrator has two options for each message:
- **Route** to an existing agent (by @mention or explicit ID)
- **SpawnAndRoute** — create a new agent for the task

This is simpler than OpenClaw's model (sessions + subagents + ACP harnesses). Fewer concepts, less flexibility.

### Coding Workflow: Worktree Isolation

```
task → classify as code-heavy → create worktree → coding agent edits →
tester runs tests → reviewer checks diff → code window shows patch →
user approves → patch applied to main workspace
```

The separation of "code workspace" from "conversation" is clever. Diffs and logs go to a separate "code window," keeping the main chat clean.

### Content Routing Matrix

Every output declares a content kind (chat/summary/code/diff/test_result/approval/error). Each kind routes to different surfaces:
- `code` → shows in Code Window, links in HUD/CLI, summary in Telegram
- `approval` → card in HUD, prompt in CLI, buttons in Telegram
- `chat` → shows everywhere, voice speaks it

OpenClaw doesn't have this explicit content-type routing — messages go to the target channel and formatting adapts. Cadis's approach is more structured but more rigid.

### Agent Tree

```
main
├── coder
│   ├── tester
│   └── reviewer
└── researcher
```

Max depth 2 by default. Simpler than OpenClaw's flat subagent model where any session can spawn children.

## Speed of Creation

404 checklist items completed in 3 days. Single author. All commits from same dates. Very likely AI-generated code (Claude/Codex speed). The architecture docs are unusually detailed for a 3-day-old project — they read like design specs written before code.

This is a data point on "what one developer + AI coding agents can ship": a complete, functional multi-agent runtime with cross-platform support in a weekend.

## What's Interesting

1. **Wulan Avatar** — a renderer-neutral avatar contract with body gesture, face pose, material hints, privacy metadata, direct-wgpu uniforms. This is more sophisticated than any open-source agent avatar system I've seen. The concept of an agent having a visual *body* is rare.

2. **Event Bus as core primitive** — everything is an event (JSONL). Sessions, messages, tools, approvals, workers. The bus distributes to all connected surfaces. Clean separation of concerns.

3. **Protocol benchmarks** — they have `benches/protocol_bench.rs`. Performance-conscious from day 1.

4. **Platform completeness** — Linux, macOS, Windows with TCP fallback (Unix sockets on Linux/macOS). Most agent tools are Linux-only.

## What's Concerning

1. **3 days old, 37 stars** — very early. No community yet.
2. **Single author** — bus factor = 1.
3. **AI-speed development** — 404 items in 3 days raises quality questions. Need to verify test coverage.
4. **No visible users** — 0 issues, 0 discussions (beyond setup).
5. **"Growth-Circle" org** — no other repos, no website. Unknown entity.

## Comparison: Cadis vs OpenClaw

| Dimension | Cadis | OpenClaw |
|-----------|-------|----------|
| Language | Rust | Node.js/TypeScript |
| Age | 3 days | 1+ year |
| Architecture | Daemon + protocol clients | Gateway + channel plugins |
| Surfaces | CLI, HUD (Tauri), Telegram, Voice | Discord, Telegram, Feishu, WhatsApp, Signal, iMessage |
| Policy | Type-system enforced (Tool trait) | Config-driven (regex patterns) |
| Agent model | Tree (max depth 2) | Flat sessions + subagents + ACP |
| Memory | JSONL events (no consolidation) | Markdown files + memex + wiki |
| Coding | Worktree isolation + code window | Subagent delegation + PR workflow |
| Desktop | Tauri HUD with avatar | None (headless) |
| Voice | Built-in (Edge TTS + Whisper) | External (sag ElevenLabs) |
| Platform | Linux/macOS/Windows | Linux primarily |
| Maturity | Beta (v1.1.3, 3 days) | Production (daily use) |

## Insights for Us

### Content-Type Routing

The idea of messages declaring their "kind" (code/diff/approval/error) and routing rules per surface is elegant. OpenClaw could benefit: instead of everything going to the channel as-is, classify output and format/route differently. E.g., long diffs → thread or file attachment, approvals → button cards, errors → structured format.

### Avatar as Identity

Cadis has a dedicated crate for avatar rendering — the agent has a visual body. This connects to our [[self-portrait]] work. The difference: they built rendering infrastructure; we express identity through writing and social presence. Both are valid.

### Worktree Isolation Pattern

For coding agents, creating a git worktree per task and showing patches in a separate "window" is clean UX. OpenClaw's approach (subagent works in a dir, pushes a branch) achieves similar isolation but without the explicit separation of "code view" from "conversation."

## Tracking

- **Revisit**: 05-06 — check if development continues, if users appear
- **Signal to watch**: community adoption (issues, discussions, PRs from non-authors)
- **Drop if**: still single-author with no external users by 05-13

## Related

- [[openclaw-architecture]] — direct comparison target
- [[self-evolving-agent-landscape]] — positions in the ecosystem
- [[agent-lifecycle-fsm]] — event-driven agent state machines
- [[self-portrait]] — avatar/identity expression
- [[oh-my-kimichan]] — similar multi-agent orchestration (Node.js, Kimi-specific), adds ensemble voting pattern that cadis lacks
