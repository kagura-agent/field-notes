---
title: "Composing Performance Skills"
created: 2026-05-10
tags: [agent-skills, performance, composition]
---

# Composing Performance Skills

The challenge of combining multiple agent skills without degrading performance.

## Key Tensions
- **Context budget**: Each skill adds system prompt tokens; composing many skills exhausts context
- **Instruction conflicts**: Skills may give contradictory guidance for the same situation
- **Priority resolution**: Which skill takes precedence when multiple match?
- **Loading strategy**: Eager (all at once) vs lazy (on-demand) skill loading

## Patterns
- **Selective loading**: Only load skills matching current intent (OpenClaw's approach)
- **Skill hierarchy**: L0 always-loaded, L1 on-demand, L2 deep-reference
- **Compression**: Distill verbose skills into compact directives (see [[invincat]])
- **Skill chaining**: One skill delegates to another rather than duplicating instructions

## Anti-patterns
- Loading all skills simultaneously (context overflow)
- Duplicating guidance across skills (drift risk)
- Skills that assume exclusive control of the agent

See also: [[skills-as-methodology]], [[agent-skill-ecosystem]]
