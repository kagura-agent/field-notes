---
title: agent-harness-kit
created: 2026-05-08
updated: 2026-05-08
status: active
---

# agent-harness-kit

**Repo**: [enmanuelmag/agent-harness-kit](https://github.com/enmanuelmag/agent-harness-kit) — 124⭐ (05-08), created 05-04
**License**: MIT | **Language**: TypeScript | **Runtime**: Node.js/Bun

Provider-agnostic multi-agent scaffolding for coding tasks. Enforces a structured pipeline: **Lead → Explorer → Builder → Reviewer**. Published as `@cardor/agent-harness-kit` on npm.

## Core Architecture

- **MCP as coordination bus**: All inter-agent communication goes through MCP tools (`tasks.get`, `tasks.claim`, `actions.write`, etc.). Any MCP-compatible AI tool can be an agent.
- **SQLite shared state**: `.harness/harness.db` stores tasks, actions, sections, files, tool calls. Task claiming uses SQLite transactions for atomicity.
- **Role-based permissions**: Lead/Reviewer read-only, Explorer reads+searches docs, Builder has designated writable paths.
- **Health gate**: `health.sh` (build+test) must pass before starting and after finishing work.
- **Acceptance criteria**: Per-task criteria with `markAcceptanceMet()`. Reviewer can't approve without all criteria met.
- **Dashboard**: Local web UI for observability (task status, file operations, tool usage stats).

## Key Design Decisions

1. **Project-scoped, not agent-scoped** — `.harness/` lives in the repo. State is per-project, not per-agent. Contrast with our workspace-level tools.
2. **Fixed 4-role pipeline** — Lead (orchestrate), Explorer (read-only analysis), Builder (implementation), Reviewer (verify). Not flexible for non-coding workflows.
3. **MCP-first, markdown fallback** — If MCP is unavailable, generates `.harness/current.md` as agent context snapshot.
4. **No memory or learning** — Pure task execution pipeline. No self-improvement, no cross-session memory. Contrast with [[orb]] lesson pipeline or [[genericagent]] skill evolution.
5. **Provider-agnostic** — Agent definitions live in both `.claude/agents/` and `.opencode/agents/`. Config specifies provider, scaffolding adapts.

## Atomic Task Claiming (notable pattern)

```typescript
async claimTask(id: number, agent: string): Promise<TaskRow | null> {
  return this.driver.transaction(async (tx) => {
    const changed = await txTasks.claim(id, agent, now)
    if (!changed) return null  // already claimed by another agent
    return task
  })
}
```

This prevents race conditions when multiple agents try to claim the same task. Worth stealing for [[gogetajob]] to prevent multiple agents from picking the same GitHub issue.

## Comparison with Our Patterns

| Aspect | agent-harness-kit | Our Tools |
|---|---|---|
| Workflow engine | Fixed 4-role pipeline | [[flowforge]] YAML DAG (flexible) |
| State persistence | SQLite in `.harness/` | FlowForge SQLite + YAML |
| Coordination protocol | MCP tools | OpenClaw subagent spawn + native tools |
| Task management | `tasks.*` MCP tools | [[pulse-todo]] + [[taskflow]] |
| Agent roles | Hard-coded Lead/Explorer/Builder/Reviewer | Soft-defined in team-lead skill |
| Learning | None | [[beliefs-candidates]], wiki, memory |
| Scope | Per-project (repo-local) | Per-agent (workspace-level) |

## Insights

- **MCP as coordination protocol** is becoming the standard pattern for multi-agent systems. This confirms the trend we saw in [[worktree-convergence-2026-05]] — agents need shared state protocols, not just shared filesystems.
- The **health gate pattern** (mandatory build+test before/after work) is exactly what our AGENTS.md "打工 PR 必须测试" rule encodes informally. agent-harness-kit makes it mechanical.
- **Acceptance criteria tracking** at the task level (not just PR level) is a gap in our team-lead workflow. We track pass/fail on CI but don't have structured criteria per task.
- The dashboard approach shows that **observability for multi-agent systems** is a growing need — who did what, when, and what files were touched.

## Relevance

- Medium-high. Not directly competing (we're a personal agent platform, they're a coding scaffolding tool), but the patterns (atomic claiming, health gates, acceptance criteria, MCP coordination) are directly applicable.
- The "harness" concept (structured environment that constrains agent behavior) is gaining traction as a response to "agents roaming freely" concerns.

## Links

- [[flowforge]]: Our workflow engine, more flexible but without role-based separation
- [[team-lead]]: Our multi-agent coding skill, less structured than agent-harness-kit
- [[gogetajob]]: Could benefit from atomic task claiming pattern
- [[skill-type-taxonomy]]: agent-harness-kit is a "harness skill" — it doesn't do work, it structures how other agents do work
- [[worktree-convergence-2026-05]]: MCP as coordination standard trend
