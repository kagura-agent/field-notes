---
title: "Agent Skill Ecosystem"
created: 2026-05-10
tags: [ecosystem, agent-skills, landscape]
---

# Agent Skill Ecosystem

The emerging ecosystem of shareable, composable agent skills — instructions, tools, and workflows that agents can install and use.

## Key Players
- **ClawHub**: OpenClaw's skill registry (early, marketplace empty)
- **agentskills.io**: Skill discovery and evaluation platform
- **addyosmani/agent-skills**: Viral curated list (33K+ ⭐)
- **library-skills**: Skills embedded in library packages (tiangolo pattern)

## Patterns
- **Skill-as-SKILL.md**: Markdown instruction files loaded into agent context
- **Skill-as-MCP**: Tool servers exposed via MCP protocol
- **Skill-as-workflow**: Executable pipelines (FlowForge, SKILL.mk)
- **Skill-as-methodology**: Domain expertise distilled into agent instructions (see [[skills-as-methodology]])

## Challenges
- No standard format (every framework invents its own)
- Quality varies wildly — most skills are untested
- Composability is unsolved (see [[compose-performance-skills]])
- Discovery/trust mechanisms immature

## Evaluation
- [[agent-skills-eval]]: Test runners for skill quality assessment
- Manual A/B: Run with/without skill, compare output quality

See also: [[compose-performance-skills]], [[skills-as-methodology]], [[mcp-vs-native-tools]]
