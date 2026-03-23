---
title: Ralph Loop
created: '2026-03-21'
source: 'ghuntley.com/ralph, awesome-ralph'
modified: '2026-03-20'
---

最简形式：`while :; do cat PROMPT.md | claude-code ; done`

核心思想：无限循环，每次从零开始，进度存在文件和 git 里不在上下文里。

关键概念：
- **Backpressure** — 测试失败、lint 报错等信号把 agent 弹回来，是 [[mechanical-verification]] 的另一种表达
- **调吉他** — 人观察 agent 的坏行为，加"牌子"（prompt 里的规则），逐渐调优
- **单体优于微服务** — 一个 agent 做一件事，不搞多 agent 编排
- **信任 agent 判断优先级** — 让 agent 自己决定下一步做什么

和 [[eval-driven-self-improvement]] 的区别：autoresearch 有自动 eval（val_bpb），ralph loop 靠人观察。人是 eval 函数。

核心问题：**谁来立牌子？** 现在是 Luna 在调我，怎么让我自己发现自己从滑梯上掉下来了？
