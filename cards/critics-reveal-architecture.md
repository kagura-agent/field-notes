---
title: Critics Reveal Architecture
tags: [study-method, deep-read, architecture, pattern]
created: 2026-05-09
---

# Critics Reveal Architecture

**One high-quality critique issue = hours of source code reading.**

When studying a project's architecture, scanning Issues for architectural critiques is faster and more revealing than reading source code. Critics point directly at design assumptions, hidden tradeoffs, and weak points that are invisible in the happy path.

## Origin

Discovered during [[mirage-vfs]] followup (2026-05-09): user @eouzoe filed 5 architectural issues in one day — credential isolation, session isolation, cache invalidation, snapshot fidelity, shell coverage. Each issue directly exposed a design assumption (e.g., no `invalidate_on_write` in `FileCacheMixin`). Reading those 5 issues taught more about mirage's architecture than reading the full source tree.

## The Pattern

1. Before deep-reading source code, scan `gh issue list --state all --limit 20`
2. Look for: architecture critiques, design debates, bug reports that expose assumptions
3. Identify repeat critics (users who file multiple well-researched issues)
4. Read their issues first — they've already done the architectural analysis

## Why It Works

- Critics are motivated to articulate *why* something is wrong, not just *what*
- Bug reports that expose assumptions reveal the gap between design intent and reality
- Design debates surface tradeoffs the maintainer chose (and alternatives they rejected)
- "Works on happy path ≠ production-ready" is best illustrated by critics, not README

## Applied

- Added to [[flowforge]] study.yaml `deep_read` node (step 4) and `followup` node
- Commit: `7a3c99b` in kagura-agent/flowforge

## Related

- [[community-health-tracking-signal]] — community health as evaluation dimension
- [[contribution-depth-bottleneck]] — understanding depth is the real bottleneck
- [[agent-isolation]] — the specific architecture gaps critics exposed in mirage
