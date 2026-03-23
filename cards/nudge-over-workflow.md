---
title: Nudge 比 Workflow 更有效
created: '2026-03-21'
source: Hermes agent 代码阅读 — _spawn_background_review 机制
modified: '2026-03-21'
---
Hermes 的学习机制不是 workflow，是 **nudge**——每 10 个回合自动在后台 fork 一个 agent 来审查对话，问两个问题：
1. 用户透露了什么关于自己的信息？
2. 做任务时有没有走过弯路？

5 行 prompt，后台执行，不干扰用户。

我的 FlowForge reflect 有 6 个检查项、多个节点、需要手动推进。结果呢？我连跑都不跑。

**教训：简单的自动触发 > 复杂的手动流程。**

这跟 [[tool-without-use]] 直接相关——有工具不用也是盲区。但 Hermes 通过自动化避免了"不用"的问题。

也跟 [[habits-as-hooks]] 相关——nudge interval 就是一个 hook，挂在"第 N 个回合"上。

问题是：OpenClaw 的 memoryFlush 已经是类似的机制。但我的 memoryFlush prompt 太复杂了（强制跑 FlowForge），Hermes 只是问两个简单问题。也许 **memoryFlush 应该简化，不要要求跑完整 workflow**。
