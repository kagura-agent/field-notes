# Thoth (siddsachar) — Local-First Personal AI Sovereignty

**Repo**: https://github.com/siddsachar/Thoth
**Stars**: 365 (2026-05-02, created 2026-03-06)
**Language**: Python (LangChain)
**License**: (not checked)
**Status**: Active, v3.19.0 released 05-01

⚠️ **Different from** [[thoth]] (SeeleAI/Thoth, 39⭐) — that's a dashboard-first orchestration runtime for autoresearch. This is a consumer-facing personal AI assistant.

## What It Does

Local-first AI assistant with:
- Integrated tools (shell, browser automation, image gen, video gen)
- Personal knowledge graph
- Voice + Vision
- Scheduled tasks ("Dream Cycle" for self-reflection)
- Messaging channels (Telegram)
- Health tracking
- Multi-provider model support (Ollama local, OpenAI API, Anthropic, Google AI, xAI, custom endpoints)
- Desktop apps (Windows installer, macOS DMG)
- Claude Code delegation skill

## v3.19.0 Highlights (2026-05-01)

### Provider Runtime Foundation
Complete rebuild of model layer around a first-class provider runtime:
- Unified provider catalog: API-key providers, Ollama, custom OpenAI-compatible endpoints, ChatGPT/Codex subscription
- Provider-aware model refs (e.g. `model:openai:gpt-5.5` vs `model:codex:gpt-5.5`)
- OS credential store for secrets (not config files)
- Surface-specific model filtering (Brain, Vision, Image, Video)

### ChatGPT / Codex Subscription Provider
- In-app ChatGPT sign-in with device-flow OAuth
- Distinct from OpenAI API access — separate labels, separate auth
- Live Codex catalog discovery from ChatGPT backend API
- SSE Responses transport with tool-call chunks

### Claude Code Delegation Skill
- Bundled skill that teaches Thoth to coordinate Claude Code CLI as external coding worker
- Approval-gated shell workflow with `--allowedTools`, `--max-turns`, budget limits
- Thoth stays coordinator (scoping, state checking, diff inspection, verification)

## Comparison to OpenClaw

| Aspect | Thoth | OpenClaw |
|--------|-------|----------|
| **Target** | Consumer desktop | Server/developer |
| **Runtime** | Local Python + LangChain | Node.js server |
| **Channels** | Telegram, desktop UI | Discord, Feishu, WhatsApp, Telegram, etc. |
| **Models** | Multi-provider + Ollama local | Multi-provider via gateway |
| **Skills** | Bundled + tool_guides | SKILL.md + ClawHub marketplace |
| **Memory** | Knowledge graph + insights | Markdown files + memex wiki |
| **Self-reflection** | "Dream Cycle" (automated) | Heartbeat + nudge reflection |
| **Coding** | Claude Code delegation skill | ACP runtime + coding-agent skill |
| **Distribution** | Desktop installers | npm / Docker |

### Key Differences
- Thoth is **consumer-first** (desktop app, setup wizard, GUI settings). OpenClaw is **developer-first** (CLI, config files, server deployment).
- Thoth's provider runtime is more sophisticated for end-users (subscription vs API key distinction, model catalog browsing, pin/unpin). OpenClaw's is simpler but extensible.
- Thoth bundles everything (knowledge graph, health tracking, image gen, browser) as one app. OpenClaw composes tools via skills and extensions.

### What OpenClaw Can Learn
1. **Provider-aware model refs** — `model:provider:name` pattern elegantly solves the "same model from different backends" ambiguity
2. **OS credential store** — using OS keyring instead of config files for API keys is more secure and user-friendly
3. **Claude Code delegation skill** — well-structured approval-gated delegation pattern with explicit safety boundaries

## Ecosystem Position
Thoth occupies the "personal AI assistant for non-developers" niche that OpenClaw could theoretically serve but doesn't target. At 365⭐ with desktop installers and a polished UI, it's one of the more complete local-first AI assistants. Its growth suggests demand for "sovereign AI" (data stays on machine) is real.

The "Dream Cycle" (automated self-reflection) concept parallels our heartbeat + nudge system — worth comparing architectures if Thoth's codebase is readable.

Links: [[openclaw]], [[self-evolving-agent-landscape]], [[coding-agent]], [[library-skills]]
