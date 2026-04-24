# Claude Code Changelog Highlights (April 2026)

> Tracked from v2.1.117-119 (April 22-24, 2026)
> Last updated: 2026-04-24

## Key Changes (v2.1.118-119)

### `--print` Mode Now Honors Agent Frontmatter (v2.1.119)
- **What**: `--print` mode now honors the agent's `tools:` and `disallowedTools:` frontmatter, matching interactive-mode behavior
- **Why it matters**: We use `claude --print --permission-mode bypassPermissions` extensively for [[coding-agent]] subagent work. Previously, `--print` ignored tool restrictions defined in agent files — now agent definitions are fully respected in headless mode
- **Impact on us**: If we create custom agent definitions with tool restrictions (e.g. read-only researcher), they now work correctly in `--print` mode. This makes headless subagent specialization viable
- **Related**: `--agent <name>` also now honors `permissionMode` for built-in agents

### Hooks: `duration_ms` in PostToolUse (v2.1.119)
- `PostToolUse` and `PostToolUseFailure` hook inputs now include `duration_ms` (tool execution time, excluding permission prompts)
- Enables performance monitoring of tool usage — useful for identifying slow tools in automated workflows
- Related: [[claude-code-plugins]] hooks system

### MCP Improvements (v2.1.119)
- Subagent and SDK MCP server reconfiguration now connects servers **in parallel** instead of serially
- Multiple OAuth fixes: refresh races, token storage corruption, step-up authorization
- Fixed MCP HTTP connections failing with OAuth discovery on non-JSON bodies

### Vim Visual Mode (v2.1.118)
- Full visual mode (`v`) and visual-line mode (`V`) with selection and operators
- Not relevant to headless usage but shows investment in interactive UX

### Hooks Can Invoke MCP Tools (v2.1.118)
- `type: "mcp_tool"` — hooks can now directly call MCP tools
- Combined with `duration_ms`, enables sophisticated hook pipelines: measure tool time → trigger MCP action if slow
- This is a step toward [[claude-code-plugins]] becoming a full automation platform

### `/fork` Optimization (v2.1.119)
- Fixed `/fork` writing the full parent conversation to disk per fork — now writes a pointer and hydrates on read
- Architectural insight: lazy hydration pattern for conversation branching — relevant to [[opencode]] compaction and [[context-budget-constraint]]

### Other Notable
- `--from-pr` now accepts GitLab, Bitbucket, and GitHub Enterprise PR URLs
- Plugins pinned by another plugin's version constraint now auto-update to highest satisfying git tag
- `/config` settings now persist to `~/.claude/settings.json` and participate in override precedence
- `isolation: "worktree"` subagent option for running in temp git worktrees — useful for parallel work
- `blockedMarketplaces` now correctly enforces `hostPattern` and `pathPattern`

## Architectural Observations

1. **Agent frontmatter parity across modes**: The `--print` fix closes a consistency gap. Interactive and headless modes now behave identically for agent definitions. This is important for CI/CD and orchestration use cases (like ours via [[openclaw]])
2. **Hooks → MCP bridge**: Hooks calling MCP tools directly is a composability leap — previously hooks could only run shell commands or agent prompts. Now hooks can reach any MCP-connected service
3. **Release velocity**: Daily releases with 30+ fixes each. The team is clearly in a "polish everything" phase post-[[claude-code-postmortem-apr2026|postmortem]]
4. **Plugin ecosystem maturing**: Version constraints between plugins, tag management (`claude plugin tag`), managed subagents — the plugin system is becoming enterprise-grade

## Links
- [[claude-code-skills]]
- [[claude-code-plugins]]
- [[claude-code-postmortem-apr2026]]
- [[coding-agent-ecosystem]]
