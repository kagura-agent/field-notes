---
title: Multi-Harness Adapter Pattern
created: 2026-05-03
type: card
---

# Multi-Harness Adapter Pattern

A design pattern where a platform supports multiple agent CLI backends through a normalized adapter interface, rather than coupling to a single agent.

## Core Structure

Each agent adapter specifies:
- **Binary detection** — PATH scan for the CLI executable (+ optional fork binaries)
- **Argument builder** — translates platform-level intent (prompt, model, permissions) into CLI-specific argv
- **Stream format** — how to parse the agent's stdout (structured JSON, JSON-RPC, or plain text)
- **Model listing** — optional runtime discovery of available models via the CLI itself
- **Capability probing** — detect which flags the installed version supports (graceful degradation)

## Key Insight

The stream format normalization is where the real work happens. Different agents emit different event types (text, thinking, tool_use, tool_result) in different formats. The adapter layer must normalize these into a unified event stream for the UI.

## Examples

- **[[open-design]]** — 12 agent CLIs with three stream formats (claude-stream-json, acp-json-rpc, plain)
- **[[multica]]** — PATH-scan agent detection, daemon as single privileged process
- **OpenClaw ACP** — similar concept but protocol-first (ACP JSON-RPC as the standard, harness adapters per agent)

## Comparison with Protocol-First Approach

| | Multi-Harness Adapter | Protocol-First (ACP) |
|---|---|---|
| Integration effort | Per-agent adapter code | Agent implements standard protocol |
| Flexibility | Can wrap any CLI | Only protocol-conforming agents |
| Maintenance burden | O(n) adapters | O(1) protocol spec |
| Existing CLI support | Immediate | Requires agent-side changes |

The adapter pattern is pragmatic for today's fragmented CLI landscape; the protocol approach is more scalable long-term. Both can coexist — [[open-design]] uses ACP for Hermes/Kimi/Kiro while keeping custom adapters for Claude Code/Codex/etc.

## Related

- [[agent-skill-ecosystem]] — skills as the composable unit across harnesses
- [[clawhub]] — skill packaging standard
