# Authorization Layer Confusion

> When a multi-layer permission system misinterprets one layer's "legitimate default" as another layer's "explicit grant," creating privilege escalation.

## Pattern

A common vulnerability in layered authorization:

1. **Layer A** returns a default "authorized" when no constraints are configured (e.g., empty approver list → anyone can approve from same chat)
2. **Layer B** treats any `authorized: true` from Layer A as an explicit grant, bypassing its own access checks (e.g., skipping `isAuthorizedSender`)
3. **Result**: An unconfigured state silently escalates to maximum privilege

## Key Insight

The bug isn't in either layer individually — it's in the **semantic gap** between them. Layer A's "no one configured, fall back to default" and Layer B's "someone explicitly said yes" are different authorization levels that got conflated into the same boolean.

## Solutions

| Approach | Example |
|----------|---------|
| **Taint marker** | Non-enumerable Symbol property distinguishes implicit vs explicit auth (OpenClaw #65714) |
| **Tri-state return** | `{ authorized: true, source: 'explicit' \| 'implicit' \| 'default' }` |
| **Deny by default** | Empty list = deny, not permit (strictest but breaks "single user with no config" UX) |
| **Separate paths** | Explicit approvers path vs same-chat fallback path never share return type |

## Implementation: OpenClaw #65714

```
// Before: empty approvers → { authorized: true } → treated as explicit
// After:  empty approvers → { authorized: true } + [Symbol marker] → treated as implicit
```

The Symbol marker (`IMPLICIT_SAME_CHAT_APPROVAL_AUTHORIZATION`) is:
- Non-enumerable → invisible to JSON serialization
- Reference-dependent → cloning/spreading drops it (fail-closed)
- Checked via `isImplicitSameChatApprovalAuthorization()` in Layer B

## Related Patterns

- [[startup-credential-guard]] — another multi-layer auth issue (weak credentials passing validation)
- [[agent-credential-security]] — broader credential isolation problem
- [[write-ahead-session-persistence]] — metadata flags as state markers (same technique, different domain)

## Applies When

- Multi-layer permission systems (plugin SDK + channel auth + gateway)
- Default-permissive for UX (single-user setup with zero config)
- Boolean authorized/unauthorized flattening (loses "why" information)

## Source

- OpenClaw PR #65714 (2026-04-13), `pgondhi987` [AI-assisted]
- Deep read during study workflow #173
