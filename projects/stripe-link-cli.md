---
title: Stripe Link CLI — Agent Commerce Layer
created: 2026-05-03
source: https://github.com/stripe/link-cli
stars: 403
last-check: 2026-05-06
last_verified: 2026-05-12
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

## Followup 2026-05-06

**Stars**: 403 → 457 (+54 in 3 days, accelerating)
**v0.4.3** released 05-05. Active: 4 PRs merged since 05-03.

### Notable Changes

1. **PR #67: Credential output to file** — agents can write payment credentials to a file instead of passing through context. Reduces context window pollution for long agent sessions. Small but practical UX improvement.
2. **PR #51: Auth config file mode 0o600** — Security hardening. `Storage` class now restricts OAuth token files to owner-only. Previously inherited `conf`'s default (0o644), exposing tokens to other local users.
3. **PR #68: Docs + skill improvements** — Totals schema type fix, copy improvements.
4. **v0.4.2** (05-02): Claude marketplace.json and plugin improvements.

**Assessment**: Credential-to-file output (PR #67) is the interesting signal — it shows they're thinking about agent context management, not just payment flow. The security fix (PR #51) is table-stakes but shows the project is maturing past MVP. Growth accelerating (+54 vs +20/day for agentic-stack) suggests strong developer interest in agent commerce.

*Followup check: 2026-05-06*

## Followup 2026-05-12

**Stars**: 457 → 495 (+38, steady growth)
**v0.5.0** released 05-11. Two security/reliability PRs worth studying:

### 1. ANSI Escape Injection Sanitization (PR #85)

**Problem**: Server-returned string fields (e.g. `merchant_name`, `line_items[].name`) can contain ANSI escape sequences or control characters that manipulate terminal output during the approval flow. An attacker could:
- Clear screen (`\x1b[2J`) and redraw fake approval UI
- Overwrite displayed amount with carriage return (`$1000\r$0.01`)
- Set window title via OSC sequences
- Inject hyperlinks to phishing sites

**Solution**: Single sanitization boundary at the resource factory level using JavaScript Proxy:

```
sanitizeResource<T>(resource: T): T → new Proxy(resource, { get: ... })
```

Every SDK resource is wrapped in `sanitizeResource()` at creation time. The Proxy intercepts all method calls, and if the return value is a Promise (all API calls are), pipes `sanitizeDeep()` over the resolved value. `sanitizeDeep()` recursively walks objects/arrays and strips ANSI sequences + control chars from all strings.

**Key design decisions**:
- **Proxy at factory boundary** > per-field sanitization — one choke point, zero caller burden
- **Preserves tabs and newlines** (legitimate formatting) while stripping everything else
- **Fast path**: `NEEDS_SANITIZE_RE` test avoids `stripAnsi()` call on clean strings
- **Defense in depth**: combines `strip-ansi` (handles CSI/OSC/etc.) with manual control char regex

**Relevance to [[agent-safety]]**: This is the first production agent CLI implementing terminal injection protection. The pattern (Proxy-based sanitization at the data boundary) is applicable to any agent that displays server-controlled text in a terminal. Our OpenClaw CLI should consider similar protection — any MCP server response or tool output could contain escape sequences.

### 2. Approval Polling Bug Fixes (PR #95)

**Problem**: CLI only recognized `approved` and `denied` as terminal states. Other terminal states (`expired`, `succeeded`, `failed`, `canceled`) caused continued polling until timeout, then displayed misleading "Timed out waiting for approval" error — or worse, displayed a **false "✓ Approved"** for denied requests.

**Root cause**: `pollUntilApproved` resolved on ANY non-pending status, but call sites treated resolution as success without checking which status.

**Fix**: Shared `TERMINAL_STATUSES` set + explicit `status === 'approved'` checks. Also bumped default polling timeout from 300s to 600s to outlive server-side 8-minute expiry.

**Pattern**: State machine terminal status sets should be exhaustive and shared as constants, not inlined at each call site. This is a common bug class in polling-based approval flows — [[stripe-link-cli]] is the first to fix it publicly.

**Assessment**: v0.5.0 shows the project maturing from MVP to production-grade. The sanitization pattern is the most architecturally interesting — it solves a real attack vector that most agent CLIs haven't considered yet. Growth steady but not explosive.

*Revisit: 05-18*
