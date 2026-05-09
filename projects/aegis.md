# Aegis — Architecture-Driven Development Method Pack

- **Repo**: GanyuanRan/Aegis
- **Stars**: 140 (2026-05-09, created 04-30)
- **Language**: Shell + Markdown (zero runtime dependencies)
- **Host**: Claude Code, Codex, Cursor, Windsurf, Gemini, OpenCode, DeepSeek-TUI, Trae, Kimi Code CLI, CodeBuddy, Warp

## What It Is

A "method pack" — 18 composable skills that install into any AI coding host to enforce development discipline. Not a framework, not a library. Pure behavioral guidance injected into agent context. Zero code dependencies.

Explicitly NOT a runtime or agent platform. They have an ADR (ADR-0001) stating "Aegis method pack is not runtime core." No completion authority, no gate decisions — just discipline.

## Core Methodology: TLREF

Task framing → Baseline read → Impact statement → Execute → Verification with evidence

### Key Skills (18)

| Skill | Purpose | Notes |
|-------|---------|-------|
| verification-before-completion | Evidence before claims | Confidence grading A/B/C, red flags for "should/probably" |
| long-task-continuation | Checkpoint/resume protocol | Artifacts: intent, checkpoint, evidence, reflection. Drift detection |
| subagent-driven-development | Multi-agent coding | Implementer + spec-reviewer + quality-reviewer roles |
| systematic-debugging | Structured bug investigation | — |
| first-principles-review | Architecture analysis | — |
| establishing-project-context | Baseline reading | — |
| finishing-a-development-branch | Branch completion discipline | — |
| using-git-worktrees | Parallel branch management | — |

### Repair + Retirement Dual Track

Every governance/cleanup change must track:
- **Repair Track**: what was repaired, how, evidence
- **Retirement Track**: what was retired, what boundary is retained, future trigger for cleanup

This prevents "accumulation of fixes" where new logic piles on without removing old fallbacks. Directly relevant to how we handle [[beliefs-candidates]] and DNA evolution — when a new belief is adopted, what old behavior is retired?

## Architecture Observations

1. **Thinnest possible "thin harness"**: Even thinner than [[open-design]] — no code at all, just SKILL.md files. The agent host IS the harness. Pure [[thin-harness-fat-skills]] pattern taken to logical extreme.

2. **Multi-harness as product strategy**: Installing into 10+ hosts means the same methodology works regardless of IDE/CLI choice. Not locked into any ecosystem.

3. **Method pack framing**: Skills as process methodology, not tools or code. This is the "knowledge transfer" use case for skills — encoding expert development practices into agent context. Different from the "capability extension" pattern (tools, MCP servers) that dominates the skill ecosystem.

4. **Chinese developer community origin**: Posted on Linux DO (Chinese tech forum), Chinese README, but English as primary language. Similar to [[invincat]] in bridging CN/EN communities.

## Relevance to Us

- **verification-before-completion** is more structured than our AGENTS.md verification discipline — adds confidence grading (A/B/C), evidence bundles, QA closure checklists. Worth adopting the confidence grading.
- **long-task-continuation** = FlowForge at single-task granularity. Their checkpoint/resume design could inform [[flowforge]]'s own persistence model.
- **Repair+Retirement tracking** is a gap in our DNA evolution process — we add new rules but don't explicitly retire old ones.
- **Contribution opportunity**: Low (2 issues, one bug, one listing request). Primarily solo-authored. Early stage.

## Trend Signal

Skills-as-methodology (process packs) is a nascent category alongside skills-as-tools and skills-as-data. Aegis, [[invincat]], and to some extent our own AGENTS.md all represent this pattern — using agent context to encode "how to work" rather than "what tools to use."

## Growth Tracking

| Date | Stars | Note |
|------|-------|------|
| 04-30 | — | Created |
| 05-09 | 140 | Initial discovery |

## Tracking
- Created: 2026-04-30
- Revisit: 2026-05-16

Links: [[thin-harness-fat-skills]], [[agent-skill-standard-convergence]], [[invincat]], [[open-design]], [[flowforge]], [[beliefs-candidates]], [[skill-type-taxonomy]]
