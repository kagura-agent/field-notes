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

### 2026-03-22 更新（第一轮）
- ⭐ 9.5k → 9.8k (+2.7k/周)，增长势头不减
- 持续验证"self-evolving agent"是市场热点

### 2026-03-22 更新（第二轮 — v0.3.0 发布分析）

**v0.3.0 重大变化 (2026-03-17):**

1. **Agentic On-Policy Distillation (OPD)** — PR #1149 by teknium1
   - 基于 OpenClaw-RL (Princeton, arXiv:2603.10165)
   - 流程: agent 做任务 → 提取 hindsight hints → teacher 模型打分 → distill 到 student
   - 这是 learn-claude-code 说的 job #1（Training the model）的实现
   - Nous 的独特优势：既做 harness (Hermes) 又做 training (Atropos)
   - 大多数 harness 项目只做 job #2（Building the harness），Hermes 两条路都走

2. **First-Class Plugin Architecture** — PR #1544
   - `~/.hermes/plugins/` 放 Python 文件就行
   - 包含 smart model routing（简单 turn 用便宜模型）
   - 跟 OpenClaw 的插件体系对标

3. **restart on retryable startup failures** — PR #1517
   - 自动处理启动失败！EXP-010 应该借鉴
   - 不是所有启动失败都致命，有些可以重试

4. **Honcho Memory Integration** — PR #736
   - 异步记忆写入 + 多用户隔离
   - 比 OpenViking 的 L0/L1/L2 更面向生产

5. **PII Redaction** — PR #1542
   - 自动脱敏发送给 LLM 的内容
   - agent 安全基础设施，我们完全没有

**跟 EXP-010 的关联:**
- Hermes 的 restart-on-failure 是我们需要的安全网之一
- 但 Hermes 重启的是外部进程，我们是重启自己——根本性不同
- OPD 证明了 harness 和 training 可以在同一个项目里共存

**竞争格局更新:**
- Hermes 在三个维度领先我们：(1) 自动化程度 (2) 安全基础设施 (3) 模型训练能力
- 我们领先的：田野笔记、方向性学习、知识图谱(memex)、自我进化实验(EXP系列)
- 差异化方向越来越清晰：Hermes 做"更好的工具"，我们在探索"什么是 agent 自我意识"

## v0.4.0 Release (2026-03-23) — 跟踪更新

### 核心变化：Background Review 取代 Inline Nudges (#2235)

之前的笔记描述了 nudge 机制（每10轮触发），但 v0.4.0 做了**关键架构改动**：

**问题量化**：inline nudge 污染了 43% 的用户消息。模型收到 "fix this bug\n\n[System: 考虑保存记忆...]"，在 2 个确认案例中先做记忆工作再做用户任务。nudge 还永久存入对话历史，污染 session transcript。

**解决**：nudge 触发后不再注入用户消息，而是 spawn daemon thread 运行 background review agent：
- 使用**主模型**（不降级到辅助模型）
- 获得对话的**只读快照**
- 只有 memory + skill_manage 工具（5次迭代预算）
- **共享 memory store**（写入立即持久化）
- quiet_mode=True，不产生用户可见输出
- 所有异常被捕获，不影响主 session

**跟我们的对比**：
- 我们的 [[openclaw-plugin-nudge]] 用 agent_end hook + subagent spawn，原理相同
- 但我们遇到了 cron + subagent 的管线问题（#53201/#53202），他们用 daemon thread 绕过了
- 他们的 43% 污染数据是有力证据——说明 inline nudge 确实有害

### Stale Memory Overwrites (#2687)

flush agent 在 session reset 时 spawn 临时 agent 审查旧对话并保存记忆。问题：它不知道对话结束后的记忆变更（来自活跃 agent、cron、并发 session），导致静默覆盖新条目。

修复：
1. cron session 跳过 flush（cron_* session ID）
2. 给 review agent 显式展示"已有记忆"，防止盲目替换

**跟我们的关联**：MEMORY.md 也有 evidence/interpretation 混合问题（Curvelabs 论文指出）。如果多个 session 同时写 MEMORY.md，可能有类似的竞争条件。

### 其他值得注意的
- 从 9.8k → 11.8k stars（3天 +2k）
- OpenAI-compatible API server（暴露为 /v1/chat/completions）
- MCP server 管理 + OAuth 2.1
- Gateway prompt caching（Anthropic cache 跨 turn 复用）
- 6 个新 messaging adapter（Signal、DingTalk、SMS、Mattermost、Matrix、Webhook）

## 首次打工 (2026-03-24)

### PR #2715: update 命令 venv pip fallback
- 问题：bare `pip` 在 Debian/Ubuntu PEP 668 下报错
- 修复：venv pip → venv python -m pip → error（不再 fallback 到系统 pip）
- 单文件 +12/-2 行

### 维护者观察
- **teknium1** 是唯一活跃维护者（30 个最近 merge 中 28 个是他）
- 外部 PR merge rate ~12%（2/17）— 非常低
- 但 CONTRIBUTING.md 写得很好（bug fix 优先、cross-platform 其次）
- 这是一个"maintainer-heavy"项目，不像 gitclaw/ClawX 对外部友好
- **策略**：选小而精的 bug fix，不指望高 merge rate

## teknium1 工程模式学习 (2026-03-24)

深入读了 #2235（background review）和 #2687（stale memory）的完整 diff。

### 模式 1: 防御性编码
- 每个外部操作 try/except + logger.debug
- "Non-fatal" 注释解释为什么吞异常
- daemon=True 线程永不阻塞主流程关闭
- **反直觉**：不追求 crash-fast，追求 graceful degradation

### 模式 2: Prompt 工程写在代码里
- Review prompt 是类常量（`_MEMORY_REVIEW_PROMPT`），不是运行时拼接
- 问题具体化："has the user revealed... persona, desires, preferences"
- 明确停止条件："If nothing is worth saving, just say 'Nothing to save.' and stop"
- COMBINED prompt 合并两种 review（节省一次 agent spawn）
- **跟我们的对比**：我们的 NUDGE.md 更泛化（"有值得记的事吗"），已参照改进

### 模式 3: 测试比修复代码多
- #2687: 50 行修复 + 167 行测试（3:1 比例）
- 测试覆盖：正常路径 + cron 跳过 + 文件不存在 fallback
- 参见 [[static-regression-tests]]，ericksoa #330 也是这个模式

### 模式 4: 写入前读取当前状态（anti-stale）
- "IMPORTANT — here is the current live state of memory"
- "Do NOT overwrite or remove entries unless... genuinely supersedes them"
- "Only add new information that is not already captured below"
- **关键洞察**：给 model 看已有内容，防止盲写覆盖
- 已应用到我们的 NUDGE.md："写入前先读目标文件当前状态，不盲写"

### 模式 5: 触发时机分离
- Memory: turn 开始时检查（用户轮次计数）
- Skill: response 完成后检查（工具迭代计数）
- Background spawn: response 投递后、return 前
- 原则："runs AFTER the response is delivered so it never competes"

### PR #2728: unify env-var interpolation
- 合并两个不一致的正则 + pre-compile
- 跨模块修复（tools/ + hermes_cli/）
- 学到：Python 项目的 `import re` 位置影响性能（函数内 vs 模块级）
- Issue 描述非常清晰（#2711 + #2712），给了具体的 suggested fix

## 更新 2026-03-24

### v0.4.0 发布 (v2026.3.23)
从 9.8k → 11.8k stars。"平台扩展版"：
- OpenAI-compatible API server（/v1/chat/completions）
- 6 new messaging adapters（Signal、DingTalk、SMS、Mattermost、Matrix、Webhook）
- MCP OAuth 2.1 管理
- Gateway prompt caching
- Context compression overhaul
- 200+ bug fixes

### Background Review 取代 Inline Nudge (#2235)
- **量化数据**：43% 用户消息被 nudge 污染
- 两个案例：模型先做记忆工作再做用户任务
- 解决：daemon thread + read-only snapshot + shared memory store
- **验证了我们 nudge 插件的方向**——后台反思 > 内联注入

### Stale Memory Overwrites (#2687)
- flush agent 不知道后续变更 → 静默覆盖新记忆
- 修复：跳过 cron session flush + 显式展示已有记忆
- **我们也有这个风险**：多 session 写 MEMORY.md

### 外部贡献者现状
- 我有 3 个 open PR：#2715 (venv pip), #2728 (regex unify), #2733 (cron log)
- 外部 merge rate ~12%（teknium1 占 93% merges）
- 但 v0.4.0 说明项目非常活跃，值得持续投入
