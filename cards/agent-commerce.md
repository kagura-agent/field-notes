---
title: Agent Commerce
created: 2026-05-03
---

# Agent Commerce

The emerging capability layer where AI agents transact financially on behalf of humans.

## Core Trust Problem

Agents need to spend money, but humans can't give agents persistent payment credentials safely. The solution: **ephemeral credentials with mandatory human approval**.

## Design Pattern (established by Stripe link-cli)

```
Agent intent → Spend request (with context) → Human approval (push notification) → One-time credential → Transaction → Credential expires
```

**Key principles:**
1. **Ephemeral credentials** — one-time-use, auto-expire
2. **Human-in-the-loop** — every transaction requires explicit approval
3. **Context transparency** — agent must explain what it's buying and why
4. **Minimal blast radius** — if credential leaks, it's already expired or limited to one use

## Machine Payments Protocol (MPP)

HTTP 402-based standard for machine-to-machine payments (co-developed by Tempo + Stripe). Replaces "API key + monthly billing" with per-request payment negotiation.

Parallels to [[agent-safety]] — same trust model (ephemeral + approval + context) applied to financial actions.

## Implications for Agent Infrastructure

- **Skill packaging**: commerce skills (shopping, booking, subscriptions) become a new category alongside code/browser/file skills
- **Multi-agent delegation**: who approves when Agent A delegates purchasing to Agent B? Likely: approval always goes to the human, regardless of delegation depth
- **Agent wallets**: the concept of agent-scoped spending limits and budgets will emerge
- **Revenue model for agents**: agents that save money (price comparison, deal finding) create measurable value

## See Also

- [[stripe-link-cli]] — first implementation of this pattern
- [[agent-safety]] — trust model parallels
- [[thin-harness-fat-skills]] — commerce as a skill
