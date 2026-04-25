---
title: Test-Time Compute
type: card
created: 2026-04-25
status: stub
---

# Test-Time Compute

推理时分配更多计算资源来提升输出质量的范式。

## 核心思想

与其训练更大的模型，不如在推理时让模型"想更久"。包括：
- Chain-of-thought / extended thinking
- Search / verification loops
- Self-consistency sampling

## 与 Agent 的关系

Agent 的 [[dreaming]] 和反思循环本质上也是 test-time compute 的一种形式——用额外的推理时间来提升决策质量。

## 相关

- [[reasoning]]
- [[dreaming]]
- [[recurrent-depth]]
