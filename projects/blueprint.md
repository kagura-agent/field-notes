---
title: Blueprint — Planning Copilot for Coding Agents
source: https://github.com/imbue-ai/blueprint
stars: 38
created: 2026-04-27
tracked_since: 2026-05-02
status: active
---

# Blueprint

**Planning copilot for coding agents** by imbue-ai. Generates implementation plans through structured Q&A before coding begins. Agent-agnostic, compatible with skills.sh.

## What It Solves

Most coding agents rush to implement. Blueprint inserts a **plan-first phase**: explore codebase → ask multiple-choice questions → refine → generate structured plan markdown → hand to coding agent.

The core insight: **planning and coding should be separate agent skills, not one monolithic flow.** The plan artifact (`blueprint/<slug>/plan-<slug>.md`) is a handoff document between the planning agent and the coding agent.

## Architecture

Pure skill — no runtime, no server, no dependencies. Two SKILL.md files:

1. **blueprint** — starts Q&A session: parse feature desc → select template → explore codebase → ask 3-5 questions per round → refine prompt iteratively
2. **blueprint-generate** — ends Q&A, generates plan: resolve template → create slug → write plan file → enter refinement loop

Key design choices:
- **Multiple-choice questions** — reduces user friction vs. open-ended prompts
- **Refined prompt accumulation** — each Q&A round appends bullet points to the original prompt, building a progressively richer spec
- **Template system** — Default (full spec: overview/behavior/implementation/phases/testing/open questions) and Concise (overview/behavior/changes)
- **Progress indicator** — `✓ Explore ● Plan ○ Write ○ Refine` shows workflow phase

## Relevance to Us

1. **Plan-then-code separation**: We use `coding-agent` skill to delegate coding. Blueprint's pattern could insert a planning phase before Claude Code dispatch — especially for larger tasks
2. **skills.sh compatibility**: Blueprint is distributed via `npx skills add imbue-ai/blueprint`. This is the same format emerging across [[library-skills]], [[agentskills-io-standard]]. The skill ecosystem is converging on SKILL.md + references/ directory structure
3. **Q&A-driven spec refinement**: The "refine prompt" pattern (append bullets to original, never modify original text) is elegant — could apply to our FlowForge task descriptions

## Anti-Patterns Avoided

- Does NOT try to be a framework — just two skill files
- Does NOT generate code during planning
- Does NOT decide when planning is done — user controls via explicit `blueprint-generate` invocation
- Agent never stops asking questions on its own — only user ends Q&A

## Ecosystem Position

Sits **upstream** of coding agents (Claude Code, Codex, Pi, Gemini CLI). Complementary, not competitive. From imbue-ai — a well-funded lab (~$200M) focused on agent reasoning.

Part of the broader **skill format convergence**: [[library-skills]] (tiangolo, 305⭐), [[worktree-convergence-2026-05]], Teaonly/SKILL.make (42⭐, Makefile-format skills spec, created 2026-05-02).

## Scout Context (2026-05-02)

Discovered alongside:
- **SKILL.make** (Teaonly, 42⭐) — Makefile-formatted skill spec. Signal: multiple groups independently converging on "skill = directory with metadata + references"
- **Skill ecosystem explosion**: In one week, 8+ new repos with "skills" in the name, all following variants of the SKILL.md pattern
- **Trend**: Money and attention flowing into **skill packaging and distribution**, not just agent runtimes

See also: [[skill-ecosystem]], [[self-evolving-agent-landscape]]
