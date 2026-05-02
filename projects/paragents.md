---
title: paragents — Parallel AI Agent Sessions
created: 2026-05-02
updated: 2026-05-02
status: new
stars: 31
url: https://github.com/FrankHui/paragents
---

# paragents

**Parallel ai-agent sessions in one panel, with permission-aware tools, preflight conflict checks.**

- **Author**: FrankHui
- **Language**: Python
- **Created**: ~2026-04-28
- **Stars**: 31 (growing)

## What It Solves

Running multiple coding agents in parallel on the same codebase without them stepping on each other. The key differentiator vs [[oh-my-kimichan]] or [[cadis]]: **preflight conflict checks** — before an agent starts a task, the system verifies no other agent is touching the same files.

## Position in Ecosystem

Part of the **worktree isolation convergent pattern** (see [[worktree-convergence-2026-05]]). Multiple projects independently arriving at git worktrees + conflict detection as the answer to parallel coding agents:
- [[cadis]] — Rust runtime, desktop HUD, policy-gated
- [[oh-my-kimichan]] — Kimi Code, DAG/ensemble, tmux
- paragents — permission-aware, preflight checks
- parallel-worktree-dev (9⭐) — Next.js specific
- amara (4⭐) — Zig terminal emulator

## Relevance to OpenClaw

Our [[team-lead]] skill coordinates agents but without formal conflict detection. Paragents' preflight check approach (verify file-level exclusion before task assignment) is worth considering if we scale to multi-agent coding.

## Related

- [[worktree-convergence-2026-05]] — trend analysis
- [[oh-my-kimichan]] — competitor with DAG scheduling
- [[cadis]] — Rust runtime competitor
- [[team-lead]] — our multi-agent skill
