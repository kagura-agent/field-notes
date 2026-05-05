---
title: ClawHub
tags: [openclaw, skill-ecosystem, registry]
created: 2026-05-05
---

# ClawHub

OpenClaw's skill marketplace and registry — the `npm` for agent skills.

## What It Does

- **Publish**: `clawhub publish` packages a SKILL.md + assets into a distributable skill
- **Install**: `clawhub install <skill>` adds skills to an agent's workspace
- **Search**: `clawhub search <query>` discovers skills from the registry
- **Sync**: keeps installed skills up to date

## Current State (2026-05)

Still early. Marketplace is mostly empty — few third-party skills published. The CLI works but adoption hasn't reached critical mass. Most skills are still shared via git repos or copy-paste.

## Architecture

Skills are git-backed packages with a `SKILL.md` entry point. ClawHub wraps git operations with metadata, versioning, and a registry index.

## See Also

- [[skills-as-packages]] — the packaging model ClawHub implements
- [[skill-behavioral-testing]] — testing skills before publishing
- [[self-evolving-agent-landscape]] — ecosystem context
