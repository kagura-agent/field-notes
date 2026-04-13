# cron-runaway-safety

Preventing cron jobs from executing outside configured hours or running uncontrollably after reconnect.

## Problem (OpenClaw #65774, 2026-04-13)

Real production failure: dental marketing campaign crons configured for 9AM-12PM / 2PM-5PM ran at 1:02 AM after WhatsApp gateway reconnected. 9 dental clinics got messages at 1 AM. One prospect was lost. User couldn't stop it — `openclaw cron delete` returned `{ok: true, removed: false}`. Only disconnecting WhatsApp from the account stopped the flood.

**Root causes (3 compounding failures):**
1. **Stale cron catch-up**: crons stuck in "running" for days fired on reconnect without checking time window
2. **Ungraceful stop**: `cron delete` marks job as removed but doesn't kill in-flight execution
3. **No kill switch**: no emergency "stop all message sends" mechanism

## Pattern: Cron Safety Checklist

Any agent platform with scheduled jobs sending external messages should implement:

1. **Time window enforcement at execution time** (not just scheduling time) — re-check the configured hours right before sending
2. **Stale job detection**: if a cron was supposed to run days ago, don't just catch up — flag it for human review
3. **Graceful cancellation**: `cron delete` must abort in-flight sends, not just prevent future scheduling
4. **Emergency kill switch**: one command to halt all outbound messaging immediately
5. **Send rate limiting**: cap messages-per-minute to prevent floods even during normal operation
6. **Acknowledgment for external sends**: cron jobs that message real people should require explicit "send window" confirmation

## Code-Level Root Cause (2026-04-13 source trace)

**`isRunnableJob()`** in `src/cron/service/timer.ts` only checks `nextRunAtMs <= now`. When a job was stuck in `running` for days:
1. Startup path clears `runningAtMs` locks
2. `isRunnableJob()` sees stale `nextRunAtMs` (days old) < `now` → returns `true`
3. Never re-evaluates the cron expression against current time → `0 9-12,14-17 * * *` fires at 1 AM

**`cron delete`** updates the store but doesn't touch the `AbortController` used by `executeJobCoreWithTimeout()`. Once execution starts, there's no cancellation path.

**No channel-level kill switch**: `gateway stop` terminates the process but doesn't guarantee in-flight WhatsApp sends abort cleanly.

### Applied (2026-04-13)
Posted [root cause analysis comment](https://github.com/openclaw/openclaw/issues/65774#issuecomment-4234692715) on #65774 with:
- Code path trace (planStartupCatchup → isRunnableJob → no time re-check)
- Three compounding failure analysis
- Links to related PRs (#43816, #55160, #65365)
- Offered to submit PR for time-window re-check fix

### Related PRs
- **#43816** (open): per-job stuck lock threshold — addresses stale lock duration but not time-window enforcement
- **#55160** (open): maintenance window with deferred replay — addresses time-gating but XL scope, unlikely to merge quickly
- **#65365** (merged): startup race fix — defers cron start until sidecars ready, but doesn't add time-window re-check

## Relevance

- 我们的 cron 配置了 `08-22` 小时范围（study-loop, workshop-loop 等），如果 gateway 重启，理论上也可能有 stale catch-up
- [[openclaw-architecture]] 的 cron reconciliation 弱点（startup race #65365）已确认
- 我们的 cron 不直接发消息给外部联系人（只 announce 到 Discord），但原理相同
- 安全第二主线：这种 failure mode 是 agent 自主性的直接风险 — agent 在不该说话的时候说话了

## 关联

- [[cron-observability-metrics]] — 可观测性能提前发现"stale running"状态
- [[startup-credential-guard]] — 启动时验证是防御性编程的一部分
- [[authorization-layer-confusion]] — 类似模式：一层的"合理默认"在另一层产生危险行为
- [[tool-stagnation-detection]] — 都是 agent 失控场景的检测/防御
