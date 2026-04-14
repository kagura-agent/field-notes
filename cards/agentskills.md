# AgentSkills

OpenClaw's modular skill system — each skill is a directory with a SKILL.md that teaches the agent how to use a specific capability.

## Structure
```
skill-name/
  SKILL.md          # Instructions (loaded into context)
  scripts/          # Executable scripts
  references/       # Reference docs (read on demand)
```

## Key Properties
- **Lazy loading**: skills loaded on-demand based on task matching
- **Tiered context**: full → mixed-tier → compact based on context pressure
- **Frontmatter**: name, description, tier metadata
- **Discovery**: agent scans `<available_skills>` descriptions to decide which to load

## Ecosystem Trend
Skill-based agent architecture is converging across platforms:
- OpenClaw: AgentSkills
- [[gbrain]]: GBRAIN_SKILLPACK.md
- Nanobot: agents/*.md
- See [[thin-harness-fat-skills]] for the architectural pattern

## Links
[[openclaw]] [[skill-ecosystem]] [[thin-harness-fat-skills]] [[openclaw-architecture]]
