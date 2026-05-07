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

## Update 2026-05-04

**Stars**: 21,736 (was 16,170 on 05-03 — +34% in one day!)

### PR #435: Skill Resource CWD Aliasing (Merged)

**Problem**: Skill side files (assets/, references/) need to be readable by the agent. But different CLIs handle directory access differently:
- Claude Code has `--add-dir` but permission policies can still block
- Codex, Gemini, OpenCode, Qwen, Kimi etc. have NO `--add-dir` equivalent
- Result: skill preambles advertise absolute paths that half the supported agents can't open

**Solution**: Copy active skill into `<cwd>/.od-skills/<folder>/` before spawning the agent. Preamble advertises both:
1. CWD-relative `.od-skills/<id>/...` (primary — works for ALL agents)
2. Absolute path (fallback — for Claude/Copilot via `--add-dir`)

**Design evolution** (3 rounds of review):
- Round 1: Symlink → **rejected** (write-amplification: agent writes through symlink mutate source)
- Round 2: `fs.cp` per-project copy + safety validation (path traversal prevention, safe segment policy)
- Round 3: Unified `effectiveCwd` to fix no-project-mode edge case, Windows junction fixtures

**Key details**:
- Only stages the *active* skill (1-3 MB), not all skills
- Uses `dereference: true` so no symlinks leak into the copy
- `stat()` not `lstat()` on source (follows symlinked SKILLS_DIR)
- Unsafe segment policy: no separators, no dot segments, no absolute, no null bytes
- Legacy symlink auto-upgrade (replaces old symlinks with real dirs)
- 17 test cases including write-barrier regression test

**Relevance to OpenClaw**: Our skill system also has side files. When skills need to provide resources to different agent backends (Claude Code, Codex, etc.), this cwd-relative staging pattern solves the "universal resource access" problem without requiring each agent CLI to support a special flag.

See [[skill-ecosystem]], [[thin-harness-fat-skills]]

### Other Changes
- PR #434: French localization
- PR #428: Skill renaming (editorial-collage → open-design-landing), kami skills, deprecated skill ID aliasing
- PR #429: Preview blob export isolation

### Growth Signal
21.7k stars in 6 days is remarkable. Still actively maintained with multi-round PR reviews (3 rounds on #435). The commit quality is high — detailed commit messages with rationale. Using `looper 0.4.0` (automated fixer agent) for multi-commit PRs.

## Update 2026-05-06

**Stars**: 27,611 (was 21,736 on 05-04 — +27% in 2 days, +71% in 3 days from 16,170)

### v0.4.0 Release (2026-05-05)

71 PRs, 100+ contributors, 2-day dev cycle. Three architecturally significant additions:

#### Critique Theater (Design Jury) — Multi-Agent Quality Gate

PR #387 (foundation) + PR #481 (phase 4, persistence + orchestrator). ~8,800 lines total.

**Concept**: Every design artifact goes through a 5-panelist evaluation before shipping. Minimum score 8.0/10. WCAG AA enforced, brand-system fidelity scored per round.

**Architecture**:
- Wire protocol v1 with streaming parser (SSE events)
- `critique_runs` SQLite table for persistence + daemon-restart recovery (`reconcileStaleRuns`)
- Transcript streaming: `PanelEvent` sequences to disk for replay
- Orchestrator manages the full critique lifecycle

**Pattern significance**: This is a **multi-agent evaluation pipeline** — not just "run the LLM and ship". The 5-panelist + score threshold pattern could apply to any agent output quality gating (code review, content generation, skill validation). Resonates with [[mechanism-vs-evolution]] — explicit quality gates vs emergent quality.

#### MCP Server (`od mcp`) — Cross-Tool Design Access

PR #399, 2,733 lines. Stdio MCP server that exposes Open Design projects as MCP resources. Any MCP-aware tool (Claude Code, Cursor, VS Code, Zed, Windsurf) can read Open Design files directly, including the currently-open project.

**Why it matters**: Design artifacts become first-class inputs to coding workflows. The "active context bridge" concept — knowing which project the user has open in the OD app — is a nice UX pattern.

#### Live Artifacts + Composio Connector Catalog

PR #381, **22,361 lines** (118 files!). Massive addition.

- Live artifact contracts: designs that react to real data (not static mockups)
- Composio-backed connector catalog: plug into hundreds of SaaS tools
- Credential/config flows for connector auth
- MCP/tool-token integration

**Pattern**: Moving from "AI generates static HTML" to "AI generates live, data-connected artifacts". This is the direction Claude Artifacts hasn't gone yet.

#### Other Notable Changes
- 13+ agent CLI adapters now (added Kilo CLI, DeepSeek TUI)
- 5 new localizations (French, Ukrainian, Russian, Brazilian Portuguese, Arabic)
- Security: daemon localhost binding by default, API key stripping on agent spawn

### Growth Analysis

27.6K stars in 8 days is extraordinary. Growth sustained past the initial HN spike. The v0.4.0 release quality (71 PRs, multi-round reviews, spec-driven development with `specs/current/`) suggests real engineering depth, not just hype-driven growth.

### Relevance Update

1. **Critique Theater pattern** → Could inspire quality gating for [[flowforge]] workflow outputs or [[clawhub]] skill validation
2. **MCP server** → The active-context-bridge concept (exposing what's currently open) is relevant for [[openclaw]] tool integrations
3. **Live artifacts** → Composio connector model shows how agent outputs can be data-connected, not just static
4. Still uses [[agentskills]] SKILL.md convention with `od:` frontmatter extensions

See [[multi-harness-adapter-pattern]], [[skill-ecosystem]], [[thin-harness-fat-skills]]

### v0.4.2-beta (2026-05-07) — Transcript Export + Headless + Image Providers

**Stars**: 31,097 (+3,486 in ~1 day from 27,611 — growth sustained, not a spike)

10+ PRs merged in 2 days post-v0.4.0. Three architecturally notable additions:

#### Transcript Export (#493) — LLM-Ready Conversation Dump

Pure function `exportProjectTranscript()` that walks SQLite conversation history → `.transcript.jsonl` in project dir. Prereq for #450 "Finalize design package" (DESIGN.md synthesis from source + transcript).

**Design decisions worth noting:**
- JSONL over JSON: ~20-30% token savings for synthesis calls, tail-friendly, jq-friendly
- Block coalescing: streaming deltas → terminal text/thinking blocks via arrival-order flush (data-driven, model-agnostic)
- Atomic write: tmp file → fsync → rename (POSIX atomic, concurrent-safe)
- Content fallback: user messages (no events_json) → single text block from content field
- Zero edits to existing files — purely additive diff

**Pattern significance**: "Transcript as export primitive" enables multiple downstream features (#450 synthesis, #451 CLI handoff, #462 resume-conversation) from one stable format. The `schemaVersion: 1` header reserves room for breaking changes. Similar to how [[openclaw]] session logs could be a reusable primitive for reflection/synthesis.

#### Headless Mode (#686) — WSL/Server Deployment

New `headless.mjs` entry point runs daemon + web without Electron. `--headless` flag on Linux install/start/stop. Enables running in WSL, SSH, CI/CD environments.

**Why it matters**: Removes the desktop-GUI-only constraint. Server-side design generation becomes possible. Aligns with the "design as a service" direction.

#### Nano Banana Image Provider (#631)

Dedicated media provider with Google Gemini-compatible `generateContent` API. Custom gateway override supported. Image generation embedded in the design loop.

#### Other Changes
- Qoder CLI agent adapter (#626) — 14th agent CLI supported
- Codex imagegen integration (#622)
- Connection tests in settings UI (#507)
- Legacy data dir migration for 0.3.x→0.4.x (#712)
- Windows ENAMETOOLONG fix (#727) — prompt delivery via stdin

### Growth Analysis (Updated 05-07)

31K stars in 9 days. Growth rate: ~3.5K/day (sustained, not decaying). For reference:
- Day 5: 16K
- Day 8: 27.6K
- Day 9: 31K

This is faster than Claude Design's own growth curve (closed-source advantage didn't help). The open-source + multi-agent approach is clearly winning community mind-share. 5 good-first-issues open for contributors.

### Upcoming: DESIGN.md Synthesis (#450)

Open issue for "Finalize design package" — daemon-side source scan + LLM pass against chat transcript → single DESIGN.md. This is the synthesis step that #493 transcript export enables. Worth watching — the concept of "synthesize a design doc from conversation + code" is a pattern [[openclaw]] could borrow for project-level context summaries.

## Tracking

- Revisit 05-12: #450 DESIGN.md synthesis feature progress, growth trajectory (still accelerating or plateauing?)
- Watch for: skill standard convergence with Claude Code / ClawHub conventions, live artifact ecosystem development, headless mode adoption
