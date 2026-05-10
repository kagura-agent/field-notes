---
title: "MCP vs Native Tools"
created: 2026-05-10
tags: [architecture, agent-tooling, mcp]
---

# MCP vs Native Tools

Two approaches for agent tool integration:

## Native Tools
- Compiled into the agent runtime
- Lower latency, direct function calls
- Tight coupling to agent implementation
- Examples: OpenClaw built-in tools (exec, read, write, message)

## MCP (Model Context Protocol)
- Standardized protocol for tool servers
- Language-agnostic, process-isolated
- Higher latency (IPC/HTTP overhead)
- Easier to develop and distribute independently
- Examples: memex MCP server, browser MCP servers

## Tradeoffs
- **Reliability**: Native tools are more reliable (no serialization bugs, no process crashes)
- **Extensibility**: MCP wins — anyone can write a tool server
- **Performance**: Native wins for high-frequency operations
- **Security**: MCP provides process isolation; native tools share agent memory

## Practical Guidance
- Core operations (file I/O, shell) → native
- Domain-specific capabilities (knowledge base, specialized APIs) → MCP
- When both exist, prefer native unless MCP version adds meaningful capability

See also: [[agent-skill-ecosystem]], [[bash-as-agent-interface]]
