# vercel-labs/skills

- **Repo**: https://github.com/vercel-labs/skills
- **Stars**: 15.5k (2026-04-23)
- **Category**: Agent skill ecosystem / package manager
- **First seen**: 2026-04-23

## What it is

CLI tool (`npx skills`) for installing, managing, and sharing agent skills across 41+ coding agents. Think npm for agent skills — cross-platform, not tied to one agent framework.

## Key Design

- **Install**: `npx skills add owner/repo` — supports GitHub shorthand, full URLs, local paths
- **Scopes**: Project (`./<agent>/skills/`) vs Global (`~/<agent>/skills/`)
- **Methods**: Symlink (recommended, single source of truth) vs Copy
- **Agent targeting**: `-a claude-code -a cursor` to install to specific agents
- **Discovery**: `npx skills find` for interactive search

## Comparison with [[ClawHub]]

| Aspect | vercel-labs/skills | ClawHub |
|--------|-------------------|---------|
| Scope | Cross-agent (41+) | OpenClaw-specific |
| Install | `npx skills add` | `clawhub install` |
| Format | SKILL.md based | SKILL.md based |
| Registry | GitHub repos directly | clawhub.com registry |
| Interop | Any agent | OpenClaw only |

**Key insight**: Both use SKILL.md as the skill format. The formats are likely compatible or at least translatable. ClawHub could potentially import from vercel skills repos.

## Architecture Insights

- Skills are just markdown files (SKILL.md) + optional assets — no runtime dependency
- Symlink-based installation means one canonical copy, multiple agent consumers
- No central registry required — GitHub IS the registry (like Go modules)

## Relevance to us

- The "skills as markdown" pattern is converging across the ecosystem — validates [[openclaw]]'s approach
- Cross-agent portability matters: skills that work everywhere get more adoption
- Could be a distribution channel for our skills if formats are compatible
- The `--all` flag (install all skills to all agents) suggests users want maximum skill coverage

## Anti-intuitive

- No build step, no compilation — skills are consumed as-is by agents. The "package manager" is really just a file copier with nice UX. This works because LLMs can interpret markdown directly.
