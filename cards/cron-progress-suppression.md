# Cron Progress Suppression

> 定时任务只需最终结果，中间思考消息应被过滤

## 问题
Agent 处理 cron 任务时，中间 progress 消息（"Checking...", "Connecting..."）泄漏到用户 channel，导致：
- 定时任务非常吵（用户不在看的时候收到一堆消息）
- 夜间/白天突然弹出一串通知
- 跟 heartbeat 的噪声问题同源

## 模式
```
process(message, on_progress=no_op)  # 传空回调阻断 progress
```

关键在于 process 函数需要支持 `on_progress` 注入：
- 交互式场景：默认回调（发到 bus → channel）
- cron/heartbeat 场景：no-op 回调（丢弃中间消息）
- 日志/调试场景：可注入 file writer 回调

## 实例
- nanobot PR #3065 — 4 行 fix + 100 行测试
- nanobot heartbeat handler 已有此模式（cron 漏掉了）
- OpenClaw cron 天然隔离（cron 写 memory，不直接发 channel）
- Workshop cron scheduler 可能需要此模式（如果直接发消息到 channel）

## 关联
- [[nanobot]] — 实现来源
- [[memory-consolidation-as-skill-entry]] — Dream 同一系统的另一个方面
- [[skill-trigger-eval]] — 同为 agent 基础设施质量问题
