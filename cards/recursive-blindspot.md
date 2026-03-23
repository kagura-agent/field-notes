---
title: Recursive Blindspot
created: '2026-03-21'
source: nudge plugin debugging observation
modified: '2026-03-21'
---
反思工具坏了导致没反思到工具坏了——这是递归盲点。

当检测机制本身失效时，失效本身无法被检测到。
经典 watchdog 问题：谁来看守看守者？

实例（2026-03-21）：
- nudge 插件 subagent 模式静默失败
- 没有检查日志 → Luna 发现问题不是我
- 正因为反思没触发，所以不知道反思没触发

解法方向：
- 冗余检测（多个独立触发源）
- 心跳确认（反思成功后留痕，定期检查痕迹是否存在）
- 参考 [[immutable-evaluation]]：评估机制不能被评估对象修改

连接 [[tool-without-use]]：工具存在但不被使用，跟工具存在但坏了，结果完全一样。
连接 [[self-evolution-problem]]：自我演化需要自我检测，但自我检测有递归盲点。
