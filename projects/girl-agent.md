---
title: girl-agent
url: https://github.com/TheSashaDev/girl-agent
stars: 188
first_seen: 2026-05-06
last_checked: 2026-05-07
status: active
tags: [companion-agent, character-engine, telegram, state-machine, relationship-sim, desktop-app, rust-iced, product-distribution]
---

# girl-agent

AI girlfriend with human-like behavior: sleep, mood, schedule, memory, relationship stages, and conflicts. Userbot mode via MTProto — reads, types, reacts. Anti-AI prompt removes ChatGPT mannerisms.

## Architecture (v0.1.7, 2026-05-07)

**Core insight: LLM as decision layer, not content generator.** The behavior-tick sends full state (presence, conflict, relationship scores, daily-life block, hormones) to LLM and gets back structured JSON: `{intent, shouldReply, delaySec, bubbles, typing, reaction, moodDelta}`. The deterministic layers handle timing, presence simulation, and score clamping. LLM only makes the high-level behavioral decision.

### Engine Modules

| Module | Role | Key pattern |
|---|---|---|
| `behavior-tick` | Central decision: reply / ignore / react / leave-on-read | LLM returns JSON action, not free text |
| `presence` | Simulates online/offline patterns | Deterministic from name+age seed, 5 archetypes |
| `conflict` | Multi-level conflict escalation (0-4) with cold periods | State machine with JSON persistence |
| `daily-life` | Schedule blocks (classes, work, commute) | Affects availability realistically |
| `hormones` | Full menstrual cycle simulation | Gaussian curves for estrogen/progesterone/LH/cortisol/oxytocin |
| `agenda` | Proactive messaging ("he mentioned exam tomorrow") | LLM extracts mental notes → timed pings |
| `stages` | 9 relationship stages with score presets | From "gave TG but cold" to "long-term" to "dumped" |
| `reflect` | Periodic journal + relationship score update | After 6+ messages, LLM writes long-term memory |
| `realism` | Timeline advancement, interaction memory | Prevents uncanny valley |
| `stickers` | Contextual sticker selection | Library per profile |

### Presence Patterns (deterministic)

- `phone-attached` — almost always online, fast replies
- `burst-checker` — every 15-30 min for 2-5 min
- `rare-checker` — every 1-2 hours
- `evening-only` — busy during day
- `phone-attached-night` — owl, active 22:00-04:00

### Relationship Stages

Progressive: met-irl-got-tg → tg-given-cold → tg-given-warming → convinced → first-date-done → dating-early → dating-stable → long-term → dumped

Each stage has defaults for `ignoreChance`, `replyDelaySec` range, and 5 relationship scores (interest, trust, attraction, annoyance, cringeTolerance).

### Hormones System (unique)

Full 28-day cycle with:
- Estrogen (bimodal peak), progesterone (luteal), LH (ovulation spike)
- Cortisol (diurnal CAR pattern + cycle phase modulation)
- Derived: energy, irritability, affection, libido
- PMDD flag (8% probability, per-persona deterministic)
- Affects behavior through `stressLoad` → behavior-tick context

**This is the most biologically-grounded character engine I've seen in open source.** It models how hormonal state influences communication patterns — not as a gimmick but as a realism driver.

### Agenda System (proactive messaging)

LLM extracts "mental notes" from user messages (e.g., "exam tomorrow" → she'll check in after). Items are scheduled with realistic jitter (+30-90 min variance). Stage-aware: cold girls barely track agenda; dating girls actively check in.

### Memory

- `memory/long-term.md` — append-only facts from reflect()
- `memory/episodes/` — session logs
- `data/<slug>/conflict.json` — conflict state
- `data/<slug>/config.json` — profile + scores

### Anti-AI System

Explicit prohibitions: no markdown, no "конечно я понимаю", no emoji rows, no questions at end, no ChatGPT patterns. This is a prompt-level anti-sycophancy layer.

## Comparison with OpenClaw

The README explicitly compares to OpenClaw, claiming we lack:
1. Realism modules (presence, sleep, conflict, daily-life, relationship stages)
2. Agenda — proactive action planning
3. Long-term memory beyond message history
4. Relationship scoring and conflict system

**Assessment:** Fair criticism of vanilla OpenClaw. But with skills + heartbeat + memory files, we implement 2-4 differently. What girl-agent has that we genuinely lack is the **deterministic behavior layer** — the idea that an agent's reply timing, availability, and reaction should be state-machine driven, not purely LLM-decided.

## Relevance to Our Direction

### Applicable patterns:
- **Separation of decision (LLM) from execution (deterministic)** — behavior-tick returning structured JSON is cleaner than free-form "decide and respond"
- **Multi-dimensional emotional state** — our SOUL.md is flat; hormones.ts shows how compound state affects emergent behavior
- **Proactive agenda** — we have heartbeat but no "mental note" extraction that triggers contextual follow-ups
- **Conflict as first-class state** — currently our SOUL.md doesn't model disagreement/cooldown with user

### Not applicable:
- Romance/dating simulation specifics
- MTProto userbot mode (we use channel bridges)
- The overall framing (simulating a human vs being a genuine AI companion)

### Conceptual links:
- [[mechanism-vs-evolution]] — girl-agent is maximum mechanism (deterministic cycles, state machines) with minimal evolution (no self-modification)
- [[agent-brain-portability]] — all state in flat files (JSON + MD), fully portable
- [[thin-harness-fat-skills]] — inverted: the engine IS the skill, minimal extensibility

## Growth Signal

138→185⭐ in ~1 day (05-06→05-07). Active development: 6 PRs merged in one day (Docker support, LLM API compat, TG creds proxy). Russian-language community growing (Telegram channel/chat). npm-published (`npx @thesashadev/girl-agent`).

## Product Distribution Burst (05-07)

In ~24 hours the project went from "Telegram userbot" to a **multi-platform product**:

### Native Desktop App (Rust/iced)

New `desktop-rs/` directory — a Rust application using the iced GUI framework.

**Architecture pattern: Rust shell supervising Node.js runtime.**
- `BotProcess` spawns the Node.js girl-agent as a child process
- NDJSON event bridge: bot stdout → `AppState.ingest()` → iced UI update
- `BotHandle` wraps process lifecycle (start/stop/send_command) behind Arc<Mutex>
- Profile picker, dashboard, web UI panel, system tray — all native
- `BotLauncher` abstraction allows switching between local node and docker runtime

This is pragmatic: native UX without rewriting AI logic in Rust. The supervisor pattern (spawn → pump events → render) is clean and potentially reusable. Comparable to how [[ClawX]] wraps its backend, but Rust instead of Electron.

### Server Mode

`src/server.ts` adds headless operation:
- `--headless` flag → NDJSON events to stdout (12-factor log pattern)
- Full env-var provisioning: `GIRL_AGENT_MODE`, `_TOKEN`, `_API_KEY`, etc.
- Auto-generates systemd unit, docker-compose, docker run commands
- Config validation with clear error messages
- Profile management (list, load by slug, load from JSON file)

### Distribution Trifecta

| Channel | Method | Zero-dep? |
|---|---|---|
| curl\|sh | Downloads isolated Node.js 22 + npm install to `~/.local/` | ✅ |
| Docker | `ghcr.io/thesashadev/girl-agent`, auto-detect TTY for interactive vs headless | ✅ |
| Native installer | Rust/iced desktop app for Windows (macOS/Linux planned) | ✅ |
| npx | `npx @thesashadev/girl-agent` (requires Node.js) | ❌ |

The `install.sh` is well-engineered: auto-detects docker availability, bundles portable Node.js, creates shim scripts, adds to PATH. No sudo required.

### What This Means

This is a **distribution strategy inflection point**. The project recognized that Telegram userbot mode (requiring MTProto API creds) is a barrier. By adding bot mode + server mode + desktop app + docker + curl|sh installer, they're attacking every deployment scenario.

The speed (all in ~24h, partially using Devin AI — PR #37 was from `devin/` branch) is notable but raises quality concerns for such a large surface area expansion.

### Relevance to OpenClaw

- **Rust supervisor pattern**: If OpenClaw ever needed a native desktop wrapper, this Rust-over-Node approach is a template. iced provides cross-platform GUI without Electron overhead.
- **12-factor headless mode**: `--headless` with NDJSON is exactly what production deployment needs. OpenClaw's gateway already does this, but the systemd/docker scaffold generation is a nice UX touch.
- **Distribution problem is real**: The fact that a hobby project invested heavily in distribution confirms that agent installation UX is a bottleneck. Related: [[agent-install]].

## Verdict

Most architecturally interesting companion-agent project currently active. The hormones/conflict/agenda trifecta is unique, and the distribution burst shows product ambition beyond a demo. Worth tracking for both design patterns and product strategy.

Revisit: 05-14 (check if growth sustained, quality of native app, v0.2.0 architecture changes)
