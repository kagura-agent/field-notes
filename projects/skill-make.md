---
title: SKILL.make
type: project
created: 2026-05-03
last_verified: 2026-05-03
status: evaluated
stars: 54
repo: Teaonly/SKILL.make
tags: [skill-format, agent-skills, makefile, DAG]
---

# SKILL.make — Makefile-Styled Agent Skills

## What It Is

A specification (no runtime implementation) that converts prose SKILL.md files into Makefile-style targets with dependency-driven execution. Uses a `Target: Dependency + Recipe` model.

**Syntax primitives:**
- `@ cmd` — shell commands
- `$ tool` — tool/function calls
- `? prompt` — reasoning prompts (LLM decides action)
- `ifeq` — conditional branching
- `VAR = val` — constants

## Key Claims

1. **~15% token reduction** — average across 19 converted skills (range: -3% to -52%)
2. **DAG dependency resolution** — harness resolves execution order, not the LLM
3. **Composability** — targets can call across files
4. **Auditability** — structured format enables tracking

## Assessment

### What's Good

- The DAG execution model is the strongest idea — making skill execution deterministic rather than relying on LLM interpretation of prose
- Format is genuinely more compact than prose SKILL.md
- The `@`/`$`/`?` prefix system cleanly separates shell/tool/reasoning actions

### What's Weak

- **No runtime** — just a spec + 19 converted examples. No harness parses or executes SKILL.make files
- **Conversion is LLM-powered** — `convert.sh` uses `claude -p` to reformat, meaning the format is optimized for LLM consumption but created by LLM translation
- **Token savings are marginal** — skills are loaded once per session; 15% on a 4KB file saves ~600 tokens, negligible vs conversation context
- **Human readability suffers** — Makefile syntax adds cognitive overhead compared to prose for simple skills; complex skills (like github-triage) become dense walls of `?` prefixed lines

### Relation to Our Stack

| Concern | SKILL.make | Our approach |
|---|---|---|
| Skill format | Makefile syntax | Prose SKILL.md (ClawHub) |
| DAG execution | Spec only (no impl) | FlowForge YAML (working impl) |
| Composability | Cross-file targets | Skill references + workflow nodes |
| Token efficiency | ~15% savings | Not a priority (skills load once) |

**Key insight**: FlowForge already solves the DAG problem with YAML workflows. SKILL.make sits in an awkward middle ground — more structured than prose SKILL.md but less capable than FlowForge YAML. For simple skills, prose is clearer. For complex multi-step workflows, YAML with branching and state is more powerful.

### Verdict

**Interesting concept, not actionable.** The core insight (structured DAG > prose for multi-step skills) is valid but we already have it via FlowForge. The Makefile-as-universal-format bet is unlikely to gain traction — it's optimizing the wrong bottleneck (token count) while ignoring the real one (execution reliability requires a runtime, not just a format).

Worth revisiting only if someone builds a harness that actually executes SKILL.make files and demonstrates reliability advantages over prose interpretation.

## See Also

- [[library-skills]] — skill format landscape
- [[repo2skill]] — automated skill generation
- [[skill-lazy-loading-poc]] — skill loading optimization
