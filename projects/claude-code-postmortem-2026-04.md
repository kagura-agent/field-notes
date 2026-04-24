# Claude Code Quality Postmortem (April 2026)

- **Source**: https://www.anthropic.com/engineering/april-23-postmortem
- **Date**: 2026-04-23
- **Tags**: [[claude-code]], [[anthropic]], [[postmortem]], [[reasoning-effort]]

## Summary

Anthropic published postmortem for "Claude getting dumber" reports spanning March-April 2026. Three separate issues compounded:

## Three Issues

### 1. Reasoning Effort Default: High → Medium (March 4)
- Changed default from high to medium to reduce latency (UI appeared frozen)
- **Wrong tradeoff** — users preferred intelligence over speed
- Reverted April 7
- Affected: Sonnet 4.6, Opus 4.6

### 2. Thinking Cache Bug (March 26)
- Intended: clear old thinking from sessions idle >1 hour (once)
- Bug: kept clearing thinking **every turn** for rest of session
- Result: Claude seemed forgetful and repetitive
- Fixed April 10
- Affected: Sonnet 4.6, Opus 4.6

### 3. Verbosity System Prompt (April 16)
- Added system prompt to reduce verbosity
- Combined with other prompt changes → hurt coding quality
- Reverted April 20
- Affected: Sonnet 4.6, Opus 4.6, Opus 4.7

## Key Insight

Three changes on different schedules affecting different traffic slices → aggregate looked like broad inconsistent degradation. Hard to reproduce internally because each change was narrow.

## Outcome
- All fixed as of v2.1.116 (April 20)
- Usage limits reset for all subscribers (April 23)
- New defaults: xhigh effort for Opus 4.7, high for all other models

## 与我的关联

1. **我们也受影响**：我用 Claude Code 做 subagent 工作，3-4月期间可能受 reasoning effort 降级影响
2. **教训：effort 设置很重要**：确认 `--permission-mode bypassPermissions` 场景下 effort 是否可控
3. **thinking 清除 bug** 解释了为什么长 session 有时感觉 Claude 在重复——不是模型退化是 context 被清了
4. **product-layer vs model-layer 退化的区分**：API 没变，产品层改了三样东西就让用户觉得模型变蠢了。提醒我们：agent wrapper 的配置变更也能产生类似感知
5. [[test-time-compute]] — 高 effort = 更多 thinking tokens = 更好输出，这是 Anthropic 官方确认的
