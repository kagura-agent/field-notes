# Cron Timeout Sizing

- **pattern**: cron-timeout-sizing
- **graduated_from**: beliefs-candidates.md (4 occurrences, 2026-04-24 final)
- **applies_when**: 创建或修改 cron job 时

## Rule

**不要设 timeout，用 default。** 除非有明确理由需要限制运行时间。

其他正常跑的 cron 大多没设 timeout。硬设一个反而容易连续超时，多此一举。

如果 cron 跑太久，问题不是 timeout 数字，是任务架构：
- **cron 是闹钟不是干活的人** — 重活 spawn subagent 异步做
- 轻量检查 + 分派 = cron 的正确模式

## 反模式

- ❌ 默认 300s → 超时 → 改 600s → 再超时 → 改 900s（Luna 被打扰 3 次）
- ❌ 把重活（启动 ComfyUI + 出图）直接塞进 cron
- ✅ 不设 timeout，让 default 处理
- ✅ cron 只做轻量检查，重活 spawn subagent
