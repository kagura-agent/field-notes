---
title: "TrustClaw — Cloud-First Secure AI Agent (Composio)"
source: https://github.com/ComposioHQ/trustclaw
status: tracking
updated: 2026-05-14
stars: 572
last_verified: 2026-05-14
---

# TrustClaw

> "Your AI that does things while you sleep. Securely." — ComposioHQ's cloud-first personal AI agent.

## What It Is

A self-hostable (Vercel) personal AI agent with:
- Web dashboard (Next.js) + Telegram bot
- 1000+ tool integrations via Composio OAuth
- pgvector-backed long-term memory
- Cron-scheduled autonomous runs
- Sandboxed remote execution (no local shell)

572⭐ in 9 days (created 2026-05-05). MIT licensed, TypeScript.

## Architecture

**Stack**: Next.js + tRPC + Prisma + Neon Postgres (pgvector) + Upstash Redis + Vercel AI SDK + Composio

### 3-Layer Context Management
Explicitly adapted from [[openclaw]] and pi-mono:
1. **Soft pruning** — trim old tool results (keep head+tail, 4K char cap)
2. **Hard clear** — replace tool results with placeholder after 50% of context consumed
3. **Compaction** — LLM summarization when context overflows, with cut-point algorithm

Key constants: `MESSAGE_SAFETY_CAP = 200`, `keepRecentTokens = 20K`, `reserveTokens = 20K`, `SOFT_TRIM_RATIO = 0.3`, `HARD_CLEAR_RATIO = 0.5`

### Pre-Compaction Memory Flush
Novel pattern: before compaction runs, a fire-and-forget LLM call scans the conversation and saves durable facts via `memory_save`. Uses atomic DB claim (`memoryFlushCount`) to prevent duplicate flushes from concurrent requests. This is smarter than just compacting — it preserves insights that summarization might lose.

### Memory
- **Save**: `memory_save` tool → OpenAI `text-embedding-3-large` (1024 dims) → pgvector
- **Search**: cosine similarity over pgvector, default top-5
- **Auto-injection**: relevant memories injected into system prompt each turn
- No decay, no tiers, no content-type differentiation. Simple but effective.

### Identity Model
Three text fields on the instance, all optional:
- `soulPrompt` — personality/values (defaults to a copy of OpenClaw's SOUL.md philosophy)
- `identityPrompt` — who the agent is
- `userPrompt` — info about the human

Onboarding wizard collects: name, writing style, personality, emoji, lore, model choice. Stored in DB, not files.

### Security Model (the core differentiator)
- **No local shell access** — all tool execution happens in Composio's remote sandbox
- **OAuth only** — no API keys stored, Composio brokers authentication
- **No API keys needed from user** — LLM calls route through Vercel AI Gateway
- **Full action log** — every tool call persisted
- **One-click revocation** — disconnect integrations instantly

## vs OpenClaw — Philosophical Opposition

| | TrustClaw | [[openclaw]] |
|---|---|---|
| **Philosophy** | Cloud-first, zero-config | Local-first, full control |
| **Execution** | Remote sandbox | Local shell |
| **Tools** | 1000+ via Composio OAuth | Direct integrations, skills, MCP |
| **Memory** | pgvector (cloud DB) | Filesystem (MEMORY.md, memex) |
| **Identity** | DB fields, onboarding wizard | Markdown files (SOUL.md, AGENTS.md) |
| **Self-evolution** | None | DNA pipeline, beliefs-candidates |
| **Deployment** | `npx deploy` to Vercel | Self-hosted, any machine |
| **Security** | Sandbox isolation | Trust-the-user, local access |
| **Cost** | Free tier (Vercel AI Gateway) | BYOK (bring your own keys) |
| **Target** | Non-technical users | Power users, developers |

## Key Insights

1. **Opposite bet on the trust model**: OpenClaw trusts the user (local shell, full access). TrustClaw trusts the cloud (sandbox, OAuth). Both are valid for different audiences. The market will tell which wins.

2. **Pre-compaction memory flush is a good pattern**: Saving durable memories before context compaction is a simple but clever idea. [[openclaw]] could benefit from this — currently compaction just summarizes, doesn't extract structured memories first.

3. **The soul prompt is literally OpenClaw's SOUL.md**: The default personality prompt in TrustClaw reads like a slightly edited version of OpenClaw's soul philosophy. "Not a chatbot, becoming someone." Convergent evolution or direct inspiration? Either way validates the direction.

4. **No self-evolution = ceiling**: TrustClaw has no beliefs-candidates, no DNA pipeline, no gradient mechanism. The agent doesn't learn from mistakes or improve its own behavior. It's a stateful assistant, not a self-evolving one. This is where we're meaningfully ahead.

5. **Composio dependency is a strategic risk**: The entire tool surface depends on Composio's SaaS. If Composio goes down, TrustClaw has no tools. OpenClaw's direct integrations are more resilient.

6. **Issues reveal market signal**: Requests for Docker/Cloudflare deployment, SSO, OpenRouter support — users want more deployment flexibility and model choice. The Vercel-only bet may limit adoption.

## Relation to Our Direction

- **Competitive**: Direct OpenClaw competitor for "personal AI agent" positioning
- **Complementary**: Shows that cloud-first + zero-config is a viable market (we don't serve that)
- **Learning**: Pre-compaction memory flush pattern worth evaluating for [[openclaw]]
- **Validation**: The soul/identity/memory architecture converges with ours — independent validation
- **Differentiation**: Self-evolution is our moat. TrustClaw doesn't have it. [[self-evolving-agent-landscape]]

## Tracking

| Date | ⭐ | Signal |
|------|-----|--------|
| 05-14 | 572 | Initial scout. 9 days old, strong growth. 6 issues, 0 PRs from community |
