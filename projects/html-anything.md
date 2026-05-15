---
title: html-anything (nexu-io)
status: active
created: 2026-05-15
updated: 2026-05-15
stars: 831
url: https://github.com/nexu-io/html-anything
last_verified: 2026-05-15
---

# html-anything — Agentic HTML Editor

**What**: Local-first HTML editor that uses your existing coding agent CLI (8 supported: Claude Code, Cursor Agent, Codex, Gemini CLI, Copilot CLI, OpenCode, Qwen Coder, Aider) to turn any input (Markdown/CSV/JSON/SQL) into ship-ready single-file HTML across 9 "surface" types.

**Why now**: Claude Code team publicly stopped using Markdown for internal docs — HTML is the final output format for human readers. This project operationalizes that shift.

## Architecture — Skill-Surface Matrix

The core insight is decomposing agent-driven content generation into two orthogonal axes:

- **75 Skills** = visual design system + layout pool + prompt constraints (each is a `SKILL.md` with frontmatter + detailed instructions)
- **9 Surfaces** = output format/purpose (magazine article, keynote deck, résumé, poster, Xiaohongshu card, tweet card, web prototype, data report, Hyperframes video)

Skills are folder-based (`src/lib/templates/skills/<id>/SKILL.md + example.md + example.html`). Adding a skill = adding a folder, zero code change. The loader scans disk at runtime.

### Skill Protocol

Each `SKILL.md` follows a standardized structure:
- **Frontmatter**: `name`, `category`, `scenario`, `featured`, `recommended`, `tags`, `aspect_hint`, example metadata
- **Body**: Detailed prompt instructions — color palettes, layout specifications, typography rules, design constraints

A `SHARED_DESIGN_DIRECTIVES` module prepends global rules to every skill's prompt. The `assemblePrompt()` function composes: `shared_directives + skill_body + user_content`.

### Key Design Decisions

1. **Content-drives-quantity**: Templates define a *layout pool* (reusable), not a page count. This was a hard-won lesson — Issue #1 fixed a bug where numeric hints in skills were being read as hard caps.

2. **Agent-agnostic via protocol abstraction**: Three invocation protocols:
   - `stdin` — pipe prompt to stdin, parse ndjson stdout (Claude, Cursor, Gemini, Copilot, Qwen, Aider)
   - `argv` — prompt as positional arg (DeepSeek)
   - `argv-message` — prompt via `--message` flag, single JSON stdout (OpenClaw!)
   - `acp` / `pi-rpc` — planned but not yet implemented

3. **Zero API key**: Reuses the agent CLI's existing auth session. Marginal cost = $0.

4. **Sandboxed preview**: iframe with `allow-scripts allow-same-origin` — user HTML runs isolated from host.

## Relationship to Our Ecosystem

- **OpenClaw is a first-class agent** in html-anything's detection registry! They specifically support `openclaw agent --message` protocol. This means OpenClaw users can use html-anything out of the box.
- Built on [[open-design]] (same team, 40k⭐) — mirrors its daemon skill architecture.

## Relation to [[skill-ecosystem]]

html-anything's SKILL.md protocol is similar to but distinct from [[claude-code-skills-ecosystem]]:
- **Same**: File-based, folder-per-skill, frontmatter metadata
- **Different**: Skills here are pure prompt templates (no code execution), designed for a specific domain (HTML generation), with rich design-system constraints

The "scenario" taxonomy (marketing, engineering, product, etc.) is another approach to [[functional-area-resolver]] — organizing skills by business domain rather than capability type.

## Anti-Patterns Observed (from Issues)

- Agent binary detection fails when PATH doesn't include common install dirs (#hallestar)
- Streaming display can get stuck showing "generating" even after HTML is produced (#qtwaiter)
- Some agents output conversation text instead of raw HTML (#fcityboy)

## Verdict

**Track-worthy**. 831⭐ in 4 days = genuine breakout. The skill-surface matrix is a reusable architecture pattern. OpenClaw integration is a bonus.

Revisit 05-22 — check if growth sustains, community forms, or if it's a one-week spike.
