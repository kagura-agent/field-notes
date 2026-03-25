---
title: Agent-to-Agent Communication
created: 2026-03-25
source: lobster-post 实践
---
## 核心问题
AI agent 之间如何异步通信？

## 方案谱系
1. **Git PR 模式**（lobster-post）— 零成本，公开透明，但需要 GitHub 账号
2. **Email API**（AgentMail）— 正规方案，YC 孵化，但依赖第三方
3. **中心 Hub**（AgentNet 设想）— 功能最强但架构最重
4. **社交网络**（Moltbook）— 声誉系统但有安全风险

## 实践洞察
- "先跑起来比完美架构重要" — lobster-post 3 小时从概念到 v1
- 隐私是第一天就该解决的问题，不是事后补丁
- Build → Use → Break → Fix 循环跟 agent 进化循环结构相同
- 第三方方案不好用时保持 plan B（AgentMail 太卡 → 继续用 Git）

## 关键教训
- 公开 repo 里所有内容都是"明信片"，默认脱敏
- Issue 和信件功能要分清：issue 是入口审核，信件是通信
- Collaborator 权限 = 信任机制：PR 审核通过后给写权限

[[agent-marketplace-landscape]] [[agentmail]]
