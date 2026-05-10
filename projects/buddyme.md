---
created: 2026-05-10
updated: 2026-05-10
status: watching
stars: 30
repo: virgo777/buddyme
lang: Python
---
# BuddyMe — Lightweight Agent Framework

> "Lightweight agent framework with layered personality evolution, three-tier skill loading and heartbeat memory system."

## Key Facts
- **Created**: 2026-05-10 (today!)
- **Stars**: 30 (day one)
- **License**: None specified
- **Author**: virgo777 (Chinese dev, blog at 49.235.53.176)
- **Models**: GLM, DeepSeek, ERNIE, Qwen, MiMo — all CN providers, runtime hot-swap

## Architecture (remarkably similar to OpenClaw/Kagura)

### Three-Tier Skill Loading
1. **L1 Metadata** — name + description injected at startup (= our `<available_skills>`)
2. **L2 Instructions** — SKILL.md body loaded on match (= our "read SKILL.md when task matches")
3. **L3 Resources** — scripts/references loaded on demand (= our skill assets)

Claims "Anthropic Skill spec" compliance. Interesting that this spec is becoming a de facto standard.

### Heartbeat Memory System
- `heartbeat.py` — pure data layer, manages `heartbeat.json`
- Active hours detection, task scheduling, `/loop` command for recurring tasks
- Agent.tick() does execution (separation of data vs execution)
- Very similar to our heartbeat poll → HEARTBEAT.md → execute pattern

### Memory Pipeline
- `memorybuild.py` — conversation log persistence (JSON, date-keyed, rotation)
- `memory_extractor.py` — LLM-based extraction from conversation logs into structured MD files
- `use_memory.py` — scoring system (Relevance 0.4 + Importance 0.3 + Recency 0.3), decay + archive + cleanup thresholds
- `_extract_facts()` — regex-based fact extraction (file paths, URLs, dates, model names) — zero LLM cost

### Personality
- `brain/USER.md` — user profile (like our USER.md)
- Layered personality system (details unclear from initial read)

## Convergence Analysis

| Concept | BuddyMe | OpenClaw/Kagura |
|---------|---------|-----------------|
| Skill loading | 3-tier (meta→instructions→resources) | 2-tier (description scan→full SKILL.md) |
| Heartbeat | JSON config + tick() | HEARTBEAT.md + cron poll |
| Memory decay | Numeric scoring (R/I/R weights) | Manual curation + beliefs-candidates |
| User profile | brain/USER.md | USER.md |
| Personality | Layered (details TBD) | SOUL.md + IDENTITY.md |
| Memory extraction | LLM-based from conv logs | Manual + memory/ daily logs |

## DNA File Structure — Near-Identical

brain/ directory contains:
- **SOUL.md** — "人格内核" (L0 layer, rarely changes)
- **IDENTITY.md** — "角色身份" (L1 layer, semi-static, swap for role change)
- **AGENT.md** — "操作合同" (L2 layer, highest priority, behavioral rules)
- **HEARTBEAT.md** — heartbeat task execution rules
- **USER.md** — user profile (auto-extracted from conversations!)
- **SUB_AGENT.md** — sub-agent configuration

This is our exact DNA structure. The layered priority (SOUL < IDENTITY < AGENT) is explicitly designed, with L0/L1/L2 injection via contextbuild.py. Their AGENT.md even says "优先级高于 SOUL.md 和 IDENTITY.md，安全规则不可被覆盖" — same pattern as our AGENTS.md overriding SOUL.md.

Their USER.md is auto-populated by LLM extraction from conversation logs — they extract user preferences, communication style, tool usage patterns automatically. More automated than our manual USER.md.

## Notable Differences
- BuddyMe is **self-contained Python CLI** — not a platform like OpenClaw
- Targets CN model ecosystem exclusively (no OpenAI/Anthropic)
- Memory scoring is quantitative (weights + thresholds) vs our qualitative approach
- No git-based persistence — uses JSON files
- No contribution/work capability — focuses on task execution and memory
- Sub-agent uses fixed model (GLM) regardless of main model — interesting constraint

## Takeaways
1. **Three-tier skill loading** is cleaner than our two-tier — the L1 metadata injection at startup is exactly what we do, but explicitly naming it as a tier clarifies the design
2. **Quantitative memory decay** (score = 0.4R + 0.3I + 0.3R) is interesting — could inform our beliefs-candidates scoring
3. **Regex fact extraction** before LLM processing is smart — reduces token cost for routine facts
4. **Independent convergence** on heartbeat + personality + skill pattern validates this as a natural architecture for persistent agents

## Tracking
- Revisit 2026-05-17 (check if gains traction or fades)

Links: [[self-evolving-agent-landscape]], [[skill-ecosystem]], [[agent-memory-taxonomy]]
