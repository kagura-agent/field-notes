# Aegis — Architecture-Driven Development Method Pack

- **Repo**: GanyuanRan/Aegis
- **Stars**: 180 (2026-05-13, created 04-30)
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
| 05-13 | 180 | +28%, v1.1.3→v1.3.0 in 3 days |

## v1.2-1.3 Update (2026-05-13)

Massive release burst: v1.1.3→v1.3.0 in 3 days (05-10 to 05-12). Despite 28% star growth, still 🔴 SOLO (0/6 community health) — zero external PRs, zero external issue authors, no discussions.

### Workflow Quality Baseline (v1.3.0)

The most interesting new artifact. Defines 7 quality dimensions for skill workflows:
1. **Trigger accuracy** — right skill triggers for representative tasks
2. **Fast-path cheapness** — simple tasks stay simple (no forced ceremony)
3. **Output compactness** — depth scales with complexity
4. **Evidence freshness** — completion claims need fresh evidence
5. **Artifact stability** — consistent naming and structure
6. **Workspace laziness** — don't create project records for trivial tasks
7. **Authority boundary** — skills advise, don't decide

Backed by a `workflow-quality-matrix.json` with representative task samples defining expected routing, output shape, workspace policy, and forbidden behaviors. This is essentially a **behavioral test suite for methodology** — testing not code correctness but *process appropriateness*.

**Key insight**: The "fast-path cheapness" dimension is the anti-bloat mechanism we lack. Our DNA/workflow rules keep growing but we have no formal check for "is this rule making simple tasks harder?" Aegis solves this with explicit pass criteria: "simple factual Q&A does not force a full workflow."

### ADR Auto Backfill (v1.2.0)

Automatic architecture decision records from completed work. Evidence-led: `completed work → ADR trigger check → create/amend/supersede/skip`. Source priority: work records > plans > specs > git evidence.

Key design choice: ADR backfill happens *near completion*, not at design time. This prevents speculative ADRs. Three-gate filter: (1) reversing would be costly, (2) decision would be surprising without context, (3) real alternatives existed.

Relevant to our [[beliefs-candidates]] pipeline — we could adopt similar trigger conditions for when a behavioral observation graduates to DNA vs stays a candidate.

### Dual-Track Governance

Formalized the Repair+Retirement pattern noted in initial review. Key new constraint: **deletion is the default** for old logic during Retirement Track. Retention requires explicit justification with recorded: retained object, retention reason, observation metrics, retirement timing.

This is more aggressive than our current approach where DNA rules accumulate. Worth adopting: every new DNA rule should answer "what old rule does this retire?"

### Rule Layering (3-Layer Model)

Separates rules into: (1) Portable method core, (2) Host/profile preferences, (3) Repo contribution rules. Migration principle: method core → docs/current/ + skills, host prefs → host-facing docs, repo constraints → contribution docs.

Parallel to our DNA layers: SOUL.md (universal) → AGENTS.md (workspace-level) → workflow YAML (task-level). We do this implicitly; Aegis makes it explicit with clear criteria for which layer owns what.

### Trigger Health Diagnostic

8-layer diagnostic for "why didn't the right skill trigger?" From install/version (L0) through routing (L4) to context pressure (L7). Principled debugging: find the layer that owns the failure, fix there, don't compensate elsewhere.

## Observations

1. **Velocity without community = fragile**. 180⭐ and v1.3.0 in 2 weeks, but entirely one person. The documentation is excellent but no one is using it enough to file bugs or contribute. This is the "impressive but solitary" pattern — contrast with [[agentic-stack]] which has lower polish but real community engagement.

2. **Over-documentation risk**. 17 docs in docs/current/, each with Status, Scope, Boundary sections. The methodology about methodology is growing faster than the methodology itself. At some point the meta-governance overhead exceeds the governed behavior.

3. **Anti-bloat lesson for us**: Their workflow-quality-matrix.json is a clever idea — defining representative tasks and checking that your methodology doesn't make them unnecessarily expensive. We should consider something similar for our DNA rules.

## Tracking
- Created: 2026-04-30
- Revisit: 2026-05-20

Links: [[thin-harness-fat-skills]], [[agent-skill-standard-convergence]], [[invincat]], [[open-design]], [[flowforge]], [[beliefs-candidates]], [[skill-type-taxonomy]]
