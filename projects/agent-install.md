# agent-install (millionco)

Universal skill & MCP installer for 45+ coding agents.

- **Repo**: <https://github.com/millionco/agent-install>
- **Stars**: 39 (2026-05-04)
- **Created**: 2026-05-01
- **Language**: TypeScript (monorepo, vite-plus build)
- **License**: (not checked, likely MIT/Apache)

## What It Does

One CLI/API to install agent skills and MCP servers across every major coding agent:
```bash
npx agent-install skill add owner/repo -a cursor
npx agent-install mcp add https://mcp.example.com -a claude-code
```

Three surfaces:
1. **skill** — install SKILL.md repos into agent-specific directories
2. **mcp** — install MCP server configs into JSON/JSONC/YAML/TOML agent configs
3. **agents-md** — read/write sections in AGENTS.md files

## Architecture

### Agent Registry (45+ agents)

Each agent has: `skillsDir`, `globalSkillsDir`, `detectInstalled()`, `isUniversal`.

"Universal" agents (Cursor, Codex, Gemini CLI, Pi, OpenCode, Kimi CLI, etc.) all read from `.agents/skills` — a canonical location. Non-universal agents have their own paths (`.claude/skills`, `.openclaw/skills`, `.windsurf/skills`, etc.).

**OpenClaw is supported**: resolves `.openclaw` → `.clawdbot` → `.moltbot` legacy paths.

### Symlink-First Installation

1. Copy skill to canonical `.agents/skills/<name>/`
2. For each target agent, create symlink from their skills dir to canonical
3. Fallback to copy if symlink fails (Windows, cross-device)

This means one skill install serves all universal agents simultaneously.

### Source Resolution

- GitHub/GitLab shorthand: `owner/repo`, `owner/repo#branch`, `owner/repo/path/to/skill`
- URLs: full git URLs, tree URLs with subpath
- Local paths: `./my-skill`, `/abs/path`
- **Well-known discovery**: HTTP `/.well-known/agent-skills/index.json` — any website can expose a skill registry

### Well-Known Protocol

Any server can host:
```json
// https://example.com/.well-known/agent-skills/index.json
[
  { "name": "my-skill", "description": "...", "files": ["SKILL.md", "helpers.md"] }
]
```

agent-install fetches the index, downloads listed files to a temp dir, installs.

## Relevance to Us

### vs ClawHub

| | ClawHub | agent-install |
|---|---|---|
| Role | Registry + marketplace | Installer + source resolver |
| Distribution | Own marketplace | GitHub repos + well-known + local |
| Target | OpenClaw only | 45+ agents |
| Discovery | `clawhub search` | GitHub shorthand + well-known |

They're complementary: ClawHub could **emit** well-known indexes that agent-install consumes. Or ClawHub could integrate agent-install as its install backend.

### Key Insights

1. **The "universal" pattern won**: ~15 agents read from `.agents/skills`. This is becoming a de facto standard path. OpenClaw's `/skills` dir is non-standard but supported.

2. **Symlink is the right abstraction**: Install once, serve many. This is exactly what we'd want if OpenClaw skills need to work in Claude Code sessions too.

3. **Well-known is clever**: No central registry needed. Any project/domain can self-host a skill index. Decentralized but discoverable.

4. **The installer layer was missing**: Between "write a SKILL.md" and "an agent loads it" there was no standard tool. agent-install fills that gap — it's `npm install` for agent skills.

5. **45 agents is the real story**: The sheer fragmentation of coding agents in 2026 makes a universal installer valuable. The skill format is converging (SKILL.md) but the installation paths aren't.

## Ecosystem Position

- **Upstream**: Skill authors (write SKILL.md repos)
- **This**: Universal installer (resolves source → places files)
- **Downstream**: Agent runtimes (load skills from known paths)
- **Competitors**: Each agent's own install mechanism; ClawHub for OpenClaw; Claude Code's plugin marketplace
- **Related**: [[skill-category-split]], [[library-skills]], [[agent-marketplace-landscape]], [[self-evolving-agent-landscape]]

## Observations

- Single push (May 1), 39⭐ in 3 days — good early traction
- Monorepo with website suggests commercial intent (millionco)
- Test coverage is solid (unit + e2e for each surface)
- The agent list itself is a valuable competitive intelligence map of the 2026 coding agent landscape
