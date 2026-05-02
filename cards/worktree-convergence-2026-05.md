---
title: Worktree Isolation Convergence (May 2026)
created: 2026-05-02
type: trend
---

# Worktree Isolation Convergence

**Pattern**: Multiple independent projects (5+) converged on git worktrees as the isolation primitive for parallel coding agents in April–May 2026.

## The Convergence

| Project | Stars | Language | Unique angle |
|---------|-------|----------|-------------|
| [[cadis]] | 39 | Rust | Desktop HUD, policy gates |
| [[oh-my-kimichan]] | 20 | TypeScript | Kimi Code, DAG + ensemble voting |
| [[paragents]] | 31 | Python | Permission-aware, preflight conflict checks |
| parallel-worktree-dev | 9 | Shell | Next.js + Conductor, per-worktree DB |
| amara | 4 | Zig | Terminal emulator approach |
| agentfleet | 1 | Python | Pure CLI, minimal |
| unity-claude-template | 10 | C# | Unity gamedev specific |

## Why Worktrees?

Git worktrees provide:
1. **File-level isolation** — each agent has its own working directory
2. **Branch semantics** — changes are naturally on separate branches
3. **Merge integration** — standard git merge as the coordination mechanism
4. **Zero overhead** — no VMs, containers, or copies needed
5. **Familiar mental model** — developers already understand branches

## What This Means

1. **Worktree is the consensus answer** — no one chose containers, VMs, or file-locking
2. **The real problem is coordination, not isolation** — isolation is solved; the differentiators are in scheduling (DAG vs round-robin), quality gates (ensemble voting, CI), and conflict prevention
3. **OpenClaw ACP** already supports worktrees implicitly (each spawn gets its own workspace), but lacks the preflight conflict detection that paragents adds
4. **Next frontier**: moving beyond file-level isolation to semantic-level isolation (two agents can edit the same file if they touch different functions)

## Related

- [[agent-memory-landscape-202603]] — parallel convergence in memory space
- [[team-lead]] — our multi-agent coordination approach
- [[coding-agent]] — single-agent approach
- [[cadis]], [[oh-my-kimichan]], [[paragents]]
