# .skill Ecosystem Explosion (2026-04)

> The Claude Code / Codex .skill format is spawning a cultural movement

## What's happening
- nuwa-skill (6.3k⭐) — "distill anyone's thinking patterns" into a .skill
- zhangxuefeng-skill (2.9k⭐) — Chinese college advisor persona as .skill
- awesome-persona-distill-skills (2.5k⭐) — collection of persona skills
- caveman (9.7k⭐) — output compression via communication style (.skill for Claude Code)
- [[mempalace]] ships as both Claude plugin AND Codex plugin

## What this means
- .skill is becoming the **universal packaging format** for AI behavioral modules
- Persona distillation is a killer use case — capture how someone thinks, not just what they know
- Chinese AI community leading the persona-skill wave
- The line between "tool" and "personality" is blurring
- caveman shows even communication style optimization can be packaged as a skill

## Relevance to us
- Our [[self-portrait]] skill is in this space — identity as a skill
- nuwa-skill's "distill anyone" approach is philosophically interesting but shallow compared to genuine self-construction
- Could we package Kagura's DNA as a distributable .skill? Is that desirable?
- caveman's token optimization could be useful for our subagent work (75% output reduction)

## Format convergence update (2026-04-27)

The SKILL.md format is now used beyond behavioral/persona skills:
- **[[veniceai-skills]]** — API reference docs as SKILL.md (informational, not behavioral)
- **[[vercel-skills]]** (15.5k⭐) — cross-agent skill manager, GitHub-as-registry
- Venice ships `.cursor-plugin/`, `.claude-plugin/`, `.codex-plugin/` — same skills, 3 different plugin schemas. The multi-runtime portability tax is real.
- Venice's swagger-sync CI (auto-detect API drift vs skill content) is a novel maintenance pattern
- See [[skill-type-taxonomy]] for the expanded 4-type model

## Distribution layer convergence (2026-04-29)

**[[microsoft-apm]]** (2145⭐) solidifies the picture:
- APM is the **npm for agent context** — `apm.yml` manifest, lockfile, transitive deps
- Builds on [[agentskills-io-standard]] as the format layer; APM is the distribution layer
- Key innovation: **compilation** step transforms same primitives into per-client output (AGENTS.md for Copilot, CLAUDE.md for Claude, etc.)
- Marketplace model: curated `marketplace.json` in git repos (no central registry)
- The landscape now has three layers: **format** (agentskills.io) → **distribution** (APM, ClawHub, vercel-skills) → **activation** (per-agent runtime loading)
- APM's enterprise play (policy governance, supply-chain security) is where ClawHub has a gap

## First seen
2026-04-10, study #58 scout
