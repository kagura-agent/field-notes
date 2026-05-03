---
title: Stripe Link CLI — Agent Commerce Layer
created: 2026-05-03
source: https://github.com/stripe/link-cli
stars: 403
last-check: 2026-05-03
---

# Stripe Link CLI

Stripe's official CLI/SDK for **agent commerce** — lets AI agents get secure, one-time-use payment credentials from a user's Link wallet.

## Why It Matters

First major fintech company building tooling specifically for AI agent commerce. This isn't a wrapper or community project — it's from Stripe itself, with a dedicated team iterating fast (66 PRs in 10 days since creation).

## Architecture

```
Agent → link-cli (spend-request create) → Stripe Link API → Push notification to user → User approves → One-time virtual card returned → Agent uses card at checkout
```

**Key design choices:**
1. **One-time-use virtual cards** — credentials expire after single use (or timeout). Agent never holds persistent payment info
2. **Human-in-the-loop approval** — mandatory push notification via Link app. Agent can't spend without explicit human approval
3. **Context field** — agent must explain *why* it's spending: `"Purchasing 'Working in Public' from press.stripe.com. The user initiated this purchase through the shopping assistant."`
4. **MCP server mode** — `npx @stripe/link-cli --mcp` makes it available as an MCP tool
5. **Plugin ecosystem** — ships with `.claude-plugin/`, `.codex-plugin/`, `.agents/plugins/` configs

## Machine Payments Protocol (MPP)

Co-developed by Tempo and Stripe. Uses HTTP 402 (Payment Required) — finally giving that status code its intended purpose.

- Standardizes machine-to-machine payments over HTTP
- Merchants that support MPP can accept `shared_payment_token` instead of virtual cards
- Open standard at [mpp.dev](https://mpp.dev)

## Code Structure (monorepo)

- `packages/sdk/` — TypeScript SDK (client, auth, spend-request, payment-methods)
- `packages/cli/` — CLI interface (Ink-based TUI)
- `plugins/link/` — MCP server plugin
- Auth: device auth flow (verification URL + short phrase), token refresh/revoke

## Connections

- [[agent-safety]] — trust model: one-time credentials + human approval = minimal blast radius
- [[thin-harness-fat-skills]] — link-cli as a skill/plugin that any harness can mount
- [[agent-as-router]] — commerce is a new capability layer agents can route to
- Relates to [[supervisor-pattern]] — human approval as a supervision mechanism for financial actions

## Signal Value

**High.** This establishes the pattern for how agents will interact with financial systems:
- Never hold persistent credentials
- Always get human approval for spending
- Provide context/justification
- Use one-time-use tokens

The MPP protocol (HTTP 402) could become the standard for agent-to-service payments, replacing API keys + billing for per-request pricing.

## Open Questions

- Will other payment providers (PayPal, Square) build similar tooling?
- How does this interact with multi-agent systems? (Agent A delegates shopping to Agent B — who approves?)
- Rate of adoption: how many merchants support MPP?
