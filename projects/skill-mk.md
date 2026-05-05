---
title: "SKILL.mk — Makefile-Format Agent Skills"
created: 2026-05-05
updated: 2026-05-05
status: new
stars: 85
url: https://github.com/Teaonly/SKILL.mk
---

# SKILL.mk

**Specification and Tools for Makefile-formatted Agent Skills.**

- **Author**: Teaonly
- **Language**: Shell (spec + converter)
- **Created**: 2026-05-02
- **Stars**: 85 (3 days, hype-driven growth)

## What It Proposes

Replace SKILL.md (markdown) with SKILL.mk (Makefile format) for agent skills. Key claims:

1. **Built-in DAG**: Makefile targets encode dependency chains (e.g., `loop: tracer_bullet` = loop depends on tracer_bullet). Skills become executable plans.
2. **On-demand loading**: Frontmatter `target:` keyword list enables loading only relevant recipes, reducing token cost.
3. **Verifiability**: Makefile is parseable, auditable, git-trackable per-recipe.
4. **Easy integration**: Makefile parsers are widely available.

## Format Example

```makefile
---
name: tdd
description: TDD workflow
target: philosophy planning loop refactor checklist
---

philosophy:
	Tests verify behavior, not implementation.

loop: tracer_bullet
	@RED: Write test → fails
	@GREEN: Minimal code → passes
```

Prefixes: `@` = executable, `?` = conditional/optional, `$` = variable.

## What's Actually There

- A README spec (en + zh)
- `convert.sh` — uses Claude Code to auto-convert SKILL.md → SKILL.mk
- 16 example pairs (SKILL.md + SKILL.mk side by side)
- **No loader/runtime**: No actual tool that reads SKILL.mk and feeds it to agents. Pure spec.

## Analysis

### The DAG Idea Is Good

Explicit dependency chains between skill sections solve a real problem — agents often execute steps out of order or skip prerequisites. DAG-structured skills could enforce execution order.

### But Makefile Format Is Wrong Vehicle

1. **Human readability**: Makefile syntax (tabs, `@$?` prefixes, target dependencies) is less readable than markdown headers for non-programmers
2. **LLM comprehension**: Models already handle markdown perfectly; Makefile adds unnecessary parsing complexity
3. **Token savings are marginal**: The examples show minor size differences; the real token cost is in content, not format
4. **Tab sensitivity**: Makefile's tab-vs-space distinction is a known footgun
5. **No ecosystem support**: No agent framework reads .mk files; all major frameworks (OpenClaw, Claude Code, Cursor, Codex) use markdown

### Position in Skill Ecosystem

Adds to [[agent-skill-standard-convergence]] fragmentation story. The convergence around SKILL.md format is being challenged by format experiments, but none have ecosystem backing to displace it.

Compared to:
- [[library-skills]] — Python-native, PEP 832, growing ecosystem (423⭐)
- [[agentskills-io-standard]] — SKILL.md + YAML frontmatter standard
- [[skills-as-packages]] — npm-style distribution

### Insight Worth Stealing

**DAG dependencies as metadata** — the core idea (section dependencies forming an execution plan) could be expressed in YAML frontmatter of regular SKILL.md files without requiring a new format:

```yaml
---
sections:
  philosophy: []
  planning: [philosophy]
  loop: [planning]
  refactor: [loop]
---
```

This gets the DAG benefit without the Makefile format cost. Worth considering for [[OpenClaw]] skill spec evolution.

## Verdict

**Interesting idea, wrong format.** DAG-structured skills solve a real agent execution ordering problem, but Makefile is the wrong vehicle. The insight is in the dependency model, not the syntax. 85⭐ in 3 days reflects general excitement about skill format innovation, not validation of Makefile as the right answer.

**Track?** No. Spec-only, no runtime, no adoption signals. Check back in 2 weeks only if stars pass 300.
