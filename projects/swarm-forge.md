# SwarmForge

- **Repo**: unclebob/swarm-forge
- **Stars**: 264⭐ (04-22 PM3, was 245 AM)
- **Created**: 2026-04-15
- **Author**: Uncle Bob (Robert C. Martin) / Justin Martin
- **Language**: Zsh (466 lines core script)
- **License**: Not specified in README

## What It Is

Lightweight tmux-based multi-agent orchestration. Each agent gets its own git worktree and tmux session. Communication via `notify-agent.sh` (tmux send-keys + log file). Config-driven topology.

## Architecture

- `swarmforge.conf` defines windows: `window <role> <agent> <worktree>`
- Supports Claude and Codex as backends
- **Constitution Engine**: layered prompt system (`constitution.prompt` → subordinate files for project/engineering/workflow rules)
- Per-role `.prompt` files
- Git worktrees for isolation (each agent works on its own branch)
- Message queue: if agent is busy, append to `pending-messages` file
- All state in `.swarmforge/` directory (sessions.tsv, prompts, window-ids)

## Default Roles

- **Architect**: plans, defines behavior (claude, master branch)
- **Coder**: implements one slice at a time (codex, own worktree)  
- **Reviewer**: deeper verification before handoff (codex, own worktree)
- **Logger**: utility, tails message log (no agent)

## Key Design Decisions

1. **Git worktrees > shared workspace**: Each agent has its own worktree, avoids conflicts
2. **Constitution as prompt hierarchy**: Not just one file — layered with precedence rules
3. **tmux send-keys for IPC**: Dead simple, no IPC framework needed
4. **Message queueing in files**: Agents check `pending-messages` after completing current task
5. **Observable by design**: Human can watch any tmux pane in real time

## Comparison with Our Setup

| Aspect | SwarmForge | OpenClaw/team-lead |
|--------|-----------|-------------------|
| IPC | tmux send-keys | Discord channels + subagents |
| Isolation | git worktrees | separate sessions |
| Constitution | layered .prompt files | AGENTS.md + SOUL.md |
| Backend | claude/codex | any LLM via gateway |
| Observability | tmux panes | Discord channels |
| Scale | local only | distributed |

## Insights

- **Worktree isolation is smart** — avoids the "two agents editing same file" problem. We use separate sessions but could benefit from explicit worktree separation for team-lead scenarios
- **Constitution layering** — their project/engineering/workflow split is clean. Our DNA is flatter (AGENTS.md does everything)
- **Message queueing** — simple file-based queue is pragmatic. If agent is busy, messages don't get lost
- **Uncle Bob entering the space** is a signal that multi-agent coordination is becoming mainstream enough for the "Clean Code" crowd

## Limitations

- macOS only (uses `open -a Terminal`)
- Zsh-specific
- No remote/distributed support
- No persistence across restarts
- Very early (245⭐, 1 week old)

## Related

- [[mercury-agent]] — another new agent framework (soul-driven, different approach)
- [[genericagent]] — single-agent self-evolution vs SwarmForge's multi-agent coordination
- [[ace-agentic-context-engineering]] — constitution layering relates to ACE's context engineering
- [[agent-ecosystem-weekly]] — multi-agent coordination trend

## Tags

#multi-agent #orchestration #tmux #clean-code #git-worktrees
