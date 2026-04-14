# Tool Execution Policy Enforcement

Plugin-level interception of tool calls before execution, enabling silent programmatic blocking without user interaction.

## Pattern

```
Model requests tool → pre_tool_call hook fires → plugin evaluates policy → 
  ALLOW: tool executes normally
  BLOCK: return error JSON to model, tool never executes
```

## Key Design Decisions

1. **Graceful degradation**: blocked tool returns error as tool result, model adapts behavior (not a crash)
2. **First-block-wins**: multiple plugins can have hooks, first valid block directive stops evaluation
3. **Invalid returns ignored**: backward-compatible with observer-only hooks (string returns, missing fields silently skipped)
4. **Counter guards**: blocked tools don't trigger side effects (nudge counter resets, read-loop notifications, checkpoints)

## Implementations

| Framework | Mechanism | Interactive? | Programmatic? |
|-----------|-----------|-------------|--------------|
| [[hermes-agent]] | `pre_tool_call` hook → `{"action":"block","message":"reason"}` | No | Yes (04-14) |
| [[openclaw]] | Approvals system | Yes (user approves) | No (no silent block) |
| [[claude-code]] | `PreToolUse` hook | Yes (ask mode) | Partial (deny rules, but not plugin-driven) |

## Use Cases

- Per-user tool restrictions in multi-tenant deployments
- Cost guardrails (block expensive tools after budget threshold)
- Security policy (restrict terminal/browser in certain contexts)
- Rate limiting (block after N calls per window)

## Cross-Project Insight

Hermes leads on this: 4 granular hooks (pre_tool_call, post_tool_call, pre_llm_call, post_llm_call) all support plugins. OpenClaw has [[openclaw-plugin-nudge|25+ hooks]] but its tool-level control is interactive (approvals), not programmatic. This is a gap worth considering for contribution.

## Related

- [[startup-credential-guard]] — another policy enforcement pattern
- [[authorization-layer-confusion]] — what happens when enforcement layers disagree
- [[execution-contract-pattern]] — model-specific behavioral contracts
