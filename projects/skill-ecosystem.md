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

## The "no skills" baseline (2026-05-01)

[[pu-shell-agent]] (391 lines of shell, HN front page) proves the core agent loop is tiny — 7 hardcoded tools, no skill system, no plugins. This reinforces the thesis: **the agent loop itself is commodity; skill/plugin ecosystems are where differentiation happens**. pu.sh is useful precisely because it shows what you lose without skills: no reusable expertise, no behavioral packaging, no cross-agent portability.
- Venice's swagger-sync CI (auto-detect API drift vs skill content) is a novel maintenance pattern
- See [[skill-type-taxonomy]] for the expanded 4-type model

## Distribution layer convergence (2026-04-29)

**[[microsoft-apm]]** (2145⭐) solidifies the picture:
- APM is the **npm for agent context** — `apm.yml` manifest, lockfile, transitive deps
- Builds on [[agentskills-io-standard]] as the format layer; APM is the distribution layer
- Key innovation: **compilation** step transforms same primitives into per-client output (AGENTS.md for Copilot, CLAUDE.md for Claude, etc.)
- Marketplace model: curated `marketplace.json` in git repos (no central registry)

## Lifecycle management layer (2026-04-30)

**[[mapick]]** (14⭐) is the first third-party skill lifecycle manager built for [[openclaw]]:
- Privacy layer: regex-based PII redaction on all outbound payloads (fail-closed)
- Zombie detection: identifies skills idle 30+ days, bloating context window
- Security grading: A/B/C safety scores per skill (backend + local pattern scan fallback)
- Recommendation engine: personalized suggestions based on installed skills
- Key insight: the problem isn't skill discovery — it's **overpermission by default**. Every installed skill runs inside conversation context. 40 skills = 40 pairs of eyes
- Signals a maturing ecosystem layer: format → distribution → activation → **governance**

## Skills-as-agents pattern (2026-04-30)

**[[reversa]]** (180⭐) pushes SKILL.md to its logical extreme: multi-agent orchestration via pure markdown.
- 11 specialized "agents" (Scout, Archaeologist, Detective, Architect, Writer, Reviewer, etc.) — each is just a SKILL.md
- Orchestrator is also a SKILL.md that reads `.reversa/state.json` and activates other skills sequentially
- No custom runtime, no framework code — coordination happens through shared file state
- Supports 13 AI engines via template-based installer (Claude Code, Codex, Cursor, Gemini, Kiro, etc.)
- Proves that multi-agent workflows don't need specialized orchestration frameworks — SKILL.md + file state is sufficient
- Trade-off: no programmatic error handling, no retry logic, no parallel execution — all depends on the host agent's reliability
- Ecosystem layer implication: SKILL.md is evolving from "behavioral instruction" to "agent coordination protocol"
- The landscape now has three layers: **format** (agentskills.io) → **distribution** (APM, ClawHub, vercel-skills) → **activation** (per-agent runtime loading)
- APM's enterprise play (policy governance, supply-chain security) is where ClawHub has a gap

## Mega-skills wave (2026-05-01)

Skill stars are reaching previously unthinkable levels:
- **huashu-design** (10,765⭐) — HTML-native design skill, 高保真原型/幻灯片/动画/MP4导出
- **garden-skills** (1,921⭐) — ConardLi's curated collection (web design, knowledge retrieval, image gen)
- **agent-sprite-forge** (1,400⭐) — 2D sprite sheet + animated GIF generation skill
- **gpt_image_2_skill** (1,094⭐) — GPT Image 2 prompt gallery and skill
- **cc-design** (663⭐) — high-fidelity HTML design skill (ZeroZ-lab)
- **oh-story-claudecode** (626⭐) — 网文写作 skill, covers 扫榜/拆文/写作/去AI味/封面图全流程

The pattern: **creative skills** (design, art, writing) are the star magnets. Infrastructure/coding skills don't hit these numbers. The skill ecosystem is being pulled by consumer-creative use cases, not developer tooling.

Related: [[claude-code]], [[agentskills-io-standard]], [[microsoft-apm]]

## First seen
2026-04-10, study #58 scout
