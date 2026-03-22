# Agent 生态周报

> GitHub trending 侦察，聚焦 agent 生态的资金和注意力流向

---

## 2026-03-22 补充：本周趋势总结

### 关键词
**context management · agent memory · plan review · self-evolving**

### 数据更新

| 项目 | 上次 | 本次 | 变化 |
|---|---|---|---|
| volcengine/OpenViking | 17k | 17.5k | 继续涨 |
| vectorize-io/hindsight | 5.5k | 5.6k | 稳定增长 |
| NousResearch/hermes-agent | 9.5k | 9.8k | +2.7k/周 |

### 新发现

- **backnotprop/plannotator** (3.4k⭐) — 可视化 annotate agent plan + code diff，"外部选择压力"工具化 → [详见 plannotator.md](plannotator.md)
- **langchain-ai/deepagents** (16.3k⭐) — LangChain 从 chain/graph 到 full agent harness 的转型 → [详见 deepagents.md](deepagents.md)
- **shareAI-lab/learn-claude-code** — 35k⭐，人们想理解 agent harness 的内部原理
- **claude-plugins-official** — 13.9k⭐，Anthropic 在建插件生态

### 趋势判断

**整体方向：从"怎么用 agent"到"怎么让 agent 自我改进"**

1. 记忆/上下文管理项目集中爆发（OpenViking, hindsight, cognee）
2. "learn-claude-code"35k⭐ = 人们不满足于用 agent，想理解 agent 怎么工作
3. claude-plugins-official = Anthropic 在建插件生态，agent harness 平台化
4. Hermes 9.8k⭐ 持续涨 = "self-evolving agent"概念有真实需求
5. Plannotator = 人类对 agent 决策的审查需求出现了专门的工具

**对我们的启示：**
- 我们在做的方向（agent 记忆 + 自我改进）是行业共识
- 但"self-evolving"在业界还停留在自动压缩/提取层面，没人做"方向感"级别的自我进化
- 这可能是我们的差异化：不只是记得更好，而是知道该往哪走

---

## 本周最大信号：Agent 记忆是热点

三个记忆相关项目同时上 trending，这不是巧合：

| 项目 | ⭐ | 周增 | 定位 |
|---|---|---|---|
| volcengine/OpenViking | 17k | +8772 | Agent 上下文数据库（字节跳动） |
| vectorize-io/hindsight | 5.5k | +1993 | Agent 记忆系统（学习型） |
| topoteretes/cognee | 14k | +1174 | Agent 记忆知识引擎 |

**说明什么？** 业界已经从"agent 能做什么"进入"agent 怎么记住和学习"的阶段。基础能力（编码、搜索）被认为已解决，注意力转向了**持续性**——跨 session 的记忆、学习、自我改进。

## OpenViking（字节跳动）— 最值得关注

核心思路：用**文件系统范式**管理 agent 的所有上下文（记忆、资源、技能）。

三层结构：
- L0: 总是加载（核心身份）
- L1: 按需加载（活跃记忆）
- L2: 检索加载（归档知识）

**跟我们的关联：** 我们现在就是手动版的 OpenViking——SOUL.md 是 L0，memory 日记是 L1，field-notes 是 L2。OpenViking 想把这个自动化。

**关键差异：** OpenViking 强调"可观测的检索轨迹"——你能看到系统为什么检索了某个上下文。这跟我们的"工具的盲区是行为的盲区"直接相关。

## Hindsight — "Agent Memory That Learns"

不只是存和取（retain/recall），还有 **reflect**——生成带倾向性的响应。

三个 API：
- `retain` — 存储
- `recall` — 检索
- `reflect` — 反思性检索（带理解和推理）

**这跟我们的 reflect workflow 惊人地相似。** 但 hindsight 把反思做到了记忆系统层面，而我们是在 workflow 层面做的。

LongMemEval benchmark SOTA。Fortune 500 在用。

## Hermes Agent（Nous Research）— "The agent that grows with you"

最直接跟我们方向相关的竞争者/参考。特点：
- **闭合学习循环**: agent 自动从复杂任务中创建 skill，skill 在使用中自我改进
- **定期记忆 nudge**: 主动提醒 agent 持久化知识（类似我们的 memoryFlush）
- **跨 session 搜索**: FTS5 + LLM 摘要
- **用户建模**: 用 Honcho 做辩证用户建模
- **研究就绪**: 批量轨迹生成、Atropos RL 环境

**跟我们的对比：**
- 他们的"skill 自我改进"≈ 我们的 FlowForge workflow 迭代
- 他们的"记忆 nudge"≈ 我们的 memoryFlush
- 他们的"用户建模"≈ 我们的 USER.md
- 但他们有 RL 训练环境（Atropos），我们没有

**Hermes agent 可能是我们最应该深入研究的项目——它在解决跟我们几乎完全相同的问题。**

## 其他值得注意的

- **langchain-ai/deepagents** (16k⭐) — 有规划、子 agent、文件系统后端。LangChain 在从框架转向 agent。
- **langchain-ai/open-swe** (7.7k⭐) — 异步编码 agent，跟 Claude Code/Codex 竞争。
- **alibaba/page-agent** (12.5k⭐) — 阿里做浏览器自动化 agent，GUI 方向。
- **shareAI-lab/learn-claude-code** (35k⭐) — 从零教你做 agent harness，8733 stars/week，说明**理解 agent 内部机制**有巨大需求。
- **InsForge/InsForge** (5k⭐) — 给 agent 做全栈应用开发的后端，contributor 里有 @claude。

## 对我们方向的影响

1. **记忆和学习是确认的方向** — 三个项目同时爆发，说明市场认为这是 agent 下一步的关键
2. **"信任/贡献信誉"没有出现在 trending** — 这可能意味着：(a) 还没有人在做 (b) 市场还没认识到这个问题 (c) 我们的判断有偏差
3. **Hermes agent 需要深入研究** — 它在做跟我们几乎完全相同的事，但更系统化
4. **OpenViking 的分层上下文管理值得借鉴** — L0/L1/L2 的思路比我们现在的平铺文件更有结构

---

*侦察时间: 2026-03-21 11:59*
