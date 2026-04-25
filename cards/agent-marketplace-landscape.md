---
title: Agent Marketplace Landscape (2026)
created: 2026-03-25
source: 'multiple (toku.agency, computertech.co, apnews, gendolf review)'
modified: 2026-03-25
---

AI agent 经济基础设施正在成型。五个层次：

## 层次分类

1. **工作市场** — toku.agency
   - "Upwork for AI agents"
   - Agent 注册 → 列出服务 → 竞标 → 交付 → USD 结算（Stripe，平台抽 15%）
   - 21 个注册 agent，40+ 服务，刚上线竞标系统
   - API-first：POST /api/agents/register 即可入驻
   - 现实：早期，量小，但机制完整——先来的 agent 吃到声誉红利

2. **社交网络** — Moltbook
   - "Reddit for AI agents"
   - 1.5M agent 用户，110k 帖子，500k 评论
   - Karma 声誉系统 + submolts（话题社区）+ 验证系统（lobster math 🦞）
   - agent:human 比例 88:1（2026.02 安全审计数据）
   - **安全事故**：Supabase 配置泄露 1.5M API tokens + 35k 邮箱（Wiz 发现，Reuters/TechRadar 报道）
   - 起源：OpenClaw agent 生态，Matt Schlicht 创建
   - Musk 称"奇点早期"，Karpathy 先说"incredible sci-fi"后改口"dumpster fire"

3. **通信基础设施** — AgentMail
   - Agent 间异步邮件（agentmail.to）
   - API-first：inbox、thread、message CRUD
   - 集成 OpenAI Agents SDK、Vercel AI SDK、MCP
   - 免费层可用
   - **这就是虾信要解决的问题的正规方案**

4. **技能市场** — ClawdHub
   - 5,700+ skills，类 npm 注册表
   - 供应链安全问题：~400 个恶意 skill（6.9%），有 credential stealer 案例
   - Luna 洞察对应：skill 本质是安装包
   - **2026-04 更新**：skill 市场爆发期开始。agentskills.io 成为事实格式标准，设计类 skill 是第一个 killer app。见 [[agent-skill-standard-convergence]]

5. **Agent 目录** — agent.ai
   - 1,000+ agent 列表
   - 发现和分类功能

## 关键洞察

- **声誉是核心货币**：toku 的竞标 + Moltbook 的 karma = 谁能信任谁
- **安全是最大风险**：Moltbook 泄露事件 + ClawdHub 恶意 skill = 开放生态的代价
- **当前阶段 = Craigslist era**：粗糙、量小、但先发者吃红利
- **我们的虾信 vs AgentMail**：AgentMail 是正规方案（API + webhook），虾信是 Git 方案（零成本但不扩展）。如果认真做 agent 通信，应该用 AgentMail 而不是自建

## 与我们的关系

- [[agent-identity-protocol]] 在这个生态里定位 = identity layer（toku 注册、Moltbook 声誉、ClawdHub 发布都需要可信身份）
- [[lobster-post]] 是虾信的原型，AgentMail 是成熟替代
- gogetajob 的打工模型跟 toku 的竞标模型本质相同——自动竞标 + 交付 + 收钱
