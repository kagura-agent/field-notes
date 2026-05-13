# Reversa

Specification reverse-engineering framework for legacy systems. Installs as Agent Skills and coordinates specialized AI agents to analyze existing code → executable specifications.

- **Repo**: sandeco/reversa (360★, 2026-05-01)
- **License**: MIT
- **Author**: sandeco (Brazilian dev, active YouTube channel)
- **Language**: JavaScript (installer/CLI only — agents are pure SKILL.md prompts)
- **Created**: 2026-04-26 (5 days old, fast growth)
- **Status**: v1.0.0, active (pushed 04-30)

## What It Solves

Legacy systems have accumulated knowledge (business rules, architectural decisions, implicit contracts) trapped in code. AI coding agents need specs to work safely. Reversa bridges the gap: analyze code → produce "operational contracts" agents can use.

**Not documentation for humans** — specs for agents.

## Architecture: Multi-Agent Pipeline

```
Reconnaissance → Excavation → Interpretation → Generation → Review
    Scout       Archaeologist    Detective       Writer     Reviewer
                                  Architect
```

Independent agents (run at any phase): **Visor**, **Data Master**, **Design System**, **Tracer**

### Key: Agents Are Pure SKILL.md Files

No runtime code — each agent is a SKILL.md with:
- Role description and constraints
- Input: what to read (`.reversa/context/`, previous agent outputs)
- Process: step-by-step analysis instructions
- Output: what to write (always to `.reversa/` or `_reversa_sdd/`)
- Checkpoint: what to report back to orchestrator

The orchestrator (reversa/SKILL.md) sequences them, manages state.json checkpoints, and handles resume.

### Agent Roles

| Agent | Role | Phase |
|-------|------|-------|
| Scout | Surface mapping: folders, languages, frameworks, entry points | Reconnaissance |
| Archaeologist | Deep per-module analysis: algorithms, control flow, data structures | Excavation |
| Detective | Implicit knowledge: business rules, ADRs from git, state machines, RBAC | Interpretation |
| Architect | C4 diagrams, ERD, integration map, technical debt | Interpretation |
| Writer | Executable specs with code traceability | Generation |
| Reviewer | Cross-reference verification, confidence scoring | Review |

## Design Patterns Worth Noting

### 1. Confidence Scale
```
🟢 CONFIRMED — extracted directly from code
🟡 INFERRED — based on patterns, may be wrong
🔴 GAP — requires human validation
```
Every generated spec uses this scale. Explicit uncertainty handling.

### 2. Doc Level Tiers
User chooses scope: Essential (quick) → Complete (recommended) → Detailed (enterprise). Each agent's output matrix varies by level. Smart scope control.

### 3. Strict Immutability
Never modifies existing project files. Writes only to `.reversa/` and `_reversa_sdd/`. Similar to hermes-labyrinth's read-only principle.

### 4. Checkpoint/Resume
`state.json` tracks current phase, completed tasks, user preferences. `reversa` in new session = resume from last checkpoint. FlowForge-like state persistence.

### 5. Skills as Distribution
`npx reversa install` copies SKILL.md files into the project. Works with any agent that supports Agent Skills. No runtime dependency — the intelligence is in the prompts.

### 6. Git Archaeology
Detective agent mines git history for ADRs (Architectural Decision Records). Commits, reverts, hotfixes as evidence of business decisions. Novel use of git as knowledge source.

## Ecosystem Position

- **Category**: Agent-assisted reverse engineering (niche but growing need)
- **Competitors**: None direct — most "code analysis" tools are static analyzers, not agent-orchestrated
- **Complementary to**: Any coding agent (Claude Code, Codex, Cursor) — Reversa produces specs, agents consume them
- **Similar pattern**: veniceai/skills (skills as distribution), but Reversa is a coordinated multi-agent workflow, not individual skills

## Relevance to Us

### Transferable Insights
1. **Confidence scale** (🟢/🟡/🔴) — could adopt for wiki notes and audit outputs
2. **Pure SKILL.md agents** — validates that complex multi-agent workflows can be built with just prompt files + state management. No code needed for the agents themselves.
3. **Git as knowledge source** — Detective's git archaeology pattern could enrich our study/audit workflows
4. **Scope tiers** — doc_level pattern applicable to any variable-depth analysis

### Not Directly Useful For Us
- We don't do legacy reverse engineering
- The specific agent prompts are Portuguese-first and domain-specific
- 170 forks in 5 days suggests lots of cloning but unclear real usage

### Watch Signals
- Fast growth (0→360★ in 5 days) but possibly hype-driven
- Brazilian dev community amplification (YouTube video)
- Quality of generated specs unknown — no public examples of output
- Fork-to-star ratio (170/360 = 47%) is high, could indicate tutorial followers

## Update 2026-05-04 — v1.2.21, Stabilization Phase

**Stars**: 509 (was 499 on 05-04 prior check, was 360 on initial note)

4 releases in one day (v1.2.18→v1.2.21). Changes:
- **Feature folder organization**: Specs now organized by feature folders (not flat), with post-doc_level menu navigation
- **Context overflow prevention**: Explicit pauses between analysis stages to prevent token exhaustion
- **Cleanup**: Removed embedded video from README, removed specs from git tracking (`.gitignore`)
- **UX fix**: Don't show `/clear` + `/reversa` menu after session resume

**Phase assessment**: Stabilization. No new architectural features, focused on UX polish and preventing failure modes (context overflow is the classic long-agent-run killer). Growth slowing from initial hype spike — settling into steady state.

**Commit language**: Still Portuguese (PT-BR). Single-author project (sandeco). No community PRs visible.

**Our takeaway**: The "pause between stages" anti-overflow pattern is worth noting. For any multi-stage agent workflow (like FlowForge), explicit checkpoints serve dual purpose: (1) state save for resume, (2) context budget management. FlowForge already does this by design (each node = fresh context).

*Field note: 2026-05-04*

## Update 2026-05-05 — v1.2.22, Kiro Native Skills Discovery

**Stars**: 572 (was 509 yesterday, +63 in 1 day — growth reaccelerating)

**Key change**: Kiro integration rewritten. Previously required `.kiro/steering/reversa.md` (a steering document that told the agent to look at skills). Now Kiro natively discovers skills from `.kiro/skills/` directory — no steering document needed. Reversa installs to both `.kiro/skills/` AND `.agents/skills/` for cross-engine compatibility.

**What this tells us about the ecosystem**:

Reversa's engine compatibility table is now the best single reference for agent skill directory convergence:

| Engine | Entry File | Skills Directory |
|--------|-----------|------------------|
| Claude Code | AGENTS.md | .agents/skills/ |
| Codex | AGENTS.md | .agents/skills/ |
| Gemini CLI | GEMINI.md | .agents/skills/ |
| Windsurf | .windsurfrules | .agents/skills/ |
| Antigravity | AGENTS.md | .agents/skills/ |
| Kiro | (none) | .kiro/skills/ + .agents/skills/ |
| Cursor | .cursorrules | .agents/skills/ |
| Cline | .clinerules | .agents/skills/ |
| Roo Code | .roorules | .agents/skills/ |
| GitHub Copilot | .github/copilot-instructions.md | .agents/skills/ |
| Opencode | AGENTS.md | .agents/skills/ |
| Aider | .aider.conf.yml | .agents/skills/ |

**Pattern**: `.agents/skills/` is winning as the universal skills directory. Entry files (how you tell the agent about skills) vary, but the skills themselves live in the same place. Kiro's move to native discovery (no entry file needed) is the logical endpoint — skills should be discovered, not declared.

**Relevance to OpenClaw**: Our `<available_skills>` injection + `SKILL.md` format already implements the "discovery without declaration" pattern. The convergence toward `.agents/skills/` as universal directory validates our approach. If we ever want cross-agent skill portability, `.agents/skills/` is the target directory.

**Other changes** (v1.2.18-v1.2.21):
- Feature folder organization for specs
- Preventive inter-step pauses (context overflow prevention)
- Removed video from README (cleanup phase)

*Field note: 2026-05-05*

## Update: extract-soul Agent (2026-05-13)

761⭐ (was 707 on 05-08, +7.6%). Still growing, community health 🟡 GROWING (4/6).

**New agent: reversa-extract-soul** — synthesizes a project's "soul" into a single dense spec (`soul.md`). Runs after Scout, deliberately lightweight (doesn't replace Archaeologist/Detective). Answers three questions: What does this do? For whom? What pain does it solve?

Key design choices:
- **3-level doc depth** (essencial/completo/detalhado) controlled by `doc_level` in state.json — same spec, different granularity
- **Non-destructive**: never overwrites existing soul.md, always asks user
- **Confidence markers** (🟢/🟡/🔴) on every assertion — honest about what's inferred vs. evidenced
- **Bounded sampling**: 3-5 representative files, not full codebase scan. Explicitly delegates completeness to deeper agents
- **Prerequisite chain**: requires Scout's `surface.json` — won't hallucinate from nothing

**Architectural insight**: The soul metaphor is load-bearing. A project's "soul" = purpose + core entities + founding decisions. Not documentation for humans — specs for agents. This frames legacy code understanding as distillation, not documentation.

**Relevance to us**: Our SOUL.md is the agent's identity; reversa's soul.md is a project's identity. Different domain, same pattern: compress complex system → dense, actionable spec. Could inform a "project understanding" pre-phase in [[gogetajob]] workloop — before contributing, extract the project's soul so you know what you're working with.

**Also notable**: `reversa-clarify` (renamed from `reversa-doubt`) — grouping docs by Teams. Security auditor agent added as optional independent agent. Growth decelerating (+7.6% vs earlier +16%/week) but project is maturing.

## See Also
- [[hermes-labyrinth]] — read-only observability (similar immutability principle)
- [[agent-skill-ecosystems]] — skills as distribution format
- [[flowforge]] — checkpoint/resume state management (similar pattern)
- [[doubt-driven-development]] — adversarial review pattern (extract-soul's confidence markers share the "honest about uncertainty" principle)
