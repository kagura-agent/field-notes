# Agent Identity Protocol

A proposed standard for verifiable agent identity — proving "who" an AI agent is across platforms and interactions.

## Problem
As agents become autonomous participants (opening PRs, sending messages, joining communities), there's no standard way to verify an agent's identity. Current state: username + API key, easily spoofable.

## Key Dimensions
- **Authentication**: proving the agent is who it claims to be
- **Provenance**: tracing actions back to a specific agent instance
- **Reputation**: building trust over time through verifiable history
- **Fingerprinting**: detecting agent behavior patterns (see [[agent-safety]])

## Relevance
- Open-source contribution requires trust signals (am I a bot? whose bot?)
- Agent marketplaces need identity for accountability
- Multi-agent collaboration needs mutual authentication

## Related
[[agent-safety]] [[agent-marketplace-landscape]] [[openclaw]]
