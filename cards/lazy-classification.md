---
title: Lazy Classification
created: '2026-03-21'
source: session reflection — bot review dismissal + tool-without-use pattern
modified: '2026-03-21'
---
把资源/信号简单二分为"有用/没用"，跳过实际检查。

表现：
- bot review → "不用管" → 实际可能有 actionable feedback
- ACP runtime → "不知道怎么用" → 实际是可用工具
- heartbeat → "配置好了就行" → 实际没有触发

根因：分类是一次性的判断，但情况会变。上次 bot review 没价值不等于这次也没价值。

修复：每次都检查，不靠历史分类。checklist > memory。

关联 [[tool-without-use]] [[knowledge-action-gap]] [[capture-failure]]
