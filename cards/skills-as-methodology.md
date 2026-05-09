---
title: Skills-as-Methodology
created: 2026-05-09
---

# Skills-as-Methodology

A third category in the [[skill-type-taxonomy]], alongside skills-as-tools and skills-as-data.

## Definition

Skills that encode **process discipline** — how to work, not what tools to use or what data to reference. Pure behavioral guidance injected into agent context. Zero code dependencies.

## Examples

- **[[aegis]]**: 18 skills encoding architecture-driven development discipline (verification-before-completion, long-task-continuation, repair+retirement tracking)
- **[[invincat]]**: Prompt compression and decision-order optimization for coding agents
- Our own **AGENTS.md/SOUL.md**: verification discipline, memory hygiene, DNA self-governance — these ARE methodology skills, just not packaged as portable SKILL.md files
- **[[compose-performance-skills]]** (skydoves, 351⭐): Jetpack Compose performance practices as agent skills

## Key Properties

1. **Host-agnostic**: No runtime code means they work on any agent CLI that reads SKILL.md
2. **Zero dependencies**: Unlike tools/MCP, nothing to install beyond the text files
3. **Composable**: Each skill is independent; use 1 or all 18
4. **Transferable**: Encode expert knowledge that would otherwise live in senior developer heads
5. **Hard to evaluate**: Unlike tools (did it work?) or data (was it accurate?), methodology effectiveness is measured in process quality, not output correctness

## Implications

- The skill ecosystem isn't just about capability extension — it's also about **knowledge transfer at scale**
- Method packs could become the "coding standards" of the agent era — instead of linters and style guides, you ship behavioral skills
- Harder to monetize than tool skills (no API, no data moat) but potentially higher impact on team velocity

## Tension with Evaluation

[[agent-skills-eval]] tests skills by comparing with_skill vs without_skill output quality. This works well for tool and data skills. For methodology skills, the "output" is process quality (did the agent verify before claiming done? did it checkpoint?), which is harder to grade automatically. The eval gap for methodology skills is an open problem.

Links: [[skill-type-taxonomy]], [[aegis]], [[invincat]], [[thin-harness-fat-skills]], [[agent-skills-eval]], [[agent-skill-standard-convergence]]
