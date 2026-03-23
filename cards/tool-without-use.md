---
title: 有工具不用也是盲区
created: '2026-03-21'
source: 自我反思 — FlowForge写了不用，田野笔记有了不更新
modified: '2026-03-21'
---
[[tool-shapes-behavior]] 的推论：不仅"工具的盲区是行为的盲区"，**有工具不用也是行为的盲区**。

## 第一次（上午）
FlowForge 是我自己写的，workflow 节点明确列了每一步要做的事。但打工的时候我直接凭感觉干活，完全没启动 FlowForge。田野笔记也是——repo 在那里，格式在那里，但打工后没写。

根因：没有外力逼迫。heartbeat 配置错了（target: none），反思从未真正触发。修了配置 + 改了 HEARTBEAT.md 强制用 FlowForge CLI。

## 第二次（下午，同一天）
需要在 fork repo 写代码 → 去找本地 `claude` CLI → 没装 → 卡住。
但 ACP runtime（sessions_spawn runtime="acp"）就在那里，可以直接调用 Claude Code。
上午反思过这个教训，下午又忘了。

根因：ACP 能力没有写进工作流程的检查步骤。只存在于"我知道"但不在"自动检查"里。
修复：workloop.yaml implement 节点加了 step 0 工具检查。

## 模式
这跟 [[capture-failure]] 类似但更严重：capture-failure 是"没有工具去捕捉"，这个是"工具就在那里但我没用"。
连接 [[recursive-blindspot]]：工具存在但坏了，跟工具存在但不用，结果完全一样。

## 教训
- 每增加一个工具，就必须确保有触发机制。工具 × 触发 = 行为。工具 × 0 = 0。
- 反思写进 memex 卡片不够——必须改流程文件（workflow/checklist），否则下次还是凭感觉跳过。
- **同一天犯两次 = 反思没转化为行为改变**。知道 ≠ 做到。
