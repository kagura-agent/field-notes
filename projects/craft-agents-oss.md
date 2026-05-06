# Craft Agents OSS

- **Repo**: warpdot-dev/craft-agents-oss (fork of lukilabs/craft-agents-oss)
- **Stars**: 212 (5 days old, 2026-05-01)
- **License**: Apache 2.0
- **Language**: TypeScript (Bun runtime)
- **Last push**: 2026-05-01

## What It Is

Desktop + headless agent workspace built on the **Claude Agent SDK**. Combines session management, MCP/REST API integrations ("Sources"), reusable instruction packs ("Skills"), automations (cron/hooks), and multi-LLM provider support in one Electron app.

Think: Claude Desktop + Cursor + OpenClaw merged into a single Apache 2.0 product.

## Architecture

Monorepo structure:
- `packages/core` — shared types/utils
- `packages/server-core` — main runtime: sessions, services, model-fetchers, transport
- `packages/session-tools-core` — tool definitions, filtering, validation
- `packages/session-mcp-server` — session-scoped MCP server
- `packages/messaging-gateway` + `messaging-whatsapp-worker` — messaging integration
- `packages/pi-agent-server` — multi-provider LLM routing (their "Pi SDK")
- `packages/shared` — agent backend, config, credentials, auth, i18n, workspaces
- `apps/electron` — Electron desktop app
- `apps/cli` — CLI client
- `apps/webui` — Web UI
- `apps/viewer` — session viewer

### Key Design Decisions

1. **Sessions are JSONL-persisted** with bundles, compaction, and metadata. Persistent across restarts.
2. **Sources = unified abstraction** over MCP servers (stdio/SSE) + OpenAPI REST APIs + OAuth services. Agent can auto-discover and wire them.
3. **Skills = workspace-scoped instruction packs**, referenced via `@` mentions in chat. Not code — pure prompt/instruction context.
4. **Multi-provider via "connections"**: Anthropic OAuth, Google AI, ChatGPT/Codex, GitHub Copilot, OpenAI-compatible endpoints.
5. **Remote mode**: headless WebSocket server, Electron is just a thin client. CLI can drive sessions.
6. **Automations**: cron, label triggers, tool hooks → spawn prompts/workflows.
7. **Workspace isolation**: allowlisted dirs, file path validation (security-conscious like us).

### Interesting Implementation Details

- `PrivilegedExecutionBroker` — permission mode per session (like our native approvals)
- `ConfigWatcher` — live config reload (like our gateway hot-reload)
- `TokenRefreshManager` — OAuth token lifecycle for sources
- `generateConversationSummary` — automatic context compaction
- `toolMetadataStore` + `getLastApiError` — tool call observability via interceptor

## Position in Ecosystem

- **Competes with**: Claude Desktop (official), Cursor (IDE), OpenClaw (infra), WindSurf
- **Differentiator**: fully open-source (Apache 2.0), multi-provider from day one, messaging integration
- **Relationship to us**: Direct competitor in the "agent workspace" space. Their approach is monolithic (everything in one app) vs our modular (gateway + channel plugins + skills). They bundle a UI; we're headless-first.

## Relevance to Our Direction

| Aspect | Craft Agents | OpenClaw |
|--------|-------------|----------|
| Architecture | Monolith, Electron | Modular, headless-first |
| Skills | Prompt/instruction packs (no code) | Code + prompt (SKILL.md + tools) |
| Sessions | JSONL + compaction | Conversation-scoped |
| Messaging | WhatsApp worker + gateway | Multi-channel plugins |
| MCP | Sources (MCP + REST unified) | MCP client support |
| Self-evolution | None visible | Core thesis |

### Takeaways for Us

1. **Validation**: The "agent workspace" category is real. 212⭐ in 5 days shows demand.
2. **Their weakness = our strength**: No self-evolution, no skill behavioral testing, no memory architecture beyond session persistence.
3. **Their strength = our gap**: Polished desktop UI, auto source discovery, OAuth token management.
4. **Messaging gateway as a package** is interesting — they modularized it similar to our channel plugins.
5. **Automations (cron/hooks)** — we have this via heartbeat/cron but they have label-triggered automations which is novel.

## Trend Signal

The skill format is converging across the ecosystem:
- Craft Agents: workspace-scoped instruction files
- [[library-skills]]: SKILL.md standard
- [[lukiIabs/skills]] (Matt Pocock fork): composable SKILL.md files with CLI installer
- [[master-skill]]: meta-skill that generates other skills
- [[oh-story-claudecode]]: viral single-purpose SKILL.md (784⭐!)

**Conclusion**: "Skills as markdown instruction files" is now the de facto standard. The differentiation is in runtime capabilities (tools, memory, evolution) not format.

## Scout Companion Notes (2026-05-06)

Other interesting finds this session:
- **lukiIabs/skills** (143⭐, 5 days) — Matt Pocock's engineering skills repo with `npx skills@latest` installer. 60k newsletter. The "skill marketplace" is materializing as git repos + CLI installers, not centralized registries.
- **Photo-agents** (51⭐, 2 days) — Vision-grounded self-evolving agents with layered memory. Commercial (API key gated). Concept of "photographic memory" (vision → observation → skill writing loop) is novel.
- **oh-my-kimi** (54⭐, 6 days) — Multi-agent orchestration for Kimi Code CLI. DAG planning + MCP skill-hooks. Chinese ecosystem building agent tooling on domestic LLMs.
- **master-skill** (33⭐, 5 days, actively pushed) — Meta-skill that auto-distills industry expertise into runnable skills. Explicitly compatible with OpenClaw. Novel idea: "skill compiler" from domain knowledge.

Links: [[skill-ecosystem]], [[agent-skill-standard-convergence]], [[self-evolving-agent-landscape]], [[thin-harness-fat-skills]], [[oh-story-claudecode]]
