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
