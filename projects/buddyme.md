---
title: "buddyMe — Multi-Model Agent with Layered Personality"
created: 2026-05-10
source: https://github.com/virgo777/buddyme
stars: 30
star_history: "30 (05-10, day 1)"
status: noted
tags: [agent-framework, personality, heartbeat, skill-ecosystem, chinese-dev]
---

# buddyMe

> Python multi-model agent framework with layered personality, three-tier skill loading, and heartbeat memory.

By virgo777. MIT. Created 2026-05-10 (brand new). 30⭐ on day 1.

## Architecture — Why It's Interesting

### Brain Directory = Our DNA Files

The `initspace/brain/` directory mirrors our workspace DNA files almost exactly:

| buddyMe | OpenClaw/Kagura | Purpose |
|---------|-----------------|---------|
| SOUL.md | SOUL.md | Personality core (L0) |
| IDENTITY.md | IDENTITY.md | Role definition (L1) |
| AGENT.md | AGENTS.md | Behavioral contract |
| HEARTBEAT.md | HEARTBEAT.md | Heartbeat task specs |
| USER.md | USER.md | User profile/preferences |
| SUB_AGENT.md | (inline in AGENTS.md) | Sub-agent rules |

This is **convergent evolution** — an independent Chinese developer arrived at the same file taxonomy we use. This validates our approach as a natural organizational pattern, not an idiosyncratic choice.

### Three-Tier Skill Loading

`skill_loader.py` implements progressive loading following [[agentskills-io-standard]]:

1. **L1 (metadata)**: Name + description injected into system prompt at startup → model knows what skills exist
2. **L2 (instructions)**: Full SKILL.md body loaded when user need matches → on-demand context injection
3. **L3 (resources)**: Scripts, references, assets loaded only during execution → minimal context pollution

This is the same pattern OpenClaw uses (scan descriptions → read SKILL.md when matched → execute). The difference: buddyMe made it explicit as a 3-level taxonomy. Worth adopting this vocabulary.

### Loop Skill Auto-Generation

The most novel mechanism: `loop_skill_manager.py` records the tool call chain from a successful first execution and auto-generates a `skill.json` for subsequent runs. This means:
- First `/loop` run: full LLM reasoning
- Subsequent runs: deterministic replay of tool calls (no LLM needed)

This is a **skill crystallization** pattern — [[mechanism-vs-evolution]] territory. An agent discovers a procedure, then hardcodes it. Smart for reducing token cost on repetitive tasks.

Limitation: `edit_file` calls are explicitly excluded (non-deterministic), so skills involving code edits can't crystallize.

### Heartbeat System

`heartbeat.py` is a pure data layer — config/schedule management, no execution logic. Execution lives in `Agent.tick()`. Supports:
- Interval-based triggers (every N minutes)
- Schedule-based triggers (specific time of day, ±5 min tolerance)
- Active hours window
- Per-task timeout

Simpler than our heartbeat (no cron, no nudge hooks), but the separation of config from execution is clean.

## Connection to Our Direction

1. **Validation signal**: Independent arrival at SOUL/IDENTITY/AGENT/HEARTBEAT/USER file taxonomy confirms this is a natural pattern for agent self-organization. See [[worktree-convergence-2026-05]].
2. **Skill crystallization**: The loop-to-skill auto-generation is a concrete implementation of [[self-evolution-as-skill]]. We could apply this pattern to FlowForge — auto-generate workflow steps from successful ad-hoc tool chains.
3. **Chinese developer ecosystem**: Uses GLM, DeepSeek, ERNIE, Qwen, MiMo — all Chinese models. This is a China-focused agent framework, indicating the agent-skills pattern has crossed the cultural boundary.

## Limitations / Critique

- No tests at all (no test directory found)
- Python-only, CLI-only — no platform integrations (Discord, Feishu, etc.)
- Memory is conversation-log-based (JSON) — no semantic search, no wiki, no structured knowledge
- 25 bundled skills are all static instruction files — no dynamic tool registration beyond the built-in 8
- Solo developer project, day 1 — high risk of abandonment
- Blog link is a raw IP address (49.235.53.176) — low polish signal

## Verdict

**Not worth tracking** — too early, too small, solo Chinese dev project with no community. But architecturally interesting as convergence evidence. The three-tier skill loading vocabulary and loop-skill crystallization are the two takeaways.
