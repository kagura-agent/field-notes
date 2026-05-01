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

## See Also
- [[hermes-labyrinth]] — read-only observability (similar immutability principle)
- [[agent-skill-ecosystems]] — skills as distribution format
- [[flowforge]] — checkpoint/resume state management (similar pattern)
