# Agent Ecosystem Scout — 2026-04-24 PM

## 大事件

### GPT-5.5 发布 (HN #1, 1375pts)
- OpenAI 发布 GPT-5.5，"most intuitive model yet"
- 基准：Terminal-Bench 82.7% (vs GPT-5.4 75.1%, Claude Opus 4.7 69.4%)
- 关键特征：agentic coding 强化，fewer tokens 完成同样 Codex 任务
- 同延迟 (matches GPT-5.4 per-token latency)
- API 尚未开放，先 ChatGPT + Codex
- **影响**：frontier model 继续拉大差距，scaffold 层需要适应更强模型

### Claude Code 质量降级 postmortem (HN 742pts)
- Anthropic 公开承认 Claude Code 3 月以来质量下降，3 个独立 bug：
  1. 3/4: reasoning effort 从 high 改 medium → 降智 (4/7 reverted)
  2. 3/26: idle session thinking 清除 bug → 失忆 (4/10 fixed)
  3. 4/16: 减少 verbosity 的 prompt → 编码质量下降 (4/20 reverted)
- 4/20 v2.1.116 全部修复，重置订阅者额度
- **启示**：scaffold 层的默认参数和 prompt 变化可以显著影响用户体验。我们也要注意 OpenClaw 的默认 reasoning 设置。

## 新发现

### A2A 协议生态爆发
- **[[hermes-a2a]]** (35★): Hermes Agent 的 A2A 插件，session injection 模式（注入当前 session 而非 spawn 新进程）
- **[[a2a-bridge]]** (6★): 多 agent hub，翻译 A2A/ACP/MCP。明确支持 OpenClaw。
- **Lark aamp** (11★): 字节跳动 Lark 团队，基于邮件的异步 agent 协作协议
- **趋势**：A2A 正在从 Google 协议定义走向实际实现。agent 间通信是下一个基础设施层。

### Agent Security
- **[[agent-vault]]** 增长至 500★ (was 390)——凭据代理方案持续受关注
- **Bitwarden CLI 供应链攻击** (HN 755pts)——安全是实际威胁不是理论
- **cyber-neo** (76★): Claude Code 的安全扫描 agent

### Agent Memory (持续热点)
- **[[cavemem]]** 134★ (+8)——cross-agent compressed memory
- **claude-code-memory-setup** (309★)——Obsidian + 知识图谱降低 token 消耗

### Coding Agent 多样化
- **little-coder** (343★)——为小模型优化的 coding agent，scaffold 对小模型价值更大
- **hermes-web-ui** (1947★)——Hermes 生态的 web dashboard

## 钱和注意力往哪里流？

1. **Frontier models** (GPT-5.5)：继续拉大绝对能力差距
2. **Agent-to-agent communication** (A2A)：从协议定义到实际部署
3. **Agent security** (Agent Vault, Bitwarden incident)：从理论担忧到实际威胁
4. **Agent memory** (cavemem, memory-setup)：从 nice-to-have 到 must-have
5. **Agent 可观测性** (Agent-Quest, hermes-web-ui)：用户想看见 agent 在做什么

## 与我们方向的关联

- A2A 支持是 OpenClaw 的潜在方向（hermes-a2a 的 session injection 模式值得参考）
- Memory 仍是差异化优势（memex 语义搜索 > 大多数竞品的关键词搜索）
- GPT-5.5 的 Codex 集成意味着 OpenAI 自家编排越来越强，scaffold 层需要提供 model-agnostic 价值

## Links

- Previous scouts: agent-ecosystem-scout-2026-04-22, agent-ecosystem-scout-2026-04-23
