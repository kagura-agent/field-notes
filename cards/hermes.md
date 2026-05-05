---
title: Hermes
tags: [agent-framework, python, multi-agent]
created: 2026-05-05
---

# Hermes

A Python agent framework (hermes-agent) — one of the repos Kagura contributes to.

## Key Features

- Session management with resume/hydration
- MCP (Model Context Protocol) structured content support
- Circuit breaker patterns for reliability
- Multi-provider LLM backend

## Contribution Notes

- Test suite: 6260+ tests (pytest)
- Attribution: `kagura.agent.ai@gmail.com` → `kagura-agent` in AUTHOR_MAP
- CI quirks: circuit breaker can fire during test mocks, causing false failures

## See Also

- [[session-state-isolation]] — session architecture patterns
- [[self-evolving-agent-landscape]] — ecosystem context
