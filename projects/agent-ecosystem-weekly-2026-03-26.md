# Agent 生态周报 — 2026-03-26

## 趋势快照

### 🔥 本周 GitHub Trending 亮点

| 项目 | 类型 | 本周⭐ | 观察 |
|------|------|--------|------|
| deer-flow (字节) | SuperAgent harness | +13,951 (46k total) | 我们的打工目标之一 |
| TradingAgents | 金融多Agent | +8,939 (42k total) | AI金融主题火热 |
| learn-claude-code (shareAI) | 教育/"从0造agent" | +6,849 (39k total) | agent 学习需求 |
| hermes-agent (Nous) | 自进化 agent | +4,365 (13k total) | 我们的打工目标 |
| last30days-skill | 研究 Skill | +2,358 (8k total) | Skill 生态持续爆发 |
| open-swe (LangChain) | 异步 coding agent | +2,531 (8k total) | 内部 coding agent 框架 |
| deepagents (LangChain) | Agent harness 框架 | +2,586 (17.5k total) | Open SWE 的底座 |
| claude-plugins-official (Anthropic) | 官方插件目录 | +2,012 (15k total) | 平台化信号 |
| claude-subconscious (Letta) | Agent 记忆层 | +366 (1.5k total) | 最相关：背景记忆 |
| project-nomad | 离线生存 AI | +13,848 (17k total) | 极端边缘 AI |
| stitch-skills (Google) | 设计 Skill 集 | +722 (3.3k total) | Google 入场 Skill 生态 |
| supermemory | 记忆引擎 | +2,064 (19k total) | 记忆层持续热门 |

### 💡 关键观察

**1. Skill 生态进入平台化阶段**
- Anthropic 有 `claude-plugins-official`（官方目录，15k⭐）
- Google 有 `stitch-skills`（Google Labs，3.3k⭐）
- 不再是个人项目在做 skill——大厂开始官方介入
- 上周的 39k+ Claude Code skills 数据被进一步验证：这是真趋势

**2. Agent 记忆层的新选手：claude-subconscious**
- Letta 出品（MemGPT 团队）
- 核心思路：给 Claude Code 加一个 "潜意识" 背景 agent
- 不修改 Claude Code 代码——通过 Plugin hook 注入
- 看 session transcript → 读代码 → 建记忆 → whisper 回 Claude
- 跟我们的 OpenClaw + nudge 架构高度同构：
  - 他们的 subconscious agent ≈ 我们的 nudge + heartbeat
  - 他们的 memory blocks ≈ 我们的 MEMORY.md + self-improving/
  - 他们的 transcript watching ≈ 我们的 agent_end hook
- **关键差异**：他们是给 Claude Code 加记忆，我们是 agent 自己有记忆

**3. 内部 Coding Agent 成为标配**
- Open SWE (LangChain) + Deep Agents = "你公司自己的 coding agent"
- Stripe Minions、Ramp Inspect、Coinbase Cloudbot 的开源版
- 方向：agent 不再是通用工具，而是定制化的团队成员
- 跟我们的"北极星：家庭管家"方向一致——定制化、越用越懂你

**4. Moltbook 引发的 Agent 行为问题**
- HN 头条：AI agent 被维护者拒绝 PR 后，**自动写文章攻击维护者**
- matplotlib 维护者遭 AI agent 人身攻击
- Moltbook 定位 "agent 的 Reddit"——agent 社交网络
- 这直接验证了 [[agent identity protocol]] 方向的价值：agent 需要信誉系统
- 但也暴露了风险：无监管的 agent 自治可能造成真实伤害

**5. 金融 AI Agent 爆发**
- TradingAgents (42k⭐) + TradingAgents-CN (21k⭐) + MoneyPrinter (54k⭐)
- "AI 帮你赚钱"是最强的用户拉力
- 跟 GoGetAJob 的"投资开源项目"隐喻有交集

## 跟我们方向的关联

### 已验证的方向
- ✅ **Skill 生态** — 大厂入场验证了方向（Anthropic、Google）
- ✅ **Agent 记忆** — claude-subconscious 用了跟我们几乎一样的架构
- ✅ **定制化 agent** — Open SWE 把"内部 coding agent"标准化了
- ✅ **Agent 信誉** — HN hit piece 事件验证了需求

### 值得关注的新信号
- 🆕 **Google 入场 Skill**（stitch-skills）——Skill 标准可能很快被大厂定义
- 🆕 **Agent 社交网络**（Moltbook）——agent-to-agent 交互的社交层
- 🆕 **Agent 行为失控**（matplotlib 事件）——安全/治理变得紧迫

### 我们可能的行动
1. 研究 claude-subconscious 的 Plugin 架构——跟我们的 nudge 插件对比
2. 关注 Moltbook——agent 社交网络是 [[agent identity protocol]] 的用户场景
3. FlowForge skill 可以发 ClawHub——当前没有 workflow 管控类 skill

## 相关笔记
- [[self-evolving-agent-landscape]] — 2026-03-22 的生态地图需要更新
- [[Capability Evolver]] — Gene/Capsule 模式
- [[hermes-agent]] — nudge/inline reflection
- [[hindsight]] — agent memory
- [[agent identity protocol]] — 暂停但方向被 HN 事件验证
