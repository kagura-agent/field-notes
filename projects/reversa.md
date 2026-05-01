# Reversa

**Repo:** sandeco/reversa
**Stars:** 180 (2026-04-30)
**Language:** JavaScript (Node.js 18+)
**Created:** 2026-04-26
**License:** MIT

## What it does

Reverse-engineering framework that transforms legacy codebases into executable specifications for AI coding agents. You install it in a legacy project, run `/reversa`, and it coordinates a team of specialized AI agents to analyze the code and produce formal specs.

## Architecture — Multi-Agent Pipeline

5-phase pipeline with 7 specialized agents + 3 independent agents:

```
Phase 1: Reconnaissance (Scout)
Phase 2: Excavation (Archaeologist) — one module per session
Phase 3: Interpretation (Detective + Architect)
Phase 4: Generation (Writer)
Phase 5: Review (Reviewer)

Independent: Visor (screenshots), Data Master (DDL/ORM), Design System (CSS/UI)
```

Each agent is a SKILL.md file — plain markdown instructions, no code. The orchestrator (`reversa` skill) reads state from `.reversa/state.json` and activates agents sequentially.

## Key Design Decisions

1. **Skills-as-agents**: Each "agent" is just a SKILL.md. No custom runtime, no framework dependency. Works with any agent that reads skill files (Claude Code, Codex, Cursor, Gemini CLI, Kiro, etc.)

2. **State checkpoint system**: `.reversa/state.json` tracks phase, module progress, doc_level. Enables resume across sessions — critical for context-window-limited agents.

3. **Confidence scale**: Every generated spec statement is tagged:
   - 🟢 CONFIRMED — extracted directly from code
   - 🟡 INFERRED — based on patterns, may be wrong
   - 🔴 GAP — requires human validation

4. **Immutability guarantee**: Agents write ONLY to `.reversa/` and `_reversa_sdd/`. Never touch existing project files. Safety-first for legacy codebases.

5. **Doc level choice**: User picks essential/complete/detailed after Scout phase. Controls which artifacts each agent generates. Prevents over-documentation for simple projects.

6. **Engine-agnostic installer**: Detects 13 AI engines (Claude Code, Codex, Cursor, Gemini, Windsurf, Kiro, Copilot, Cline, Roo Code, Amazon Q, Aider, Antigravity, OpenCode). Copies skills to the right location for each.

## What's Interesting

### Multi-agent orchestration via pure markdown
No code orchestration layer — the orchestrator itself is a SKILL.md that reads state and activates other skills. This is the [[skill-ecosystem]] pattern taken to its logical conclusion: agents coordinating agents through shared file state.

### Confidence-tagged specs
The 🟢/🟡/🔴 scale is a practical solution to the hallucination problem in reverse engineering. Instead of pretending every inference is fact, it makes uncertainty explicit and actionable. Similar concept to [[stash]] episode confidence scoring, but applied to specification artifacts.

### Legacy-to-agent bridge
Addresses a real gap: most agent tooling assumes greenfield development or well-documented codebases. Legacy systems — where AI agents could add the most value — are the hardest for agents to work with because the knowledge is implicit. Reversa makes that knowledge explicit and structured.

## Limitations

- **No tests at all** — zero test files in the repo
- **No code logic** — the installer is ~200 lines, everything else is markdown templates
- **Portuguese-first docs** — most docs are in Portuguese, English is secondary
- **Single contributor** — sandeco only
- **Young project** — 4 days old, unclear if it will sustain momentum
- **Token-heavy** — running all 5 phases on a large codebase would consume enormous context

## Relation to Our Direction

**Complementary to [[coding-agent]] workflow.** When we contribute to unfamiliar repos, we manually read code to understand structure. Reversa automates this discovery phase. The confidence scale pattern could inform how we tag our own wiki notes.

**Skill orchestration pattern** is notable: it proves that multi-agent coordination can work with just files + SKILL.md, no custom runtime needed. Validates the [[skill-ecosystem]] approach we're already using with [[flowforge]] and [[clawhub]].

**Not a contribution target** — too young, no tests, single maintainer, Portuguese-primary. But the architecture patterns are worth watching.

## Tracking

- 05-01 update: 180→341⭐ (+89% in 1 day), 164 forks. v1.2.14. English CLI translation added, video demo, removed Chronicler/Tracer agents. Still single contributor, still no tests.
- Revisit 05-07: check contributor diversification, test addition
- Drop if: still single contributor, no tests, stars plateau
