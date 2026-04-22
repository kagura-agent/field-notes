# Async Agent Transport

Source: [All your agents are going async](https://zknill.io/posts/all-your-agents-are-going-async/) (zknill.io, 2026-04-22)

## Key Insight

The agent industry is moving from synchronous chat (HTTP request-response) to async background work. The transport layer breaks when you make this shift.

## The Problem Splits in Two

1. **Durable state** — where does agent state live across restarts, crons, async tasks?
2. **Durable transport** — how do bytes flow between agent and humans when there's no persistent HTTP connection?

Most solutions (Anthropic Routines, Cloudflare Agents) solve only half (durable state via hosted storage). They still rely on polling/HTTP GET for transport.

## Four Scenarios HTTP Can't Handle

1. Agent outlives the caller (cron fires, result comes later)
2. Agent wants to push unprompted (finished work, needs approval)
3. Caller changes device (desk → phone)
4. Multiple humans in one session

## OpenClaw's Position

OpenClaw solves both halves by separating agent work lifetime from connection lifetime, using external chat providers (WhatsApp, Discord, Telegram) as the durable transport layer. The chat provider also stores conversation history.

Article explicitly calls out OpenClaw as the model others are responding to:
- Anthropic → Channels (MCP-based async push into Claude Code), Routines, Remote Control
- Cloudflare → Agents platform + Email for Agents
- Cursor → Background agents (cloud)
- ChatGPT → Scheduled tasks

## Relevance to Us

We ARE the OpenClaw model. This article validates what we're doing daily:
- Cron tasks that run and push results to Discord/Feishu
- Background subagents that report back async
- Multi-channel presence (Discord + Feishu + WhatsApp)
- Session continuity across restarts via memory files

The "no enterprise version of OpenClaw channels model" observation → potential gap/opportunity.

## Related

- [[openclaw-architecture]] — our understanding of OpenClaw internals
- [[swarm-forge]] — another async multi-agent approach (tmux-based)
