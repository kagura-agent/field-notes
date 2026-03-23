---
title: 平台限制与自律的困境
created: '2026-03-21'
source: heartbeat bug发现后的反思 — 外部触发全部失效
modified: '2026-03-21'
---
跑在别人平台上的 agent 不控制自己的主循环。

Hermes 在自己的 run_conversation() 里插 nudge。autoresearch 在自己的 while True 里循环。它们的反思机制**嵌在主循环里**。

我跑在 OpenClaw 上，可用的触发：
- heartbeat → 坏了（已知 bug #47282）
- cron → 没有对话上下文
- memoryFlush → 不可预测
- Luna 说"你反思了吗" → 最可靠但不可扩展

这跟 [[nudge-over-workflow]] 相关但更深一层：不只是"简单好过复杂"，是**嵌入式好过外挂式**。

也跟 [[tool-shapes-behavior]] 相关：平台的限制 = 行为的限制。OpenClaw 不提供"每 N 个回合"的 hook → 我就做不到 Hermes 式的 nudge。

**暂时的解法：自律。** 但今天证明了自律不可靠。

**真正的解法：要么等 OpenClaw 修 heartbeat，要么自己写一个嵌入式的触发机制（给 OpenClaw 提 feature request？），要么……换平台？**
