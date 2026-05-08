# Mirage — Unified Virtual Filesystem for AI Agents

- **Repo**: [strukto-ai/mirage](https://github.com/strukto-ai/mirage)
- **Stars**: ~1,105 (2026-05-08 PM; was 990 AM — growth decoupled from commits, no new pushes since 05-06)
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
- **Startup cost**: created 05-06, 1 day old. Beautiful code, well-structured, but very early. No community yet.
- **Filesystem metaphor ceiling**: works great for read-heavy agents, but interactive/write-heavy workflows (send message, create issue) feel shoehorned into file ops

## Relationship to Our Direction

- **Not a competitor**: Mirage is infra, OpenClaw is a runtime. Could be complementary.
- **Pattern worth watching**: the "one abstraction to rule them all" bet is bold. If it works, it validates that agents don't need MCP — they need good metaphors. [[mcp-vs-native-tools]]
- **Contrast with MCP**: MCP = give agents typed functions. Mirage = give agents a filesystem. Both reduce N-SDK complexity, but MCP preserves API semantics while Mirage forces filesystem semantics.

## Verdict

**Track** — 990⭐ in 48h is serious signal. Revisit 05-14 for adoption patterns and whether the filesystem metaphor holds under real agent workloads.
