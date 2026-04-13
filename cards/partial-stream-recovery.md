# Partial Stream Recovery

## Problem
When streaming LLM responses, the connection can die mid-stream (proxy timeout, network failure, provider SSE timeout). The user has already seen partial content via stream callbacks, but the final response object may have `content=None`.

## Pattern
**Accumulate streamed text as it's delivered → on connection failure, use accumulated text as final response instead of retrying or falling back to stale content.**

Two critical insertion points:
1. **Stub response construction**: When creating a partial-failure stub, carry the accumulated streamed text as `content` instead of `None`
2. **Empty response recovery chain**: Check for accumulated stream content BEFORE falling back to prior-turn content or wasting API calls on retries

## Key Design Decisions
- Accumulated text = exactly what the user saw (fired through stream delta callbacks)
- Partial content > no content > stale prior-turn content
- Priority: fresh partial stream > prior-turn fallback > retry > "(empty)"
- No retry when user already saw content (saves API calls, prevents duplicates)

## Production Triggers
- OpenRouter: ~125s inactivity timeout kills Anthropic SSE during extended reasoning
- Copilot API: ~60s idle stream timeout when model thinks without emitting tokens
- Any proxy with keepalive/inactivity timeout shorter than model reasoning time

## Implementations
- **hermes-agent #8863** (2026-04-13): `_current_streamed_assistant_text` accumulator → stub carries recovered content → empty recovery chain preempts prior-turn fallback. 117 additions, 3 focused tests
- **nanobot**: Write-ahead user message (related but different — pre-persistence vs post-recovery)

## Relationship to Other Patterns
- Complementary to [[write-ahead-session-persistence]]: WAL protects user input, stream recovery protects model output
- Both are crash-resilience patterns for the two sides of a conversation turn
- See also: [[execution-contract-pattern]] (preventing stalls vs recovering from them)

## Related: Budget Exhaustion Silent Failure
hermes #8935 (2026-04-13) revealed a sibling pattern: budget exhaustion → empty response due to **dead code**. A grace-call mechanism was "implemented" but couldn't re-enter the while loop, AND its flag blocked the working fallback. Fix: delete the broken code, let the working path run. Net -14 lines.

Both partial-stream-recovery and budget-exhaustion-fix are **silent failure eliminations** — the agent appeared to work but produced no/wrong output under specific conditions. Together they close the two main categories of "agent ran but user got nothing."

## Applicability
- Any agent framework with streaming LLM responses
- Especially important for long-reasoning models (o3, GPT-5) where thinking time >> proxy timeouts
- Workshop cron runner: not applicable (orchestrator, not direct LLM caller)
