---
title: library-skills (tiangolo)
type: project
created: 2026-05-03
updated: 2026-05-03
status: tracking
stars: 366
---

# library-skills

**Repo**: [tiangolo/library-skills](https://github.com/tiangolo/library-skills)
**Author**: Sebastián Ramírez (FastAPI creator)
**Stars**: 366 (2026-05-03)
**Language**: Python + Node

## What It Does

Library-embedded AI skill distribution. Instead of a central skill registry, library authors embed AI skills in their packages. `library-skills` CLI:

1. Scans project dependencies
2. Discovers skills embedded in installed libraries
3. Installs them as symlinks in `.agents/` directory
4. Skills auto-update when libraries are updated

Supports Python (`uvx library-skills`) and Node (`npx library-skills`).

## Key Insight: Distribution Model

Two emerging models for agent skill distribution:

| | Central Registry (ClawHub) | Library-Embedded (library-skills) |
|---|---|---|
| **Discovery** | Search registry | Scan dependencies |
| **Updates** | Manual update | Auto with library |
| **Scope** | Any skill | Library-specific skills |
| **Authority** | Registry curation | Library author |
| **Install** | `clawhub install` | `uvx library-skills` |

These are **complementary**, not competing. ClawHub for standalone/cross-cutting skills, library-skills for library-specific guidance.

## Convention

References [agentskills.io](https://agentskills.io) — a standard for where/how libraries embed skills. FastAPI and Streamlit already ship built-in agent skills.

## Relevance to OpenClaw

- ClawHub could support library-embedded discovery as an additional source
- The symlink-based install is elegant for version sync
- agentskills.io convention could be adopted by OpenClaw skill creators

Links: [[clawhub]], [[skill-ecosystem]], [[agentskills-io-standard]]

*First noted: 2026-05-01. Wiki note: 2026-05-03.*
