# Gitclaw — Git-Native Agent Framework

**Repo:** open-gitagent/gitclaw | **Stars:** 166 | **Created:** 2026-03-04 | **Language:** TypeScript

## What It Is
A framework where the agent IS a git repo. Identity, rules, memory, tools, skills — all version-controlled files.

## Core Architecture
- `agent.yaml` — model, tools, runtime config
- `SOUL.md` — personality and identity
- `RULES.md` — behavioral constraints
- `memory/` — git-committed memory with full history
- `tools/` — declarative YAML tool definitions
- `skills/` — composable skill modules
- `hooks/` — lifecycle hooks

## Why It Matters
This is essentially what we're doing with OpenClaw + dna repo, but as a first-class design principle rather than an emergent pattern. The key insight: **fork an agent, branch a personality, git log your memory, diff your rules.**

## Comparison with Our Setup
| Aspect | Gitclaw | Our Setup (OpenClaw) |
|--------|---------|---------------------|
| Identity files | SOUL.md, RULES.md | SOUL.md, AGENTS.md, IDENTITY.md |
| Memory | git-committed memory/ | local memory/ (not in dna repo) |
| Version control | Core design principle | Emergent/partial |
| Tool definitions | Declarative YAML | Skills via SKILL.md |
| Runtime | Standalone | OpenClaw gateway |

## Insight
Gitclaw makes explicit what we discovered organically: agent identity should be version-controlled. But they go further — memory is also version-controlled, which gives you `git log` on an agent's memory. We deliberately separated memory from DNA, but their approach has merit for auditability.

## Relevance to Agent Identity Protocol
If agent identity lives in git, then contribution history is already there via `git log`. This validates our direction — git as the source of truth for agent identity.

---
*First noted: 2026-03-22*
