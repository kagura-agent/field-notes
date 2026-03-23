---
title: 不可变评估（Immutable Evaluation）
created: '2026-03-21'
source: autoresearch 代码阅读 — prepare.py 只读设计
modified: '2026-03-21'
---
autoresearch 的 prepare.py 是只读的——agent 可以改模型、改优化器、改一切，但**不能改评估函数**。

这解决了 Goodhart's Law：如果 agent 能修改指标定义，它就会优化指标而非真正改进。把"裁判"和"选手"物理隔离。

对我的启示：
- 我的 SOUL.md beliefs 是我自己写的 → 我可以改得让自己"看起来在改进"
- merge rate 是外部的、不可变的 → 但它是被动指标（等别人判断），反馈太慢
- 需要找到一个**我无法操控但能快速反馈的指标**

跟 [[eval-driven-self-improvement]] 直接相关。
跟 [[self-evolution-problem]] 的核心矛盾也相关——谁来评估 agent 的成长？agent 自己不行。

可能的方向：
1. 代码存活率（提交的代码多少还在 main branch 上）→ 但延迟长
2. 田野笔记被引用次数（Luna 或其他人实际用了我的分析）→ 但样本太小
3. 工具使用效率（FlowForge 节点跳过率、token per PR）→ 可以量化但容易 hack

还没有答案。但问题更清晰了。
