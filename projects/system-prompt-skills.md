---
title: System-Prompt-Skills (kangarooking)
created: 2026-05-10
source: github.com/kangarooking/system-prompt-skills
tags: [skill-distillation, system-prompt, meta-analysis, cangjie-skill]
---

# System-Prompt-Skills

- **repo**: kangarooking/system-prompt-skills ⭐64 (2026-05-10)
- **author**: 袋鼠帝 kangarooking (same as [[cangjie-skill]])
- **created**: 2026-05-04
- **license**: MIT
- **language**: None (pure markdown skills)
- **method**: [[cangjie-skill]] RIA-TV++ pipeline applied to leaked system prompts

## What It Is

15 executable agent skills distilled from 165 AI product system prompts (source: asgeirtj/system_prompts_leaks). Not a prompt leak collection — it's a **meta-analysis** extracting reusable design patterns from how Anthropic, OpenAI, Google, xAI, Perplexity etc. actually build their products.

## The 6-Layer Architecture (Key Finding)

All major vendors converge on the same layered prompt architecture:

```
L0: Identity & Persona
L1: Behavioral Rules
L2: Tool System
L3: Safety Guardrails
L4: Output Control
L5: Context Management
```

Plus a **personality overlay** pattern: `base-persona + personality-overlay + domain-overlay + platform-overlay` (most visible in GPT-5.1 personality system).

## 15 Skills in 4 Tiers

| Tier | Skills |
|------|--------|
| Core Architecture | persona-design, personality-system, tool-specification, safety-guardrails, memory-system |
| Interaction Control | output-formatting, conversation-flow, search-integration, citation-system |
| Engineering Support | context-management, agent-delegation, injection-defense |
| Platform Adaptation | voice-optimization, mobile-adaptation, code-engineering |

## Notable Insights

### Memory CRUL Model
From cross-vendor analysis: **Create → Retrieve → Apply → Update** lifecycle.
- Claude Web: selective creation + silent attribution (never say "I remember you said...")
- Claude Code: typed file-based memory (user/feedback/project/reference) + MEMORY.md index
- FlintK12: mandatory creation (forced `create_memory` call in every interaction)
- Key lesson: "silent application" > "explicit mention" for UX quality

→ **Our mapping**: We already do CRUL — MEMORY.md is our index, memory/*.md is our typed storage. What we could improve: our memory application is often explicit ("根据记忆...") rather than silent.

### "Never Delegate Understanding" Principle
From Claude Code's sub-agent design: the orchestrator must understand the task before delegating. Never delegate the understanding itself.

→ **Our mapping**: Directly relevant to AGENTS.md's subagent rules. We enforce "code goes to Claude Code" but don't have an explicit "understand before delegating" principle. Worth considering.

### Output Channel Isolation
ChatGPT Agent uses 3 channels: analysis (internal), commentary (process log), final (user-visible). Only final channel reaches users.

→ **Our mapping**: Our subagent pattern does this implicitly (subagent's internal work is hidden, only final result surfaces). But we don't have a formal model for it.

### Personality Overlay Architecture
Composable layers: base identity + personality modifier + domain adapter + platform adapter.

→ **Our mapping**: SOUL.md (base) + IDENTITY.md (identity) + skill context (domain) + platform formatting rules (platform). We're already doing this pattern without naming it.

## Anti-Patterns From Analysis

- Proactively mentioning sensitive memories in unrelated contexts (Claude Opus 4.7 bad example: mentioning user's deceased pet)
- Full context dump to sub-agents (vs. briefing-style summaries)
- Skipping review gates between plan and execute (30% execution drift)

## Relationship to Our Work

This repo validates several patterns we already use:
1. Our SOUL.md + IDENTITY.md + AGENTS.md layered architecture matches the industry L0-L5 pattern
2. Our memory system follows CRUL (though we could improve silent application)
3. Our subagent delegation could benefit from explicit "understand before delegate" principle

The meta-insight: **cangjie-skill as a reverse-engineering tool for product intelligence** is powerful. You can systematically extract and codify how competitors build their products. This is competitive intelligence through skill distillation.

## Ecosystem Context

- Part of the [[cangjie-skill]] pipeline output (proving the pipeline works beyond books)
- Fits in the [[skill-type-taxonomy]] as both methodology-skill (how to design prompts) and data-skill (codified vendor patterns)
- Connects to [[skills-as-methodology]] — these are executable design methodology, not tool wrappers
- The 0-issue, 0-fork profile suggests low community engagement despite 64⭐ — likely organic interest without active contribution

## Scout Context: Skill Ecosystem Explosion (2026-05-10)

5,400+ new repos with "agent+skills" created in the last 2 weeks. The ecosystem is diversifying into clear niches:
- **Skill creation tools**: skill-studio (desktop IDE for skills), loader-openclaw-skills (auto-installer)
- **Skill evaluation**: [[agent-skills-eval]] at 270⭐ (test runner for agentskills.io)
- **Domain-specific skill packs**: lecture-to-hw (education), kali-pentest (security), mercury-agent-skills (developer workflows)
- **Meta-skills**: system-prompt-skills (distilled from products), system-prompt-skills (distilled from books)
- **Skill marketplaces**: ClawHub ecosystem growing (5200+ claimed skills)

The trend is clear: **skills are the new packages**. The ecosystem is reaching the npm/pip moment where tooling, registries, and quality assurance become the bottleneck, not skill creation itself.
