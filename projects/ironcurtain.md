---
title: IronCurtain
url: https://github.com/provos/ironcurtain
stars: 391
created: 2026-02-21
last_updated: 2026-05-11
depth: 🔭 scout
status: active
last_verified: 2026-05-11
---

# IronCurtain — Constitutional Security for AI Agents

Apache-2.0, 391⭐, 50 forks, by provos (likely Niels Provos, security researcher). Research prototype, very active (pushing daily).

## Core Idea

**"Agent is untrusted"** as design principle. Security doesn't depend on the model "being good."

Plain-English constitution → LLM-compiled to deterministic rules → validated against test scenarios → enforced at runtime on every tool call. No LLM involvement at enforcement time.

## Architecture

Two execution modes:
1. **Builtin Agent (Code Mode)** — TypeScript in V8 isolate, no direct host access. All tool calls exit as structured MCP requests through policy engine.
2. **Docker Agent Mode** — External agent (Claude Code, Goose, etc.) in Docker container. TLS-terminating MITM proxy for LLM calls (host allowlist, key swap). MCP tool calls through policy engine. Registry proxy for package installs.

Policy engine decisions: **allow / deny / escalate** (to user for approval).

## Key Innovation: Semantic Interposition

All agent interactions go through MCP servers (filesystem, git, etc.). Every tool call passes through the policy engine. This means:
- No raw system access — all actions are semantically meaningful
- Policy can reason about intent, not just syscalls
- Escalation is contextual (e.g., "git push" escalates, "git status" doesn't)

## Smart Approval

Auto-approver concept: user's trusted input from "command mode" (Ctrl-A) provides clear intent, so some escalated actions can be auto-approved. Reduces approval fatigue without reducing security.

## Relevance to OpenClaw

OpenClaw has a simpler approval model (native approvals for elevated commands). IronCurtain's approach is more principled:
- **Constitution-based**: Security intent expressed in English, not code
- **MCP-mediated**: All tool calls are structured, auditable, policy-checkable
- **No ambient authority**: Agent never inherits user privileges directly

The "compile English intent to deterministic rules" pattern could inspire improvements to OpenClaw's permission system.

## Related
- [[opensandbox]] — Alibaba's sandbox approach (container-level isolation)
- [[poco-claw]] — competitor that also sandboxes agents in Docker
- [[self-evolving-agent-landscape]] — security layer for autonomous agents
