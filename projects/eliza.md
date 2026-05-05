# elizaOS/eliza

Agent framework for building AI agents with multi-modal capabilities.

## Overview
- **Language:** TypeScript (Bun/Node)
- **Stars:** 18k+
- **Merge Rate:** 85%
- **Default Branch:** develop
- **Package Manager:** bun
- **Test Framework:** vitest
- **Monorepo:** Yes — packages/, plugins/, apps/

## First PR
- **PR #7382**: fix(orchestrator): pre-seed bypassPermissionsAcknowledged to prevent PTY exit 1
- **Issue #7365**: PTY subprocess exits 1 on unhandled "Bypass Permissions confirmation" dialog
- **Status:** Pending review (CI passing)
- **Relationship:** new (first PR, disclosure included)

## Architecture Notes
- `plugins/plugin-agent-orchestrator/` — core agent orchestration logic
  - `pty-service.ts` — PTY session lifecycle, trust seeding, spawn management
  - `pty-auto-response.ts` — regex-based auto-response rules for blocking prompts
  - `pty-spawn.ts` — spawn config builder
  - `swarm-coordinator.ts` — multi-agent task coordination
  - `swarm-decision-loop.ts` — decision handling for blocked/idle sessions
  - `swarm-idle-watchdog.ts` — idle session detection
- `coding-agent-adapters` (external pkg) — adapter layer for Claude/Codex/Gemini/Aider
- `pty-manager` (external pkg) — PTY process management, worker-level prompt detection
- Three-layer defense for blocking prompts:
  1. Pre-seeding config (prevents dialog from showing)
  2. Auto-response rules (regex-based pattern matching on PTY output)
  3. Swarm decision loop (event-based prompt handling)
- `skipAdapterAutoResponse: true` disables layer-2 for coordinator-managed sessions

## Key Patterns
- Coordinator-managed sessions skip adapter auto-response (direct LLM supervision)
- `~/.claude.json` is the central config file for Claude Code:
  - `projects[workdir].hasTrustDialogAccepted` — workspace trust (per-workdir)
  - `bypassPermissionsAcknowledged` — skip permissions dialog (global)
- Write queue (`claudeConfigWriteQueue`) serializes concurrent config writes

## PR Template
Uses detailed PR template — must include: Relates to, Risks, Background (what/why/kind), Testing.

## CI/Lint
- CI: label-pr + label-issue (fast, passes in seconds)
- CodeRabbit: present but skipped review on my PR
- No changeset required

## Maintenance Notes
- Very active repo (commits daily)
- Large codebase (15k+ files)
- bun required for full build/test
- Shallow clone recommended (repo is huge)
- Tests require full `bun install` at root (monorepo workspace resolution)

## Next Time
- If need to run tests locally: `bun install` at root first (takes time)
- Watch for interaction between pty-manager's default prompt handling and orchestrator rules
- The `skipAdapterAutoResponse` flag is key to understanding which layer handles prompts
