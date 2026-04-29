# Augment Code: AGENTS.md Effectiveness Study

**Source**: https://www.augmentcode.com/blog/how-to-write-good-agents-dot-md-files
**Date**: 2026-04-22 (read 2026-04-29)
**Author**: Slava Zhenylenko (Augment Code)
**Type**: Empirical study (internal eval suite "AuggieBench")

## What This Is

First data-backed study on what makes AGENTS.md files effective or harmful. Augment ran their coding agent on real PRs with and without AGENTS.md, comparing output to golden PRs reviewed by senior engineers.

**Key headline**: Best AGENTS.md = quality jump from Haiku→Opus. Worst = worse than no file at all.

## What Works (with measured numbers)

| Pattern | Effect |
|---------|--------|
| Progressive disclosure (100-150 lines + refs) | +10-15% all metrics |
| Procedural workflows (numbered steps) | +25% correctness, +20% completeness |
| Decision tables (resolving ambiguity) | +25% best_practices |
| Real code examples (3-10 lines) | +20% code_reuse |
| Domain-specific rules (specific/enforceable) | Improves when relevant |
| Pair "don't" with "do" | Prevents over-exploration |
| Module-level > repo-root | 10-15% gains in ~100-file modules |

## What Fails

### The Overexploration Trap (most common failure)
1. **Too much architecture overview** — agent reads 12+ docs, loads 80K irrelevant tokens, completeness drops 25%
2. **Excessive warnings** — 30+ "don'ts" without "dos" → agent verifies each against task, 2x slower, 20% less complete

### New Patterns Break Old Docs
- AGENTS.md documenting REST+polling → agent built polling solution when task required WebSockets
- Fix: spec-driven development for net-new architecture, not better AGENTS.md

## Doc Discovery Rates (traced across hundreds of sessions)

| Location | Discovery Rate |
|----------|---------------|
| AGENTS.md (hierarchy) | 100% (auto-loaded) |
| References from AGENTS.md | 90%+ (on demand) |
| Directory README.md | 80%+ (when working in dir) |
| Nested READMEs (other dirs) | ~40% |
| Orphan _docs/ folders | <10% |

**Insight**: AGENTS.md is the ONLY reliable discovery point. If something needs to be seen, it lives there or is referenced from there.

## Counter-intuitive Finding

The same AGENTS.md block can boost one task +25% and hurt another -30%. It's not "good file vs bad file" — it's "right block for right task." This means **task-type awareness** in doc design matters.

## Relation to Our Direction

### Direct applicability to OpenClaw workspace AGENTS.md
Our AGENTS.md is ~180 lines (excluding injected runtime cache). Slightly over the optimal 100-150 range, but we're a different use case (personal assistant context, not coding module).

**Self-audit against findings:**
- ✅ Procedural workflows (FlowForge, workloop steps)
- ✅ Domain-specific rules (specific, enforceable)
- ⚠️ Some "don'ts" without "dos" (Red Lines section has some bare prohibitions)
- ⚠️ Architecture descriptions could trigger exploration (subagent rules, heartbeat details)
- ✅ Progressive disclosure via skill system (SKILL.md files loaded on demand)

### Connection to [[skill-ecosystem]]
The "progressive disclosure" pattern maps exactly to how OpenClaw skills work: AGENTS.md is the hub, SKILL.md files are the reference docs loaded on demand. The study validates this architecture pattern with data.

### Connection to [[microsoft-apm]]
APM's compilation step (same source → different per-client output) could apply to AGENTS.md too: compile different context blocks for different task types. Not practical today, but directionally interesting.

## Actionable Takeaways

1. **Audit our "don'ts"**: Every prohibition in AGENTS.md should have a paired "do instead"
2. **Consider task-type routing**: Different context blocks for coding vs chat vs admin tasks (already somewhat done via skills)
3. **Reference file pattern validated**: Our SKILL.md architecture is empirically sound
4. **150-line budget is real**: If AGENTS.md grows, move detail to referenced files not inline

## Level

Concept-level insight applicable to [[skill-ecosystem]], AGENTS.md design, and [[context-management]].
