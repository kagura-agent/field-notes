# Constitution Layering

Structuring agent instructions as a layered hierarchy instead of a flat document.

## Pattern

Instead of one monolithic instruction file, split into layers with explicit precedence:

1. **Core identity** — who you are, non-negotiable values (SOUL.md equivalent)
2. **Project rules** — repo-specific conventions, tech stack constraints
3. **Engineering standards** — code quality, testing, review process
4. **Workflow instructions** — step-by-step procedures for specific tasks

Higher layers override lower layers on conflict.

## Examples

| Project | Layers | Mechanism |
|---------|--------|-----------|
| SwarmForge | constitution.prompt → per-role .prompt files | File inclusion with precedence rules |
| OpenClaw/Kagura | SOUL.md + AGENTS.md + SKILL.md per task | Flat — AGENTS.md mixes all concerns |
| ACE (Agentic Context Engineering) | system → project → task context | Programmatic context assembly |

## Key Insight

Flat instruction files grow unbounded and mix concerns. SwarmForge's approach (project/engineering/workflow split) keeps each layer focused. The agent reads all layers but knows which takes precedence.

## Our DNA Assessment (2026-04-22)

Current state:
- `SOUL.md` (34 lines) — clean, identity only ✅
- `AGENTS.md` (212 lines) — **mixed concerns**: workspace rules + memory + safety + validation + social + tools + heartbeat + subagent + DNA governance
- Skills — per-task procedures ✅

**Improvement opportunity**: AGENTS.md could split into:
- `AGENTS.md` — workspace rules, memory, safety (core operating)
- Engineering/validation rules → could live in a dedicated file or workflow nodes
- Social/group chat rules → could live in channel-specific config

**Decision**: Not worth splitting now — OpenClaw injects workspace files automatically, adding more files = more context tokens. The layering insight is more useful for **team-lead scenarios** where each agent role gets different instruction subsets.

## Application

- For team-lead multi-agent work: give each agent role-specific constitution (architect sees design rules, coder sees engineering standards)
- For skill design: skills already act as "workflow layer" — validate they don't duplicate AGENTS.md rules

## Related

- [[swarm-forge]] — source of this pattern
- [[ace-agentic-context-engineering]] — programmatic context layering
- [[genericagent]] — single-agent self-evolution with DNA files

#pattern #prompt-engineering #multi-agent
