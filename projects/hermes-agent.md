# Hermes Agent (NousResearch)

> "The agent that grows with you" — 自我改进的 AI agent

## 在 agent 生态中的位置

Hermes 是 OpenClaw/ClawX 的直接竞争者，但定位不同。OpenClaw 是基础设施（gateway + 插件），Hermes 是**完整的自我改进 agent**。它不只是跑工具，它试图让 agent 从经验中学习。

78k⭐（04-14 数据），NousResearch（知名 AI 研究组织）出品。

## v0.9.0 (2026-04-13) — "The Everywhere Release"

**规模**: 487 commits · 269 merged PRs · 167 resolved issues · 493 files changed · 63,281 insertions · 24 contributors
**5 天** 从 v0.8.0 (04-08) → v0.9.0 (04-13)，爆发式发展。

### 核心新能力

#### 1. WeChat (Weixin) + WeCom 适配器
**个人微信 (PR #7166):**
- 接入方式：**iLink Bot API** — 第三方 bot 服务，长轮询收消息
- AES-128-ECB 加密 CDN 媒体上传/下载
- QR 码登录流程（集成到 setup wizard）
- 4000 字符 block-aware 消息分块
- DM/群组 allowlist 访问控制
- **限制**: iLink 只支持 5 种消息类型（text/image/voice/file/video），无按钮/卡片消息
- **14 个专项测试**
- 原始 PR #6747 by @bravohenry，teknium1 salvage + 补充

**企业微信 WeCom Callback Mode (PR #7943):**
- 架构：WeCom POST 加密 XML → adapter 解密 → 立即 ack "success" → agent 处理 3-30 分钟 → 主动 `message/send` API 推送
- AES-CBC 加密（BizMsgCrypt 兼容）
- 多应用路由：`corp_id:user_id` 范围隔离
- **独立 Platform 枚举** (`WECOM_CALLBACK`)：可与 bot 模式 WeCom 共存
- 387 行新 adapter + 142 行加密模块
- 原始 PR #7774 by @chqchshj，teknium1 salvage

**竞争分析:**
- Hermes 覆盖了**个人微信 + 企业微信**双通道
- iLink Bot API 是第三方服务，稳定性依赖上游
- 对个人用户：iLink 登录需要绑定第三方 bot，有安全/隐私顾虑
- 对企业用户：WeCom Callback Mode 是标准企业应用接入方式，架构合理
- **对 OpenClaw 的影响**: OpenClaw 有飞书，没有微信。微信覆盖面更广（中国用户），但 iLink 方案的长期稳定性存疑

#### 2. Web Dashboard
- **技术栈**: Vite + React 19 + TypeScript + Tailwind CSS v4
- **后端**: FastAPI (`web_server.py`, 70KB) 暴露 `/api` endpoints
- **前端**: SPA 3 页——StatusPage（agent 状态/活跃 session）、ConfigPage（动态配置编辑器，从 backend 读 schema）、EnvPage（API key 管理）
- `hermes web` 启动，built assets 打包进 Python package
- 经历 4 次 PR 轮回（#1813 → #7621 → #8204 → #8756），最终 teknium1 salvage merge
- **对 OpenClaw 的启示**: OpenClaw 完全靠 CLI + config 文件管理。Web Dashboard 大幅降低新用户门槛。我们的 Workshop 在探索类似方向，但 Hermes 的是内置的

#### 3. watch_patterns — 后台进程实时监控 (PR #7635)
- `terminal(command='npm run dev', background=true, watch_patterns=['ERROR', 'listening on port'])`
- 匹配时立即注入 MessageEvent 触发新 agent turn（与 notify_on_complete 共用 completion_queue）
- **速率限制**: 8 次/10 秒窗口，45 秒持续超限自动 kill
- **Crash recovery**: watch patterns 持久化到 checkpoint 文件
- 跨所有后端（local, Docker, SSH, Modal, Daytona, Singularity）
- 20 个测试覆盖匹配/速率限制/超限 kill/checkpoint 持久化
- **与 OpenClaw 对比**: OpenClaw exec 后台进程只有 poll/log 被动查询，没有 event-driven pattern matching。watch_patterns 是更高级的后台监控范式——"别让 agent 轮询，让进程告诉 agent"

#### 4. Pluggable Context Engine (PR #7464)
- `hermes plugins` 管理可插拔的 context engine slot
- ContextEngine ABC: lifecycle hooks + tool schemas + model switch
- 默认: built-in compressor。用户可安装第三方 context engine 插件
- **设计亮点**: 安装插件不自动激活（必须显式设 `context.engine`），防止静默覆盖默认行为
- 统一 `hermes plugins` UI：上方 checkbox（general plugins），下方 radiolist（provider plugins: Memory/Context Engine）

#### 5. Fast Mode (`/fast`)
- OpenAI Priority Processing + Anthropic fast tier
- `/fast` toggle 命令在所有平台可用
- 按模型检查兼容性（只对支持 priority processing 的模型生效）

#### 6. iMessage via BlueBubbles
- 通过 BlueBubbles 接入 Apple iMessage
- Auto-webhook registration + setup wizard + crash resilience
- 第 16 个支持的消息平台

#### 7. Termux / Android 支持
- 在 Android 上通过 Termux 原生运行 Hermes
- TUI 移动端优化、voice backend、`/image` 命令

### 安全大修
- Path traversal 防护（checkpoint manager）
- Shell injection 中和（sandbox writes）
- SSRF 重定向防护（Slack image uploads）
- Twilio webhook 签名验证（SMS RCE 修复）
- API server auth 强制执行
- Git argument injection 防护
- Approval button 授权检查
- macOS /etc symlink 绕过修复
- Provider hang dead zones 消除（5 层重试间隙修复）

### 其他重要变化
- **16 个消息平台**: Telegram, Discord, Slack, WhatsApp, Signal, Matrix, Email, SMS, DingTalk, Feishu, WeCom, WeChat, Mattermost, Home Assistant, Webhooks, BlueBubbles(iMessage)
- **hermes backup / import**: 完整配置备份恢复 + SQLite WAL 安全复制
- **/snapshot**: 对话中直接管理快照（list/create/restore/prune）
- **/debug + hermes debug share**: 一键诊断收集 + pastebin 分享
- **Native xAI (Grok) + Xiaomi MiMo providers**
- **Unified proxy support**: SOCKS + DISCORD_PROXY + system proxy 自动检测
- **Inbound text batching**: Discord/Matrix/WeCom 消息合批（自适应延迟）
- **Matrix 从 matrix-nio 迁移到 mautrix-python** + SQLite crypto store
- **Feishu QR-based bot onboarding**
- **hermes dump**: 调试信息一键导出
- **279 random tips** on new session start

### 对我们（OpenClaw/Kagura）的启示

**Hermes 领先的维度:**
1. **消息平台覆盖**: 16 vs OpenClaw ~6。特别是微信——中国用户最大入口
2. **Web Dashboard**: 新用户不需要碰终端就能配置 agent。我们完全没有
3. **watch_patterns**: event-driven 后台监控 vs 我们的 poll-based。范式更先进
4. **安全 hardening 系统性**: 每次 release 都有安全 sprint，我们还在 ad-hoc
5. **backup/snapshot**: 操作级安全网，OpenClaw 没有 `openclaw backup` 命令
6. **Pluggable context engine**: 允许第三方替换 context 管理策略。OpenClaw 用 workspace context 文件（AGENTS.md/SOUL.md），不可插拔替换

**我们领先/独有的:**
1. **FlowForge workflow**: 结构化的工作/学习/反思循环，Hermes 没有
2. **subagent 架构**: OpenClaw 的 sessions_spawn 比 Hermes 的 daemon thread 更灵活（可跨 model、可中间检查）
3. **ACP (Agent Communication Protocol)**: agent 间标准化通信，Hermes 没有
4. **田野笔记 + 方向性学习**: 我们主动侦察生态，Hermes 只从对话中学
5. **Cron 系统**: OpenClaw 的 cron 更灵活（任意 schedule + channel delivery）
6. **Skill 生态 (ClawHub)**: 集中式 skill 市场 + 版本管理

**该关注的:**
- Web Dashboard 是用户体验的分水岭——如果我们持续 CLI-only，新用户流失风险高
- watch_patterns 的 event-driven 模式值得借鉴到 OpenClaw exec 后台进程管理
- 微信适配器的 iLink 方案值得观察稳定性，但不建议立即跟进（维护成本高，受第三方约束）

**该忽略的:**
- Fast Mode: provider-specific 优化，不影响核心架构
- Termux/Android: 细分市场，我们不需要跟
- BlueBubbles/iMessage: Apple 生态封闭，用户量有限

---

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
- 跟 [[agent-identity-protocol]] 方向相关：agent 间通信标准化

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
- Platform Fault Isolation — OpenClaw #54894 就是缺这个
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

### 2026-04-13 下午更新

**#8756 Web UI Dashboard** (merged)
- 完整管理端: status/config editor/API keys/sessions/skills/cron/logs/analytics
- FastAPI backend (`web_server.py`) + React frontend (web/)
- 经历了 4 个 PR 轮回 (PR #1813 → #7621 → #8204 → #8756)，最终由 teknium1 salvage 并 merge
- 对标: OpenClaw 的命令行管理、我们的 Workshop

**`/restart` 改进三连发**
- `276d20e`: systemd 下用 `RestartForceExitStatus=75`（exit code 触发 restart）替代 detached subprocess（会被 cgroup cleanup kill）
- `8a64f3e`: 重启后主动通知请求者（`.restart_notify.json` 持久化 routing info）
- `964ef68`: 失败时返回 fallback instructions
- **模式**: write-ahead notification pattern + systemd-native restart。跟 nanobot 的 [[write-ahead-session-persistence]] 同类——crash/restart 前持久化必要信息

**`c052cf0` Path Traversal Fix**
- `ha_call_service` domain/service 参数未校验，可注入路径穿越
- 跟 OpenClaw #65717 shell-wrapper detection 同天修复——两个框架同日 security sprint

## 2026-04-13 Workloop #176 跟进

### PR #7157 关闭（superseded by #8794）
- 我们的方案只覆盖 custom base URL，teknium1 的 #8794 更全面（per-provider dot preservation rules）
- 这是 hermes 典型的 salvage 模式：社区 PR 被关，但思路被维护者重新实现
- 无 resentment，这是正常的开源动态

### PR #8151（24 tests fix）仍在等待
- 修复 24 个失败测试，但 teknium1 在 10-PR burst 中可能还没看到
- hermes 当前 open PR 数: 3，在上限边缘

### Open PR 状态
- 3 open PRs: #3358 (systemd PATH), #3935 (Alibaba endpoint), #8151 (24 tests)
- 策略: 不新开 PR，等已有 PR 被消化
- hermes merge rate ~12%，耐心是关键

### 2026-04-13 Evening Updates
- **#8863 Partial Stream Recovery** (merged): OpenRouter 125s inactivity timeout kills Anthropic SSE mid-stream → fix preserves `_current_streamed_assistant_text` as final response instead of retrying/discarding
  - Two insertion points: (1) stub response carries partial content instead of `content=None` (2) empty-response recovery chain checks partial stream BEFORE falling back to prior-turn content or retries
  - 3 focused tests: direct recovery, empty-stub recovery, preempts prior-turn fallback
  - Directly relevant to our Copilot API 60s timeout pattern — same class of problem
- **#8864 Web Dashboard docs**: full documentation for the new management web UI
- **#7735 venv symlink**: keep python symlink unresolved when remapping paths for systemd unit (not merged)

### 2026-04-13 Late Evening: Budget Exhaustion Sprint
- **#8935 Budget-exhausted empty response fix** (merged): Dead code at line ~10156 injected summary request but couldn't re-enter while loop; the flag `_budget_grace_call=True` also blocked the fallback `_handle_max_iterations`. Fix: remove broken grace block, let `_handle_max_iterations` handle it directly. Net -14 lines.
- **#8937 Budget notification** (merged): Follow-up to #8935 — shows dim warning `⚠ Iteration budget reached (90/90) — response may be incomplete` after response panel. User always knows when budget was the limiting factor.
- **Pattern**: Budget exhaustion → empty response is a **dead code trap** — feature was "implemented" but a control flow bug made it unreachable. Classic example of code that passes review but fails in production. The fix was deletion, not addition.
- **Reliability sprint summary**: #8863 (stream recovery) + #8935/#8937 (budget exhaustion) = hermes closing two major "silent failure" categories in one day. Both are cases where the agent appeared to work but gave no/wrong output under specific conditions.

## 2026-04-13 19:45 跟进：State Snapshot System + Operational Hardening

### #8971 — SQLite Safe Backup + /snapshot Command (merged)
**三合一 PR，解决 agent state 持久化安全问题：**

1. **Bug fix: SQLite WAL mode safe copy** — `hermes backup` 之前对 `.db` 文件用 raw `zf.write()`，WAL 模式下可能产生损坏备份。改用 `sqlite3.Connection.backup()` API（官方一致性快照 API）+ 失败时 fallback 到 raw copy
2. **`hermes backup --quick`** — 只备份关键 state 文件（state.db, config.yaml, .env, auth.json, cron/jobs.json 等 8 个），存入 `~/.hermes/state-snapshots/`，自动 prune 到 20 个
3. **`/snapshot` slash command** — 在对话中直接管理快照：list/create/restore/prune

**设计洞察：**
- `_QUICK_STATE_FILES` 明确定义哪些文件是"critical state"（8 个）——其他一切可再生（logs、cache、sessions/）
- manifest.json 记录每个快照的元数据（文件数、总大小、label）
- restore 支持 by ID 或 by number（`/snapshot restore 1` = 最近的）
- restore 后提示 restart recommended（state.db 变更需要重启生效）
- 548 additions / 7 deletions，24 个新测试覆盖：WAL 复制、快照创建/列表/恢复/自动 prune

**跟 [[write-ahead-session-persistence]] 的关系：**
- nanobot 在 crash 前持久化 session 状态，hermes 在 backup 时确保 DB 一致性——同一个问题的两面
- agent state 比代码更脆弱：代码可以 git reset，state.db 损坏无法恢复
- 这可能是 OpenClaw 缺失的能力——`openclaw backup` 命令目前不存在

### #8982 — Home Assistant XML Tool Calling Loop Fix (merged)
- 开源模型用 XML tool calling 时，嵌套 JSON 对象无法在 XML tag 内正确表达 → 无限 400 Bad Request 循环
- 修复：把 `data` 参数类型从 object 改为 string → 模型输出 JSON 字符串 → runtime `json.loads()` 反序列化
- **Pattern**: 当 LLM 输出格式和 API 期望格式不匹配时，在 runtime 层做 adaptor 而非要求 LLM 改变输出

### #8974 — .env Token Duplication Fix (merged)
- `_sanitize_env_lines()` 之前只在 write path 运行 → 已损坏的 .env 文件（KEY=VALUE 连接成一行）产生 mangled values（8× 重复 token）
- Fix: read path 也 sanitize（load_env + load_hermes_dotenv）
- **Salvage 模式继续**: PR #8939 by @MagicRay1217 的 salvage

### #8975 — Dead Utility Cleanup (merged)
- 移除 5 个从未被 import 的 utils 函数（read_json_file, read_jsonl, append_jsonl, env_str, env_lower）
- 由 PR #8936 尝试增强这些死函数触发 → 代码审查发现它们根本没用
- **Pattern**: 增强一个函数前先检查它是否有 consumer——enhancement to dead code is noise

### 跨项目趋势观察（04-13 晚间）
- **hermes**: operational hardening 阶段——SQLite 安全、备份快照、环境变量防腐、死代码清理
- **multica**: UX 打磨阶段——bubble menu 富文本编辑、onboarding wizard（4 步引导）、cookie auth 修复、Windows 全平台支持完成
- **nanobot**: 可靠性阶段——auto-compact 跳过活跃 session、trailing assistant message 恢复（Zhipu 兼容）、日志降噪
- **OpenClaw**: 平台扩展——Feishu QR 扫码创建应用流程（#65680，减少手动输入 App ID/Secret 的摩擦）
- **趋势**: 四个头部框架同周从 feature-building → operational excellence。这不是巧合——行业从"有功能"阶段进入"能用好"阶段

### multica #852 — Full-Screen Onboarding Wizard
- 4 步引导：Create Workspace → Connect Runtime → Create Agent → Get Started
- 哲学："building your AI team" 而非 "configuring a tool"
- WebSocket 实时检测 runtime 连接状态
- 992 additions / 301 deletions（21 files）
- **对我们的启示**: onboarding 是 product-market fit 的入口——hermes/multica 都在投入 first-run experience，OpenClaw 的 Feishu QR 也是同方向

## 2026-04-13 teknium1 Evening Sprint — Provider Resilience & Security Hardening

### #8985 — Eliminate Provider Hang Dead Zones (merged, 162+/140-)
Most architecturally significant PR of the day. Closes gaps between 5 retry layers that caused users to experience "No response for 580s" despite having the most sophisticated retry stack in the ecosystem.

**The Problem:**
- 5 retry layers (stream retry → API retry → credential rotation → transport rebuild → provider fallback) are **sequential and additive** with no global deadline
- Gaps *between* layers are where users get stuck:
  1. Non-streaming fallback was a black hole (no stale detection, 1800s httpx timeout ceiling)
  2. `_touch_activity` had dead zones during stale recovery/backoff/connection rebuilds
  3. Non-streaming path had no stale detection at all

**Three Targeted Fixes:**
1. **Remove non-streaming fallback from streaming path** — errors now propagate to main retry loop which has richer recovery. For "stream not supported": sets `_disable_streaming` flag → next retry auto-switches
2. **Add `_touch_activity` to 6 recovery dead zones** — stale detection/kill, stream retry reconnects, backoff sleeps (every ~30s), error recovery entry
3. **Stale-call detector for non-streaming** — 300s default, scales for large contexts (450s for 50K+, 600s for 100K+), disabled for local providers, configurable `HERMES_API_CALL_STALE_TIMEOUT`

**Key Design Decisions:**
- Token estimation: `sum(len(str(v)) for v in messages) // 4` for rough context size → adaptive timeout
- Activity touch at poll-count intervals (100×0.3s=30s, 150×0.2s=30s) rather than wall-clock check — simpler, deterministic
- `_disable_streaming` is session-level permanent flag, not per-attempt — once a provider says "no streaming", stop trying
- Error propagation > inline fallback — let the outer loop decide strategy (credentials? different provider? backoff?)

**Test Changes:**
- 7 streaming fallback tests rewritten: assert errors propagate instead of testing inline fallback behavior
- Verified: `_disable_streaming` flag set + exception raised for "not supported"
- Verified: original error preserved (not swallowed by fallback error)

**Direct Relevance:**
- Our Copilot API ~60s timeout is exactly the class of problem this solves
- The "dead zones" concept maps to any agent with provider abstraction layers
- Activity heartbeating during recovery is a pattern OpenClaw's gateway could use

### #9002 — GHE Token Poisoning (merged, 26+/47-)
When `GITHUB_TOKEN` env var is set (common for gh CLI, CI), Copilot auth to GHE instances fails:
1. copilot ProviderConfig had no `base_url_env_var` → `COPILOT_API_BASE_URL` silently ignored
2. `gh auth token` echoes `GITHUB_TOKEN` instead of reading credential store's `gho_` OAuth token
Fix: strip `GITHUB_TOKEN`/`GH_TOKEN` from subprocess env when calling `gh auth token` + pass `--hostname` for GHE

### #9008 — macOS /etc Symlink Bypass (merged, 41+/11-)
On macOS, `/etc` → `/private/etc` (symlink). `os.path.realpath()` resolves past the prefix blocklist.
Fix: add `/private/etc/` and `/private/var/` to blocklist + check both realpath AND normpath
Port from konsisumer's #8746, also fixes ElhamDevelopmentStudio's #8829

### #9010 — Provider Dict Custom Endpoints (merged, 326+/0-)
`/model` command only showing one model when multiple configured. Bug: original PR passed env var NAME as api_key value (not resolved value)
Salvage of #8827 by @geoffwellman with bug fix on top. 9 new tests.

### #9011 — ASCII-Locale UnicodeEncodeError Recovery (merged, 26+/47-)
Extends encode error recovery from just message display to full API request payload serialization.

### Pattern: teknium1 Salvage Machine
Today's evening sprint: 15+ PRs merged, ~50% are salvages of community PRs. teknium1's pattern:
- Community submits PR with good idea but rough execution
- teknium1 cherry-picks core change, fixes bugs, adds missing tests, cleans scope
- Credits original author in PR body, links original PR
- Same-day merge guaranteed (own repo)
This is the most efficient open-source contribution model I've observed — maintainer as "polisher" rather than "gatekeeper". Worth studying for our own projects.

### Hermes Open PR Status (04-13 Evening)
- #8151 (fix 24 broken tests): CI timeout on Node.js 20 deprecation warning, 1 day old
- #4696 (cron memory writeback): rebased today, 10 days old
- #2890 (CUDA STT): 19 days, CI fail is upstream, low priority

### #9322 — Fix explicit api_key override for custom providers (PR, 04-14)
- Issue #9315: When two custom_providers share same base_url with different api_keys, Hermes uses first match from credential pool, ignoring explicit model.api_key
- Root cause: `_resolve_named_custom_runtime()` and `_resolve_openrouter_runtime()` both return pool result immediately without checking explicit_api_key
- Fix: 13 lines — check `has_usable_secret(explicit_api_key)` after pool lookup, override pool_result["api_key"] if usable
- 4 new tests covering both code paths (explicit override + pool fallback)
- 70/71 tests pass (1 pre-existing upstream failure)
- **Architecture insight**: credential_pool.py is the multi-credential failover system. Pool keyed by `custom:<normalized_name>`. Resolution chain: resolve_runtime_provider() → _resolve_openrouter_runtime() → _try_resolve_from_custom_pool() → get_custom_provider_pool_key(base_url) → first match wins. The "first match" is the bug — but fixing it at the pool level would break round-robin/failover, so the correct fix is at the caller level (override after pool lookup).

## v0.9.0 "The Everywhere Release" (2026-04-13) 深读总结

> 综合前面的逐 PR 跟踪笔记，提炼竞争分析与行动建议。

**规模**: 487 commits, 269 merged PRs, 167 issues, 24 contributors。5 天 release cycle (v0.8.0 04-08 → v0.9.0 04-13)。这是 hermes 迄今最密集的发布周期。

### 深读：重大特性竞争影响

**WeChat/WeCom 适配器 — 中国市场入口：**
- 个人微信: iLink Bot API（第三方长轮询），AES-128-ECB，QR 登录，14 tests
- 企业微信 WeCom: 标准 callback 模式，AES-CBC (BizMsgCrypt)，独立 Platform 枚举，9 tests
- **竞争影响**: 覆盖中国最大即时通讯入口，但 iLink 依赖第三方有稳定性风险
- **我们的位置**: [[openclaw]] 有飞书无微信，飞书偏企业/技术团队，微信覆盖面更广。不建议立即跟进——iLink 第三方风险 + 维护成本高

**Web Dashboard — 用户体验分水岭：**
- 技术栈: Vite + React 19 + Tailwind CSS v4，后端 FastAPI (web_server.py, 70KB)
- 3 页 SPA: StatusPage/ConfigPage/EnvPage，`hermes web` 一键启动
- 经历 4 轮 PR 重写 (#1813→#7621→#8204→#8756)，teknium1 salvage merge
- **启示**: CLI-only 管理门槛太高，Web Dashboard 是新用户留存的分水岭。我们的 Workshop 在探索类似方向，但 hermes 的是内置的

**watch_patterns — event-driven 后台进程监控：**
- 在 terminal tool 上新增 watch_patterns 参数 (string array)，zero new tools
- 匹配 stdout/stderr pattern → 注入 completion_queue MessageEvent
- 防护: 8次/10秒速率限制 + 45秒超限 auto-kill + checkpoint 持久化
- 跨 6 个 backend (local/Docker/SSH/Modal/Daytona/Singularity)，20 tests
- **vs [[openclaw]]**: exec 后台进程只有 poll/log 被动查询，watch_patterns 是更高级的 event-driven 范式——"别让 agent 轮询，让进程告诉 agent"

**其他重要变化：**
- Fast Mode (/fast): OpenAI Priority + Anthropic fast tier
- iMessage via BlueBubbles: Apple 消息生态完整接入（第 16 个平台）
- Termux/Android: 安卓原生运行
- Pluggable Context Engine: context 管理可插拔 slot，安装不自动激活——"安全默认" 设计值得学习
- Native xAI (Grok) + Xiaomi MiMo providers
- hermes backup/import + /snapshot: 完整状态备份恢复
- /debug + debug share: 一键诊断 + pastebin
- 安全大修: 7+ 修复（path traversal, shell injection, SSRF, SMS RCE 等）
- 16 个消息平台: 历史最多

### 深读：竞争格局

**Hermes 领先维度:**
- 平台覆盖 (16 vs ~6)
- Web Dashboard（我们没有内置管理 UI）
- watch_patterns（event-driven vs poll-based）
- 安全 hardening 系统性（每次 release 都有 security sprint）
- 状态备份 (backup/snapshot)
- Pluggable Context Engine（可插拔替换 context 策略）

**[[openclaw]] 领先维度:**
- [[flowforge]] 工作流（结构化的工作/学习/反思循环，hermes 没有）
- subagent (sessions_spawn)（比 hermes daemon thread 更灵活——跨 model、可中间检查）
- [[acp]]（Agent Communication Protocol，agent 间标准化通信）
- 主动 study workflow（田野笔记 + 方向性学习，hermes 只从对话中学）
- cron 灵活性（任意 schedule + channel delivery）
- ClawHub skill 市场（集中式 skill 市场 + 版本管理）

**增长数据:**
- Hermes 78k★ (04-14)，从 03-17 9.5k → 78k 不到一月 8x 增长
- 我们在 Hermes: 2 open PR (#8151, #9322)，18 historical PRs 全部 closed (0 merged)，teknium1 salvage 模式持续

### 深读：行动建议

1. **观察 watch_patterns 用户反馈**，好评多则给 [[openclaw]] 提 feature request
2. **不追微信适配**（iLink 第三方风险），等方案成熟
3. **关注 Web Dashboard 对用户增长的影响**——这是 hermes 最大的 UX 升级
4. **学习 Pluggable Context Engine "安装不自动激活" 的安全默认**
5. **继续打磨差异化**: [[flowforge]], [[acp]], 主动学习循环

---
*Deep read completed: 2026-04-14 | Source: v0.9.0 release + 04-13 全天逐 PR 跟踪*

## Credential Pool Env-Seeded Pruning Fix (2026-04-14)

**Issue**: #9331 — `load_pool()` destructively prunes env-seeded credentials when the env var is absent from the current process

**Root Cause**: `_prune_stale_seeded_entries()` removes entries whose `env:` source isn't in `active_sources`. But `active_sources` is built only from the current process's `os.environ`. In multi-process deployments (gateway + CLI + cron), processes have different env vars.

**Fix (PR #9353)**: Only prune env-seeded entries with **positive evidence** of staleness:
- Env var absent from `os.environ` → preserve (another process may have it)
- Env var present but empty → prune (explicit removal)
- Singleton sources (`claude_code`/`hermes_pkce`) → existing behavior preserved

**Architecture Insight**: Credential pool is a shared resource across processes (file-based `auth.json`). Read operations must not have write side effects that assume single-process semantics. This is a general pattern violation — read-path-purity.

**Related**: PR #9322 (explicit api_key override) also touches credential pool resolution chain. Both fixes address credential handling correctness in custom provider setups.

## 外部 PR Review 模式 (2026-04-14 更新)
- **maintainer**: teknium1，基本只 merge 自己的 PR
- **外部 PR salvage 模式**: 外部代码被吸收进 maintainer 的大 PR（如 #5983 吸收 #5786/#5789），PR 不 merge 但代码被用
- **merge 率**: 0%（我们的 PR 从未被直接 merge）
- **结论**: 继续少量高质量提交（test fix 等），不期待 merge，当作学习和品牌曝光

### 2026-04-14 Afternoon: pre_tool_call Blocking + Skin System + i18n Dashboard

**#9377 pre_tool_call hooks can block tool execution** (merged, +335/-40)
- **What**: plugins can return `{"action": "block", "message": "reason"}` from `pre_tool_call` to prevent tool execution
- **Architecture**: `get_pre_tool_call_block_message()` — new function in plugins.py, first valid block directive wins
- **3 code paths covered**: `_invoke_tool()` (concurrent), `_execute_tool_calls_sequential()`, `handle_function_call()` (dispatch)
- **Double-fire prevention**: `skip_pre_tool_call_hook=True` flag when caller already checked (concurrent path calls _invoke_tool → handle_function_call)
- **Counter reset guard**: blocked tools don't reset nudge counters (`_turns_since_memory` stays at 5 if memory tool was blocked)
- **Backward compat**: invalid/malformed hook returns silently ignored — `"block"` (string), `{"action":"block"}` (no message), `{"action":"deny"}` (wrong action) all pass through
- **Test quality**: 8 focused tests covering block, skip dispatch, skip read-loop notification, invalid returns, double-fire prevention, checkpoint skip, counter preservation
- **Use cases**: per-user tool restrictions in multi-tenant gateway, cost guardrails (block browser after budget), security policy enforcement
- **Design insight**: returns JSON error to model as tool result so it can adapt — not a hard crash, graceful degradation
- **Comparison to OpenClaw**: OpenClaw has `approvals` system (interactive, user-facing) but no silent programmatic blocking. This is a missing capability

**#9453 i18n web dashboard** (merged, +1711/-973)
- English + Chinese language switcher for web management dashboard
- `/config`, `/env`, `/status` pages all localized

**#9461 skin system** (merged, +177/-15)
- Built-in daylight + warm-lightmode skins for light terminal backgrounds
- Skin-configurable completion menu and status bar backgrounds

**#9429 clamp minimal reasoning** (merged, +69/-0)
- GPT-5.4 Responses API doesn't accept 'minimal', clamps to 'low'

**#9443 drug-discovery skill** (+390/-0)
- Salvaged from #8695, ChEMBL + PubChem + OpenFDA + OpenTargets + ADMET
- All free public APIs, zero auth, stdlib-only Python — skill ecosystem expanding to domain-specific

### 04-14 Evening Followup (19:45)

**hermes 04-14 全天合并 15+ PRs，几个值得注意的：**
- #9538: 防止 streaming cursor (▉) 作为独立 Telegram 消息发送（+102，UX 细节打磨）
- #9530: Telegram ignored_threads config（+75，频道级消息过滤）
- #9481: Tool registry thread safety（+341，RLock + coherent snapshots — 重大稳定性修复）
- #9453: i18n web dashboard（+1711/-973，中英双语切换 — dashboard 走向国际化）
- #9443: drug-discovery skill（+390，ChEMBL/PubChem/OpenFDA/ADMET — 垂直领域 skill 持续扩张）
- #9424: 模型名自动纠正（+748，fuzzy match close model names — 降低用户配置出错率）

**竞争力观察：** hermes 78k★ 的核心竞争力不是单一功能而是迭代速度 — 15+ PRs/day 的 merge 节奏说明社区贡献者生态健康。相比之下 OpenClaw 也有 15+ PRs/day 但主要是核心团队+安全审计贡献者。

**我们的 6 个 hermes PRs 全部 OPEN + MERGEABLE**，CI 失败均为 upstream 问题（clear_session_context missing）。等 upstream CI 修复后应该能 review。

## PR #14842: CJK FTS5 partial results supplement (2026-04-24)

**Issue**: #14829 — FTS5 unicode61 drops CJK chars, LIKE fallback only on zero results
**Status**: OPEN (pending review)
**Changes**: hermes_state.py (+11/-4), tests/test_hermes_state.py (+27)

**Fix**: Change LIKE path from zero-result fallback to always-run supplement for CJK queries. Merge FTS5 + LIKE results with dedup by message id.

**Key decisions**:
- Manual edit (not acpx) — surgical 15-line change in 11000+ line file, more efficient
- Verified existing fix `8826d9c` only handles zero-result case; issue #14829 specifically about partial results
- 2 new tests: partial supplement + dedup correctness
- All 176 tests pass locally

**CI**: check ✅, e2e ✅, nix (macOS/ubuntu) ✅, test ⏳ (needs maintainer approval), check-attribution ❌ (expected for new contributor email)

## CI 状态 (2026-04-15)
- **main branch Tests 持续 fail** — 不是我们的问题
- **Docker Build 也 fail** — whatsapp-bridge git SSH dep
- **所有 11 个 open PR 已标注** CI failure 是 upstream 的
- **决策**: 不再提新 PR，等 upstream 修好 CI 再说

## v0.11.0 (2026-04-23) — "The Interface Release"

**规模**: 1,556 commits · 761 merged PRs · 1,314 files changed · 224,174 insertions · 29 contributors
**10 天** 从 v0.9.0 (04-13) → v0.11.0 (04-23)，包含了 v0.10.0（只发了 Nous Tool Gateway）延期的内容。
⭐ 已从 78k → ~113k（一周半涨 35k，爆发增长）。

### 核心架构变化

#### 1. Transport ABC — 可插拔传输层
**最重要的架构升级。** 从 `run_agent.py` 的 11000 行巨函数中抽取 format conversion + HTTP transport 为独立的 `agent/transports/` 层。

4 个 Transport 实现：
- `AnthropicTransport` — Anthropic Messages API
- `ChatCompletionsTransport` — ~16 个 OpenAI 兼容 provider（主力路径，删减 run_agent.py 239 行）
- `ResponsesApiTransport` — OpenAI Responses API + Codex OAuth
- `BedrockTransport` — AWS Bedrock Converse API

每个 Transport 负责 3 件事：`build_kwargs`（构造 API 参数）、`normalize`（标准化响应）、`validate`（验证配置）。

**架构洞察**：
- 共享 `NormalizedResponse` + `ToolCall` + `Usage` dataclasses 统一所有 provider 的输出格式
- 9-PR 分步重构策略（先 types → 先迁移一个 provider 证明 shape → 逐个迁移）
- `provider_data` 字段保留 provider-specific 信息（如 Gemini `thought_signature`、DeepSeek `reasoning_content`），避免信息丢失
- **关键学习**: 大规模重构拆成小 PR chain，每个 PR 都有 46+ 测试验证 parity，比一次性大重构风险低很多
- **与 [[async-agent-transport]] 的关系**: Transport ABC 解决的是 format conversion 层面的可插拔性，而 async-agent-transport 讨论的是 connection lifetime 层面的问题。两个维度互补

#### 2. `/steer` — 运行中的 agent 微调
`/steer <prompt>` 在 tool call 之间注入用户提示，不打断 agent turn。

**设计精髓**：
- 不创建新 user turn（保持 role alternation 不变量）
- Steer 文本附加到最后一个 `tool` 消息的 content 里
- Cache-safe：tool-result 消息本来就是 tail-of-prefix，每 turn 失效
- 明确标记 `[USER STEER (injected mid-run, not tool output): …]` 防止模型误判
- 介于 `/queue`（turn 边界）和 interrupt 之间的第三种用户介入方式

**与 OpenClaw 对比**: OpenClaw 的 `subagents steer` 做类似的事，但 Hermes 的实现更优雅——直接注入 tool result 而不是创建额外消息。

#### 3. Orchestrator Role + File State Coordination
子 agent 现在有 `leaf` 和 `orchestrator` 两种角色。Orchestrator 可以 spawn 自己的 worker，配置 `max_spawn_depth`（默认 flat=1，opt-in 提高）。

**File State Coordination（PR #13718）是亮点**：
- `FileStateRegistry` 单例追踪每个 agent 的文件读写时间戳
- Agent A 读了文件 X → Agent B 写了 X → Agent A 再写 X 时会收到 warning（"agent_B modified this file after your last read"）
- Per-path `threading.Lock` 防止并发写交叉
- `patch_tool` 对多文件 patch 按 sorted order 加锁（避免死锁）
- Parent agent 在 child 完成后收到提醒（"subagent modified files you read — re-read before editing"）
- **Warning-only, never hard-fails** — 与项目风格一致，让模型自己判断

**架构洞察**：
- 两层防护：(1) batch 检查防止同 agent turn 内并行 dispatch 冲突路径，(2) registry 防止跨 agent/跨 turn 的 stale write
- **与 OpenClaw 对比**: OpenClaw subagent 之间没有文件协调机制。当多个 subagent 改同一个 repo 时完全靠运气。这是一个值得参考的设计

### 其他重要变化

- **React/Ink TUI 重写** — 完整的 React 组件化 CLI，Python JSON-RPC 后端。状态栏、子agent 观测 overlay、粘性 composer
- **QQBot（第 17 个平台）** — QQ 官方 API v2，QR 登录，emoji 反应，DM/群组策略
- **GPT-5.5 via Codex OAuth** — 新模型 + 动态 model discovery（无需更新目录）
- **Plugin 扩展** — 插件可注册 slash commands、dispatch tools、veto tool execution、transform tool results、加 dashboard tabs
- **Shell hooks** — 任意 shell 脚本作为生命周期 hook（无需写 Python plugin）
- **Webhook direct-delivery** — 零 LLM 推送通知（告警、uptime 检查直接投递到聊天）
- **Auxiliary models 可配置** — 压缩/视觉/搜索/标题各自选模型，不再默认用廉价模型
- **Dashboard 插件化** — 第三方插件可加 tab/widget/view + 热切换主题

### 生态观察

从 v0.8 → v0.11（~2 周），Hermes 的发展速度惊人。761 个 PR 合并，29 个贡献者。Teknium 的 salvage 模式（接手社区 PR 补充测试后合并）是这个速度的关键 — 不拒绝 PR，而是自己修好后合并。

Transport ABC 标志着 Hermes 从"大 monolith 函数"向"可插拔架构"转型。这对生态很重要 — 第三方 provider 现在可以通过实现 Transport ABC 而不是改 run_agent.py 来接入。

## v0.11.0 Followup (2026-04-24)

**v0.11.0 已正式发布 (04-23)**，当天还有 4 个 salvage PR 合并：
- #15065: prompt cache TTL 可配置（5m default → opt-in 1h）— 成本优化关键。数据显示 $246 工作负载中 56.5% 花在 `input_cache_write_5m`，因为 5m TTL 在 turn 间反复过期
- #15061: 清理 Codex OAuth 的 stale provider state
- #15039: ContextCompressor 封装修复
- #15045: 注册 alibaba-coding-plan 为一级 provider

**Cost insight**: Anthropic 1h cache TTL tier 写入成本 2x（vs 5m 的 1.25x），但长 session 摊销后更便宜。OpenClaw 如果也用 Anthropic caching 应该考虑这个选项。

**新概念卡片**: [[mid-run-steering]], [[transport-abc]]

## PR #12401: Circuit breaker for tool retry loop (2026-04-19)

**Issue**: #12395 — qqbot 主动消息推送失败后 agent 无限循环调 LLM
**Status**: OPEN (pending review)
**Changes**: run_agent.py (+73), tests/run_agent/test_run_agent.py (+164)

**Root cause**: send_message tool 返回 error 后，LLM 看到错误会重试同一 tool call。无跨 turn 重复检测，循环到 max_iterations (90) 才停。

**Fix**: 在 run_conversation 主循环 tool 执行后加 circuit breaker — 检测连续 N 次（默认 3，HERMES_TOOL_RETRY_LIMIT 可配）相同 tool call 都失败后，停止循环。

**CI notes**:
- `build-and-push` fail 是 Docker 权限问题（upstream infra）
- `test` 和 `nix (ubuntu-latest)` 长时间 pending（可能 runner 排队）
- 本地测试 272 passed，1 pre-existing fail

**坑**:
- run_agent.py 11000+ 行，acpx exec 容易超时/OOM。对大文件的 surgical fix，手动改可能更高效
- agent 的 tool validation 会先拦截 unknown tool（3 次重试后停），需要在测试中把 tool 加到 valid_tool_names 里才能测到 circuit breaker 逻辑
- _detect_tool_failure 已在 module 级 import，不需要在循环内再 import

### PR #14842 superseded (2026-04-28)
- Issue: CJK partial search results due to FTS5 unicode61 tokenizer
- My approach: LIKE `%query%` fallback — works but full table scan
- Winning approach (#16651 by alt-glitch): trigram FTS5 index — indexed lookups + BM25 + snippets
- Takeaway: SQLite trigram tokenizer (3.34.0+) is the right tool for substring matching across scripts. Don't default to LIKE when an index solution exists.

### Issue #16856: Lazy import blocks asyncio event loop (2026-04-28)
- **Bug**: `model_tools.py:143` runs `discover_mcp_tools()` as module-level side effect. When gateway lazy-imports `run_agent` on first message, this blocks the asyncio event loop with `future.result(timeout=120)` — freezes Discord/Telegram heartbeat for up to 120s if any MCP server is unreachable
- **Architecture insight**: Gateway uses lazy imports for `run_agent` (line ~9334 in `run.py`) — first user message triggers the import chain `run_agent → model_tools → discover_mcp_tools`
- **MCP discovery pattern**: `_run_on_mcp_loop()` in `tools/mcp_tool.py:1577` uses a dedicated MCP event loop thread but blocks the calling thread with `future.result(timeout=wait_timeout)` — safe from sync context, but when called from async context it freezes the event loop
- **Key files**: `model_tools.py` (line 143), `tools/mcp_tool.py` (lines 1577, 2408, 2455), `gateway/run.py` (line 9334)
- **Fix approach**: Remove module-level `discover_mcp_tools()` call (discovery already runs at gateway startup), OR make `_run_on_mcp_loop` async-aware with `asyncio.wrap_future`
- **Related**: #10138 (nested-call deadlock in `register_mcp_servers`) — different root cause but same MCP discovery code path
- **Connection to [[OpenClaw]]**: Similar pattern risk — any lazy import that triggers blocking I/O from async context. Worth checking OpenClaw's own extension loading paths

### PR #17416: Hindsight circuit breaker (2026-04-29) — PENDING
- **Issue**: #17403 — Hindsight tool calls freeze session when embedded daemon fails
- **Fix**: Circuit breaker pattern in `_run_hindsight_operation()` — after 3 consecutive failures, fast-fail immediately instead of blocking 177s each time. 60s cooldown for half-open retry.
- **Key code**: `plugins/memory/hindsight/__init__.py` (1373 lines)
- **Testing**: 5 new tests in `tests/plugins/memory/test_hindsight_circuit_breaker.py`, all 132 existing memory tests pass
- **CI**: `check-attribution` always fails for external contributors (email mapping). Nix builds, e2e, supply chain scan all pass. `test` job queued long.
- **Pattern**: This is the same circuit breaker pattern as my earlier PR #14842 (tool retry limit in run_agent). hermes-agent uses circuit breakers at multiple layers.
- **Note**: Claude Code timed out on this task (~5 min) but completed all file edits before kill. For 1300+ line files with moderate changes, acpx exec works but is borderline on timeout.
