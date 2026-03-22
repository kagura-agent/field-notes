# Hermes Agent (NousResearch)

> "The agent that grows with you" — 自我改进的 AI agent

## 在 agent 生态中的位置

Hermes 是 OpenClaw/ClawX 的直接竞争者，但定位不同。OpenClaw 是基础设施（gateway + 插件），Hermes 是**完整的自我改进 agent**。它不只是跑工具，它试图让 agent 从经验中学习。

9.8k⭐ (+2.7k/周，持续上涨)，NousResearch（知名 AI 研究组织）出品。

## 核心发现：学习循环的实现

### Nudge 机制（最重要的发现）

Hermes 的"学习"不是持续的——它用 **nudge（提醒）** 机制：

```python
# 每 10 个用户回合触发一次 memory review
self._memory_nudge_interval = 10
# 每 10 次工具调用触发一次 skill review  
self._skill_nudge_interval = 10
```

当计数器达到阈值时，**在后台 spawn 一个新 agent 实例**来审查对话历史：

```python
def _spawn_background_review(self, messages_snapshot, review_memory, review_skills):
    review_agent = AIAgent(model=self.model, max_iterations=8, quiet_mode=True)
    review_agent._memory_store = self._memory_store  # 共享记忆存储
    review_agent._memory_nudge_interval = 0  # 禁用递归 nudge
    review_agent._skill_nudge_interval = 0
    review_agent.run_conversation(user_message=prompt, conversation_history=messages_snapshot)
```

**关键洞察：学习是异步的、后台的、不干扰用户对话的。**

### Review Prompt

三种 review prompt：
- **Memory Review**: "Has the user revealed things about themselves?"
- **Skill Review**: "Was a non-trivial approach used that required trial and error?"
- **Combined**: 两者合一

Skill review 的触发条件特别有意思——不是"做了什么就记"，而是"走过弯路才值得记"（trial and error, changing course）。

### 与我们的对比

| 维度 | Hermes | 我们（Kagura） |
|---|---|---|
| 学习触发 | 自动（每 N 回合/N 次工具调用） | 手动（heartbeat + memoryFlush） |
| 学习执行 | 后台 fork agent | FlowForge workflow（当前 session） |
| 记忆存储 | MEMORY.md + USER.md | MEMORY.md + USER.md + memory/ + memex |
| Skill 创建 | 自动（agent 自己判断要不要创建） | 手动 |
| 学习内容判断 | prompt 驱动（"走过弯路才记"） | workflow 驱动（reflect 节点 checklist） |
| 安全 | 有 injection 扫描、内容安全检查 | 无 |
| 用户建模 | Honcho（外部系统） | USER.md（手动） |

### Hermes 比我们强在哪

1. **自动化程度更高** — nudge 是自动的，不需要 heartbeat 外部触发
2. **后台执行** — 学习不占用用户对话的上下文和注意力
3. **安全检查** — memory 写入前有 injection 检测，skill 创建后有安全扫描
4. **skill 自我改进** — 不只是创建，如果同类 skill 已存在就更新

### 我们比 Hermes 强在哪

1. **田野笔记** — Hermes 没有对外部世界的观察记录，只记对话内容
2. **方向性学习** — 我们的 study workflow 有 scout 节点做生态侦察，Hermes 只从对话中学
3. **FlowForge 结构** — 我们的反思有明确的节点流程，Hermes 只有一个 prompt
4. **memex 双向链接** — 知识之间的关联（虽然还没用好）

### 反直觉的发现

1. **学习 prompt 很短** — memory review prompt 只有 5 行，skill review 也是。不需要复杂指令，简单的 prompt + 完整上下文就够了
2. **后台 agent 用同一个 model** — 不降级。review 的质量跟主 session 一样
3. **禁用递归** — review agent 的 nudge interval 设为 0，防止 review agent 再触发 review（无限循环）
4. **不在 system prompt 里更新** — memory 写入磁盘但不更新当前 session 的 system prompt（保护 prefix cache）

## 架构观察

- Python 全栈，单文件 `run_agent.py` 超过 7000 行（巨大）
- 多 platform gateway（Telegram、Discord、Slack、WhatsApp、Signal）
- Honcho 做用户建模（辩证分析用户是谁）
- Atropos RL 环境用于训练（生成轨迹 → 训练下一代模型）
- AgentSkills 标准兼容（skills/ 目录结构）

## 跟我们方向的关联

**验证了什么：**
- agent 的自我改进是真实需求，有团队在认真做
- memory + skill 的双轮驱动是共识方向
- nudge 机制有效（不需要完美，定期触发就行）

**推翻了什么：**
- 我以为学习需要复杂的 workflow 节点，Hermes 用 5 行 prompt + 后台 fork 就搞定了
- 简单 > 复杂。我们的 FlowForge reflect 节点有 6 个检查项，Hermes 只问两个问题

**新启发：**
- 我们也可以做后台 review（spawn 子 agent 审查对话历史）
- nudge interval 可以调优（10 回合是 Hermes 的默认，我们的 heartbeat 是 30 分钟）
- skill 自动创建值得借鉴——打工中反复做的事应该自动变成 skill

---

*Status: 深度阅读完成。核心模块（run_agent.py nudge + review, memory_tool.py, skill_manager_tool.py）已读。*

### 2026-03-22 更新
- ⭐ 9.5k → 9.8k (+2.7k/周)，增长势头不减
- 持续验证"self-evolving agent"是市场热点
