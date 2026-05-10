# Mirage — Unified Virtual Filesystem for AI Agents

- **Repo**: [strukto-ai/mirage](https://github.com/strukto-ai/mirage)
- **Stars**: 1,487 (2026-05-09 PM; was 1,460 early 05-09 — growth slowing to ~2%/day)
- **Language**: Python + TypeScript (dual SDK)
- **License**: Apache 2.0
- **Company**: Strukto.AI

## What It Does

Mounts heterogeneous services (S3, GitHub, Slack, Discord, Gmail, Redis, MongoDB, SSH) as a single VFS tree. Agents interact using familiar Unix commands (`cat`, `grep`, `ls`, `cp`, `find`, `jq`) across all mounts. No new vocabulary needed — any LLM that knows bash can use it.

```
/s3/      → S3Resource
/github/  → GitHubResource
/slack/   → SlackResource
/data/    → RAMResource (ephemeral)
```

## Architecture Insights

- **MountRegistry** resolves paths to resources, **Workspace** dispatches ops
- **CommandSpec** system: each resource type can override commands per filetype (e.g., `cat` on `.parquet` renders JSON, not raw bytes)
- **Shell parse layer**: implements pipes, redirects, job control within the VFS — agents compose commands like real bash
- **Full bash interpreter** (v0.0.2-alpha): parameter expansion (`${X:-default}`, `${X#prefix}`, `${X//from/to}`, `${X:offset:length}`, etc.), arrays, `set -e`/`pipefail`, `readonly`, `VAR=val cmd` prefix scoping. 73 new tests per binding (Python + TS parity). 5,451 Python tests, 2,516 TS tests total.
- **Session + History**: tracks execution per agent per session, supports snapshot/restore
- **FUSE mount**: optional real FUSE layer so native CLI tools can access the VFS too
- **Cache layer**: file-level caching (RAM or Redis) with consistency policies (LAZY/STRICT)
- **Observer**: records agent interactions into a dedicated resource for observability

## Why It Matters

1. **Universal interface hypothesis**: instead of N tools/MCPs, give agents ONE abstraction they already know (filesystem + bash). Radical simplification of agent tooling surface.
2. **Composability through pipes**: `grep alert /slack/general/*.json | wc -l` — cross-service queries composed like shell pipelines. This is the [[thin-harness-fat-skills]] philosophy applied to data access.
3. **Snapshot portability**: clone/version agent environments. Relevant to [[agent-session-resume]] patterns.

## Tradeoffs

- **Impedance mismatch risk**: not everything maps cleanly to files (real-time streams, paginated APIs, write semantics)
- **Command surface explosion**: each resource needs custom command overrides per filetype — N resources × M filetypes × K commands
- **Startup cost**: created 05-06, v0.0.2-alpha as of 05-08. Maturing fast — 11 PRs merged in 3 days. Active development.
- **Filesystem metaphor ceiling**: works great for read-heavy agents, but interactive/write-heavy workflows (send message, create issue) feel shoehorned into file ops

## Relationship to Our Direction

- **Not a competitor**: Mirage is infra, OpenClaw is a runtime. Could be complementary.
- **Pattern worth watching**: the "one abstraction to rule them all" bet is bold. If it works, it validates that agents don't need MCP — they need good metaphors. [[mcp-vs-native-tools]]
- **Contrast with MCP**: MCP = give agents typed functions. Mirage = give agents a filesystem. Both reduce N-SDK complexity, but MCP preserves API semantics while Mirage forces filesystem semantics.

## Verdict

**Track** — 1,460⭐ in 4 days, fastest growth in portfolio. Now facing serious architectural scrutiny (5 critical issues filed by @eouzoe, a Rust/Nix/Firecracker infrastructure person). Growth is real but the gap between VFS promise and multi-agent reality is becoming visible. Key question: can they address isolation and cache correctness without breaking the simplicity that drives adoption? Revisit 05-14.

## Updates

- **05-09 PM**: 1,460⭐. **Critical architectural scrutiny**: @eouzoe (Rust/Nix/Firecracker background) filed 5 well-researched issues in one batch:
  1. **#15 Snapshot fidelity**: snapshot/load only captures RAM + config, not remote state. No version IDs/ETags tracked. "Portability" is overstated.
  2. **#16 Session isolation**: concurrent agents share all filesystem state. No COW, no branch-scoped views, no conflict detection. Fan-out patterns (ToT, Reflexion) need per-session delta layers.
  3. **#17 Credential blast radius**: all mount credentials colocated in one daemon. `MountMode.READ` is software-level, not a capability boundary. One prompt-injected agent can pivot to every mounted resource.
  4. **#18 Cache invalidation**: read-through cache with no write-through invalidation. Read-after-write returns stale cached bytes. Verified in code: `FileCacheMixin` has no `invalidate_on_write` hook. This is a correctness bug.
  5. **#19 Shell coverage gaps**: undocumented unsupported constructs (process substitution, here-docs, arithmetic expansion, brace expansion, job control). LLMs will reach for these and get silent failures.
  - **0 maintainer responses** after ~24h. Watch how they handle this — will determine project maturity trajectory.
  - **Lesson for us**: filesystem metaphor for agents is powerful but "works on the happy path" ≠ production-ready. Multi-agent isolation is the hard problem that separates toys from infrastructure. [[agent-isolation]] [[capability-scoping]]
- **05-09 PM update**: 1,487⭐ (+1.8%). PR#10 "agents prompt isolation" merged — **misleading title**: actually dependency isolation between agent backends (pydantic_ai, openai_agents, langchain), not session isolation. Extracted shared `MIRAGE_SYSTEM_PROMPT` into `prompts.py`, added tests ensuring each backend can import without cross-dependencies (e.g., pydantic_ai works even if deepagents not installed). 6 test cases including module-blocking fixtures. v0.0.2-alpha version bump. New bug: #14 (grep mount path breaks file reads). Critical arch issues #15-#19 still open with **0 maintainer response** after ~48h. Growth decelerating (2%/day vs 12%/day earlier). New issue from community (@SaguaroDev) = real users hitting real bugs now.
- **05-10**: 1,686⭐ (+13%, reaccelerating). **Maintainer responding to critiques.** PR#22 fixes issues #17/#18/#19 (credential isolation, session isolation, cache invalidation — the @eouzoe issues). PR#23 adds `Session.fork()` for proper session propagation (allowedMounts inherit to child sessions). Both Python and TypeScript ports updated. This is a significant maturity signal — the project is taking architectural criticism seriously rather than ignoring it. Growth re-acceleration may be tied to demonstrating responsiveness.
