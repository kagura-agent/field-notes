# wanman — Agent Matrix Runtime

**Repo**: [chekusu/wanman](https://github.com/chekusu/wanman)
**Created**: 2026-04-22 | **Stars**: 371 (5 days) | **Lang**: TypeScript
**Tags**: multi-agent, orchestration, Claude Code, Codex, supervisor

## What It Is

Local-mode agent matrix framework. Runs a supervised network of Claude Code or Codex agents on your machine, coordinated through a JSON-RPC supervisor. Name from Japanese ワンマン電車 (one-man train) — the human watches, agents drive.

Hosted version at wanman.ai (Sandbank Cloud sandbox) adds: sandbox isolation, dynamic role extraction, skill self-evolution, db9 global search.

## Architecture

```
CLI (JSON-RPC client) → Supervisor (Node.js, SQLite, HTTP :3120) → AgentProcess[] → Claude/Codex subprocess
```

- **Supervisor**: central coordinator. MessageStore, ContextStore, TaskPool, ArtifactStore, InitiativeBoard, CronScheduler, Relay, LoopEventBus — all backed by a single SQLite db.
- **Per-agent isolation**: git worktree + per-agent `$HOME` + per-agent `.claude/` directory.
- **Runtime adapters**: Claude and Codex share the same `AgentRunEvent` interface. Adding adapters is straightforward.

### Agent Lifecycle Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| `24/7` | Continuous respawn loop | CEO, always-on coordinator |
| `on-demand` | Idle until triggered | Task workers, saves CPU |
| **`idle_cached`** | Idle but preserves `claude --resume` session id | Stateful agents that shouldn't run forever — **novel** |

`idle_cached` is the interesting innovation: combines "no CPU when idle" with "preserved conversation context via --resume". Claude-only today (Codex has no equivalent).

### Steer Mechanism

Steer-priority messages → SIGKILL current subprocess → next loop picks up steer message first (SQL ordering). Brute force but reliable. Compare: [[mid-run-steering]].

### MergeQueue

Serialized branch integration: rebase → test → fast-forward merge. Keeps main linear. Standard CI pattern brought to agent world.

### SafetyGate

Two-tier: `git_commit` and `git_merge_staging` auto-allowed; everything else (deploy, email, financial, delete) requires human approval. Simple and effective.

### Shared Skill Manager

Built-in skills materialized into each agent's `~/.claude/skills/`. **Skill activation snapshots** record exactly which skill versions an agent had for each run — auditable skill provenance. Relevant to [[skill-trust-layer]] discussions.

## Key Command: `takeover`

```bash
wanman takeover /path/to/repo
```

Scans project (languages, frameworks, CI, tests, README) → auto-generates agent config → starts supervisor. One command to hand a repo to agents. Strong UX.

## Ecosystem Position

- **Competes with**: [[OpenClaw]] ACP (multi-agent coordination), [[oh-my-codex]] (Codex orchestration)
- **Complements**: Could use OpenClaw as a distribution/communication layer; wanman as the execution engine
- **Upstream of**: Claude Code / Codex CLI (requires them as runtime)

## vs OpenClaw Comparison

| Dimension | wanman | OpenClaw |
|-----------|--------|----------|
| Architecture | Centralized supervisor (single machine) | Distributed gateway + channels |
| Runtime | Claude/Codex CLI subprocess | ACP harness (multi-backend) |
| State | SQLite local | Memory files + session state |
| Skill distribution | Snapshot to ~/.claude/skills/ | ClawHub registry |
| Use case | "Take over a repo" | "Run an agent's life" |
| Multi-user | Single user | Multi-user (Discord/Telegram) |
| Memory | db9 brain adapter (optional) | Memory + wiki + memex |

## Insights for Our Direction

1. **`idle_cached` is worth stealing**: Session resume between triggers saves cost while preserving context. OpenClaw ACP could implement this pattern.
2. **`takeover` UX is a moat**: One-command project onboarding lowers barriers dramatically. We should think about analogous UX for OpenClaw.
3. **Skill snapshot auditing**: Recording which skill version was active per run. Important for [[skill-trust-layer]] — we need this for ClawHub.
4. **Centralized vs distributed is the real fork**: wanman chose simplicity (SQLite, single process); OpenClaw chose flexibility (distributed, multi-channel). Both valid, different target users.
5. **371 stars in 5 days signals demand**: Multi-agent repo orchestration is a hot space right now.

## Open Questions

- How does wanman.ai's "dynamic skill self-evolution" work in practice?
- What's the db9 brain adapter's data model? How does cross-run memory work?
- How well does `idle_cached` work in practice? Session id staleness? Context window limits?

---
*First noted: 2026-04-27 | Source: deep read of OSS codebase*
