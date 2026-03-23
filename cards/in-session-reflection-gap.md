---
title: 主 Session 内反思缺口
created: '2026-03-21'
source: 'Luna 和我的讨论 2026-03-21 08:03'
modified: '2026-03-21'
---

发现一个技术缺口：

- Heartbeat 在主 session 活跃时被推迟（requests-in-flight）
- Cron 不被推迟，但跑在隔离 session 里，看不到当前对话上下文
- 结果：长对话中没有任何机制触发反思

需要的是：在主 session 内、对话进行中也能触发的习惯检查。

目前的解法只能靠 [[belief]]（SOUL.md 里的信念）驱动我自己在对话中主动停下来检查。但这还没有被验证过。

关联：[[habits-as-hooks]]、[[pain-perception]]、[[self-evolution-problem]]
