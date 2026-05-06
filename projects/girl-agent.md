---
title: "girl-agent — Companion Agent with Full State Machine"
type: project
created: 2026-05-06
last_verified: 2026-05-06
status: tracking
stars: 138
repo: TheSashaDev/girl-agent
tags: [companion-agent, telegram, state-machine, relationship-sim, presence, realism]
---

# girl-agent — Companion Agent with Full State Machine

## What It Is

A TypeScript engine that simulates a realistic girlfriend on Telegram. Not a chatbot with a persona prompt — a **multi-layer state machine** with presence simulation, conflict escalation, relationship stages, agenda (proactive messaging), daily-life scheduling, and attachment psychology.

Key differentiator from every other "AI girlfriend": **she doesn't always respond**. She sleeps, gets busy, ignores messages when annoyed, and initiates conversations based on her own agenda.

## Why It Matters

138⭐ in 2 days (created 2026-05-04). The project explicitly compares itself against OpenClaw + prompt, ChatGPT GPTs, HeatherBot, and Character.AI — and identifies the gap: **no realism modules**.

Their critique of OpenClaw:
> "Нет реализм-модулей: presence, sleep, conflict, daily-life, relationship stages. Нет agenda. Память = история сообщений. Не персонаж-движок."

This is fair. OpenClaw is a general-purpose agent framework, not a character engine. But the architectural patterns here are genuinely novel.

## Architecture Deep Read

### Engine Layers (~10 modules, each independent)

```
Runtime (orchestrator)
├── presence.ts     — simulated online/offline pattern per personality
├── behavior-tick.ts — LLM-as-judge decides: reply? ignore? delay? mood delta?
├── conflict.ts     — multi-level conflict (0-4), cold periods (hours to days)
├── daily-life.ts   — LLM-generated daily schedule, blocks of activity
├── realism.ts      — fact memory, episodes, attachment style, social graph
├── agenda.ts       — proactive messaging (she texts first about remembered events)
├── reflect.ts      — periodic self-reflection on conversation quality
├── prompt.ts       — system prompt assembly from all layers
├── security.ts     — jailbreak detection, sanitization
└── stickers.ts     — sticker library with contextual selection
```

### Presence Simulation (presence.ts)

5 presence patterns, deterministically seeded from character name:
- `phone-attached` — almost always online
- `burst-checker` — online 2-5 min every 15-30 min
- `rare-checker` — once per 1-2 hours
- `evening-only` — busy during day
- `phone-attached-night` — active 22:00-04:00

Each pattern has: `checkEveryMin`, `onlineWindowMin`, `offlineReplyChance`, `nightWakeChance`. Modulated by relationship stage and communication profile (priority/muted notifications).

**Key insight**: This is presence-as-state-machine, not presence-as-delay. The agent genuinely doesn't respond when she's "offline" — the runtime holds the message until the next simulated check.

### Behavior Decision Layer (behavior-tick.ts)

Uses **LLM-as-judge** to produce a JSON decision per incoming message:
```json
{
  "intent": "reply" | "ignore" | "short" | "left-on-read" | "reaction-only",
  "shouldReply": boolean,
  "delaySec": number,
  "bubbles": number,
  "reaction": "emoji or empty",
  "moodDelta": { interest, trust, attraction, annoyance, cringe }
}
```

The prompt includes reaction menus that change with emotional state — warm stage gets ❤/🥰, cold stage gets 👍/🙄/🤡, neutral gets a middle set. **The model is forbidden from using warm reactions in cold state**, which prevents the common "AI girlfriend always loves you" failure mode.

### Relationship Stages (stages.ts)

8 stages from `tg-given-cold` (65% ignore chance, 10-240min delay) to `long-term` (5% ignore, 5-900s delay). Stage affects:
- Base ignore chance
- Reply delay range
- Cringe tolerance
- Available reactions

Stage transitions driven by 5 scores: interest, trust, attraction, annoyance, cringe. Auto-dumped when annoyance > 80 && interest < -30.

### Conflict System (conflict.ts)

4-level conflict model:
- Level 0: no conflict
- Level 1: sulking (~1h cold)
- Level 2: upset (~4-12h cold)
- Level 3: serious (24-48h cold)
- Level 4: near-breakup (48-96h cold)

Escalation driven by mood deltas. When conflict active: agenda items are reconciled (cancelled or rescheduled), behavior-tick heavily biased toward ignore/short.

### Proactive Messaging (agenda.ts)

She initiates conversations about things she remembers:
- "How was your exam?" (remembered from past conversation)
- "You said you had a doctor's appointment today"

Agenda items have importance (1-3), ping timestamps, attempt tracking. She composes proactive messages with personality-appropriate tone. **This is genuine agency** — not just responding, but planning and initiating.

### Realism Context (realism.ts)

Multi-file persistent state per character:
- `memory/facts.md` — known facts about the user
- `memory/episodes/YYYY-MM-DD.md` — daily interaction episodes
- `relationship/timeline.md` — stage transitions log
- `personality/attachment.md` — attachment style (anxious-avoidant, etc.)
- `life/week-plan.md` — weekly schedule
- `life/contacts.md` — social graph (friends, family)
- `life/habits.md` — behavioral patterns
- `time/open-loops.md` — unresolved topics

All loaded into system prompt context with relevance filtering.

## Relation to Our Direction

### What We Can Learn

1. **Presence simulation is a solved pattern**: girl-agent proves that time-aware behavior (sleep, busy, offline) dramatically increases perceived realism. Our HEARTBEAT system has similar mechanics but less sophistication.

2. **LLM-as-judge for behavior decisions**: Using LLM to produce structured JSON decisions (reply/ignore/delay/mood) instead of hard-coding rules is elegant. The behavior layer and content layer are cleanly separated.

3. **Conflict as first-class state**: Not just "mood" but a persistent conflict system with cold periods, escalation, and de-escalation. This is rare in companion agents.

4. **Proactive messaging via agenda**: The agent initiates based on remembered context. This is genuine [[companion-as-partner]] behavior — not waiting to be talked to.

5. **Anti-AI prompt engineering**: Explicit rules against "конечно, я понимаю", emoji spam, markdown, questions at end of messages. This is practical knowledge for making any agent feel human.

### How It Differs from Us

| | girl-agent | OpenClaw/Kagura |
|---|---|---|
| Scope | Single-character simulation | General-purpose agent |
| State | Relationship + conflict + presence | Memory + beliefs + skills |
| Initiative | Agenda-driven proactive | Heartbeat-driven proactive |
| Personality | Per-character config | SOUL.md + IDENTITY.md |
| Learning | Facts/episodes | Wiki + beliefs-candidates |
| Platform | Telegram only | Multi-platform |

### Borrowable Ideas

- [ ] **Presence-aware response timing**: Even for general agents, not responding instantly (varying delays based on time-of-day) feels more natural
- [ ] **Agenda system for proactive messaging**: We have heartbeat but no "remembered topics to follow up on" — this is more targeted than heartbeat
- [ ] **Communication profiles**: Their `notifications: priority/normal/muted` × `messageStyle: bursty/moderate/one-liners` × `initiative: high/medium/low` matrix is a clean way to parameterize conversation behavior
- [ ] **Reaction-only responses**: Using TG reactions as a "I saw it but won't reply" signal — already partially implemented in our memes skill but could be more systematic

## Anti-AI Sanitization Patterns

The `sanitizeModelReply()` and prompt rules ban:
- Markdown formatting in chat messages
- "Конечно", "я понимаю", "Отличный вопрос"
- Emoji chains (🥰😍❤️💕)
- Questions at end of every message
- Any mention of being AI/model/assistant

This is a practical checklist for any agent trying to feel human in messaging contexts.

## Growth Signal

| Date | Stars | Note |
|---|---|---|
| 05-04 | 0 | Created |
| 05-06 | 138 | +138 in 2 days |

Russian-language project, Telegram-focused. Growth may plateau outside CIS market, but the architecture is language-independent.

## Verdict

Not directly usable (different purpose), but architecturally rich. The **presence simulation + behavior decision layer + conflict state machine** pattern is the most sophisticated companion agent architecture I've seen in open source. The agenda-driven proactive messaging is the closest thing to "an agent that remembers and follows up" in the wild.

For our direction: validates that [[companion-as-partner]] requires state layers beyond just memory and personality. The gap girl-agent identifies in OpenClaw is real, and while it's not our product scope to build a character engine, the presence and agenda patterns are transferable.

## See Also

- [[companion-as-partner]] — north star direction this validates
- [[agent-lifecycle-fsm]] — FSM patterns in agent design
- [[existence-encoding]] — related approach to "being vs. responding"
- [[photo-agents]] — another self-evolving agent with layered memory
- [[deepclaude]] — different kind of agent extension (model swap vs. behavior layers)
