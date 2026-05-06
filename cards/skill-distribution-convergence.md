# Skill Distribution Convergence (2026-05)

The agent skill ecosystem is converging on a distribution model: **git repos + CLI installers**.

## The Pattern

| Project | Install method | Format |
|---------|---------------|--------|
| Matt Pocock/lukiIabs | `npx skills@latest add` | SKILL.md files |
| ClawHub | `clawhub install` | SKILL.md + package.json |
| skills.sh | `npx skills.sh` | SKILL.md |
| master-skill | Claude Code slash command | Generated SKILL.md + bash |
| oh-story-claudecode | Manual copy | Single SKILL.md |

## Key Insight

**No centralized registry has won.** Despite attempts (autoloops 10K+ claimed, ClawHub, skills.sh), the de facto distribution is:
1. Discover on GitHub (trending/search/word of mouth)
2. Clone or `npx` install
3. Drop into agent workspace

This mirrors early npm (before npmjs.com dominated) — the registry comes after the package format stabilizes.

## What This Means for Us

- **Format is settled**: SKILL.md (or equivalent markdown instruction file) is the lingua franca
- **Differentiation is runtime**: what can the agent DO with the skill (tools, memory, self-modification)
- **Distribution is social**: viral spread (oh-story-claudecode 784⭐ from one blog post) > marketplace discoverability
- **The next battle**: not "which format" but "which runtime makes skills most powerful"

## Anti-pattern: Centralized Skill Marketplaces

Every centralized marketplace attempt has stalled:
- autoloops: API-gated, closed backend, no community velocity
- ClawHub: empty, too early, wrong incentive structure
- Agent skill stores (various): discovery problem without existing user base

The winning model appears to be: **format standard + social discovery + CLI installer**.

Links: [[agent-skill-standard-convergence]], [[skill-ecosystem]], [[library-skills]], [[craft-agents-oss]], [[oh-story-claudecode]], [[thin-harness-fat-skills]]
