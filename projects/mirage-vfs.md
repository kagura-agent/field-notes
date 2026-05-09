# Mirage — Unified Virtual Filesystem for AI Agents

- **Repo**: [strukto-ai/mirage](https://github.com/strukto-ai/mirage)
- **Stars**: 1,446 (2026-05-09; was 1,286 late 05-08, 1,105 early 05-08, 990 on 05-07 — sustained explosive growth ~12%/day)
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

**Track** — 1,446⭐ in 3 days is the fastest growth in our tracking portfolio. Now has agent prompt isolation (per-framework system prompts for OpenAI Agents, LangChain, PydanticAI) and serious bash interpreter work. Revisit 05-14.

## Updates

- **05-09**: 1,446⭐ (+12.4% from 05-08 PM). v0.0.2-alpha: (1) full bash interpreter parity — parameter expansion, arrays, set -e, pipefail, readonly, VAR=val prefix scoping, 73 new tests per binding; (2) agent prompt isolation — per-framework system prompts with mount info injection; (3) execute options + cancel support. The bash interpreter work is the most significant — they're treating shell fidelity as a core differentiator, not a nice-to-have.
