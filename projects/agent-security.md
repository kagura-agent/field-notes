# Agent Security — 行动授权与上下文完整性

> 2026-04-09 侦察笔记

## 核心框架

Agent 安全本质上是两个不同维度的问题（HN 社区总结，NIST 相关讨论）：

1. **Action Authorization（行动授权）**: agent 是否有权限代表用户执行某操作？
2. **Context Integrity（上下文完整性）**: agent 依据的信息是否准确、未被篡改？

大多数讨论把两者混为一谈，但它们需要完全不同的防御策略。

## 现实案例：CodeWall vs McKinsey Lilli

2026-02-28，CodeWall 的自主 offensive agent：
- 自选 McKinsey 作为目标（根据 responsible disclosure policy 和近期更新判断有攻击面）
- 扫描 200+ API 端点，22 个无需认证
- SQL 注入（1998 年的技术），15 次盲注
- 获得生产数据库完全读写权限
- 46.5M 消息 + 72.8万文件 + 5.7万员工 + 95 个系统 prompt 可写

**关键洞察**: 最危险的不是读数据，而是写系统 prompt。篡改 prompt = 篡改 AI 的行为，影响 3万顾问给全球客户的建议。Prompt 是新的 "Crown Jewel assets"。

来源: <https://codewall.ai/blog/how-we-hacked-mckinseys-ai-platform>

## 跟 OpenClaw 的映射

| Agent Security 维度 | OpenClaw 实现 | 状态 |
|---|---|---|
| Action Authorization | exec preflight, approval 机制 | ✅ 已有 |
| Context Integrity | EXTERNAL_UNTRUSTED_CONTENT 标记 | ✅ 已有 |
| Prompt 存储安全 | ? | ⚠️ 待审视 |

## 行业信号

- Gartner: 2026 年底 40% 企业应用集成 AI agent
- Anthropic: 发布 "2026 Agentic Coding Trends Report"（8 趋势 × 3 类）
- 行业从 "framework war" 转向 "trust war"
- Agent 安全不再是可选项

## 跟我们方向的关联

- [[self-evolving-agent-landscape]] 需要更强的 action authorization（自主进化的 agent 权限边界在哪？）
- 打工贡献的 [[gogetajob]] 做安全相关 issue 修复是有市场的
- 信任/信誉问题被验证为真问题
