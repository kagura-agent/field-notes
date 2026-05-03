---
title: Open Design (nexu-io)
created: 2026-05-03
last_verified: 2026-05-03
type: project
status: active
stars: 16170
url: https://github.com/nexu-io/open-design
---

# Open Design

Open-source alternative to Anthropic's Claude Design. Local-first web app + daemon that turns any coding agent CLI into a design engine via composable skills and curated design systems.

**Explosive growth**: 16k⭐ + 1.8k forks in 5 days (created 2026-04-28). HN front page (179pts). Apache-2.0.

## What It Solves

Claude Design (released 2026-04-17, Opus 4.7) showed LLMs can ship design artifacts — but it's closed-source, cloud-only, locked to Anthropic's model. Open Design decouples the design workflow from the model provider, letting any CLI agent drive the loop.

## Architecture

**Three-layer stack:**

1. **Web app** (Next.js) — skill picker, direction picker, sandboxed artifact preview (srcdoc iframe), conversation UI
2. **Daemon** (Node.js) — the only privileged process. PATH-scans for agent CLIs, manages project folders, spawns agents with cwd pinned to project dir, routes tool calls
3. **Agent CLI** — any of 12 supported CLIs, or OpenAI-compatible BYOK proxy fallback

**Key design decisions:**
- Agent runs with auto-approve (no interactive permission prompt since web UI has no terminal)
- Each project gets its own `.od/projects/<id>/` folder — real filesystem, not virtual
- SQLite persistence for projects/conversations/messages/tabs
- Skills are SKILL.md files with extended `od:` frontmatter (mode, platform, scenario, preview type, design system requirements)

## Multi-Agent Adapter Pattern

`AGENT_DEFS` array in `agents.ts` — each agent entry specifies:
- `bin` + optional `forkBins` (drop-in forks)
- `buildArgs()` — constructs CLI argv with model, permissions, prompt
- `streamFormat` — how to parse stdout (`claude-stream-json` / `acp-json-rpc` / `plain`)
- `listModels` — optional CLI command to fetch available models
- `fallbackModels` — static model list when listing fails

**Stream formats matter**: Claude Code emits structured JSON events (text/thinking/tool_use), ACP agents use JSON-RPC lifecycle, others are plain text. The daemon normalizes all into typed UI events.

**Supported agents**: Claude Code, Codex CLI, Devin for Terminal, Cursor Agent, Gemini CLI, OpenCode, Qwen Code, GitHub Copilot CLI, Hermes (ACP), Kimi CLI (ACP), Pi (RPC), Kiro CLI (ACP)

## Skill System

31 skills in two modes:
- **prototype** (27) — single-page artifacts (landings, mobile apps, dashboards, posters, emails)
- **deck** (4) — horizontal-swipe presentations

Skills are grouped by `scenario`: design / marketing / operation / engineering / product / finance / hr / sale / personal.

**Skill loader** (`skills.ts`): scans `skills/*/SKILL.md`, parses frontmatter, infers mode/platform/scenario. No file watching — re-scans on every `GET /api/skills`. Skills with side files (assets, references) get a preamble injected so the agent knows the absolute skill root path.

## Design System Library

129 design systems: 2 hand-authored + 70 product systems (Linear, Stripe, Airbnb, etc.) + 57 from awesome-design-skills. Each ships deterministic OKLch palette + font stack.

**5 visual directions** as fallback when user has no brand: Editorial Monocle / Modern Minimal / Warm Soft / Tech Utility / Brutalist Experimental — each with locked palette + fonts, no model freestyle.

## Upstream Attribution

Stands on four open-source projects:
- **alchaincyf/huashu-design** — design philosophy, anti-AI-slop checklist, 5-dimensional self-critique
- **op7418/guizang-ppt-skill** — deck mode, magazine layouts (bundled verbatim)
- **OpenCoworkAI/open-codesign** — UX north star, streaming artifact loop, sandboxed preview
- **[[multica]]** — daemon architecture, PATH-scan agent detection

## Relevance to Us

### Direct connections
- Uses **SKILL.md convention** — same as [[clawhub]] skill packaging. Their `od:` frontmatter extension is an interesting data point for skill metadata standards
- Lists **Hermes** as supported agent (we contribute to [[hermes-agent]])
- **[[multica]]** architecture influence — we have an open PR there (#1944)
- ACP JSON-RPC support means OpenClaw agents could theoretically be OD backends

### Patterns worth noting
- **Deterministic design constraints** (locked palettes, font stacks) as guardrails against model freestyle — parallel to our FlowForge workflow nodes constraining agent behavior
- **Discovery form before generation** — structured Q&A before the model writes anything. Similar to [[blueprint]]'s plan-first pattern
- **Multi-harness adapter** — a clean pattern for supporting N agent CLIs with different stream formats. More polished than ad-hoc per-agent code
- **Skill-as-folder** with side files (assets, templates, references) — richer than SKILL.md-as-single-file

### Contribution potential
- 108 open issues, active community (1.8k forks)
- Bug: "Gemini CLI not detected when installed via npm global (PATH issue on macOS)" (#333) — could be fixable
- Bug: "Open button on HTML files: new tab shows source instead of rendered prototype" (#336)

## Anti-Hype Check

⚠️ 16k stars in 5 days is extraordinary but needs context:
- Rides the Claude Design hype wave (the "open alternative" pattern)
- Aggregates 4 existing projects with integration glue
- Core innovation is the multi-agent adapter + skill frontmatter — not the design output itself
- Real test: does it sustain commits + community after the launch spike?

## Tracking

- Revisit 05-10: check commit velocity, community PR merge rate, whether star growth sustains
- Watch for: skill standard convergence with Claude Code / ClawHub conventions
