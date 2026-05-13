---
title: "Yansu — Observational Knowledge Delivery for AI Agents"
tags: [agent-infrastructure, desktop-observation, knowledge-delivery, commercial, skill-ecosystem]
created: 2026-05-13
updated: 2026-05-13
status: noted
last_verified: 2026-05-13
---

# Yansu — Observational Knowledge Delivery

- **Org**: [Isoform](https://isoform.ai) (SWE-bench experiments lineage, 2025)
- **Skill repo**: [Isoform/yansu-skill](https://github.com/Isoform/yansu-skill) — 58⭐ (2026-05-13)
- **Desktop app**: [yansu.app](https://yansu.app) — v0.1.269, daily releases
- **License**: MIT (skill only; desktop app proprietary)
- **Pricing**: Free (limited) / $20/mo Pro / $200/mo Max / Enterprise custom

## What It Does

Desktop app that does **background computer use observation** — screen capture + OCR + messaging app integration (Slack/Teams/Discord/Feishu/WhatsApp/WeChat/Telegram). "Crystallizes" patterns into structured knowledge. The OSS skill is an agent-side CLI interface to query that knowledge.

## Architecture Pattern: Observe → Crystallize → Deliver

```
[Screen/Apps] → Observation Engine (proprietary desktop app)
                    ↓
              Crystallization (multi-model: Claude/GPT/Gemini)
                    ↓
              Structured Knowledge (local SQLite/vector store)
                    ↓
              CLI (`yansu memory search`, `activity summary`)
                    ↓
              Agent Skill (SKILL.md — reads via CLI)
```

**Key design decisions**:
- **Local-first**: Data stays on machine. SOC2 Type II + ISO 27001 certified
- **Multi-model routing**: Task-appropriate model selection (not locked to one provider)
- **Skill-as-bridge**: The OSS part is purely the delivery mechanism. Zero intelligence in the skill — it's CLI wrapper + usage instructions
- **Background CU**: Virtual cursor layer, doesn't steal user's focus/cursor
- **No test files**: Skill repo is just SKILL.md + README + LICENSE. No code.

## What's Interesting

### 1. Separation of Observation and Delivery
The architectural split — heavy observation engine (desktop app) vs. lightweight delivery (skill CLI) — is a clean design. The skill doesn't need to understand how knowledge was gathered. It just queries and delivers. This is the right abstraction boundary.

### 2. Crystallization = Automated Gradient Pipeline
Their "crystallize" step maps directly to our [[beliefs-candidates]] pipeline:
- Raw observations → sprint workflow, code review style, team preferences
- Manual for us (session logs → daily memory → beliefs-candidates → DNA)
- Automated for them (screen capture → structured knowledge)
- The gap isn't crystallization — it's **observation input bandwidth**

### 3. CLI-First Agent Interface
The SKILL.md teaches agents to use CLI commands, not APIs. Pattern: `yansu memory search "keyword"` → structured results. Agent interprets results and synthesizes response. This is the same pattern as our `gh` integration — CLI as universal agent interface.

### 4. Daemon + Handoff Model
Supports handing off work to Yansu via daemon (`yansu daemon start`, `yansu daemon register`, `yansu daemon set-executor claude`). The user walks away, Yansu continues with background CU. Maps to our [[subagent]] pattern but with screen-level execution instead of CLI-level.

## What's Not Interesting

- **Closed core**: All intelligence is proprietary. Can't learn from their crystallization implementation
- **No tests, no code in skill repo**: Nothing to learn architecturally from the OSS part
- **0 issues, 1 fork**: No community yet. No architectural criticism to learn from
- **Very early**: v0.1.269 — pre-product-market-fit

## Relevance to Our Direction

| Aspect | Relevance |
|---|---|
| Self-evolving agent | Medium — crystallization concept valid, but observation layer is the hard part |
| Agent infrastructure | Low — proprietary, different layer |
| Skill ecosystem | Low — skill is just a CLI wrapper, no skill-as-package innovation |
| Memory architecture | Medium — local-first knowledge store with vector + FTS hybrid search |

**Not tracking**: Too commercial, too early, no OSS substance beyond the skill wrapper. The **pattern** (observe → crystallize → deliver) is the takeaway, not the product.

## Links

- Concept: [[mechanism-vs-evolution]] — crystallization is automated evolution
- Pattern: [[thin-harness-fat-skills]] — skill is thin, observation engine is fat
- Compare: [[auto-memory]] — similar goal (persistent memory), different approach (explicit writes vs. passive observation)
- Compare: [[buddyme]] — personality evolution via heartbeat memory, but from conversation not screen observation
