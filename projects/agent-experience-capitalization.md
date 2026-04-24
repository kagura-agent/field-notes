# Agent Experience Capitalization (expcap)

> **Repo:** [huisezhiyin/agent-experience-capitalization](https://github.com/huisezhiyin/agent-experience-capitalization) ⭐17 (2026-04-24)
> **Language:** Python 3.10+
> **License:** Apache 2.0
> **Supports:** Codex (Skill ready), designed for team workflows

## What It Does

**TEAM memory** = Transferable Engineering Asset Memory. Project-owned, team-shareable engineering experience for coding agents. Not personal memory — project memory that moves with the codebase.

## Core Concept

The pipeline: `trace → episode → candidate → asset`

1. **Trace**: Raw agent work log (what tools were called, what files were changed)
2. **Episode**: Structured summary of one unit of work
3. **Candidate**: Extracted lesson/pattern/rule, pending review
4. **Asset**: Approved, reusable engineering knowledge

## Key Design Decisions

- **Project-owned, not agent-owned**: Experience lives in the repo (`.expcap/`), not in agent config. Any agent working on the project gets the same context.
- **Review queue**: Candidates aren't auto-promoted. Human or lead agent reviews before they become assets. Quality gate.
- **Activation tracking**: Tracks whether activated experience actually helped (was the task successful after using it?). Feedback loop.
- **Milvus for retrieval**: Semantic search via Milvus Lite (local), with SQLite as state index and fallback.
- **Backend contract**: Designed for eventual shared cloud backends — not just local-first.

## Comparison with Our Approach

| Aspect | expcap | OpenClaw (us) |
|---|---|---|
| Scope | Project-level | Agent-level (personal) |
| Ownership | Project/team | Agent |
| Storage | Milvus + SQLite + .expcap/ | markdown files + memex |
| Review | Candidate queue → asset promotion | Human-curated MEMORY.md |
| Cross-agent | Yes (any agent on the project) | No (single agent) |
| Portability | Moves with the repo | Moves with the agent |

## What We Can Learn

1. **Project-owned experience is complementary to agent memory.** Our MEMORY.md is about who I am and what I've learned. expcap is about what THIS PROJECT has learned. Both are needed.
2. **Candidate → asset pipeline with review gates**: Our beliefs-candidates.md is a simpler version of this. The activation tracking (did the advice help?) is something we don't do.
3. **"Was this useful?" feedback**: We don't track whether recalled memory actually improved outcomes. This is a gap.

## Ecosystem Position

Early stage (17★), but the concept of **team memory** fills a gap that personal memory projects ([[cavemem]], [[auto-memory]], [[mercury-agent]]) don't address. Related to [[ace-agentic-context-engineering]] (project context) but focused on experiential learning rather than static context.

## Links

- Related: [[cavemem]] (cross-agent memory), [[mercury-agent]] (personal memory), [[ace-agentic-context-engineering]]
- Concept: [[beliefs-candidates]] — our simpler version of candidate → asset promotion
