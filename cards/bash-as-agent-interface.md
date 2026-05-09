---
title: Bash as Agent Interface
tags: [agent-infra, interface-design, mirage, filesystem-metaphor]
created: 2026-05-09
updated: 2026-05-09
---

# Bash as Agent Interface

The hypothesis that **bash/filesystem is the optimal interface for AI agents** — better than typed function APIs, MCP tools, or custom DSLs.

## Core Argument

LLMs are trained on massive amounts of Unix shell content. Bash commands (`cat`, `grep`, `ls`, `cp`, `find`, `jq`) are among the most fluent vocabulary for modern LLMs. Instead of teaching agents new APIs, give them a filesystem abstraction they already know.

## Key Implementation: [[mirage-vfs]]

Mirage (strukto-ai, 1,446⭐ in 3 days) is the leading implementation:
- Mounts heterogeneous services (S3, GitHub, Slack, etc.) as VFS paths
- Implements a **full bash interpreter** in both Python and TypeScript (not shell-out — in-process, sandboxed)
- Session state (env, cwd, arrays, readonly vars, shell options) fully managed in-memory
- Pipes compose across services: `grep alert /slack/general/*.json | wc -l`

The bash interpreter is treated as a first-class component with 5,451+ Python tests and 2,516+ TS tests. Supports parameter expansion, arrays, `set -e`/`pipefail`, `readonly`, function definitions.

## Tradeoffs vs Typed APIs ([[mcp-vs-native-tools]])

| Dimension | Bash/VFS | Typed APIs (MCP, function calling) |
|---|---|---|
| LLM fluency | High (pre-trained) | Medium (requires examples) |
| Composability | Natural (pipes) | Manual (chaining calls) |
| Type safety | None | Strong |
| Write semantics | Awkward (`echo > /slack/general/msg`) | Natural (`send_message()`) |
| Error handling | Exit codes + stderr | Structured errors |
| Discoverability | `ls`, `find` | Schema introspection |

## Counter-argument

Not everything maps cleanly to files. Real-time streams, paginated APIs, write-heavy workflows (send message, create issue) feel shoehorned into file ops. The filesystem metaphor has a ceiling.

## Relevance to OpenClaw

OpenClaw uses typed tool calls (message, exec, etc.) — the opposite end of the spectrum. Mirage's bet is that unifying everything into bash is worth the impedance mismatch. If mirage succeeds, it validates that LLMs don't need MCP — they need good metaphors. If it fails, it validates that typed APIs are worth the learning cost.

Worth watching as a natural experiment in agent interface design.
