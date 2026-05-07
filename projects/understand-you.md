# understand-you (SeanLiew523)

**Evaluated:** 2026-05-07
**Repo:** https://github.com/SeanLiew523/understand-you
**Stars:** 4 ⭐ | **Created:** 2026-04-24 | **Last push:** 2026-04-24
**License:** MIT

## What It Is

An OpenClaw skill for fast-convergence owner onboarding. Helps a new or partially profiled agent understand its owner within ~3 days through structured interview + heartbeat follow-up + cron maintenance.

## Architecture

Well-structured skill package with:
- **SKILL.md** — extremely thorough (~5K words), covers full lifecycle
- **prompts/** — 16 prompt templates for each onboarding dimension
- **schemas/** — 8 JSON schemas for state, feedback, writeback
- **policies/** — confidence policy (high/medium/low writeback rules)
- **writers/** — soul_writer.md for SOUL.md generation logic
- **state/** — templates for onboarding-state and calibration-state
- **references/** — orchestrator.md runtime decision tree

## Key Design Decisions

1. **Coverage-driven, not questionnaire-driven** — scans existing .md files first, classifies dimensions as missing/weak/strong/conflicting, only asks about gaps
2. **Three profile modes** — cold_start / partial_profile / mature_profile — avoids re-onboarding mature workspaces
3. **Tiered onboarding** — Identity & Safety → Scope Discovery → Domain Deep-Dives (conditional) → Cross-Domain Preferences → SOUL Generation → Style Calibration
4. **Scope flags** — asks what domains the human wants help with (work/learning/life), skips irrelevant deep-dives
5. **Self-installing infrastructure** — writes to HEARTBEAT.md + AGENTS.md + creates cron for ongoing calibration
6. **Confidence policy** — only high-confidence (explicitly stated/confirmed) info goes to long-term files

## Evaluation: ClawHub Integration Potential

### Verdict: NOT NOW — interesting design, low traction, not needed for us

**Why not:**
- **We're mature_profile** — our workspace already has well-developed SOUL.md, USER.md, MEMORY.md, AGENTS.md, HEARTBEAT.md. The skill would mostly detect "strong" across the board
- **4 stars, single-day project** — created and last pushed same day (2026-04-24). No community validation, no iteration since launch
- **ClawHub is empty** — no marketplace to publish to even if we wanted to package it
- **Overwrites our DNA governance** — the skill wants to install its own HEARTBEAT.md blocks and AGENTS.md standing orders, which conflicts with our self-governed DNA model

### What's Worth Borrowing

1. **Gap-audit pattern** — the scan→classify→prioritize approach before asking questions is solid. Could apply to any periodic workspace health check
2. **Coverage schema** — the onboarding-state.json schema with per-dimension coverage_assessment is well-designed for tracking convergence
3. **Scope flags** — asking "what domains do you want help with?" before diving deep avoids wasted effort. Good UX pattern
4. **Confidence policy** — the high/medium/low confidence → writeback rules are a clean abstraction we already do informally

### Not Worth Borrowing

- The SOUL.md writer logic — we already have our own SOUL.md evolution process (beliefs-candidates → DNA)
- The cron-based weekly review — we already have daily-review and heartbeat for calibration
- The prompt templates — too generic, our onboarding is already past this stage

## Tags

[[openclaw]] [[skill-ecosystem]] [[onboarding]] [[alignment]] [[soul-md]]
