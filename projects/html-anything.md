---
title: html-anything (nexu-io)
status: active
created: 2026-05-15
updated: 2026-05-15
stars: 1087
url: https://github.com/nexu-io/html-anything
last_verified: 2026-05-16
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

2. **Agent-agnostic via protocol abstraction**: Four invocation protocols:
   - `stdin` — pipe prompt to stdin, parse ndjson stdout (Claude, Cursor, Gemini, Copilot, Qwen, Aider)
   - `argv` — prompt as positional arg (DeepSeek)
   - `argv-message` — prompt via `--message` flag, single JSON stdout (OpenClaw!)
   - `acp` / `pi-rpc` — planned but not yet implemented

3a. **Adapter pattern** (PR#14): `adapter` field in AgentDef lets wrapper binaries reuse another agent's argv/parser without code changes. Example: `{ id: "codex-nightly", bin: "codex-next", adapter: "codex" }`. Enables users to register custom agent CLIs via environment variables.

3b. **Environment-based extension hooks** (PR#14): Three-tier customization without code:
   - `HTML_ANYTHING_EXTRA_AGENTS` — JSON array of custom AgentDefs, appended to built-in list
   - `HTML_ANYTHING_MODELS_<AGENT>` — comma-separated model overrides per agent
   - `HTML_ANYTHING_BIN_<AGENT>` — binary path override per agent
   - `HTML_ANYTHING_AGENT_PROXY` — explicit proxy control for agent subprocesses

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

- Agent binary detection fails when PATH doesn't include common install dirs (#hallestar) — **fixed by PR#14** with unified `resolveAgentBin()` and env override support
- Streaming display can get stuck showing "generating" even after HTML is produced (#qtwaiter) — **fixed by PR#9/#11** (write-tool rescue)
- Some agents output conversation text instead of raw HTML (#fcityboy) — **fixed by PR#14** with empty-output detection and `summarizeJsonLine()` diagnostics
- Windows spawn EINVAL failures (#15, #16) — **open**, likely agent binary quoting issue on Windows

## Growth Trajectory

| Date | Stars | Delta | Notes |
|------|-------|-------|-------|
| 05-11 | ~0 | — | First commits |
| 05-15 AM | 831 | — | Initial tracking |
| 05-15 PM | 1,087 | +30.8% | Viral breakout confirmed |
| 05-16 AM | 1,964 | +80.6% | Explosive — approaching 2K milestone |

Community: 🟢 THRIVING 6/6 — 9 unique issue authors, 5 external PRs, 118 forks, 2 merged PR authors.

## PR#14 Architecture Deep Read (05-15)

The biggest architectural shift since launch. Three key patterns:

### 1. Extensible Agent Registry via Environment

`parseExtraAgents()` reads `HTML_ANYTHING_EXTRA_AGENTS` env var — a JSON array of agent definitions. This means users can add custom agent CLIs without forking. Each custom agent can specify `adapter` to reuse an existing protocol implementation.

**Insight**: This is the [[skill-ecosystem]] "plugin without plugin system" pattern — using environment variables as the extension surface instead of a plugin API. Zero runtime overhead, works in Docker/CI, no config files to manage. Trade-off: no validation, no UI for discovery.

### 2. Unified Binary Resolution

`resolveAgentBin()` consolidates the previously scattered binary lookup into one function with clear priority: env override → primary bin → fallback bins → env-provided extra bins. The old code had detection and invocation doing separate PATH lookups that could disagree.

**Relevance to OpenClaw**: The `resolveOpenclawAgentId()` function probes `openclaw agents list` with a 5-minute TTL cache — it knows OpenClaw refuses `agent --message` without `--agent`. This is the kind of adapter-specific knowledge that makes first-class support real vs. superficial.

### 3. Defensive Output Parsing

PR#14 adds `hasContent` tracking and `summarizeJsonLine()` — if an agent exits without producing HTML/text, the user gets a diagnostic with the last parsed event type, not a silent failure. Also filters known Codex stderr noise (10+ benign warning patterns). This is production hardening.

## Verdict (updated)

**Strong track**. Growth trajectory suggests sustained viral adoption, not a one-week spike. The architecture is maturing rapidly (4 PRs in 24 hours fixing real user-reported issues). OpenClaw first-class support is genuine — they wrote adapter-specific code, not just string matching.

Revisit 05-22 — watch for: 2K⭐ milestone, Windows fix, ACP protocol implementation.
