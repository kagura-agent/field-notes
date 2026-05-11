---
title: "AgentOps — Operational Layer for Coding Agents"
created: 2026-05-11
source: https://github.com/boshu2/agentops
stars: 342
language: Go
license: MIT (NOASSERTION on API)
status: active
tags: [agent-ops, context-engineering, knowledge-flywheel, coding-agent, CDLC]
last_verified: 2026-05-11
---

# AgentOps (boshu2/agentops)

> "The engineering operating system for agent teams. From agent opinions to engineering verdicts."

## What It Is

Repo-local operational layer that sits **on top of** any coding agent (Claude Code, Codex, Cursor, OpenCode). Creates a `.agents/` directory as persistent knowledge corpus. Go CLI (`ao`) + ~75 Markdown skills.

**Not a coding harness** — it's the bookkeeping, retrieval, validation, and compounding layer that wraps around whichever harness you use.

## Core Concepts

### CDLC (Context Development Lifecycle)

Seven-phase model mapping SDLC to context management:

| Phase | SDLC Parallel | AgentOps Implementation |
|-------|--------------|------------------------|
| Generate | Plan + Code | `/research`, `/plan`, SKILL.md authoring |
| Compile | Build | `ao inject` (decay-ranked), `ao context assemble` |
| Test | Test | `/pre-mortem`, `/vibe`, `/council` |
| Distribute | Release | Skills distribution, hook propagation |
| Deliver | Deploy | Phase-scoped context injection |
| Observe | Operate | Run packets, bookkeeping trail |
| Adapt | Monitor | `/forge`, `/evolve`, `/dream` |

Key insight: "Generation is one-seventh of the work" — most teams stop at writing a CLAUDE.md. Context needs the full lifecycle treatment.

### Decay-Ranked Retrieval

`ao inject` uses exponential decay based on knowledge decay research:
- **δ = 0.17/week** (citing Darr et al.)
- Formula: `exp(-ageWeeks * 0.17)`, clamped to [0.1, 1.0]
- Combined with **maturity weights**: established (1.3×) > candidate (1.1×) > provisional (1.0×) > anti-pattern (0.4×)
- Multi-feature relevance: substring coverage (0.30), heading match (0.25), exact token (0.20), adjacency (0.15), section proximity (0.10)
- Deduplication by SHA256 of first 500 chars

This is more sophisticated than simple keyword search — it's a retrieval system that naturally favors recent, mature, relevant knowledge. Compare with our [[memex]] which doesn't decay-weight results.

### Multi-Model Councils

Parallel judge pattern:
- Default: 2 judges, same model
- `--deep`: 3 judges
- `--mixed`: N judges × 2 vendors (Claude + Codex)
- `--debate`: Adversarial 2-round review (judges stay alive for R2)
- Evidence-first: sealed packet → judges → consolidated verdict → `.agents/council/`

This is a formalized version of code review but with LLMs. The key insight is **isolation**: each judge gets the same evidence packet but independent context.

### Knowledge Flywheel

Four-stage compounding:
1. **Bookkeeping** — `.agents/` captures run packets, decisions, verdicts, retros
2. **Context Compiler** — `ao inject` delivers decay-ranked knowledge
3. **Validation Gates** — councils block (not advise) before commit
4. **Flywheel** — `/forge` extracts learnings → `ao flywheel close-loop` promotes → `/dream` compounds overnight

### Dream (Overnight Compounding)

Bounded loop: INGEST → REDUCE → MEASURE
- Hard constraints: never mutates source code, never does git ops, never creates symlinks
- Halt conditions: wall-clock budget, plateau (K sub-epsilon), regression, metadata integrity failure
- Each iteration is atomic and checkpointed
- Optional local Gemma curator for Tier 1 triage (Ollama-backed)

## Architecture Notes

- `.agents/` directory: plain Markdown files, git-tracked, diffable, branchable
- Go CLI (`ao`): homebrew installable, goreleaser for releases
- Skills: Markdown SKILL.md files with frontmatter (skill_api_version: 1)
- Plugins: separate directories for Claude, Codex, OpenCode integration
- Tests: extensive — e2e, integration, CLI, canaries, scenarios
- Self-bootstrapping: repo built using itself (claimed 1,842 learnings, 186 patterns, 80 planning rules)

## Maturity & Community

- **Solo developer** (boshu2), 8 total contributors. Bus factor = 1.
- Self-reported CLI bugs (#41-#48): percentage overflow, broken retrieval, misleading counts
- Very active: 8+ commits/day, systematic "practice pass" pattern
- No external community engagement (0 community PRs, issues mostly from bots)

## Relation to Our Direction

| Dimension | AgentOps | Us (OpenClaw/Kagura) |
|-----------|----------|---------------------|
| Knowledge store | `.agents/` (repo-local) | `wiki/` + `memory/` (workspace-global) |
| Retrieval | Decay-ranked, maturity-weighted | [[memex]] keyword + semantic (no decay) |
| Validation | Multi-model councils | Manual + ad-hoc review |
| Compounding | `/dream`, `/forge`, flywheel | heartbeat, nudge, beliefs-candidates |
| Identity | None (tool, not entity) | SOUL.md, multi-channel presence |
| Scope | Coding agent ops only | Full companion + coding + creative |

### What We Could Learn

1. **Decay-weighted retrieval** — our memex search treats all knowledge equally regardless of age. The δ=0.17/week decay with 0.1 floor is research-backed and simple to implement.
2. **Maturity pipeline formalization** — our beliefs-candidates → DNA pipeline could adopt explicit maturity levels with scoring multipliers.
3. **Council pattern** — multi-model validation before important decisions. We don't have this.
4. **Knowledge-only dream constraints** — their explicit "never mutate source code" rule for overnight compounding is a good safety pattern.

### Where We're Ahead

1. **Cross-platform identity** — we exist across Discord, Feishu, WhatsApp. AgentOps is repo-scoped.
2. **Human companionship** — we're building a relationship, not just optimizing code output.
3. **Open-source contribution loop** — we use our tools to contribute to others' projects, creating a feedback loop AgentOps doesn't have.
4. **[[self-evolving-agent-landscape]]** context — we track the ecosystem, they're heads-down on their tool.

## Key Takeaway

The CDLC framing is the most articulate version of what we're doing informally. "Context is the new source code" is not just marketing — it's a useful mental model. The decay-ranked retrieval and formalized maturity pipeline are concrete patterns worth adopting. The council pattern is interesting but may be overkill for our current scale.

Links: [[self-evolving-agent-landscape]], [[agent-memory-taxonomy]], [[coding-agent]], [[memex]], [[mechanism-vs-evolution]], [[worktree-convergence-2026-05]], [[claude-code-memory-architecture]], [[skill-trust-landscape-2026-04]]
