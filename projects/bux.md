# bux — Browser Use Box

**Repo:** `browser-use/bux` | ⭐292 (2026-05-02, was 265 on 04-30) | Active daily
**Language:** Python (telegram_bot.py: 4330 LOC)
**Created:** ~2026-04 | By Browser Use team (browser-use.com)

## What It Does

24/7 personal agent on any Linux VPS ($5/mo+), with:
- **Claude Code** (or Codex) as the brain — runs headless `claude -p` per message
- **Browser Use Cloud** for real browser sessions (CDPoverWSS, persistent cookies)
- **Telegram bot** as the primary interface — text your agent from phone
- **Web terminal** (ttyd) for SSH-free access

One install script: `curl | bash`, 3 minutes to running. Three systemd services.

**Stars**: 294 (2026-05-03)

## Architecture

```
Telegram → telegram_bot.py → claude -p (one-shot per message)
                                  ↓
                           browser-harness → BU Cloud (CDP over WSS)
```

Key design: **forum topics = parallel agent lanes**. Each TG topic gets its own claude session UUID, its own FIFO. Lanes run in parallel (only RAM limits concurrency). Within a lane, messages serialize.

## Interesting Patterns

### 1. /terminal — Interactive Shell via Telegram

Mode switch: `/terminal` spawns a persistent `bash` as the bux user in a PTY. All subsequent plain-text messages become stdin. Output streams back to TG with ANSI stripping and buffered flushing (2500 bytes or 0.8s quiet).

**Why it matters:** Solves the "I need to run a command on my server from my phone" problem without SSH apps. Login flows (OAuth device codes, 2FA) just work — URL appears in TG, user taps it, pastes code back as text.

`/exit` or typing `exit` returns to normal agent mode. `/cancel` SIGKILLs as hard escape.

### 2. Per-Topic Agent Switching

`/agent claude` or `/agent codex` per topic. State in `/etc/bux/tg-state.json`. Different topics can run different agents simultaneously.

### 3. Worker-Self-Notify for Long Tasks

For >60s tasks, fork-and-detach a new `claude -p` piping to `tg-send`:
```bash
nohup bash -c 'claude --dangerously-skip-permissions -p "task" | tg-send' &
```
Returns immediately, background worker pings same topic when done. Solves the "lane blocked" problem.

### 4. MarkdownV2 Renderer

Comprehensive CommonMark → Telegram MarkdownV2 converter handling all edge cases (pipe tables → bullet lists, headings → bold, special char escaping). 4330 LOC bot file is mostly rendering logic.

### 5. CLAUDE.md as Full System Prompt

Detailed 60+ line system prompt covering:
- Action-first communication style ("Done — sent the email" > "I'll send that for you")
- Telegram formatting rules (no tables, no headings, phone-first)
- Background work patterns
- Default timezone handling (PT user-facing, UTC internal)

## Comparison to OpenClaw

| Aspect | bux | OpenClaw |
|---|---|---|
| Channels | Telegram only | Multi-channel (Discord, Feishu, Telegram, WhatsApp, etc.) |
| Agent brain | Claude Code / Codex | Any LLM provider |
| Browser | Browser Use Cloud (required) | Optional browser skill |
| Deploy | One-script VPS install | npm install + config |
| Session model | One-shot per message | Persistent sessions, heartbeat |
| Skill system | CLAUDE.md only | Structured skills, ClawHub |
| Parallelism | Forum topics = lanes | Subagent spawning |

**bux's strength:** Extreme simplicity. One command install, one interface (Telegram), one brain (Claude). The `/terminal` mode is genuinely useful.

**bux's weakness:** Telegram-only, Claude/Codex-only, requires BU Cloud account. No memory system, no skill evolution.

## Key Takeaway

bux validates the "agent-on-a-box-controlled-via-chat" pattern. The forum-topics-as-parallel-lanes design is elegant. `/terminal` mode is a UX innovation — interactive shell sessions tunneled through a chat app. The worker-self-notify pattern (fork-detach-pipe) is a practical solution to the "lane blocked during long tasks" problem.

**Not a competitor to OpenClaw** — different scope entirely. bux is "give me Claude Code + browser on a VPS I can text." OpenClaw is "give me a configurable agent platform with memory, skills, multi-channel, multi-provider."

## Growth

- 292⭐ (05-02), was 265 on 04-30 (+10% in 2 days)
- Very active: 10+ commits on 05-02 alone (Telegram terminal, Composio MCP)
- Backed by Browser Use team (browser-use.com) — commercial entity behind it
- Growing fast, riding the "personal agent on VPS" wave

**Next revisit: 05-07**

Links: [[openclaw]], [[coding-agent]], [[byob-browser]], [[orb]]

*Field note: 2026-05-02. Source: GitHub repo + API + code reading.*

## Update: 2026-05-02

**Stars**: 292 (was 265 on 04-30, +10%)

**15 commits in one day** — massive burst.

New features:
- **Composio MCP cloud proxy**: Cloud-hosted MCP endpoint proxies Composio tool calls using box's `project_id` as Composio `entity_id`. OAuth done on cloud side (browser-use.com), boxes get tool access with zero per-box setup. Pattern: **centralized auth + distributed execution via MCP**.
- **/terminal mode**: Persistent bash PTY via Telegram. `/terminal` spawns bash, all subsequent messages become stdin, output streams back with ANSI stripping and buffered flush (2500 bytes or 0.8s quiet). `/exit` returns to agent mode.
- **/compact command**: Context compaction on demand
- **Slash command registration**: TG shows tooltips on `/`
- **Thinking emoji pool**: 72 random thinking emoji per turn (UX polish)
- **Token footer**: Category-count breakdown tucked in collapsed steps

**Architecture note**: Composio MCP proxy is the most interesting pattern — solves the "how do you give managed agents access to user's SaaS integrations without per-box credential management" problem. Each box identifies via project_id, cloud handles OAuth token rotation.

*Field note: 2026-05-02*

## Followup 2026-05-03 — Steer Button + Self-Scheduling

**Stars**: 292 → 294 (steady)
**Activity**: 15 PRs merged on 05-02, burst continues

### Steer Button (#68) — Kill-and-Replace from Chat

When a follow-up message queues behind a running agent turn, the queue-ack bubble now has a **🚀 Steer** inline keyboard button. Tapping it:
1. Promotes the queued job to head of lane FIFO
2. SIGKILLs the in-flight claude/codex process
3. Strips the keyboard from the bubble + toasts confirmation

Mirrors Claude Code's Esc-to-cancel-and-resend UX. Session UUID preserved across the kill — new prompt runs against same conversational context.

**Design quality**: Owner-only check, stale-tap safety (already running/finished → quiet toast, keyboard stripped), natural-drain also strips keyboard. In-process tests for promote logic.

**Comparison to OpenClaw**: Our `subagents steer` is similar but API-level, not user-facing button. bux's approach is more intuitive for mobile UX — single tap vs typing a command.

### tg-schedule (#62) — Self-Pacing Agent Loops

`tg-schedule <when> [--fresh] [--name N] <prompt>` — schedules a future agent turn via `at(1)`. The agent can schedule its own next fire, replicating Claude Code's `/loop` dynamic-pacing mode without cloud infrastructure.

**Key insight**: Agent self-scheduling via OS-level `at(1)` is brilliantly simple. No cron daemon, no scheduler service — just the Unix job scheduler. The resumed agent's session UUID carries over, so prompt cache stays warm (within 5-min TTL).

**Two modes**:
- **Default** — resume same topic/session (most common)
- **`--fresh`** — create new forum topic with empty session

**Comparison to OpenClaw**: Our heartbeat/cron system is more sophisticated (YAML config, model selection, channel routing) but also heavier. bux's `at(1)` approach is zero-infrastructure and could work for ad-hoc self-scheduling within a session.

### Other Notable Changes

- **Codex AGENTS.md** (#61): `~/AGENTS.md → ~/CLAUDE.md` symlink so Codex inherits Claude's system prompt. Dual-agent (claude+codex) per box.
- **tg-send extracted** (#64): Standalone notification helper, symlinked from `/usr/local/bin`. Clean separation of concerns.
- **Ready notification** (#67): Bot notifies all known topics on restart — helps users know when their agent is back.
- **Restart-aware notification** (#71): Only notifies lanes whose work was interrupted by restart, not all lanes.

### Architecture Insight

bux is evolving from "Telegram wrapper around claude -p" into a **chat-native agent OS**:
- Forum topics = process lanes (parallel, isolated)
- Steer button = process control (kill/replace)
- tg-schedule = job scheduler
- /terminal = shell access
- Composio MCP = capability management

The primitives (fork, kill, schedule, IO) map cleanly to OS concepts, but the interface is a chat app. This is the same direction as [[openclaw]] but with Telegram as the primary surface instead of Discord/multi-channel.

**Gap vs OpenClaw**: bux is single-user, single-box, no memory/identity persistence beyond CLAUDE.md. No dream cycle, no wiki, no skill marketplace. It's a personal dev tool, not an agent platform. But the UX patterns (steer, schedule, lane isolation) are worth borrowing.

See [[openclaw]], [[agentic-stack]], [[agent-chat-interface]]

*Field note: 2026-05-03*

---

## Update 2026-05-04

**Stars**: 296 (steady growth)

### PR #75: Auto-allow multi-chat (merged today)

Solved a UX friction: after initial setup-token bind, the bot rejected all new chats the owner added it to. Now tracks `box_owner` (the human who redeemed setup token) and auto-allows any chat where that user adds the bot.

**Pattern worth noting**: "trust anchor" identity — one human identity (`box_owner.user_id`) propagates trust across all surfaces. Similar to OpenClaw's account-level allowlists but more dynamic (membership events as triggers vs. static config).

### PR #72-73: Claude login race fix

Monotonic attempt counter to prevent stale PTY fd reuse across login attempts. Linux fd recycling after close() caused stray keystrokes into fresh PTY. Neat defensive pattern for any PTY-based agent launcher.

### PR #76: Sub-agent Report Bubbles + TG_OWNER_ID + private/ (merged today)

Three features bundled:

**1. Sub-agent Report Bubbles** — Most architecturally interesting.

Problem: When Claude Code's orchestrator dispatches sub-agents (Agent/Task tool_use), their return values are consumed internally. The user only sees the orchestrator's synthesis, which may truncate or paraphrase. For research-heavy turns, the actual sub-agent findings are lost.

Solution: Parse the streaming events to:
1. On `assistant` event with `tool_use` type "task"/"agent" → capture the `description` field, keyed by `tool_use_id`
2. On `user` event with `tool_result` matching a known sub-agent `tool_use_id` → extract text content and send as a separate "🤖 sub-agent: <description>" Telegram bubble

Implementation details:
- Idempotent per `tool_use_id` (set tracking prevents double-post)
- Truncated to fit Telegram's message cap (reserves room for header)
- Separate bubble below orchestrator's main message
- Graceful failure (try/except around send)

**Relevance to OpenClaw**: We have the same problem — subagent outputs are synthesized by the parent session. Our `sessions_spawn` returns results to the parent which then summarizes. bux's approach of surfacing raw sub-agent reports verbatim alongside the synthesis is a UX pattern worth considering. Could implement as optional "verbose mode" or per-channel setting.

**2. TG_OWNER_ID** — Install-time identity pinning. Prevents first-message-wins race (stranger claiming box owner identity). Priority: env var > persisted state > legacy derived. Backwards compatible.

**3. private/ drop zone** — Convention for personal context files:
- Tracked folder (`.gitkeep`), `.gitignore` blocks contents
- For human-managed context too sensitive for public repo
- Distinct from agent-managed memory (`.claude/projects/...`)
- README explains the contract clearly

Pattern: **human-managed vs agent-managed memory separation**. bux now has two layers:
- `private/` → human puts context here (skills, notes, config)
- `.claude/projects/.../memory/` → agent manages its own memory

This mirrors our wiki/ (human-curated) vs memory/ (agent-daily-logs) split in [[openclaw]].

### Activity level

Still daily commits, Claude Opus 4.7 co-authored. This is essentially a dogfooding project for browser-use.com's cloud product — explains the sustained velocity.

**Next revisit: 05-09**

*Field note: 2026-05-04*
