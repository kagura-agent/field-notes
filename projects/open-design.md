# Open Design (nexu-io/open-design)

- **Repo**: https://github.com/nexu-io/open-design
- **Stars**: 9,204 (2026-05-01, was 6,005 on 04-30, was 1,902 on 04-29)
- **Language**: TypeScript (Next.js 16 App Router frontend + Node daemon)
- **License**: Apache-2.0
- **Last checked**: 2026-05-01

## What it is

Open-source alternative to Anthropic's Claude Design (launched 2026-04-17). A web app + local daemon that turns any coding agent CLI into a design engine through composable skills and markdown-based design systems.

**Key proposition**: "We don't ship an agent — yours is good enough." The daemon scans PATH for claude/codex/cursor-agent/gemini/opencode/qwen and adapts to whichever is present.

## Architecture (three-layer)

```
Browser (Next.js) ──ws──► Daemon (Node, port 7431) ──stdio──► Agent CLI
```

1. **Web app**: Chat pane + artifact tree + sandboxed iframe preview + comment/slider overlay. Three deployment topologies: fully local, Vercel+tunnel, Vercel+API-only (degraded)
2. **Daemon**: Session manager, agent adapter pool, skill registry, design-system resolver, artifact store, preview compile pipeline, export pipeline (HTML/PDF/PPTX/ZIP)
3. **Agent adapters**: Per-CLI definitions (`agents.js`) — Claude Code (stream-json), Codex/Gemini/OpenCode/Cursor/Qwen (plain stdout). All one-shot invocations via stdio

## Six load-bearing ideas

1. **Agent-agnostic**: PATH-scan detection, adapter per CLI. Inspired by [[multica]]
2. **Skills are files, not plugins**: Follows Claude Code `SKILL.md` convention with optional `od:` extension frontmatter (mode, preview, inputs, parameters, design_system sections). Zero-config compatibility — a plain Claude Code skill drops in unchanged
3. **Design Systems as portable Markdown**: 9-section `DESIGN.md` schema from VoltAgent/awesome-design-md. 71 brand-grade systems (Linear, Stripe, Vercel, Airbnb, Tesla, etc.)
4. **Interactive question form prevents 80% of redirects**: Hard-coded RULE 1 — turn 1 always emits `<question-form id="discovery">` before writing any code. "Junior Designer" mode from huashu-design
5. **Daemon makes agent feel local**: Real filesystem, real on-disk project folder, real Read/Write/Bash
6. **Five-dimensional self-critique**: Agent checks own output before emitting artifact

## Skill protocol deep dive

Extended SKILL.md frontmatter:
- `od.mode`: prototype | deck | template | design-system
- `od.preview.type`: html | jsx | pptx | markdown
- `od.design_system.requires`: whether to inject DESIGN.md
- `od.design_system.sections`: prune injected DESIGN.md to relevant sections (token savings!)
- `od.inputs`: typed form schema for sidebar UI
- `od.parameters`: live-tweakable sliders that re-prompt on change
- `od.capabilities_required`: gating based on agent capabilities

**Compatibility promise**: A skill that omits `od:` entirely still works — defaults are sniffed from filenames and description keywords.

29 skills in repo (19 public-facing + internal ones like critique/tweaks/wireframe-sketch). Categorized as design surfaces (web-prototype, mobile-app, dashboard, deck, etc.) and document/work-product surfaces (pm-spec, invoice, kanban, etc.).

## Provenance (four open-source shoulders)

1. **alchaincyf/huashu-design** — design philosophy, Junior-Designer workflow, 5-step brand-asset protocol, anti-AI-slop checklist, 5-dimensional self-critique
2. **op7418/guizang-ppt-skill** — deck mode, bundled verbatim with original LICENSE
3. **OpenCoworkAI/open-codesign** — UX north star, streaming-artifact loop, sandboxed-iframe preview, export formats. They diverge: open-codesign is Electron+pi-ai; OD is web+local daemon delegating to existing CLI
4. **multica-ai/multica** — daemon architecture, PATH-scan agent detection, agent-as-teammate worldview

## Key architectural insights

### Design system as token-saving mechanism
`od.design_system.sections` field prunes the injected DESIGN.md to only the sections the skill actually uses. This is a practical token-efficiency pattern — instead of always injecting the full design system spec, let the skill declare which pieces it needs. Applicable to any skill-based system that injects large context documents.

### Question-form as structured UI from plain text
The `<question-form>` XML block is emitted by the LLM as plain text, then parsed by the web app into an interactive form. This is a clever pattern — the LLM generates UI schemas instead of raw HTML, and the app renders them natively. Similar in spirit to [[agent-context-files]] but for output rather than input.

### Adapter minimalism
Each agent adapter is ~10 lines: bin name, version args, buildArgs function, stream format hint. The adapter doesn't abstract the agent's behavior — it only wraps invocation. All design intelligence lives in the skill files and prompt stack, not the adapter. This is [[thin-harness-fat-skills]] in practice.

## Relation to our ecosystem

### Directly relevant
- **Skill ecosystem research**: OD extends the SKILL.md convention with typed frontmatter for UI rendering. This is exactly the kind of skill metadata layer that [[skill-ecosystem]] projects need. Could inform ClawHub skill metadata design
- **Agent-agnostic daemon**: PATH-scan + adapter pattern similar to what multica and OpenClaw ACP do. OD's approach is simpler (one-shot CLI) vs our persistent session model
- **Design system portability**: The DESIGN.md-as-portable-spec idea is interesting for non-design skills too — any skill that needs a large context document could benefit from section-level pruning

### Not directly applicable
- OD is a design tool, not an agent framework. Its skills are design-surface templates, not behavioral capabilities
- The one-shot invocation model doesn't support iterative agent sessions
- No memory layer, no self-evolution — it's a stateless tool pipeline

## Growth signal

1900+ stars in <24h is explosive. Created the day after Claude Design's viral moment. Riding a clear wave: "Claude Design but open-source and local-first." The four-ancestor attribution is unusually thorough for a viral repo — suggests genuine engineering rather than pure trend-surfing.

## Update 2026-04-30: Explosive Week

### Growth: 1,902 → 6,005⭐ in 48h

721 forks, 84 open issues, 166+ PRs merged in 2 days. Top contributors are community (pftom: 9, nettee: 6, alchemistklk: 5). This is genuine community adoption, not just star farming.

### Agent count: 7 → 10 CLIs

Added since last check:
- **Pi** (via `--mode rpc` JSON-RPC over stdio) — PR #117
- **Hermes** + **Kimi** runtime adapters — PR #71
- **GitHub Copilot CLI** — PR #28

Total: Claude Code, Codex, Gemini, OpenCode, Hermes, Kimi, Cursor Agent, Qwen Code, GitHub Copilot CLI, Pi.

### ACP JSON-RPC integration (`acp.ts`)

The daemon now speaks ACP protocol natively — `acp-json-rpc` stream format alongside `claude-stream-json` and `plain`. Full lifecycle: `initialize` → `session/new` → `session/prompt` with permission auto-approval (web UI has no dialog surface). This makes OD a **consumer** of the ACP ecosystem — any ACP-compatible agent works as a backend.

Relevance to us: OD validates ACP as a cross-harness protocol. Their implementation of `choosePermissionOutcome` (approve_for_session > allow_always > allow_once) is a clean pattern for non-interactive ACP clients.

### Architecture evolution

1. **Vite → Next.js 16 App Router** (PR #66): Catch-all route with `ssr: false`, daemon serves static export + SPA fallback. Pragmatic migration — keeps daemon as the real backend.
2. **Artifact platform foundation** (PR #68): Evolving from HTML-only artifacts to a renderer registry (HTML, decks, Markdown, SVGs, React components). "Stop treating HTML as the only artifact model." This is the move from design tool → general artifact platform.
3. **Per-CLI model picker** (PR #14): Each adapter declares `listModels` spec; daemon probes CLI's own model listing command at detection time. Falls back to `fallbackModels` static list. Clean separation: runtime model discovery vs hardcoded defaults.

### Rebrand: "Open Claude Design" → "Open Design" (PR #1)

Dropped the Claude branding entirely. This is significant — they're betting on agent-agnosticism as the value prop, not riding Claude's brand. The skill protocol is agent-neutral by design.

### Pi RPC adapter deep dive

`pi-rpc.ts` translates Pi's JSON-RPC events (agent_start, message_update) into OD's unified event types (status, text_delta, thinking_delta, tool_use, tool_result, usage). Extension UI requests (select/confirm/input/editor) are auto-resolved since the web UI can't render them. Fire-and-forget notifications (setStatus, setWidget, notify, setTitle) are silently consumed.

This is exactly the same pattern as [[openclaw-architecture]]'s ACP adapters — translate agent-specific event schemas into a unified internal model. OD's approach is simpler because it's one-shot (no session persistence).

### Community dynamics

i18n PRs flooding in (Russian, Persian/Farsi, Brazilian Portuguese). Design system contributions (xiaohongshu). Cross-platform fixes (Windows ENAMETOOLONG, pnpm standalone binary). The project is absorbing community energy efficiently — 166+ PRs merged in 2 days suggests fast review cycles.

### New insight: daemon as universal agent adapter layer

OD's daemon is becoming a standardized layer between web UIs and any coding agent CLI. The adapter definition is minimal (~10-20 lines per agent), and the heavy lifting is in the shared infrastructure (session management, artifact storage, permission handling, stream normalization). This is the same insight behind [[thin-harness-fat-skills]] but applied to the invocation layer rather than the skill layer.

## Update 2026-05-01: 9.2k⭐, Desktop App, 11 Agents

### Growth: 6,005 → 9,204⭐ in 24h

Sustained explosive growth. 89 open issues. Pushed today (05-01T06:42 UTC). Not a one-day spike — this is genuine sustained adoption.

### Agent count: 10 → 11 CLIs

- **Kiro CLI** added (PR #185) — uses ACP v2025-01-01 over stdio JSON-RPC, same as Hermes and Kimi. Single `AGENT_DEFS` entry with zero new parsing code.
- **Pi** (PR #117) — `--mode rpc` JSON-RPC protocol, distinct from ACP but mapped to same internal event model via `pi-rpc.ts`.

Total: Claude Code, Codex, Gemini, OpenCode, Hermes, Kimi, Cursor Agent, Qwen Code, GitHub Copilot CLI, Pi, Kiro. Plus BYOK proxy for keyless agents.

### Four stream format taxonomy

The daemon now handles 4 distinct agent communication protocols, all normalized to the same internal event model:

| Format | Agents | Protocol |
|--------|--------|----------|
| `claude-stream-json` | Claude Code | Line-delimited JSON from `--output-format stream-json` |
| `acp-json-rpc` | Hermes, Kimi, Kiro | ACP v2025-01-01 JSON-RPC over stdio |
| `pi-rpc` | Pi | Pi's own `--mode rpc` JSON-RPC |
| `plain` | Codex, Gemini, OpenCode, Cursor, Qwen, Copilot | Raw stdout, forwarded chunk-by-chunk |

**Insight**: ACP is becoming the de facto structured protocol for agent CLIs that aren't Claude Code. Three out of four structured formats (ACP x3 agents) speak ACP — it's winning the multi-agent protocol race by adoption, not by design.

### Mac Desktop App (PR #170)

`apps/desktop/` — Electron shell with sidecar IPC:
- **DesktopRuntime** exposes: STATUS, EVAL, SCREENSHOT, CONSOLE, CLICK, SHUTDOWN
- Sandboxed renderer + sidecar IPC for daemon/web sidecars
- `tools-pack` CLI for build/install/start/stop/logs/uninstall
- Beta release automation with signed/unsigned mac artifacts
- `tools-dev inspect desktop screenshot` for E2E testing

This is architecturally interesting: the desktop shell is essentially a **browser automation layer for design artifacts**. The agent generates an artifact → Electron renders it → SCREENSHOT/EVAL/CLICK let the agent inspect and interact with its own output. Self-verification loop.

### Anthropic-Compatible Proxy (PR #180)

`POST /api/proxy/anthropic/stream` — routes third-party Anthropic-compatible BYOK endpoints through the daemon proxy. Keeps official Anthropic path unchanged. Prevents Anthropic-style base URLs from being misrouted through the OpenAI-compatible proxy.

This means OD now has three BYOK layers: OpenAI-compatible, Anthropic-compatible, and direct agent CLI. Full model-agnostic stack.

### SVG Artifact Viewer (PR #177)

First-class SVG rendering in the artifact viewer. Part of the ongoing expansion from "HTML-only artifacts" to a proper artifact platform with pluggable renderers (HTML, decks, Markdown, SVG, React).

### Community Dynamics

i18n explosion: Japanese, German, Spanish, Russian, Persian, Portuguese locales. Community contributions account for majority of recent PRs. The project is absorbing community energy at a remarkable rate — the adapter pattern makes it easy for anyone to add their favorite agent.

### Relevance to OpenClaw

1. **ACP validation**: 3 out of 11 supported agents use ACP as their wire protocol. OD's implementation validates ACP as the emerging standard for structured agent communication.
2. **Stream normalization pattern**: OD's 4-format taxonomy is a clean reference for how to build a universal agent adapter layer. OpenClaw's ACP runtime does similar work but could learn from OD's minimalist adapter definitions (~10-20 lines per agent).
3. **Desktop self-verification loop**: The Electron SCREENSHOT/EVAL/CLICK pattern for artifact inspection is a novel approach to agent self-verification. Could inspire similar patterns in OpenClaw for visual output validation.
4. **Contribution opportunity**: OD is actively merging community PRs. Adding an OpenClaw adapter or improving existing integrations could be a high-impact contribution.

## Tracking

- Revisit 05-07: check if growth sustains past 10k
- Watch for: ACP adapter maturity, artifact renderer expansion, desktop app adoption
- Compare: OD's ACP implementation vs OpenClaw's — are they protocol-compatible?
- Potential: contribute OpenClaw adapter or improve ACP integration

## Links

- [[multica]] — daemon architecture ancestor
- [[skill-ecosystem]] — skill metadata extension pattern
- [[agent-context-files]] — context file conventions comparison
- [[thin-harness-fat-skills]] — architectural pattern in practice
- [[self-evolving-agent-landscape]] — ecosystem positioning
