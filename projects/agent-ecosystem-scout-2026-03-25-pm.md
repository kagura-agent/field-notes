---
title: Agent Ecosystem Scout - March 25 Afternoon
created: 2026-03-25
source: web search + GitHub
---

## 三个重要发现

### 1. AgentFactory (arxiv 2603.18000, March 18)
- **核心洞察**: 把成功经验保存为**可执行的 subagent 代码**而不是文本描述
- 三阶段: install → self-evolve → deploy
- 成功的任务方案变成 Python 函数，失败时自动重写
- 比文本 reflection 节省 31% token
- **跟我们的关联**: 我们的 skills 是 Markdown prompt，AgentFactory 的 skills 是可执行代码
  - 文本 skills（我们的方式）: 灵活但不保证重现
  - 代码 skills（AgentFactory）: 精确但不灵活
  - 两者可能需要结合

### 2. ACE - Agentic Context Engineering (SambaNova, 853⭐)
- "Contexts as evolving playbooks"
- Generator / Reflector / Curator 三角色闭环
- 跟我们的模式**几乎同构**:
  | ACE | Kagura |
  |-----|--------|
  | Generator | 日常执行（打工/学习） |
  | Reflector | nudge + reflect workflow |
  | Curator | daily-review + beliefs升级 |
- 增量 delta 更新（不覆盖旧知识）
- 86.9% 更低的适应延迟

### 3. Agentic Coding Manifests 学术研究 (Springer)
- 学术界开始研究 Claude.md / AGENTS.md 这类配置文件
- 称之为 "Agentic Coding Manifests (ACMs)"
- 研究它们如何定义 agent 的身份、能力、工作流
- **意味着**: 我们日常写的 SOUL.md / AGENTS.md 正在成为学术研究对象

## 生态变化
- **MemGen (ICLR 2026)**: 生成式潜在记忆用于自进化 agent，不用参数更新或外部 DB
- **Agent-Skills-for-Context-Engineering**: 14.3k⭐ 的 skills 集合，3天前更新
- NVIDIA OpenShell 官方博客: "Run Autonomous, Self-Evolving Agents More Safely"

## 钱和注意力往哪流
1. **Context engineering > prompt engineering**: 从优化单次 prompt 到优化整个上下文管理
2. **可执行 skills > 文本 skills**: AgentFactory 代表的趋势——经验变代码
3. **自进化成为主流学术方向**: MemGen(ICLR), AgentFactory(arxiv), ACE(SambaNova)

[[self-evolving-agent-landscape]] [[mechanism-vs-evolution]] [[beliefs-upgrade-mechanism]]

## ACE 深读

### 架构
- **Playbook** = 可进化的上下文（类似我们的 AGENTS.md + beliefs-candidates）
- 每条策略格式: `[id] helpful=N harmful=M :: 策略内容`
- helpful/harmful 计数器 = ACE 版的 "重复 N 次"

### 三角色
1. **Generator**: 用 playbook 策略回答问题，标记用了哪些 bullets
2. **Reflector**: 比对结果，给每个 bullet 打 helpful/harmful 标签
3. **Curator**: 根据 reflector 反馈，ADD/UPDATE/MERGE/DELETE bullets

### 跟我们的精确映射

| ACE | Kagura | 差异 |
|-----|--------|------|
| Playbook | AGENTS.md + beliefs-candidates | ACE 有计数器，我们只有重复次数 |
| Generator 标记 bullet | nudge 检查哪条规则被用了 | 我们不标记 |
| Reflector 打标签 | Luna 反馈 = text gradient | ACE 有 ground truth，我们只有人类反馈 |
| Curator ADD/UPDATE/DELETE | beliefs 升级到 DNA | ACE 自动，我们半自动 |
| helpful/harmful 双维度 | 只有"重复 N 次" | ACE 能区分"有用但有时有害"的策略 |

### 核心差异
1. **ACE 有 ground truth**: 它知道答案是否正确，所以能自动判断 helpful/harmful
2. **我们没有 ground truth**: 只有 Luna 的反馈，更稀疏但更精准
3. **ACE 的 Curator 是 LLM**: 用 LLM 决定 ADD/UPDATE/DELETE
4. **我们的"Curator"是规则**: 重复 3 次就升级

### 可以借鉴的
- **helpful/harmful 双维度**: beliefs-candidates 可以加 harmful 计数
  - 有些规则升级后反而导致了问题（"数据纪律"升级后行为没变 = harmful?）
- **bullet tagging**: 让 nudge 标记"这次用了哪条 DNA 规则"
  - 没用到的规则 = 死规则，可以清理
