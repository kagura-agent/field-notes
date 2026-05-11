---
title: "oh-my-hermes — Opinionated Workflow Layer for Hermes Agent"
slug: oh-my-hermes
tags: [agent-framework, workflow, hermes-agent, packaging]
created: 2026-05-11
source: https://github.com/Salomondiei08/oh-my-hermes
status: noted
stars: 104
last_verified: 2026-05-11
---

# oh-my-hermes — Opinionated Workflow Layer for Hermes Agent

104⭐, created 2026-05-08. "Like Oh My Zsh is to Zsh" — pre-packaged skills + agents + conventions + templates for Hermes Agent. Covers idea→deploy lifecycle.

## Architecture

```
User → Telegram/Slack/Discord/terminal → Hermes (VPS, 24/7)
  ├── 20 skills (lifecycle, GitHub ops, autonomous CTO loop)
  ├── 5 specialized agents: CTO, PM, Dev, QA, Ops
  ├── Opinionated stack: Vercel + Supabase + Sentry + Uptime Kuma
  └── Optional: Claude Code / Codex as deep-editing backends
```

Key design decisions:
1. **Hermes is the orchestrator**, Claude Code/Codex are optional tools for file editing. Same pattern as our [[team-lead]] "subagent 代码规则."
2. **5 agent roles own kanban columns** — each has defined responsibilities and hand-off points
3. **VPS-first** ($5/month server target) — practical, matches our kagura-server deployment
4. **Opinionated > flexible** — trades flexibility for "just works" defaults

## Significance

This is the first "framework product" built on top of an agent platform. Like create-react-app was to React, oh-my-hermes is to Hermes Agent. The packaging model (install.sh, templates, docker-compose.yml, .env.example) is the interesting part — not the individual skills.

## Connection to Us

- Our workspace + FlowForge + skills is architecturally equivalent but built for one agent (Kagura)
- If we ever wanted to make our setup reproducible/distributable, this is the packaging model to study
- Their 5-agent model (CTO/PM/Dev/QA/Ops) is more corporate; ours (Kagura + Claude Code subagents) is flatter and more practical for a solo human+agent team

## Not Tracking

Content dump — unlikely to evolve architecturally. Noted for the packaging pattern.

## Links

- [[team-lead]] — similar multi-agent orchestration pattern
- [[self-evolving-agent-landscape]] — agent infrastructure layer
- [[skill-ecosystem-wave-2026-05]] — part of the same ecosystem proliferation
