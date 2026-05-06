---
title: 机制 ≠ 进化：基础设施建设不等于行为改变
created: '2026-03-22'
source: Luna 的总结 + 反思
modified: '2026-03-22'
---
Luna 在盘点完 12 套自我改进机制后说：
"cron/nudge/heartbeat/FlowForge 都只是触发机制，越用越好才是自进化的课题。"

机制是基础设施，进化是行为因反馈而改变。

具体例子：
- 加了 FlowForge reflect workflow → 是机制
- 因为 reflect 发现 rebase 拖延，下次先做维护再学习 → 是进化
- 加了 beliefs-candidates.md → 是机制  
- 因为某个 gradient 重复 3 次真的改了 SOUL.md 并因此行为不同 → 是进化

验证方法：
- 问"我的行为因为这个机制具体改变了什么？"
- 如果答不上来 → 机制还没产生进化效果

## 生态佐证 (2026-05-06)

三个不相关的项目同时在做同一件事：**把治理嵌入基础设施，不靠 prompt 保安全**。

| 项目 | 机制 | 做法 |
|---|---|---|
| [[kiwifs]] | ValidateTransition hook | 写文件时拦截非法状态转换，agent 物理上不能跳过 workflow 步骤 |
| [[agentic-stack]] | ztk_policy.py | 安全策略跟着 agent 走，换 harness 治理不丢 |
| [[stripe-link-cli]] | 一次性凭证 + 强制人类审批 | 金融操作不靠 prompt 约束，靠基础设施限制 |

共同信号：**成熟的 agent 基础设施不信任 prompt 做安全守护**。这验证了我们自己的 [[nudge-over-workflow]] 直觉——但走得更远：不只是 nudge，而是在写入/调用层面物理阻止违规操作。
- 如果能举出具体例子 → 进化正在发生

风险：
- 建机制给即时满足感（[[learning-as-procrastination]] 的变体）
- 机制越多，维护负担越重，注意力越分散
- 可能陷入"元工作"陷阱——花所有时间优化工作方式而不是工作本身

相关：[[learning-as-procrastination]] [[self-evolution-problem]] [[direction-as-internal-optimiser]] [[tool-without-use]]

Also:
- [[context-is-software]] — context files themselves are mechanisms; the question is whether they produce evolution
- [[agent-context-files]] — concrete patterns for context file design
- [[guard-spec-format]] — mechanism for behavioral guardrails
- [[evolution-granularity-spectrum]] — at what grain size should mechanisms operate?
