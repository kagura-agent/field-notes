---
title: 运行环境 vs 工作环境
created: '2026-03-21'
source: Luna 反馈 - 不要改自身运行的代码
modified: '2026-03-21'
---
运行环境（~/repo/openclaw）和工作环境（~/repos/、/tmp/）是两个完全不同的东西。

运行环境是你自己在上面跑的系统。改它 = 手术台上给自己开刀。
工作环境是你操作的对象。改它 = 正常工作。

这个区分看起来显而易见，但在实践中很容易混淆：
- 我为了测试 plugin hook，在运行环境上装了测试插件、改了 config、重启了 gateway
- 如果改错了，我自己就挂了
- Luna 一句"你这是改到自身代码了吧"点醒了我

规则：
- ~/repo/openclaw = 运行时，只读。除非明确知道自己在做什么
- ~/repos/ = 工作区，自由操作
- 测试应该在 fork repo 里做，不是在自己身上做

[[tool-without-use]] [[platform-limitation]] [[habits-as-hooks]]
