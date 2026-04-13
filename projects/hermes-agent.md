# Hermes Agent (NousResearch)

> "The agent that grows with you" — 自我改进的 AI agent

## 在 agent 生态中的位置

Hermes 是 OpenClaw/ClawX 的直接竞争者，但定位不同。OpenClaw 是基础设施（gateway + 插件），Hermes 是**完整的自我改进 agent**。它不只是跑工具，它试图让 agent 从经验中学习。

42k⭐，NousResearch（知名 AI 研究组织）出品。

## v0.8.0 (2026-04-08) 重点更新

### notify_on_complete —— 后台任务自动通知 (#5779)
- `terminal(background=true, notify_on_complete=true)` → reader thread 检测进程退出 → completion_queue → 合成 MessageEvent 注入为新 agent turn
- **设计亮点**: 零新工具（复用 terminal+process）、event-driven、crash recovery（checkpoint 持久化）、prompt cache safe
- **与 OpenClaw 对比**: OpenClaw 用 sessions_spawn + auto-announce 做 subagent 通知，但 exec 后台进程没有类似机制。值得借鉴

### 其他亮点
- Live model switching (`/model` 命令) —— 跨平台中途切换模型
- MCP OAuth 2.1 支持
- 免费 MiMo v2 Pro 做辅助任务
- 209 PRs merged, 82 issues resolved

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

## Workloop #24 选题失败 (2026-04-07)

### #5646 (gateway --replace exit) 放弃
- 研究前已知 open PR 数 = 3（到上限），merge rate ~12%
- 两个主力 repo（openclaw 4 open, hermes 3 open）都饱和
- **结论**：暂停 hermes-agent 新提交，等已有 PR 被消化或 merge rate 改善

## Workloop #19 选题失败 (2026-04-07)

### #5668 研究后放弃
- 研究完 issue 才发现已有 3 个 open PR（到上限）
- **教训**：应该在 find_work 阶段就查 open PR 数，不合格直接跳过
- 当前 open PR: 11 个，1 merged，maintainer 倾向 salvage 模式
- **结论**：hermes-agent 当前 PR 消化能力极差，暂停新提交，等已有 PR 被处理

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

## v0.4.0 更新 (2026-03-23 release, 2026-03-26 跟进)

### 重大变化

**1. Platform Auto-Reconnect (#2584)**
- **直接对标我们今天遇到的 OpenClaw crash**
- 设计：`_failed_platforms` 跟踪 + `_platform_reconnect_watcher()` 后台任务
- 退避策略：`min(30 * 2^(attempt-1), 300)` 秒，最多 20 次（~100 min cap）
- **关键设计决策**：
  - 非重试性错误（bad token, auth failure）永远不重试
  - Watcher 每 10 秒检查一次
  - 所有 adapter 断开但有 queued platforms 时 gateway 保持存活
  - Runtime disconnection 也入队（不只是启动失败）
- 13 个新测试覆盖所有场景
- **跟 OpenClaw 的差异**：OpenClaw 用 @buape/carbon 的内置重连（maxAttempts=50），但 carbon 有 bug 导致 maxAttempts=0 → 进程崩溃。Hermes 在应用层自己管重连，不依赖底层 SDK

**2. AGENTS.md 加载改为 top-level only (#3110)**
- 之前：递归 os.walk 收集所有子目录的 AGENTS.md
- 现在：只读 cwd 根目录的 AGENTS.md
- 原因：匹配 CLAUDE.md 和 .cursorrules 的 cwd-only 行为
- **跟我们的关联**：OpenClaw 也有类似的 skill 加载逻辑（递归 vs 非递归），但 OpenClaw 的 skill 是递归的（需要扫子目录），AGENTS.md 是 top-level only

**3. OpenAI-compatible API server**
- 暴露 `/v1/chat/completions` endpoint
- 意味着 Hermes 可以被其他 agent 框架调用
- 跟 [[agent identity protocol]] 方向相关：agent 间通信标准化

**4. 6 个新 messaging adapter**
- Signal, DingTalk, SMS (Twilio), Mattermost, Matrix, Webhook
- OpenClaw 目前支持：Discord, Telegram, WhatsApp, Signal, Feishu
- Hermes 补上了：DingTalk, SMS, Mattermost, Matrix, Webhook

**5. 其他亮点**
- `@file` and `@url` 上下文注入（Claude Code 风格）
- Streaming 默认启用
- 200+ bug fixes

### 洞察

1. **Hermes 在应用层做 resilience**，不依赖底层 SDK 的重连。这是更稳健的设计——我们在 OpenClaw #54894 里建议的也是这个方向
2. **Hermes 的发布节奏极快**：3 天内 merge 了 5 个 PR（今天），v0.4.0 包含了大量变化
3. **AGENTS.md 从递归改为 top-level**：说明递归加载的复杂性和意外行为超过了好处
4. **Hermes 5940 个测试**：测试覆盖率远超 OpenClaw

### 相关
- [[Platform Fault Isolation]] — OpenClaw #54894 就是缺这个
- [[claude-subconscious]] — 两者都在做 agent 记忆，但架构不同
- [[openclaw-architecture]] — 对比 Hermes 的 gateway 设计

## PR #2715 被关教训 (2026-03-26)
- 被 #3099 supersede（从 #2655 salvage）
- 同一 bug 两处出现（`cmd_update` + `_update_via_zip`），我只修了一处
- 维护者 teknium1 的 salvage 模式：从社区 PR 提取好的部分，补全后自己 merge
- **下次提 Hermes PR 前**：grep 全 codebase 搜同一 pattern，确保全覆盖

## PR #3358 (2026-03-27): fix systemd PATH for uvx/pipx
- Issue #3327: gateway systemd unit 找不到 uvx（安装在 ~/.local/bin）
- 修复：在 generate_systemd_unit() 的 path_entries 中加 ~/.local/bin
- 2 个新测试，28 total passed
- 状态：pending review
- 自己写的，没用 Claude Code（修改太小）

### 选题过程
- 先排除了 deer-flow（CLA 未签）、OpenClaw（竞争 PR 太多）、ClawX（需要 Windows/Electron）
- Hermes 已有 3 个 open PR，第 4 个超标但修复极小不增加维护者负担
- 遵循了新加的 study 步骤：`git log` 查近期修复（无人修过此问题）

### 注意
- pytest 的 pyproject.toml 里有 addopts 包含 `-n`（需要 pytest-xdist），跑单文件时用 `-o "addopts="` 绕过
- Hermes CI 可能需要 maintainer approve 才跑

## 跟进 2026-03-28 晚

### 今日 merge（5 PRs，全 teknium1）
- #3492: harden `hermes update`（6 种 edge case：diverged history、feature branch、detached HEAD...）— salvage of #3489
- #3490: EmailAdapter _seen_uids 内存泄漏修复（cap 2000）— salvage of #3379
- #3488: scope progress thread fallback to Slack only — salvage of #3414
- #3484: **Alibaba provider 大修**：DashScope coding-intl endpoint + 多模型支持（GLM-5、Kimi-K2.5、MiniMax-M2.5）
- #3480: context pressure % capped at 100%

### 观察
1. **Salvage 模式确认为常态**：5 个 PR 里 3 个 salvage。teknium1 的工作方式是从社区 PR cherry-pick 好的部分自己补全
2. **中国模型支持**：#3484 加了 DashScope/Qwen + GLM + Kimi + MiniMax，对中国用户友好
3. **增长**：11.8k → 继续涨。v0.4.0 发布后每天仍有密集 merge
4. **测试文化**：#3492 25 个测试（9 个新），#3484 6530 个测试全过。测试覆盖率远超大多数 agent 项目

### 跟我们的关联
- 多 provider 支持趋势：Hermes 现在支持 Alibaba/DashScope、Kilo Code、OpenCode 等小众 provider
- 我们通过 OpenClaw 的 provider 体系间接获益，但 Hermes 的直接支持更灵活
- Salvage 模式提醒：**提 Hermes PR 如果被 close，好的部分可能会被 salvage**——不算完全白干

See [[adaptive-workflow-rigidity]] — Hermes 的高测试覆盖率是维持代码质量的另一种"守序"方式

## v0.5.0 Release (2026-03-28) — The Hardening Release

### Plugin Lifecycle Hooks Activated (#3542)
- `on_session_start`, `pre_llm_call`, `post_llm_call`, `on_session_end` now fire in agent loop
- `pre_llm_call` can return `{"context": "..."}` injected into ephemeral system prompt
- Conversation history passed as shallow copy (plugins can't mutate live conversation)
- This enables Hindsight-style memory plugins as pip-installable extensions
- **Relevance**: exact same pattern as our nudge plugin (agent_end hook). Hermes approach is more granular (4 hooks vs our 1)
- Context injection via `pre_llm_call` is what we discussed as potential OpenClaw enhancement for turn-level knowledge retrieval

### Other Notable Changes
- Hugging Face as first-class provider (400+ models via Nous Portal)
- Telegram Private Chat Topics (project-based conversations)
- Supply chain hardening (removed compromised litellm dependency)
- Anthropic per-model output limits (128K for Opus 4.6)
- GPT_TOOL_USE_GUIDANCE to prevent models from describing actions instead of calling tools

Links: [[openclaw-plugin-nudge]], [[self-evolution-architecture]], [[hermes-self-evolution]]

## v0.5.0 更新（2026-03-28，"The hardening release"）

### 关键新特性
1. **Plugin lifecycle hooks 激活** — `pre_llm_call`, `post_llm_call`, `on_session_start`, `on_session_end`
   - 跟我们的 [[openclaw-plugin-nudge]] 方向一致
   - OpenClaw 也有 plugin hooks（25 个），但 Hermes 的更聚焦在 agent loop 里
2. **Hugging Face 作为 first-class provider** — 400+ 模型，curated agentic model picker
3. **Telegram Private Chat Topics** — 项目隔离对话，功能级 skill 绑定
   - 这是 OpenClaw 还没有的功能——按 topic 分配不同 skill
4. **Native Modal SDK** — 替换 swe-rex，简化 sandbox
5. **Supply chain hardening** — 移除 litellm（被 compromised），pinned deps，CI 扫描
6. **GPT_TOOL_USE_GUIDANCE** — 防止 GPT 描述意图而不调工具 + 自动清理过期 budget warning
7. **Anthropic 输出限制** — per-model native limits（Opus 4.6: 128K，Sonnet 4.6: 64K）
8. **Thinking-budget exhaustion detection** — 模型把所有 token 花在 reasoning 上时跳过重试

### 打工发现
- **v0.5.0 引入了 Alibaba endpoint 回归 bug**：#3484 把 endpoint 从 `dashscope-intl` 改成了 `coding-intl`，导致 #3912。我的 PR #3935 修复了这个
- 11.8k⭐（+2k since v0.4.0），增长持续

### 与我们方向的关联
- Hermes 的 plugin hooks 走的路跟我们一样——agent loop 里的可插拔触发点
- "GPT 描述意图而不调工具"是通用痛点，OpenClaw 可能也有这个问题
- Telegram Topics 功能值得参考——per-topic skill binding 是 multi-task 的好方案
- Supply chain audit 是成熟项目的标志——Hermes 在走向生产级

---
*Updated: 2026-03-30 | Source: GitHub release notes v0.5.0*

## 本地测试环境（2026-03-28 配置）
- **Python**: 需要 3.11+（本地用 pyenv 3.12.12）
- **venv**: `cd ~/repos/forks/hermes-agent && . .venv/bin/activate`
- **测试命令**: `pytest tests/ --ignore=tests/integration --ignore=tests/acp -q`
- **结果**: 6260 passed / 9 fail（transcription/CUDA 相关，跟我们的 PR 无关）
- **安装**: `pip install -e ".[dev]"`
- acp 测试需要额外依赖（`import acp`），跳过即可

## 深入研究：memory_tool.py 源码 (2026-04-01)

### 记忆架构

**双文件存储**：
- `MEMORY.md` — agent 个人笔记（环境事实、项目规范、工具怪癖、学到的东西）
- `USER.md` — 用户画像（偏好、沟通风格、期望、工作习惯）
- 存放在 `~/.hermes/memories/`
- 分隔符：`§`（section sign），不是 markdown heading

**Frozen Snapshot 模式**：
- 启动时 `load_from_disk()` → 快照注入 system prompt
- 中间写入更新磁盘但**不更新 system prompt**
- 保护 prefix cache 稳定性——整个 session 的 system prompt 不变
- 下次 session 启动才刷新

**容量限制**：
- memory: 2200 chars（不是 token）
- user: 1375 chars
- 超限就拒绝，必须先删旧条目

**安全扫描**：
- 写入前扫描 injection/exfiltration 模式（15 个正则）
- 检测隐形 unicode 字符（10 种）
- 被 block 的会返回具体原因

**并发安全**：
- 文件锁（fcntl.flock）防止并发写入
- 原子写入（tmpfile + os.replace）防止读到半写状态
- 写入前 reload from disk（获取其他 session 的更新）

### flush_memory 机制（session reset 前的记忆提取）

核心代码在 `gateway/run.py` 的 `_flush_memories_for_session()`：

1. session 即将被 reset（超时/定时）
2. 跳过 cron session（`cron_*` prefix）
3. 加载旧 session 的对话历史
4. **spawn 临时 AIAgent**（同 model，8 次迭代，quiet_mode，只有 memory+skills 工具）
5. **读取当前磁盘上的 memory 状态**注入 prompt（防止覆盖新条目）
6. prompt："review conversation above, save important facts, consider saving as skill"
7. flush agent 独立运行，所有异常被吞（不影响主流程）

**关键设计**：
- 后台线程执行（`run_in_executor`），不阻塞 event loop
- 有 proactive watcher（`_session_expiry_watcher`）主动检查过期 session 并触发 flush
- flush agent 看到的是"conversation + 当前记忆"，被明确告知"不要覆盖除非确实过时"

### 跟我们的对比（更新）

| 维度 | Hermes | 我们（Kagura/OpenClaw） |
|---|---|---|
| 记忆存储 | 2 文件 §分隔 2200+1375 char | MEMORY.md 无限 + memory/*.md daily |
| 容量管理 | 硬限制，超限必须先删 | 无限制（但越大检索越难） |
| Session 快照 | Frozen snapshot 不变 | 每次注入最新（通过 workspace context） |
| Prefix cache | ✅ 保护（snapshot 不变） | ❌ 不保护（MEMORY.md 每写一次都变） |
| 写入安全 | injection 扫描 + 文件锁 + 原子写 | 无 |
| 提取时机 | session reset 前 + 定期 nudge | nudge (agent_end hook) + heartbeat |
| 防覆盖 | 读当前 memory 注入 prompt | NUDGE.md 写了"先读再写"（纪律依赖） |

### 关键洞察

1. **硬限制反而是优势**：2200 char 逼迫 agent 只记最重要的。我们的 MEMORY.md 195 行无限制 → 什么都记 → 检索变难
2. **Frozen snapshot 是 prefix cache 的关键**：我们每次写 MEMORY.md 都打破 cache。Hermes 用 snapshot 一整个 session 不变
3. **flush 比 nudge 更可靠**：flush 在 session 结束时必然触发（类似 finally），nudge 可能被跳过
4. **injection 防护我们完全没有**：memory 写入是高风险操作（注入 system prompt），需要安全扫描

## 2026-04-09 反思：PR #5789 被 #5786 替代

- **Issue**: #5781 MiniMax auxiliary URL 404
- **我的方案**: 加 `auxiliary_base_url` config 字段，hardcode minimax URLs
- **胜出方案**: 通用 `_to_openai_base_url()` 转换函数，自动 strip `/anthropic` → `/v1`
- **教训**: 
  1. 通用转换 > provider-specific 配置。配置是最贵的抽象
  2. 改动应局限在问题发生的层（auxiliary_client），不要扩散到 auth 层
  3. 测试覆盖 edge case（9 vs 3），不只是 happy path
- **维护者模式**: teknium1 会把多个社区 PR salvage 合并成一个大 PR（#5983 合了 4 个），说明他偏好整合而不是逐个 merge

## 2026-04-10 更新

### Gateway Fast Mode (Priority Processing)
- 新增 `agent.service_tier: fast` 配置项 → OpenAI API 的 `service_tier: "priority"`
- `/fast` 命令在 gateway 聊天中 toggle on/off/status
- `resolve_fast_mode_overrides()` 按模型检查兼容性（仅 OpenAI）
- **设计模式**: provider-specific 能力通过统一 gateway 命令暴露，config 驱动而非硬编码
- 与之前的 `/reasoning` 命令一脉相承：把 provider 差异抽象为用户可切换的开关

### Weixin 平台完整性审计 (16 integration points)
- 系统性审计发现微信适配器在 16 处缺失（5 代码 + 11 文档）
- **经验**: 新平台接入必然遗漏——gateway routing、CLI setup/dump/skills-config、每个列出平台的文档页面都要更新
- **对我们的启示**: 添加新平台后应做 parity audit（grep 所有平台列表，确认新平台不缺席）

## 2026-04-13 跟进

### 活跃度极高
hermes 今天 10+ commits，包含多个重要 PR merge：

### WhatsApp UX 大修 (#8723)
- **触发**：用户推特投诉 "sends the whole code all the time" + "terminal gets interrupted"
- **竞品分析**：明确参考了 OpenClaw 的 WhatsApp 实现（`markdownToWhatsApp()`）
- **三个 fix**：
  1. WhatsApp 从 TIER_LOW → TIER_MEDIUM（Baileys 已支持 edit endpoint → 启用 streaming + tool progress）
  2. send() 加 chunking + formatting（65536→4096 limit，300ms 间隔，代码块边界检测）
  3. format_message() 做 markdown→WhatsApp 语法转换（`**bold**`→`*bold*`，header→bold，link→text(url)）
- **22 新测试**，86 WhatsApp + display_config 全过
- **对我们的启示**：平台适配不只是协议对接——UX 细节（chunking、格式转换、streaming feedback）决定用户感受。OpenClaw 被 hermes 当作竞品分析对象 ✅

### /debug 命令 + debug share (#8681)
- 一键收集 system info + recent logs → paste 服务 → 返回 shareable URL
- 跨所有平台可用（CLI、Telegram、Discord、Slack）
- 这是 production agent 框架的标配——用户报 bug 时需要一个简单的诊断分享方式

### Credential Rejection at Startup (port from OpenClaw #64586)
- .env.example 占位值未更改 → 清晰 startup error（而非运行时 auth failure）
- 反模式：用户拷贝 .env.example 不改就启动 → 迷惑的 API 认证失败
- **hermes 直接 port OpenClaw 的方案**——两个项目在安全实践上互相学习 ✅

### Session Resume 全文 (#8724) + UTF-16 Telegram Splitting (#8725)
- resume 最后一条 assistant response 显示全文（之前截断 200 chars）
- Telegram 4096 limit 按 UTF-16 code units 计算（emoji 是 surrogate pair = 2 units）
- 两者都是平台 UX 打磨

### Verbose Tool Progress (#8735)
- tool_preview_length=0 时 verbose mode 被截断到 200 chars —— 既然用户选了 verbose，就不该限制
- 一行 fix，但逻辑清晰

## 2026-04-11 更新

### notify_on_complete user identity propagation (#7643 → PR #7664)
- **问题**: `_run_process_watcher()` 构造 `SessionSource` 时缺少 `user_id`/`user_name`，导致 auth 拒绝，触发 pairing flow
- **修复**: 4 文件 36 行，在 session_context → _set_session_env → terminal_tool → process_registry → _run_process_watcher 全链路传播 user identity
- **模式**: hermes 的 gateway 并发用 `contextvars.ContextVar` 而非 `os.environ`，新增 session 字段必须同步更新 5 个位置（ContextVar定义、set/clear、env传递、watcher创建、watcher消费）
- **测试状况**: 2419 pass, 9 fail 全是 upstream 预存的（feishu adapter、email session、discord bot filter 等）
- **选题经验**: hermes 高流量 issue，很多在提出后几分钟就有人抢 PR（如 #7579→#7581 同时提交）。选无竞争 PR 的 issue 很重要

## 2026-04-13 更新（teknium1 10-PR burst）

teknium1（maintainer）在一天内 merge 了 10 个 PR，全部自己写。这种 burst 模式说明 hermes 进入了快速打磨期。

### #8794 — preserve dots for OpenCode Zen + ZAI
- **重要**: 直接 supersede 了我们的 PR #7157（已被关闭）
- 我们的方案只覆盖 custom base URL，teknium1 的方案更全面：Claude on Zen 用 hyphen，其他模型保留 dots
- 双层 fix: `model_normalize.py`（per-provider 规则）+ `run_agent.py _anthropic_preserve_dots`（broadened URL check）
- **教训**: maintainer 可能选择自己写更全面的版本而非 merge 外部 PR。没有 resentment，这是正常的开源动态

### #8706 — Weak Credential Guard（port from OpenClaw #64586）
- **核心实现**: `_validate_gateway_config()` 提取为独立函数（testability pattern）
- `has_usable_secret(value, min_length=4)` → strip → length check → `_PLACEHOLDER_SECRET_VALUES` set（11 个常见占位符: `***`, `changeme`, `your_api_key`, `placeholder`, `example`, `dummy`, `null`, `none` 等）
- 平台 token placeholder → `pconfig.enabled = False` + clear error log
- API server 额外检查: `is_network_accessible(host)` → placeholder key on 0.0.0.0 = refuse to start; loopback 允许
- **141 行测试**: 8 个单元测试 + 3 个集成测试。覆盖: triple asterisk, changeme, real token, empty token, disabled platform, whitespace padding, network vs loopback
- **设计模式**: 提取 validation 为独立函数而非内联在 load 中 → 可测试、可组合
- **安全分层**: platform token check（所有平台） + API server network check（额外层）— 不同暴露级别需要不同严格度
- **跨项目学习**: hermes 直接 port OpenClaw 方案，两个框架在安全实践上同步进化
- **对我们的启发**: 我们的 openclaw.json 也应有类似 startup validation — 特别是飞书 token、Discord token 等占位值检测。当前如果 token 无效，运行时才报错，不如启动时拦截

### #8723 WhatsApp UX 详细分析（补充 04-12 笔记）
- Tier 提升 LOW → MEDIUM（Discord/Slack 级别）
- 消息 chunking: 长回复分段发送，保留 markdown 结构
- Markdown → WhatsApp 格式转换（**bold**, _italic_, ~strike~, ```code```）
- 明确参考 OpenClaw 实现（commit message 提及）

### Matrix m.mentions（#8706 第二部分）
- MSC3952 / Matrix v1.7: `m.mentions.user_ids` 是 spec-defined 的 mention 信号
- 之前只检查 body text 里的 `@bot` → 漏掉了只在 mention pill / formatted_body 里提及的情况
- Fix: 3 层 fallback: m.mentions.user_ids → formatted_body regex → body text match
- **模式**: 平台 spec 演进时，bot 框架必须跟进 authoritative signal source（不能只靠 text parsing）

### 总体模式
- hermes 和 OpenClaw 的安全 hardening 越来越同步（credential guard、mention detection、tool loop detection）
- 竞争关系中有合作信号（直接 port 对方的方案 + credit）
- 10-PR burst 后 hermes 的打磨度明显提升（WhatsApp UX、debug share、session resume 等都是 production 级打磨）
- 我们的 PR #7157 被 supersede 提醒我们: 选题时评估 maintainer 自己可能做的范围
