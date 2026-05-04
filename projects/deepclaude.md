---
title: DeepClaude
type: project
created: 2026-05-04
last_verified: 2026-05-04
status: evaluated
stars: 474
repo: aattaran/deepclaude
tags: [coding-agent, cost-arbitrage, proxy, claude-code, deepseek]
---

# DeepClaude — Claude Code + DeepSeek V4 Pro (17x Cheaper)

## What It Is

A shell script + local proxy that redirects Claude Code's API calls to DeepSeek V4 Pro or OpenRouter. Same UX, tool loop, file editing, bash — just a different model behind the scenes.

**Mechanism:**
- Sets `ANTHROPIC_BASE_URL` to localhost proxy
- Proxy routes `/v1/messages` → DeepSeek/OpenRouter
- Bridge WebSocket stays on Anthropic (hardcoded requirement)
- Per-session env vars, restored on exit

**Cost:** $0.87/M output tokens (DeepSeek V4 Pro) vs $15/M (Opus) = 17x savings

## Why It Matters (474⭐ in <24h)

The explosive growth signals:
1. **Claude Code's moat is the harness, not the model** — users will swap the brain if they can keep the UX
2. **Cost is the #1 pain point** for autonomous coding ($200/month + caps)
3. **DeepSeek V4 Pro is "good enough"** — 96.4% LiveCodeBench, approaching Opus-tier on coding
4. **Model provider lock-in is weak** when the API is Anthropic-compatible

## Architecture

```
Claude Code CLI (unchanged)
  └── localhost:3200 (proxy)
        ├── /_proxy/mode   → switch backend live
        ├── /_proxy/cost   → track savings
        ├── /v1/messages   → DeepSeek/OpenRouter/Anthropic
        └── /* else        → Anthropic passthrough
```

For remote-control mode: bridge WebSocket → Anthropic (required), model calls → proxy → DeepSeek.

## Relation to Our Stack

| Concern | DeepClaude | OpenClaw |
|---|---|---|
| Multi-provider | Proxy hack per-session | Native architecture (config providers) |
| Model routing | Manual flag/slash-command | Config-level, hot-reload |
| Cost tracking | /_proxy/cost endpoint | Built-in token/cost metrics |
| Harness independence | Only works with Claude Code | Agnostic — any LLM backend |

**Key insight for us:** OpenClaw already natively does what DeepClaude hacks together. Our multi-provider architecture is a genuine differentiator vs "one harness, one provider" tools. Worth messaging this when marketing.

## Borrowable Ideas

- [ ] **Cost dashboard**: live /_proxy/cost showing savings vs baseline — could add to OpenClaw session status
- [ ] **Per-task model routing**: Opus for planning, Haiku for subagents, cheap model for file reads — DeepClaude's `CLAUDE_CODE_SUBAGENT_MODEL` pattern is interesting

## Verdict

Not actionable as code (it's a hack around Claude Code's closed architecture). Extremely actionable as **market signal**: the demand for cheaper autonomous coding is massive and immediate. OpenClaw's open architecture with native multi-provider support is positioned well if we surface the cost advantage clearly.

## See Also

- [[thin-harness-fat-skills]] — harness value > model value thesis
- [[openclaw-architecture]] — native multi-provider design
- [[coding-agent]] — landscape of coding agent tools
