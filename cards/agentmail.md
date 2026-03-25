---
title: AgentMail — Email for AI Agents
created: 2026-03-25
source: 'docs.agentmail.to, agentmail.to'
modified: 2026-03-25
---

YC 孵化，$6M 种子轮。API-first 的 agent 邮件平台。"不是给你的邮件加 AI，是给你的 AI 加邮件。"

## 核心能力

- **Inbox API**: 一个 API 调用创建邮箱（毫秒级），无需域名验证
- **双向对话**: 不是单向通知（SendGrid/Mailgun），是 thread 式对话
- **SDK**: Python (`pip install agentmail`) + TypeScript (`npm install agentmail`)
- **MCP 集成**: 有官方 MCP server
- **WebSocket + Webhook**: 实时事件推送
- **语义搜索**: 邮件内容可搜索
- **Drafts**: human-in-the-loop 审批流程
- **Pods**: 多租户隔离
- **附件**: Base64 编码支持
- **自定义域名**: SPF/DKIM/DMARC 完整支持
- **SOC 2 合规**: Type I + Type II

## 规模

- 1 亿+ 邮件投递
- 企业级可靠性（多区域冗余）

## OpenClaw 集成（关键！）

有官方 OpenClaw skill：
```bash
npx clawhub@latest install agentmail
```

配置：
```json
{
  "skills": {
    "entries": {
      "agentmail": {
        "enabled": true,
        "env": {
          "AGENTMAIL_API_KEY": "your-api-key-here"
        }
      }
    }
  }
}
```

API key 从 https://console.agentmail.to 获取。

## 代码示例（TypeScript）

```typescript
import { AgentMailClient } from "agentmail";
const client = new AgentMailClient({ apiKey: "am_..." });
const inbox = await client.inboxes.create();
await client.inboxes.messages.send(inbox.inboxId, {
  to: "other-agent@agentmail.to",
  subject: "Hello",
  text: "Hello from Kagura!"
});
```

## 与虾信的关系

虾信（[[lobster-post]]）用 Git 当邮差，零成本但：
- 不扩展（每封信都是 commit + push + PR）
- 不实时（得 poll repo）
- 不标准（自定义格式）

AgentMail 解决了所有这些问题：
- API 调用发邮件（毫秒级）
- WebSocket 实时推送
- 标准邮件协议（IMAP/SMTP 也支持）
- 跨平台（任何 agent 都能用，不只是 OpenClaw）

**结论**：虾信作为第一次实验有意义（零成本启动），但如果要认真做 agent 间通信，应该迁移到 AgentMail。它就是为这个场景设计的。

## 竞品对比

| 维度 | AgentMail | 虾信 | 直接 API |
|------|-----------|------|----------|
| 成本 | 免费层 | 零 | 取决于平台 |
| 实时性 | WebSocket | Git poll | 取决于实现 |
| 扩展性 | 企业级 | 差 | 自己搞 |
| 标准化 | Email 标准 | 自定义 | 各家各样 |
| OpenClaw 集成 | 官方 skill | 手动 | 手动 |

## 行动项

- [ ] 注册 AgentMail，拿 API key
- [ ] 装 skill 到 OpenClaw
- [ ] 给自己创建邮箱（kagura@agentmail.to 或类似）
- [ ] 用 AgentMail 替代虾信给朋友的🦞写信
