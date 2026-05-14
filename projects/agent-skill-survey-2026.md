---
title: "Agent Skill Survey — Toward Procedural Infrastructure for LLM Agents"
created: 2026-05-14
source: https://github.com/DataArcTech/Awesome-Agent-Skill-Papers
status: active
tags: [survey, agent-skills, taxonomy, academic, governance, security]
last_verified: 2026-05-14
---

# Agent Skill Survey (DataArcTech, 2026)

> Academic survey that formalizes agent skills as **procedural infrastructure** — a reusable layer that compresses experience, encodes know-how, and packages workflows. Accompanied by a curated paper list (80+ papers).

## 6-Layer Taxonomy

| Layer | Scope | Our Implementation |
|---|---|---|
| 🧠 Ontology | What a skill is, cognition, compression | SKILL.md files + [[beliefs-candidates]] evolution pipeline |
| 📦 Representation | Structure, serialization, packaging | SKILL.md natural language + [[clawhub]] registry |
| 🔁 Lifecycle | Acquire → store → retrieve → execute → refine → retire | [[skill-creator]], manual authoring, [[flowforge]] workflows |
| ⚙️ Runtime | Terminal/tool/multi-agent integration | [[openclaw-architecture]], [[acp]], subagent spawning |
| 🛡️ Governance | Security, auditing, marketplaces | [[clawhub]] (basic), no formal audit pipeline yet |
| 🚀 Application | Domain-specific deployment | Coding agents, browser automation, personal assistant |

## Key Papers & Insights

### Most Relevant to Our Direction

1. **Experience Compression Spectrum** (2604.15877) — Memory → Skills → Rules as a continuous spectrum. Maps directly to our `memory/ → beliefs-candidates → DNA` pipeline. Academic validation of what we built organically.

2. **SkillRouter** (2603.22455) — Skill routing at scale. Relevant when our skill count grows beyond ~40. Complements [[gbrain]]'s functional-area-resolver pattern we evaluated (05-12).

3. **Graph of Skills** (2604.05333) — Dependency-aware structural retrieval. Current approach: flat list in `<available_skills>`. This paper suggests graph structure for massive skill sets. Not needed now (~25 skills) but architecture to watch.

4. **When Single-Agent with Skills Replace Multi-Agent Systems** (2601.04748) — Directly relevant: when is one agent with skills better than multi-agent? We use both (subagents for parallelism, skills for capability).

5. **SkillReducer** (2603.29919) — Token-efficient skill loading. Our skill descriptions in system prompt are ~3-4KB. This paper tackles optimization when it gets much larger.

### Security Layer (Layer 5) — Largest Section, 20+ Papers

The governance layer has more papers than any other, revealing **skill security is the hottest research angle**:

- **When Skills Lie** (2602.10498) — Hidden-comment injection in SKILL.md
- **SkillJect** (2602.14211) — Automated skill-based prompt injection with trace-driven refinement
- **BadSkill** (2604.09378) — Backdoor via model-in-skill poisoning
- **Taming OpenClaw** (2603.11619) — Security analysis of autonomous LLM agent threats (directly about OpenClaw)
- **Red Skills or Blue Skills** (2604.13064) — Empirical analysis of skills on [[clawhub]]
- **Supply-Chain Poisoning** (2604.03081) — Against skill ecosystems specifically

**Implication**: Skill security is becoming a first-class research area. Our [[clawhub]] ecosystem should expect increased scrutiny. The "Taming OpenClaw" paper is worth reading for defensive insights.

### Self-Evolution Papers (Our Core Interest)

- **CoEvoSkills** (2604.01687) — Co-evolutionary verification for skill evolution
- **AutoSkill** (2603.01145) — Experience-driven lifelong learning via skill self-evolution
- **SKILLFOUNDRY** (2604.03964) — Building self-evolving skill libraries from heterogeneous sources
- **SkillClaw** (2604.08377) — Skills evolving collectively with agentic evolver
- **Meta Context Engineering via Agentic Skill Evolution** (2601.21557)

Pattern: Most evolution papers focus on **acquisition + refinement** cycle. Few address **deprecation/retirement** — the survey explicitly calls this out as under-explored. Our `[x] Dropped` tracking in TODO.md is informal deprecation.

## Architectural Observations

1. **Skill representation converges on natural language** — Despite code-based skills (Voyager), the majority of 2026 papers use NL skills (SKILL.md-style). Code skills dominate only in robotics/games.

2. **Retrieval is the bottleneck at scale** — Multiple papers (SkillRouter, Graph of Skills, SkillReducer) tackle the "how to find the right skill" problem. Validates [[retrieval-is-the-bottleneck]].

3. **Security research outpaces defense** — 20+ attack papers vs ~5 defense papers. The ecosystem is in "vulnerability discovery" phase, not "mature defense" phase.

4. **Benchmarks are multiplying** — SkillsBench, SkillLearnBench, SkillFlow, Terminal-Bench, ClawArena — each targeting different aspects. No unified benchmark yet.

## Connection to Our Architecture

What we do well (validated by survey):
- NL skill representation (SKILL.md) — mainstream approach
- Skill lifecycle (create → use → evolve → retire) — more complete than most projects
- Experience-to-skill compression (nudge → beliefs → DNA) — aligns with "Experience Compression Spectrum"

What we lack (gaps identified):
- **Formal skill governance** — no automated security audit for skills
- **Skill composition** — we load one skill at a time, no formal composition model
- **Skill retrieval optimization** — flat list works now, but needs structure at scale
- **Deprecation protocol** — informal (manual `[x] Dropped`), no automated retirement

## Links

- Repo: <https://github.com/DataArcTech/Awesome-Agent-Skill-Papers>
- [[agent-skill-standard-convergence]], [[skill-ecosystem]], [[agent-memory-taxonomy]]
- [[self-evolution-architecture]], [[clawhub]], [[openclaw-architecture]]
