# Cron Design Principles

**Graduated from**: beliefs-candidates.md (5 entries merged, patterns: cron-quality, cron-frequency-sense, cron-config-checklist, cron-architecture, output formatting)
**Date**: 2026-05-03

## Architecture
- **Cron = alarm clock, not worker**: Cron jobs should be lightweight checks + dispatch (spawn subagent). Heavy work goes async.
- **Don't set custom timeout**: Use default. Manually set timeouts (300s, 1800s) caused 3 consecutive failures. Other healthy crons don't set them.
- See also: [[cron-timeout-sizing]] for detailed history.

## Quality
- **Message structure**: Follow mature crons (daily-audit/morning-briefing). Include: Context + Steps + 纪律 + 环境. Don't write 3-line drafts.
- **Frequency matches project rhythm**: Research projects = 1-2x/day. Don't copy hourly templates by default.
- **Config checklist**: Always include `--account kagura`. Compare delivery field against working crons.

## Output
- **Human-readable**: Output for Luna must read like a briefing, not a debug log. Use grouping + emoji + concise bullets.
- **PR生命周期**: merged ≠ done. Post-merge comments are common. Cron must check comments on merged PRs too.

## Evidence
- avatar-biz cron: OOM from putting ComfyUI generation inside cron
- agent-tamagotchi: 3 big issues → 8 small ones after cron timeout
- cron-timeout-sizing: 4 iterations before settling on "don't set it"
