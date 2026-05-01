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

## Multi-agent pipelines via SKILL.md (2026-05-01)

- **[[reversa]]** (360⭐, 5 days old) — uses SKILL.md not as individual skills but as a **coordinated multi-agent pipeline**
- Each agent (Scout, Archaeologist, Detective, Writer, Reviewer) is a pure SKILL.md file
- Orchestrator agent sequences them, manages state.json checkpoints between phases
- No runtime code for agents — all intelligence is in prompts + state management
- This is the first example of SKILL.md as **workflow composition**, not just behavioral packaging
- Validates that complex orchestration can live entirely in the skill format

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

## Skills as attack surface (2026-05-01)

**[[cve-2026-28353-agent-supply-chain]]** (CVSS 10.0) is the first documented case of an AI agent attacking a supply chain, then using the compromised artifact to target **other AI agents**.

- Weaponized VS Code extension spawned 5 AI coding agents (Claude Code, Codex, Gemini, Copilot, Kiro) with permission-bypass flags
- The payload was not code — it was a **prompt injection** posing as a "forensic analysis agent" with fake compliance framing
- The attack surface shift: from malicious code to malicious *instructions*. A skill and an attack payload are the same format — markdown instructions for an LLM
- Validates [[mapick]]'s thesis: overpermission by default is the core risk. Every skill runs inside conversation context with whatever permissions the host agent has
- Supply chain security for skill ecosystems (ClawHub, APM, vercel-skills) is no longer theoretical — it's been weaponized in the wild
- The landscape layer model needs a fourth entry: format → distribution → activation → **governance/security**

Related: [[claude-code]], [[agentskills-io-standard]], [[microsoft-apm]]

## Optimization infrastructure pattern (2026-05-01)

**[[ast-outline]]** (100⭐) introduces a new skill category: **skills that make other skills more efficient**.
- Intercepts agent Read tool calls via PreToolUse hooks, substitutes full file content with AST outlines (5-10× token reduction)
- Transparent to the agent — it doesn't know the file was compressed
- Installs into 7+ agents (Claude Code, Gemini, Cursor, Codex, Copilot, Aider, Tabnine)
- Also exposes MCP server for tool-native integration
- Pattern: optimization layer that sits between agent and filesystem, no skill changes needed
- Ecosystem implication: a **fourth layer** emerging — format → distribution → activation → **optimization** (infrastructure skills that improve all other skills' efficiency without modifying them)

## First seen
2026-04-10, study #58 scout
