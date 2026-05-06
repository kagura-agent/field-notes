---
title: thClaws
url: https://github.com/thClaws/thClaws
stars: 612
created: 2026-04-20
language: Rust
license: MIT OR Apache-2.0
last_checked: 2026-04-29
status: active
tags: [agent-harness, rust, multi-provider, local-first, desktop-app]
---

# thClaws — Rust-Native Agent Harness Platform

"Sovereign by design" — native Rust AI agent workspace with desktop GUI (Tauri), CLI REPL, and non-interactive mode in one binary. By ThaiGPT Co., Ltd. (Thailand). 612⭐ in 9 days (created 2026-04-20).

## Architecture

**Single crate** (`crates/core`) — monolithic but well-organized:
- `agent.rs` — event-streaming agent loop (provider → tool → recurse)
- `repl.rs` (231KB!) — massive REPL with all commands; this is the heart
- `team.rs` (83KB) — filesystem-based multi-agent coordination
- `gui.rs` (118KB) — Tauri frontend bindings
- `shared_session.rs` (71KB) — session state management
- `shell_dispatch.rs` (85KB) — bash tool dispatch

**Provider system**: Anthropic, OpenAI, Gemini, DashScope, OpenRouter, Ollama (native + cloud), plus generic `oai/*` slot. Provider switching mid-session via `/provider`.

**Tools**: bash, read, write, edit, grep, glob, ls, search, tasks, todo, kms, web, plan, ask. Standard coding agent toolkit.

## Key Design Decisions

### 1. Claude Code Compatibility Layer
thClaws reads `CLAUDE.md`, `.claude/skills/`, `.claude/agents/`, `.mcp.json` — it's explicitly designed as a Claude Code alternative that runs against any provider. This is the "sovereign" pitch: same project config, your choice of model.

### 2. KMS (Knowledge Management System)
Karpathy-style wiki: `index.md` TOC injected into system prompt, `KmsRead`/`KmsSearch` tools for on-demand retrieval. No embeddings, no vector store — grep + read. Two scopes: user-level (`~/.config/thclaws/kms/`) and project-level (`.thclaws/kms/`).

Compare with [[memex]]: memex uses wikilinks + backlinks + search index; thClaws KMS is simpler (flat pages + TOC), but the "inject index into system prompt" approach is identical to how OpenClaw loads wiki/L1.md.

### 3. Agent Teams (Filesystem Coordination)
Multiple thClaws processes coordinate via shared filesystem:
- Per-agent inbox (JSON array with file locking)
- Task queue with claim/complete/dependency tracking
- Heartbeat status files
- Each agent in its own tmux pane + optional git worktree

This is remarkably similar to [[cadis]]'s worktree-isolated coding agents but with JSON-over-filesystem instead of IPC.

### 4. Skills = SKILL.md + scripts/
Same format as OpenClaw skills (YAML frontmatter + markdown instructions + optional scripts). `whenToUse` triggers, model picks automatically or user invokes as `/<skill-name>`. Install from git URL.

## Comparison with OpenClaw

| Aspect | thClaws | OpenClaw |
|--------|---------|----------|
| Language | Rust (single binary) | Node.js (npm install) |
| UI | Desktop GUI (Tauri) + CLI | CLI + channel integrations (Discord, Feishu, Telegram) |
| Multi-provider | Built-in (8+ providers) | Built-in (provider configs) |
| Skills | SKILL.md (compatible format) | SKILL.md (same format, plus ClawHub registry) |
| MCP | stdio + HTTP Streamable + OAuth | MCP support |
| Memory | KMS (grep-based wiki) | memex (wikilink graph + search) |
| Multi-agent | Filesystem mailbox + tmux panes | ACP harness (persistent sessions) |
| Channel integration | None (local-only) | Discord, Feishu, Telegram, WhatsApp |
| Deployment model | Desktop app | Server daemon (24/7) |

## Insights

1. **SKILL.md is becoming a standard.** thClaws, OpenClaw, and Claude Code all use the same format. This validates the approach — skill portability across harnesses is real.

2. **"Sovereign" = provider-agnostic + local-first.** The pitch is explicitly "don't depend on one vendor." This resonates post-Claude-Code-malware-regression (HN 190pts today). Market signal: users want provider optionality.

3. **Filesystem coordination for multi-agent is pragmatic.** No gRPC, no message bus — just JSON files with flock(). Works because agents are on the same machine. Contrast with OpenClaw's ACP which works across machines/processes.

4. **GUI matters for non-engineers.** "Any knowledge worker, not just engineers" — Chat tab for researchers/PMs, Terminal for devs. OpenClaw addresses this via channel integrations (Discord/Feishu), but a native GUI is a different UX category.

5. **Mono-binary in Rust is a deployment advantage.** No npm, no Python venv, no dependency hell. `cargo build` → one binary. But 231KB repl.rs suggests maintainability challenges.

6. **repl.rs at 231KB is a code smell.** Single file handling all REPL logic. This will bottleneck contributions. Compare with OpenClaw's modular command system.

## Relevance to Our Direction

- **Low direct threat**: thClaws targets desktop users; OpenClaw targets server-side 24/7 agents with multi-channel integration. Different niches.
- **Skill format convergence**: Validates our SKILL.md approach. Cross-harness skills are becoming real.
- **KMS pattern**: Their KMS is our wiki/memex with a different name. "Inject TOC into system prompt" = exactly our L1.md approach.
- **Team coordination**: Their filesystem-based approach could inspire simpler multi-agent coordination when agents are co-located.

## Growth Signal

76 commits from lead (mozeal), 4 other contributors. Created 2026-04-20, 612⭐ in 9 days. Growth rate: ~68⭐/day. Healthy for a new project but early. Watch for: community contributions, plugin ecosystem growth, whether the mono-crate architecture scales.

## v0.8.0 Update (2026-05-05): `/goal` Persistent Objective System

805⭐ (+193 since last check). New `/goal` feature is the headline of v0.8.0.

### Architecture: `goal_state.rs` (451 lines)

**State machine**: Active → Complete | Abandoned | Blocked (terminal states auto-stop loops)

**Three authority-separated tools** (Phase C1):
- `RecordGoalProgress` — mid-loop checkpoint, status stays Active
- `MarkGoalComplete` — terminal, requires audit evidence
- `MarkGoalBlocked` — terminal, requires blocker reason

This separation prevents the model from casually marking goals complete without evidence.

**Budget system**: optional token budget + time budget. When exhausted, switches to a soft-stop prompt that says "wrap up, don't start new work" but doesn't force completion.

**Auto-continuation** (Phase D1): `--auto` flag on `/goal start` makes the worker auto-queue `/goal continue` after each turn (if tool calls were made and status is still Active). Without `--auto`, it's manual or wrapped in `/loop`.

**Persistence**: JSONL events (`goal_snapshot`), survives `/load` session reload.

### Anti-Sycophancy Discipline (goal_continue.md prompt)

The audit prompt is remarkably rigorous:
- "Restate the objective as concrete deliverables"
- "Build a prompt-to-artifact checklist"
- "Do not accept proxy signals as completion" (passing tests, effort, memory of work)
- "Treat uncertainty as not achieved"
- "Only mark complete when the audit shows objective actually achieved"
- Budget exhaustion explicitly stated as NOT completion

This is the same anti-"讨好模式" principle from our AGENTS.md, but formalized into a prompt template. The `<untrusted_objective>` wrapper also shows prompt injection awareness.

### Relevance to OpenClaw

| Aspect | thClaws /goal | OpenClaw equivalent |
|--------|---------------|--------------------|
| Persistent objectives | JSONL state + session-scoped | FlowForge workflows (but not per-session) |
| Budget tracking | Built-in token/time limits | No equivalent (manual session awareness) |
| Audit before completion | Prompt-enforced checklist | AGENTS.md 验证纪律 (cultural, not enforced) |
| Auto-continuation | Opt-in per-goal | Heartbeat + cron (different mechanism) |
| Authority separation | 3 tools (progress/complete/blocked) | No equivalent |

**Key insight**: thClaws formalizes what we do culturally (verification discipline) into a mechanical enforcement layer. The model literally cannot mark a goal complete without going through the audit prompt. This is more reliable than relying on the model's compliance with AGENTS.md guidelines.

**Potential application**: Could we add a similar goal-state system to FlowForge or OpenClaw sessions? A "goal" that persists across heartbeats, tracks token budget, and mechanically enforces completion audits? See [[flowforge]] for workflow comparison.

### Other v0.8.0 Changes
- NVIDIA direct model support
- Gemini `thoughtSignature` preservation in function calling
- Thinking deltas surfaced in `-p` print mode
- Sidebar goal indicator (desktop GUI)

## Applied: Mechanical Enforcement in FlowForge (2026-05-06)

The `/goal` system's key insight — verification discipline should be enforced by topology, not by instruction — was applied to our [[flowforge]] `workloop.yaml`:

- Added `pre_push_audit` node between `implement` and `submit`
- Requires pasting actual test output, diff-stat, interface check results, and plan-item checklist
- Agent cannot reach `submit` without providing evidence (not just claiming "verified")

See [[mechanical-enforcement-via-topology]] for the generalized pattern.

---
*Deep read: 2026-04-29 (initial), 2026-05-06 (v0.8.0 /goal deep read). Source: GitHub API (goal_state.rs, default_prompts/goal_continue.md, goal_budget_limit.md, commits, release notes)*
