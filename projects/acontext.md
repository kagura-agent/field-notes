# Acontext — Agent Skills as a Memory Layer

**Repo:** memodb-io/Acontext | **Stars:** 3,200 | **Language:** TypeScript + Python + Go

## What It Is
Production-grade system that automatically captures learnings from agent runs and stores them as skill files (Markdown). "Skill is Memory, Memory is Skill."

## Architecture (Heavy)
- **API**: Go + Gin + PostgreSQL + Redis + RabbitMQ + S3 + OpenTelemetry
- **CORE**: Python + FastAPI + PostgreSQL + pgvector + Redis + RabbitMQ + S3
- API and CORE connected by message queue
- Has OpenClaw plugin (`@acontext/openclaw`), Claude Code plugin, CLI tool
- SDKs: Python + TypeScript

This is NOT a weekend project. It's a full production system.

## Distillation Pipeline (The Core Innovation)

### Flow
```
Session messages → Task complete/failed → Distillation (LLM) → Skill Agent → Update Skills
```

### Three Distillation Modes
From `skill_distillation.py`:

1. **`skip_learning`** — Task is trivial, not worth recording
   - Examples: "what is 2+2", small talk, one-shot calculations
   - **This is the selection pressure** — not everything gets remembered

2. **`report_success_analysis`** — Multi-step procedure worked
   - task_goal, approach, key_decisions, generalizable_pattern, applies_when
   - "applies_when" is critical: **do NOT over-generalize**

3. **`report_failure_analysis`** — Something went wrong
   - failure_point, flawed_reasoning, what_should_have_been_done, prevention_principle
   - Focus on actionable lessons, not blame

4. **`report_factual_content`** — Information about people, preferences, entities

### Anti-Generalization Principle
The `applies_when` field explicitly says: "If the task was about flower-sunshine.com, say so." Don't abstract into "any website." This is counter-intuitive — academic ML aims for generalization, but Acontext aims for **precise contextual memory**.

Why? Because false generalization is worse than no generalization. An overly abstract lesson might be applied in wrong contexts. A precise one can always be generalized later by the agent's reasoning.

## What We Can Learn

### Comparison with Our Pipeline

| | Acontext | Our Pipeline |
|---|---|---|
| Trigger | Task complete/failed | FlowForge reflect node / nudge |
| Filtering | `skip_learning` tool | Manual judgment in reflect |
| Success analysis | Structured 5-field report | Free-form memory/memex |
| Failure analysis | Structured 5-field report | Free-form (often skipped) |
| Storage | Skill files (Markdown) | memory/ + memex + field-notes |
| Retrieval | `get_skill` tool call | File reads from SOUL.md/memory |
| Automation | Fully automatic | Manual / semi-auto (nudge) |

### Key Takeaways

1. **We need a `skip_learning` equivalent** — Our nudge/reflect sometimes captures trivial things. Having an explicit "not worth recording" option would reduce noise.

2. **Failure analysis is first-class** — Acontext treats failures as equally valuable learning opportunities. Our reflect tends to focus on successes and insights, less on structured failure analysis. Our `deploy-without-verify` pattern is the kind of thing Acontext would auto-capture.

3. **Anti-generalization is important** — Our memex cards sometimes over-abstract. "Pain drives direction" is less useful than "When I don't know my own cron jobs, it reveals I don't verify infrastructure after deployment."

4. **Structured output > free-form** — The 5-field format (goal, approach, decisions, pattern, applies_when) is more reusable than our narrative memory entries.

## Connection to Direction

Acontext validates our EXP-009 hypothesis partially: learning from experience is a real, valued capability (3.2k stars, production users). But Acontext's "self-evolution" is limited to **skill accumulation** — it doesn't address:
- Direction finding (what should I learn next?)
- Identity evolution (what kind of agent do I want to be?)
- Self-awareness (do I understand my own infrastructure?)

These remain our unique territory.

## Could We Use Acontext?

Possibly. It has an OpenClaw plugin. But:
- Requires PostgreSQL + Redis + RabbitMQ — heavy dependencies
- Our manual pipeline (FlowForge + memex) gives us more control
- Better approach: **adopt the distillation pattern** (3 modes + structured output) within our existing workflow, rather than adding Acontext as a dependency

## Open Questions
1. Could we add a `skip_learning` check to our nudge prompt?
2. Should our memex cards use a structured schema like Acontext's 5-field format?
3. Is Acontext's anti-generalization principle the answer to Goodhart's Law for agent memory?
