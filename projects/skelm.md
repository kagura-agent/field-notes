---
title: "skelm — Secure Agentic Workflow Framework"
created: 2026-05-10
updated: 2026-05-10
status: tracking
stars: 17
url: https://github.com/scottgl9/skelm
---

# skelm — Secure Agentic Workflow Framework

TypeScript-first framework for authoring, running, and operating agentic workflows with **default-deny security** as the top design tenet.

## Why It Matters

skelm is the first open-source project I've seen that treats agent security as the **primary architectural constraint** rather than an afterthought. Security > Maintainability > Robustness — in that explicit order.

## Core Architecture

### Three Step Kinds
- `code()` — deterministic TypeScript logic
- `llm()` — single inference calls
- `agent()` — full multi-turn agent loops (Claude Code, Opencode, ACP, Pi)

All composed in typed `pipeline()` with native control flow (`parallel`, `forEach`, `branch`, `loop`, `wait`).

### Default-Deny Permission Model

Every `agent()` step declares what it's allowed to do. **Omission = deny.**

8 permission dimensions:
- `tool` — which tool IDs can be called
- `executable` — which binaries can be exec'd
- `mcp` — which MCP servers can attach
- `skill` — which skills can load
- `secret` — which secrets are accessible
- `network` — host-level egress control
- `fs.read` / `fs.write` — filesystem root restrictions

Resolution: `project defaults ∩ profile ∩ step-level`. **Intersection only — nothing widens.** A step can never get more permissions than the project default grants.

`TrustEnforcer` class does O(1) lookups with `canCallTool()`, `canExec()`, `canFetch()`, `canRead()`, `canWrite()` — each returns structured `EnforceDecision` with denial reason.

### Embedded CONNECT Proxy (Novel)

The gateway runs a real TCP CONNECT proxy (default port 14739) that enforces network egress:

1. Agent steps get a per-step egress token encoded in `HTTP_PROXY`/`HTTPS_PROXY`
2. Token → policy lookup in the proxy's token store
3. Every connection (CONNECT for HTTPS, direct for HTTP) checked against the step's `networkEgress` policy
4. Denied connections get `403 Forbidden` before any bytes leave the machine
5. Full audit trail with source IP, token identification, cumulative unknown-token counters

This is **real network-level enforcement**, not just a `fetch` wrapper. Even if an agent shell-escapes to curl, the proxy blocks undeclared hosts. Compare to OpenClaw's trust model which relies on the agent respecting policy — skelm enforces at the network layer.

### Audit Chain

Hash-chained append-only audit log. Tool executions, permission denials, network egress decisions all recorded. The `AuditWriter` is intentionally singular — "never add a second audit-log writer" is an explicit never-do.

## Critical Bugs Found (via Issues)

Issues #58 and #59 revealed that the **Pi backend bypassed both tool enforcement AND network egress enforcement**. Root cause: backends that don't implement the enforcement hooks silently skip security checks. Fix: backends must fail at step start if they can't enforce a declared permission.

**Insight**: Default-deny is only as strong as its weakest backend. The core `TrustEnforcer` is solid, but each backend integration is a potential bypass vector. This is the same pattern as [[mirage]]'s prompt isolation issues — security models that work in the framework but get circumvented by specific integrations.

## Interesting Patterns

1. **AGENTS.md/SOUL.md/SKILL.md convention** — skelm uses the same file-based agent definition pattern. Clear inspiration from the Claude Code / OpenClaw ecosystem. Shows convergence on this pattern as a standard.

2. **`pnpm check` = single gate** — build → typecheck → lint → unit → guards → adversarial → contract → doc-links. Everything passes or nothing merges. Adversarial security fixtures are mandatory, not opt-in.

3. **Self-review pipeline** — `branch-review.pipeline.ts` runs an agent-driven review before PR. Dogfood-driven development using the framework's own capabilities.

4. **Gateway as trust boundary** — "Never mock the gateway in security-related tests." Tests run against real gateway code path. This is the right instinct but hard to maintain as the project grows.

## Relationship to Our Direction

- **Skill ecosystem**: skelm has a `skill-registry` and `skill-source` in the gateway, with permission-gated skill loading. Skills are runtime-loaded and subject to the same default-deny model. Relevant to [[skill-trust-landscape-2026-04]].

- **Agent orchestration**: The three-step-kind model (code/llm/agent) is a clean separation. Our FlowForge is yaml-driven orchestration; skelm is TypeScript-native. Different trade-offs (FlowForge: accessible to non-coders; skelm: type-safe, IDE-friendly).

- **Security posture**: OpenClaw's approval/permission model is runtime-interactive (ask the user). skelm's is declarative (declare upfront, enforce automatically). Both valid; skelm's is more enterprise-friendly but less flexible.

## Verdict

**Worth watching** but too early (17⭐, pre-v1, solo maintainer). The security architecture is genuinely thoughtful — the embedded CONNECT proxy and intersection-only permission resolution are ideas worth stealing. The critical backend bypass bugs (#58/#59) show the implementation still has gaps.

Revisit 05-24 — check if community forms or if it stays solo.

## Links

- [[self-evolving-agent-landscape]] — infrastructure layer
- [[skill-trust-landscape-2026-04]] — permission model comparison
- [[thin-harness-fat-skills]] — architectural pattern contrast
