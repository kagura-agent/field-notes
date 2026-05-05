# Addy Osmani — Agent Skills

> 2026-05-05 deep read | 26K⭐ | [repo](https://github.com/addyosmani/agent-skills) | [blog post](https://addyosmani.com/blog/agent-skills/)

## What It Is

A collection of 20 production-grade engineering workflow skills for AI coding agents (Claude Code primary, also Cursor/Copilot/OpenCode). Written by Addy Osmani (Google Chrome team). Positioned as "senior engineer scaffolding" — encoding the invisible work (specs, tests, reviews, scope discipline) that agents skip by default.

## Why It Matters

- **26K stars in weeks** — validates that skill quality/curation matters more than quantity
- **Addy Osmani authorship** — Google-level engineering practices, not indie weekend hack
- **Process over prose** — the core insight is that skills must be _workflows with checkpoints_, not reference docs or essays. "If you put best practices in context, the agent reads them and skips them. If you put a workflow with exit criteria, the agent has something to do and you have something to verify."
- **Blog post on HN front page** (69pts) — pushing skill design patterns into mainstream dev consciousness

## Architecture

```
skills/<name>/SKILL.md     ← workflow per skill (frontmatter: name + description)
agents/<role>.md           ← personas (code-reviewer, test-engineer, security-auditor)
hooks/                     ← session lifecycle (session-start, SDD cache)
.claude/commands/          ← slash commands (/spec, /plan, /build, /test, /review, /ship)
references/                ← supplementary checklists (testing, performance, security)
docs/                      ← setup guides for 6 IDEs/tools
```

**Three composable layers:**
1. **Skills** = workflows (the _how_)
2. **Personas** = roles (the _who_)
3. **Slash commands** = entry points (the _when_)

Composition rule: user/command is orchestrator. Personas don't invoke other personas. Only endorsed multi-persona pattern: **parallel fan-out with merge** (used by `/ship`).

## Key Design Patterns

### 1. Anti-Rationalization Tables

Most distinctive design decision. Each skill has a table of common excuses to skip the workflow + rebuttals:

| Rationalization | Reality |
|---|---|
| "I'll write tests after the code works" | You won't. Tests written after test implementation, not behavior. |
| "This is too simple to test" | Simple code gets complicated. The test documents expected behavior. |
| "It's faster to do it all at once" | Feels faster until something breaks in 500 changed lines. |

**Insight for us:** Our AGENTS.md has some of this ("讨好模式防范") but not per-workflow. Worth stealing for skill SKILL.md format — especially for [[flowforge]] workflow nodes.

### 2. Gated Workflow Phases

```
SPECIFY → PLAN → TASKS → IMPLEMENT
   ↓        ↓       ↓        ↓
 Human    Human   Human    Human
 reviews  reviews reviews  reviews
```

Each phase has explicit "do not advance until validated" gates. This is the same pattern as our [[flowforge]] branch nodes but more rigidly structured.

### 3. SDLC-as-Skills

Maps 6 SDLC phases to skill groups:
- **Define**: spec-driven, idea-refine
- **Plan**: planning-and-task-breakdown
- **Build**: incremental-implementation, TDD, context-engineering, source-driven, frontend, API design
- **Verify**: browser-testing, debugging
- **Review**: code-review, code-simplification, security, performance
- **Ship**: git-workflow, CI/CD, docs/ADRs, shipping-and-launch

### 4. Context Hierarchy (context-engineering skill)

```
Rules Files (CLAUDE.md)      ← always loaded
Spec / Architecture Docs     ← per session
Relevant Source Files         ← per task
Error Output / Test Results   ← per iteration
Conversation History          ← accumulates
```

This mirrors our own context layering (AGENTS.md → skill SKILL.md → wiki → memory) but makes it explicit and teachable.

### 5. Red Flags Section

Every skill includes behavioral red flags — patterns that indicate the skill is being violated. Complement to anti-rationalization (which is about _excuses_), red flags are about _observable symptoms_.

## Comparison with Our Setup

| Aspect | Addy's agent-skills | Our system ([[flowforge]] + skills/) |
|---|---|---|
| Skill format | SKILL.md with YAML frontmatter | SKILL.md with YAML frontmatter ✅ same |
| Workflow engine | Agent follows steps in SKILL.md | FlowForge YAML with branching + state |
| Anti-rationalization | Per-skill tables | Per-workflow node (informal) |
| Personas | Separate agents/ dir | Not separated (agent identity in SOUL.md) |
| Phase gating | Human review between phases | FlowForge branch nodes |
| Context management | Explicit context-engineering skill | AGENTS.md startup sequence |
| Scope | Software engineering only | Broader (study, work, reflection, identity) |

## Actionable Takeaways

1. **Anti-rationalization tables** — ✅ APPLIED (2026-05-05). Added to study.yaml (note, reflect, scout, deep_read nodes) and workloop.yaml (reflect node). Commit 6e2f09b. Each table pairs common excuses with concrete rebuttals. Already rendering in flowforge output.
2. **Red Flags sections** — complement to our AGENTS.md 讨好模式 / 观测闭环 checks. Could add per-skill.
3. **"Process over prose"** — validates our FlowForge approach (workflow > instructions). Our skills that are mostly essays should be refactored into step-by-step workflows.
4. **Parallel fan-out with merge** — the only multi-persona orchestration pattern they endorse. Interesting constraint — no router agents, only fan-out + merge. Relevant for [[team-lead]] skill design.

## Position in Ecosystem

- **Relationship to [[claude-code-skill-ecosystem]]**: This is the quality benchmark. While most skill repos are quantity-plays (235+ skills), this is 20 deeply-crafted workflows.
- **Relationship to [[library-skills]]**: library-skills is about _packaging_ (how skills get installed/distributed). agent-skills is about _content_ (what goes in a skill). Complementary.
- **Relationship to [[agentskills-io-standard]]**: agentskills.io defines the metadata standard; agent-skills defines the workflow standard.
- **Competitive signal**: 26K stars for 20 skills > 12.7K for 235 skills. Quality wins.

## Tracking

- ⭐ 28,334 (2026-05-05 evening, +2.3K from morning)
- Forks: 3,484
- Last push: 2026-05-03
- HN front page: 286pts (2026-05-05 evening, climbing) — second wave of attention after blog post
- Revisit: 05-12 (check for new skills, community adoption patterns)
