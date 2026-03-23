---
title: Deploy Without Verify
created: '2026-03-22'
source: memory/2026-03-22.md
modified: '2026-03-22'
---
配了新东西但不验证它是否真的在工作。

## 模式
- 改了配置 → 以为完成了 → 从不检查产出是否送达
- 3/21: heartbeat target: none → 反思结果被吞掉
- 3/22: cron jobs main mode → 产出混在对话里或被 HEARTBEAT_OK 吞掉

## 根因
完成感来自"我改了配置"而不是"产出被送达了"。缺少 verify 步骤。

## 对策
任何基础设施变更后，设一个 checkpoint：
1. 配完 → 记录在 MEMORY.md
2. 第一次运行后 → 检查日志确认产出送达
3. 没送达 → 当 bug 修

[[tool-without-use]]
[[eval-driven-self-improvement]]
