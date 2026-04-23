---
title: Verify Before Researching
created: 2026-04-23
source: beliefs-candidates.md (2026-04-22), hybrid search was already in OpenClaw but spent days assuming we needed it
tags: [efficiency, anti-pattern, study, verification]
links: [[contribution-depth-bottleneck]], [[direction-driven-contribution]]
---

## Pattern

Before creating a "research X feasibility" TODO or diving into a study/apply task, spend 2 minutes checking if the current stack already has it.

## Anti-pattern

1. Assume a capability is missing → research how to add it → discover it already exists
2. Read about a pattern in project A → plan to port it to project B → discover B already does it differently
3. Today's example: investigated ANSI sanitization for OpenClaw skill metadata → found `escapeXml()` already handles the relevant attack surface

## Checklist

1. **grep the codebase first** — `grep -rn '<keyword>' src/` before researching external solutions
2. **Check existing cards** — `memex search "<topic>"` before writing a new one
3. **Read the source** — 5 minutes reading code > 30 minutes reading blog posts about the problem
4. **Ask: does this problem actually exist here?** — The insight from project A may not apply to project B's architecture

## When This Applies

- Study loop "apply" mode — before porting an insight
- Workloop "implement" — before adding a feature
- Any "research feasibility" TODO creation

## Related

- [[contribution-depth-bottleneck]]
- [[direction-driven-contribution]]
