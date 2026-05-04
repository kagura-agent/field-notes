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

Links: [[clawhub]], [[skill-ecosystem]], [[agentskills-io-standard]], [[claude-code-skills-ecosystem]]

*First noted: 2026-05-01. Wiki note: 2026-05-03.*

---

## Update 2026-05-04: v0.0.5 Deep Read

**Stars**: 388 (+22 in 2 days, accelerating)

### PEP 832 Support (PR #55)

`.venv` can now be a **file** (not just a directory) containing a path to the real venv. This enables centralized/shared venvs without polluting the project tree. `_venv_from_dot_venv()` checks: is `.venv` a dir? → use it. Is it a file? → read first line as redirect path, resolve, verify `pyvenv.cfg` exists.

### Architecture Insights (from code read)

**Scanner dual-path design:**
1. Primary: Parse `.dist-info/RECORD` (CSV) → grep for `.agents/skills/*/SKILL.md` entries
2. Fallback: For editable installs, read `direct_url.json` → find source root → rglob for skill files
3. Node: Simply glob `node_modules/*/` and `node_modules/@*/*/` for `.agents/skills/*/SKILL.md`

**Skill validation is strict:**
- Name must match `^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$`, no double-hyphens
- Name MUST equal parent directory name
- Description required, max 1024 chars
- YAML frontmatter required (no frontmatter = skip)

**Dual install targets:**
- `.agents/skills/` — universal (agentskills.io standard)
- `.claude/skills/` — Claude-compatible (opt-in via `--include-claude`)

This dual-target pattern means library-skills is positioning as the **bridge** between agentskills.io convention and vendor-specific skill directories.

**TypeScript SDK is a 1:1 mirror** — same logic in `ts/src/`, scanning both Python site-packages AND node_modules from either runtime. Cross-ecosystem discovery.

### Growth Signal

- FastAPI/Streamlit already ship built-in agent skills
- 388⭐ in ~1 week from launch with only tiangolo's network effect
- npx + uvx dual-entry means zero friction from either ecosystem
- If this hits 1k+ stars, it becomes the de facto standard for library-embedded skills

### Relevance to OpenClaw

1. **ClawHub integration opportunity**: `clawhub scan` could discover library-embedded skills the same way — scan site-packages/node_modules
2. **Skill format alignment**: Our SKILL.md format already matches their validation rules (name, description, frontmatter). Zero adaptation needed.
3. **Dual-target lesson**: If `.claude/skills/` becomes standard, OpenClaw skills should also emit to it for discoverability by Claude Code users
4. **Symlink-first install**: Elegant for version sync. ClawHub could adopt this for local skills that are pip/npm-installed.

### Followup Questions
- Will agentskills.io become a formal standard or stay FastAPI-ecosystem?
- How will this interact with Claude Code's native skill discovery?
- What happens when two dependencies ship conflicting skill names?
