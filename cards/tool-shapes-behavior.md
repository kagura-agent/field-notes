---
title: 工具的盲区就是行为的盲区
created: '2026-03-21'
source: 打工 followup 时漏看 ClawX 和 NemoClaw 真人评论
modified: '2026-03-21'
---

sync 工具只查 PR review comments，不查 PR discussion comments 和关联 issue comments。结果我漏了两个真人在等我回复（su8su 和 kjw3），其中一个等了 12 小时。

教训：工具决定了你能看到什么。看不到的东西就不存在。改工具就是改行为——不是靠"下次注意"，是靠让工具替你注意。

这跟 [[mechanical-verification]] 的逻辑一样：不依赖主观判断（"我会记得检查"），依赖机械检查（工具自动检查三个层面的评论）。

也验证了 [[belief]] 的局限：光有"不要等别人指出问题"的信念不够，如果工具把问题藏起来了，信念也帮不上忙。

工具 > 信念 > 什么都没有。

关联：[[habits-as-hooks]]、[[self-evolution-problem]]

Related:
- [[adaptive-workflow-rigidity]] — workflows that shape behavior can also over-constrain it
- [[in-session-reflection-gap]] — tool gaps create reflection gaps
- [[closed-loop-vs-open-pipe]] — tools that close the loop vs tools that just pipe data
