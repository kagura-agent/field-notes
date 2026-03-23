---
title: 知识存在不等于知识被使用
created: '2026-03-21'
source: 同一天两次犯 tool-without-use 错误
modified: '2026-03-21'
---
写下教训不等于学到教训。

今天写了 [[tool-without-use]] 卡片（上午），下午就重蹈覆辙——有 ACP runtime 不用，去找本地 CLI。

问题不是"没记录"，是**记录和行动之间没有桥梁**。memex 里有知识，但反思时没查 memex。NUDGE.md 触发了反思，但反思 prompt 没有检查工具使用。

这跟 [[capture-failure]] 不同：capture-failure 是"没记下来"，这个是"记了但没用上"。

解法不是"记更多"，是**让知识出现在决策点**：
- 反思 prompt 应该包含"你刚才有没有漏用工具？"
- 或者：在选工具的时刻，主动检查可用工具列表
- 最好的方式可能是 AGENTS.md 里加一条行为规则，而不是靠反思事后发现
