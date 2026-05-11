---
title: "Gread — Hosted Code Reader for AI Agents"
created: 2026-05-11
updated: 2026-05-11
status: tracking
stars: 36
repo: NitroRCr/gread
tags: [agent-infrastructure, code-reading, mcp, skill]
---

# Gread — Hosted Code Reader for AI Agents

**Repo**: [NitroRCr/gread](https://github.com/NitroRCr/gread) | ⭐ 36 | Created 2026-05-08 | Apache-2.0

## What It Does

A hosted API + MCP server that gives agents access to any public GitHub repo's source code without cloning. Five operations: search repos, view repo (tree + info), list directory tree, read files, and git grep inside repos.

## Architecture

- **Runtime**: Bun + Hono (HTTP framework) + Drizzle ORM + SQLite
- **Clone strategy**: `git clone --depth 1 --filter=blob:limit=100k --no-checkout` — partial clone that skips large blobs, no working tree checkout. Only fetches git objects, uses `git show HEAD:<path>` to read files on demand.
- **Indexing**: Background sync process crawls repos with ≥10k stars weekly. On-demand indexing for requested repos (lazy clone on first access).
- **LLM assist**: Uses OpenAI-compatible API (gpt-4o-mini) to generate clean repo descriptions and detect org-level doc repos.
- **Doc awareness**: Automatically finds and indexes doc repos in the same org (name contains "doc").
- **MCP**: Dual interface — HTTP GET endpoints + Streamable HTTP MCP server (via `@hono/mcp`).
- **Rate limiting**: 60 RPM per IP, configurable.

## Key Architectural Insights

1. **No-checkout partial clone is the core trick** — repos are stored as bare-ish git objects with blob size filtering. This lets you serve code from thousands of repos with minimal disk. `git show HEAD:<path>` reads individual files without checkout.

2. **`GIT_NO_LAZY_FETCH=1` for grep** — prevents git from lazily fetching large blobs during grep operations. Smart optimization: you only want to search text you already have, not trigger downloads.

3. **Hono MCP bridge** (`@hono/mcp`) — clean pattern for serving both HTTP REST and MCP from the same Hono app. Worth noting as a reusable technique.

4. **LLM-enhanced indexing** — using LLM to clean descriptions and find doc repos is a small but clever touch. The LLM call is cheap (gpt-4o-mini on small text) and improves the browsing experience for agents.

## Tradeoffs & Limitations

- **100k blob limit**: files >100KB are invisible (can't be read or grepped). Reasonable for code, bad for data files or large configs.
- **No branch selection**: always reads HEAD. Can't browse older versions or non-default branches.
- **Single instance**: SQLite + local git repos = not horizontally scalable without sharding.
- **No auth**: all public repos, no private repo support.
- **No code intelligence**: pure text search, no semantic/AST-level understanding.

## Position in Agent Ecosystem

Fills the gap between "clone the whole repo" (expensive, slow) and "use GitHub API" (rate-limited, no grep). Positioned as an [[agent-infrastructure]] layer — an agent can read any codebase through a skill or MCP without managing local clones.

Competes with: GitHub's own code search API, Sourcegraph, and local `gh` CLI. Differentiator: zero setup for agents, combined tree+read+grep in one API, MCP-native.

Complementary to: [[skills-as-packages]] pattern — this is a "capability-as-service" rather than a packaged skill.

## Relevance to Our Direction

- **For study/scout workflows**: Could replace manual `git clone` in our study workflow when we just need to read a repo quickly. Currently we clone to /tmp which is ephemeral.
- **MCP + Skill dual interface pattern**: Worth adopting. Our skills are SKILL.md-only; offering MCP endpoints alongside increases compatibility surface.
- **No-checkout partial clone technique**: Could use this approach for our fork management — lighter storage footprint when we just need to read/grep.

## Community

- Solo project (NitroRCr), no issues yet, very new (3 days old).
- Published on Linux Do (Chinese dev community).
- Cross-published as both npm skill (`npx skills add`) and MCP server.

## Verdict

Small but architecturally clean project. The core idea (hosted code reader for agents) is genuinely useful. Worth watching for growth. The no-checkout partial clone pattern is the most reusable technical insight.

**Revisit**: 05-18 (check if growth sustains, issues appear)
