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

---
*Deep read: 2026-04-29. Source: GitHub API (README, src/ tree, agent.rs, team.rs, kms.rs, skills.rs headers)*
