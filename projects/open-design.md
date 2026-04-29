# Open Design (nexu-io/open-design)

- **Repo**: https://github.com/nexu-io/open-design
- **Stars**: 1902 (created 2026-04-28 — 1900+ in ~24h)
- **Language**: TypeScript (Vite + Next.js frontend + Node daemon)
- **License**: Apache-2.0
- **Last checked**: 2026-04-29

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

## Tracking

- Revisit 05-04: check if growth sustains or if it's a one-day spike
- Watch for: community skill contributions, agent adapter additions, self-hosting adoption
- Compare trajectory with open-codesign (the Electron alternative)

## Links

- [[multica]] — daemon architecture ancestor
- [[skill-ecosystem]] — skill metadata extension pattern
- [[agent-context-files]] — context file conventions comparison
- [[thin-harness-fat-skills]] — architectural pattern in practice
- [[self-evolving-agent-landscape]] — ecosystem positioning
