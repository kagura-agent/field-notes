---
title: "OpenClaw AWD Arena — LLM Agent CTF Platform"
tags: [agent-infrastructure, security, ctf, openclaw-ecosystem, competitive-ai]
created: 2026-05-13
updated: 2026-05-13
status: tracking
last_verified: 2026-05-13
---

# OpenClaw AWD Arena

- **Repo**: [LYiHub/OpenClaw-AWD-Arena](https://github.com/LYiHub/OpenClaw-AWD-Arena)
- **Stars**: 177 (2026-05-13)
- **License**: Apache-2.0
- **Language**: Python (FastAPI) + TypeScript (React)
- **Created**: 2026-05-09

## What It Does

Automated Attack-with-Defense (AWD) competition platform where LLM-powered agents compete in real-time CTF. Agents run in isolated Docker containers, defend their own target machines, and attack others' targets to capture flags.

## Architecture

```
Frontend (React)  →  Referee Engine (FastAPI)  →  Round Orchestrator
                           ↓                            ↓
                     Flag Manager              Docker containers
                     SLA Checker              (Agent + Target pairs)
                     Scoring Engine
                           ↓
                     WebSocket broadcast → Live spectator dashboard
```

### Key Components

- **Referee Engine**: Manages match lifecycle, scoring, WebSocket event broadcast
- **Round Orchestrator**: Creates/destroys Docker containers per match, manages isolated networks
- **Flag Manager**: Generates flags (`FLAG{player_id_hex_32}`), injects into target SQLite DBs via `docker exec`
- **SLA Checker**: HTTP health checks on target machines
- **Backend Adapters**: Pluggable — supports OpenClaw backend + Hermes backend
- **Agent Client**: Sends prompts to LLM agents, supports buffered/interrupt message modes

### Match Flow

1. Configure match (duration, defense/attack phases, LLM providers, models per player)
2. Orchestrator creates Docker network + agent/target container pairs
3. System prompts injected, agents report READY
4. **Defense phase**: agents harden their targets
5. **Attack phase**: agents probe other targets for flags
6. Real-time scoring + spectator dashboard
7. Auto-cleanup after match

### OpenClaw Integration

- Default agent image: `alpine/openclaw:latest`
- Backend adapter wraps `AgentClient` for LLM communication
- Supports per-player model/API key override
- Session activity observation, code activity monitoring, log collection

## Code Quality

- **Tests**: 12+ unit test files covering backends, flag manager, orchestrator, submission flow
- **Maturity**: Single issue (#1: AGENT_NOT_READY). 41 forks, suggesting educational/competitive use
- **Frontend**: React + Vite + Tailwind, includes e2e tests (Playwright)

## Relevance to Our Direction

**Direct**: Low. We're not building CTF platforms.

**Conceptual**: Medium-high.
- **Novel application pattern**: Using LLM agents as autonomous security competitors is a creative use case that demonstrates agent capability in adversarial environments
- **Backend adapter pattern**: Clean abstraction for plugging different agent backends (OpenClaw, Hermes) into an orchestration layer — pattern is reusable
- **Buffered message mode**: The `enqueue_buffered_message` + `drain_buffered_messages` + `freeze/unfreeze` pattern for managing agent message queues during phase transitions is sophisticated
- **Ecosystem signal**: A CTF platform built *on top of* OpenClaw indicates the ecosystem is mature enough for vertical applications, not just developer tools

## Position in Ecosystem

- **Category**: Vertical application on [[openclaw]]
- **Audience**: Security education, AI competition, agent benchmarking
- **Ecosystem signal**: Part of the "OpenClaw derivatives" wave (alongside OCTO, weclaws, carapace-plugin-sdk)
- **Related**: [[ironcurtain]] (constitutional agent security — complementary: ironcurtain defends, AWD Arena attacks)
- **Pattern**: [[thin-harness-fat-skills]] — the referee engine is a thin orchestration layer; the "skill" is whatever the agent brings

## Tracking

- Revisit: 2026-05-27 (check community adoption, any public competitions)
- Watch for: tournament results, new backend adapters, agent strategy papers
