---
title: Mechanical Verification
created: '2026-03-21'
source: karpathy/autoresearch program.md
modified: '2026-03-20'
---

指标必须是机器可以判定的数字。不接受"看起来不错"。

这是 [[eval-driven-self-improvement]] 整个范式的地基。没有硬指标，循环就无法自动化。

例子：
- val_bpb（LLM 训练）— 天然硬指标
- 测试通过率 — 半硬，通过不等于好
- 用户满意度 — 软指标，没法自动化

核心问题：真正重要的东西（"agent 是否变聪明了"）往往没有硬指标。怎么办？
