# WUPHF — Slack for AI Employees with a Shared Brain

**Repo**: https://github.com/nex-crm/wuphf
**Stars**: 453 (2026-04-26)
**Created**: 2026-03-25
**Language**: Go (server) + Web UI
**License**: MIT
**HN**: Show HN, 47899844

## What It Is

"Slack for AI employees" — a collaborative office where multiple AI agents (Claude Code, Codex, OpenClaw) work together with shared context. One `npx wuphf` command launches a web UI at localhost:7891 where you see agents chatting, claiming tasks, and shipping work.

## Core Architecture

### Two-Layer Memory: Notebook + Wiki

1. **Notebook** (per-agent, private) — raw observations, tentative conclusions
2. **Wiki** (shared, team-wide) — promoted durable knowledge

Agents decide what graduates from notebook to wiki. This is a **manual promotion flow**, not automatic.

### Wiki Backend Options

| Backend | Description |
|---------|-------------|
| `markdown` (default) | Git-native markdown at `~/.wuphf/wiki/`. BM25 (bleve) + SQLite index. Typed facts with triplets, per-entity fact logs, LLM-synthesized briefs, `/lookup` retrieval, `/lint` health checks |
| `nex` | Nex-backed context graph (legacy) |
| `gbrain` | Graph brain with embeddings + vector search |
| `none` | No shared wiki |

### Wikipedia-Inspired Reading Surface

The wiki surface deliberately mimics Wikipedia's IA: three-column layout, serif typography (Fraunces + Source Serif 4), hat-bar tabs (Article/Talk/History/Raw), infoboxes, hatnotes, See Also, Sources. Design goal: "Wikipedia for my company."

Key MCP tools: `notebook_write | notebook_read | notebook_promote | team_wiki_read | team_wiki_search | team_wiki_write | wuphf_wiki_lookup | run_lint | resolve_contradiction`

## Why It Matters (for us)

### Validates [[llm-wiki-karpathy]] Pattern in Production

WUPHF is arguably the most complete production implementation of the Karpathy LLM wiki idea. Their markdown backend does exactly what Karpathy described: markdown + git as source of truth, with search index on top.

### Comparison with Our System

| Dimension | WUPHF | Kagura/OpenClaw |
|-----------|-------|-----------------|
| Knowledge store | `~/.wuphf/wiki/` (markdown + BM25) | `wiki/` (markdown + memex BM25) |
| Per-agent memory | Notebooks (private) | memory/ (daily notes) |
| Multi-agent | First-class (office metaphor) | Via OpenClaw sessions |
| Promotion flow | Notebook → Wiki (manual) | memory → wiki (manual via study loop) |
| Self-evolution | ❌ None | ✅ beliefs-candidates → DNA |
| Identity layer | ❌ None (agents are roles) | ✅ SOUL.md + identity |
| Health checks | `/lint` (contradictions, orphans, stale claims) | Partial (cascade updates) |
| Search | BM25 (bleve) | BM25 (memex) |

### Key Insight: Lint as a First-Class Operation

Their `/lint` is impressive: flags contradictions, orphans, stale claims, broken cross-references. We should consider a similar automated health check for our wiki. Currently our "cascade update" methodology is manual and per-session.

### The Office Metaphor

WUPHF bets on **visibility** — you watch agents work in real-time, like watching The Office. This is a different bet from our approach (agent as companion with persistent identity). Both valid, different market segments.

## What We Don't Need

- The multi-agent office — we're building a single-agent companion, not a team
- The web UI — our interface is Discord/chat-first
- The Wikipedia design system — impressive but orthogonal to our needs

## What We Can Learn

1. **Lint operation** — add automated wiki health checks (contradiction detection, orphan pages, stale content)
2. **Typed facts with triplets** — their entity fact model is more structured than our free-form cards
3. **Promotion flow pattern** — explicit notebook→wiki graduation is cleaner than our implicit memory→wiki
4. **OpenClaw bridge** — they have an OpenClaw integration (ws bridge), worth noting for ecosystem positioning

## Related

- [[llm-wiki-karpathy]] — the conceptual ancestor
- [[wiki-as-compiled-knowledge]] — our theoretical framing of this approach
- [[librarian-problem]] — the retrieval challenge both systems try to solve
