---
title: "Whale — DeepSeek-Native CLI Coding Agent"
created: 2026-05-10
updated: 2026-05-10
tags: [agent, cli, deepseek, prefix-cache, cost-optimization]
url: https://github.com/usewhale/whale
stars: 118
status: active
updated: 2026-05-14
last_verified: 2026-05-14
---

# Whale — DeepSeek-Native CLI Coding Agent

Go-based CLI coding agent, explicitly **not** model-agnostic. Optimized for DeepSeek's prefix caching, tool-call quirks, and pricing. Claims **90% prefix-cache hit rate** and **~30x cheaper per task vs Claude Code**.

## Architecture

### 3-Layer Memory Model (Prefix-Cache Optimized)

```
ImmutablePrefix (system blocks, SHA256-hashed)
  └─ AppendOnlyLog (conversation turns, never edited mid-stream)
      └─ VolatileScratch (per-turn ephemeral, reset each iteration)
```

The key insight: DeepSeek's KV cache is **byte-sensitive**. By structuring context so the prefix (system prompt + project memory) stays identical across turns, whale maximizes cache hits. When AGENTS.md or project files change mid-session, a `PrefixDrift` event fires — the system detects and reports the cache invalidation rather than silently paying for re-computation.

This is the [[model-native-vs-model-agnostic]] argument made concrete: generic provider abstractions hide the very cache mechanics that determine cost.

### DeepSeek-Specific Tool Handling

DeepSeek produces malformed tool-call JSON more often than Claude/GPT-4. Whale has dedicated machinery:

1. **JSON repair** — regex-based trailing comma removal, bracket closure
2. **Scavenging** — extracts tool calls embedded in reasoning text (up to 4 per turn)
3. **Storm breaker** — detects rapid tool-call failure loops (3 failures in 6-turn window) and breaks the cycle

### Recovery Policy

10 failure classes with distinct recovery actions — more nuanced than generic retry:

- `timeout` → retry with backoff (2 attempts)
- `parse_failed` / `empty_output` → retry once
- `exec_failed` / `permission_denied` / `mcp_tool_error` → pass through to model
- `policy_denied` / `approval_denied` / `plan_required` → hard block

### Budget Tracking

Per-session USD cost tracking using DeepSeek's pricing. Warnings at 80% and 100% of cap. Session meta persisted. Usage log includes prefix fingerprint for cache analysis.

### Compact (Context Window Management)

When estimated tokens exceed `compactThresh × contextWindow`, auto-compacts by generating an LLM summary and rewriting the session. Similar to [[openclaw-architecture]] compaction, but integrated with the prefix-cache fingerprint tracking.

### Benchmarking (livecache)

Built-in bench suite that runs tasks against real DeepSeek API and measures:
- Cache hit ratio per task
- Cost per task (USD)
- Pass rate
- Weighted aggregate cache hit across all runs

This is rare — most agents don't systematically benchmark their cache performance.

## Skills

Compatible SKILL.md format. Discovery roots: `.whale/skills/` and `.agents/skills/`. Same parse/validate pattern as [[clawhub]] / [[openclaw-architecture]].

## Community Signal

- 69⭐ in 4 days (2026-05-10), 6 forks
- External PRs happening (#7 — community contributor)
- Issues: mostly Windows compatibility (#6, #8, #10), one visionary multi-agent proposal (#5 — SSD architecture with prefix-sharing between expert agents)
- Active development (pushed daily)

## Relevance to Our Direction

1. **ImmutablePrefix pattern** — we should measure prefix cache hit rates with providers that expose cache stats. Even if we're model-agnostic, knowing our cache efficiency is valuable.
2. **Tool repair/storm-breaker** — relevant for any model that produces malformed tool calls. The failure classification (10 classes vs generic retry) is well-designed.
3. **Budget tracking per-session** — useful pattern for cost-aware operation. We track usage but not in a prefix-fingerprint-correlated way.
4. **Validates [[model-native-vs-model-agnostic]]** — whale is a concrete example of the model-native path. Their README explicitly argues against generic provider abstractions for this reason.
5. **Livecache bench** — the idea of systematically benchmarking cache performance is worth borrowing.

## Anti-Patterns to Avoid

- **Locked to one provider** — whale accepts this tradeoff explicitly, but it limits adoption. Fine for DeepSeek users, risky if DeepSeek pricing changes.
- **JSON repair via regex** — fragile. Better than nothing, but proper streaming JSON parsers would be more robust.

## Updates

- **05-14**: 117⭐ (+24% since 05-12). Two significant features shipped:
  1. **Skills system overhaul** (PR#32 by external contributor @shayne-snap): `when`/`requires` frontmatter for conditional skill availability, 4-bucket availability system (ready/needs_setup/disabled/problem), TUI skills manager with search + enable/disable, symlink-aware path escape security, `/skills` slash commands. More granular than OpenClaw's binary skill loading — worth studying the `requires` (commands/env/MCP) validation pattern.
  2. **Cross-workspace resume** (05-13): sessions can resume across different workspace directories. TUI viewport freeze fix. Assistant transcript reconciliation.
  - **Community**: 🟢 THRIVING (5/6). 14 external PRs in 30 days. 2 unique merged PR authors. Active issues.
  - **Growth trajectory**: 69→86→94→117⭐ in 4 days. Steepening curve — possibly reaching inflection point.
  - **Signal for us**: whale's `requires` frontmatter (check commands/env/MCP availability before loading skill) is a pattern OpenClaw could adopt. Our skills are always-loaded with no prerequisite checking.
- **05-14 (deep read)**: 118⭐. PR#32 code review — deep-read of `internal/skills/skills.go` (+450 lines). Key architecture insights:
  1. **4-bucket availability**: `BuildReport()` groups skills into ready/needs_setup/disabled/problem based on runtime checks. `MissingRequirements()` uses `exec.LookPath` for commands, `os.Getenv` for env vars, and MCP connection state map. Simple, no-side-effect validation — doesn't install anything, just reports.
  2. **Security boundary**: `isDiscoveredSkillReadPath()` in toolset.go permits read-only file access inside discovered skill directories, with `filepath.EvalSymlinks` for symlink-aware escape detection. Disabled skills don't expand read boundaries. Write/edit tools deny skill paths entirely.
  3. **Issue #35 — cross-agent skill compat**: user had 15+ skills in `~/.agents/skills/` but whale only found `~/.whale/skills/`. Fixed by adding `.agents/skills` as discovery root. This is the exact [[agent-skill-standard-convergence]] problem — skill directories fragmenting across agents (`.claude/`, `.agents/`, `.whale/`).
  4. **vs OpenClaw**: OpenClaw loads all discovered skills into system prompt unconditionally. whale's approach is more granular — skills with missing `requires` show as "needs_setup" and their instructions are still available but flagged. The TUI enable/disable with persistent config (`.whale/config.toml`) is also nicer than OpenClaw's current all-or-nothing model.
  5. **Community signal**: 42 unique issue authors + 42 external PRs in 30 days for thClaws (comparable Thai agent). whale's community is smaller (14 PRs/30d) but quality contributions — @shayne-snap's PR#32 was 2572 lines with 2000+ test lines.

## Links

- [[model-native-vs-model-agnostic]]
- [[openclaw-architecture]]
- [[clawhub]]
- [[self-evolving-agent-landscape]]
