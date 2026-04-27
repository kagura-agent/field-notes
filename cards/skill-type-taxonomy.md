---
title: Skill Type Taxonomy
created: 2026-03-24
source: Claude Code skills ecosystem analysis
modified: 2026-03-24
---
Three types of "skills" are emerging in the agent ecosystem, but they have fundamentally different characteristics:

**Prompt Skills (coaching)**: Pure markdown, no code. Knowledge injection — agent reads and "knows" something. Example: slavingia/skills (entrepreneurship advice). Lowest barrier, highest quantity, lowest differentiation.

**Tool Skills (installation)**: Scripts, servers, dependencies. Traditional tools wrapped in skill format. Example: web-access (CDP proxy). Luna insight: "these are installation guides, not skills."

**System Skills (transformation)**: Modify agent DNA — SOUL.md, AGENTS.md, HEARTBEAT.md. Change how the agent operates, not just what it can do. Example: [[self-improving]]. Most valuable but most invasive. Cannot be cleanly "uninstalled."

The word "skill" is being overloaded. Need distinct vocabulary: skill (prompt) vs plugin (tool) vs system (transformation). See [[mechanism-vs-evolution]] — system skills aim for evolution, but most deliver mechanism.

**API Reference Skills (documentation)** *(added 2026-04-27)*: Structured API docs formatted for agent consumption. Not behavioral ("how to do X") but informational ("here's the API spec for X"). Example: [[veniceai-skills]] — each SKILL.md maps to an API surface area with endpoint tables, param specs, error matrices. Can be auto-generated from OpenAPI specs. The swagger-sync pattern (CI detects drift between spec and skill) is a freshness mechanism unique to this type.

The word "skill" is being overloaded. Need distinct vocabulary: skill (prompt) vs plugin (tool) vs system (transformation) vs reference (API docs). See [[mechanism-vs-evolution]] — system skills aim for evolution, but most deliver mechanism.

## Convergence signal (2026-04-27)

Despite type differences, all four types converge on **SKILL.md with YAML frontmatter** as the packaging format. Venice, Vercel ([[vercel-skills]]), and OpenClaw all use this convention independently. The format is becoming a de facto standard — the "package.json of agent knowledge."

Related: [[self-evolution-as-skill]], [[agent-publishing-identity]], [[veniceai-skills]], [[vercel-skills]]
