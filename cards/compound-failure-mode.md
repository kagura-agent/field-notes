# Compound Failure Mode

Multiple small, individually-defensible changes that overlap in time and scope, creating emergent degradation that no single test catches.

## Pattern
- Each change affects a different slice (users, features, traffic)
- Each change ships on a different schedule
- Each passes its own tests
- The aggregate effect looks like "broad, inconsistent" quality loss
- Traditional A/B testing (one variable at a time) can't detect it
- User feedback is often the only reliable signal

## Key Example
[[claude-code-postmortem-apr2026]]: Three Claude Code changes (effort downgrade, thinking cache bug, verbosity prompt) on different schedules created perceived "model degradation" that Anthropic couldn't initially distinguish from normal variation.

## Detection
- Monitor aggregate quality metrics, not just per-change metrics
- User feedback channels are essential — `/feedback` in Claude Code was the signal
- Back-testing with newer/smarter models can find bugs that original review missed

## Related
- [[cron-runaway-safety]] — compound failures in cron systems
- [[agent-safety]] — quality monitoring for agent systems
- [[execution-contract-pattern]] — explicit contracts prevent implicit state corruption
