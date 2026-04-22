# Cron Timeout Sizing

- **pattern**: cron-timeout-sizing
- **graduated_from**: beliefs-candidates.md (3 occurrences, 2026-04-20)
- **applies_when**: 创建或修改 cron job 时设置 timeout

## Rule

创建涉及 **web_fetch + 写长文档** 的 cron job 时，timeout 直接给足（**≥900s**），不要从 300s 逐步试错。

低估 timeout 浪费的是 Luna 的注意力，不只是 cron 的时间。

## Timeout 参考

| 类型 | 建议 timeout |
|------|-------------|
| 简单通知/检查 | 120s |
| 单次 web_fetch + 短消息 | 300s |
| 多次 web_fetch + 文档生成 | 900s |
| 复杂研究/爬取 + 长报告 | 1200s+ |

## 反模式

- ❌ 默认 300s → 超时 → 改 600s → 再超时 → 改 900s（Luna 被打扰 3 次）
- ✅ 一次给足 900s，宁可提前完成也不反复超时
