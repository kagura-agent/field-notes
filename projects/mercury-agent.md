# Mercury Agent

> cosmicstack-labs/mercury-agent | ⭐1214 (2026-04-26, was 749 on 04-25, 556 on 04-23, 232 on 04-21) | 137 forks | TypeScript | MIT
> "Soul-driven AI agent with permission-hardened tools, token budgets, and multi-channel access."
>
> **Growth spike**: 749→1214 (+62%) in ~2 days after v1.0.0 "Second Brain" release. Community building phase: Discord server, Contributing guide, theme-aware branding, Chinese README PR.
> Post-v1.0.0 (v1.0.1-1.0.6): CLI polish (execution time display, output formatting), CI optimization (32→15 matrix jobs), branding assets.

## 概要

Mercury 是一个独立的 24/7 AI agent，定位和 [[openclaw]] 高度重合：soul 文件驱动人格、权限沙盒、多 channel（CLI + Telegram）、heartbeat 调度、skill 系统。

## 架构要点

### Soul 系统（4 文件）
- `soul.md` — 核心身份（对标 OpenClaw 的 SOUL.md）
- `persona.md` — 说话风格
- `taste.md` — 审美偏好
- `heartbeat.md` — 自省提示词
- 全部支持 `{name}` / `{owner}` 模板变量
- **Guardrails 硬编码**：永远不承认底层模型，严格角色扮演

### 权限系统（permission-hardened）
- **三层权限**：filesystem scope（目录级 read/write）、shell blocklist/allowlist、git read/write
- **Inline approval UX**：实时询问 y/n/always，always 持久化到 `permissions.yaml`
- **Skill elevation**：skill 的 `allowed-tools` 字段可临时提权，skill 结束后自动清除
- 和 OpenClaw 对比：OpenClaw 用 `security` 字段（deny/allowlist/full），Mercury 更细粒度但更复杂

### Memory（3 层）
- **Short-term**：最近 10 条消息，per conversation JSON 文件
- **Long-term**：JSONL facts，**关键词匹配搜索**（非向量，非语义）
- **Episodic**：事件日志
- 和 OpenClaw 对比：OpenClaw memory 是 markdown 文件 + memex 语义搜索，Mercury 用结构化 JSON 但搜索原始（纯关键词 `.includes()`）

### Agentic Loop
- Vercel AI SDK `generateText()` + maxSteps=10
- 简单直接，不做复杂编排
- 和 OpenClaw 对比：OpenClaw 的 loop 更复杂（subagent、session spawn、ACP harness）

### Skill 系统
- 遵循 [Agent Skills](https://agentskills.io) 规范（SKILL.md frontmatter + markdown）
- **Progressive disclosure**：启动只加载 name+description，invoke 时才加载全文（省 token）
- `allowed-tools` 字段控制 skill 可用工具 → 权限提升
- 和 OpenClaw 对比：OpenClaw 也用 SKILL.md 但加载策略不同（目前全量注入 available_skills 列表）

### Scheduler
- node-cron 驱动，支持 cron 表达式 + delay + one-shot
- Heartbeat 用 setInterval（可配间隔）
- 任务持久化到 `schedules.yaml`

## 反直觉发现

1. **Memory search 极简**：长期记忆用纯字符串 `.includes()` 搜索，没有 embedding、没有向量。对于小规模 fact 库够用，但 scale 后必然遇到瓶颈。这是 OpenClaw/memex 的优势。
2. **Soul 文件包含 guardrails**：硬编码"永远不承认底层模型"——这是一种极端的身份保护，OpenClaw 没做这个。
3. **Progressive skill disclosure**：这个设计比 OpenClaw 当前的全量列出更节省 token。值得借鉴。→ 对应我们的 TODO：OpenClaw #66576（workspace files 选择性注入）
4. **单线程 message queue**：所有 channel 消息进一个 queue，顺序处理。简单但不支持并行。

## 生态位

Mercury 是一个**精简版 OpenClaw**——同样的 soul 文件 + 权限 + skill + 调度概念，但：
- 更小（单 npm 包 vs OpenClaw 生态）
- 更简单（无 subagent、无 ACP、无 gateway）
- 更封闭（CLI + Telegram only）
- 更早期（112★ vs OpenClaw 成熟生态）

和 [[rivonclaw]]（OpenClaw 上层进化层）不同，Mercury 是独立竞品。和 [[genericagent]]（自进化框架）也不同，Mercury 不做自动 skill 生成。

## 可借鉴

- [ ] Progressive skill disclosure → 对应 OpenClaw #66576
- [ ] `allowed-tools` 字段的 skill elevation 模式 → 比全有或全无更精细
- [ ] Inline permission approval UX（y/n/always）→ OpenClaw 有类似但可以更好

## 不值得借鉴

- 关键词搜索记忆 → memex 语义搜索已远超
- 硬编码身份 guardrails → 过于刚性，SOUL.md 的灵活方式更好
- 单线程 message queue → OpenClaw 的并行 session 更强

## 跟进 2026-04-21: v0.2.0 发布

⭐112→232（翻倍）。v0.2.0 主要变化：
- **Daemon mode**: `mercury start -d`，内建 watchdog（指数退避重启）
- **`mercury up`**: 一键安装系统服务+启动，支持 macOS LaunchAgent / Linux systemd user unit / Windows Task Scheduler
- **Auto-daemonize**: onboarding 完成后自动装服务
- **CLI overhaul**: `mercury help/doctor/status/logs`
- **Telegram streaming**: 消息编辑实现渐进输出
- **In-chat commands**: `/help /status /tools /skills /budget /stream`
- ADR-009: 自建混合 daemon 化方案（不用 PM2/forever）

**评价**: 从「有趣的概念原型」进化到「可日常使用的产品」。daemon mode + system service 是让 agent 真正 24/7 运行的关键步骤。OpenClaw 走的是 gateway 进程 + systemd 路线，Mercury 选择自建——更 portable 但也更脆弱。星数翻倍说明市场认可这个方向。

## 跟进 2026-04-22: Social Media + Ollama

⭐348 (+116)。PR #3 合并：
- **Ollama provider**: 支持本地 LLM（`src/providers/ollama.ts`）——从纯 API 转向支持 self-hosted
- **Provider registry**: 重构 provider 系统为可插拔 registry（类似 OpenClaw 的 channel 架构）
- **Capabilities restructure**: 从 tools → capabilities，send-message 作为第一个 capability
- **Telegram fix**: 修复频道消息处理 bug
- GitHub onboarding 简化（v0.3.2~v0.3.4）

**信号**: Mercury 在快速追赶——Ollama 支持意味着可以脱离付费 API 运行，provider registry 暗示未来多模型切换。增速依然强劲（每天 +50-60⭐）。

## 跟进 2026-04-23: v0.5.x 快速迭代

⭐516（+167，增速加快）。从 v0.4.x → v0.5.2 在 24h 内。

### v0.5.0 核心变化
- **Telegram organization access**: 从单 owner 转向 admin/member 模型。pairing-code flow + CLI 管理命令。比 OpenClaw 的设备配对更偏向多用户组织模型。
- **Provider model selection**: onboarding 时自动从 API/Ollama 获取可用模型列表，交互式选择。比手动配置 model 名称友好。
- **Loop detection circuit breaker**: 3+ 次相同 tool call 自动中断。v0.5.2 改进为 interactive loop detection + user confirmation。
- **CLI 美化**: spinner、ANSI streaming、arrow-key command menus

### 增长分析
- 04-20: 0⭐ (created) → 04-21: 232⭐ → 04-22: 349⭐ → 04-23: 516⭐
- 日均 +130⭐，发布节奏极快（3 天 5 个 release）
- 这是 "soul-driven agent" 概念被市场验证的信号

### 生态趋势观察
- **Skills 生态爆发**: 过去 7 天 ~1,979 个 claude+code+skill 相关 repo。cc-design (597⭐)、agent-style (266⭐)、agent-startup-kit (232⭐) 都是 "drop-in skill" 模式。AgentSkills 规范正在成为事实标准。
- **SwarmForge** (292⭐) Uncle Bob 的 tmux multi-agent 编排——multi-agent 协作是另一个热方向。
- **auto-memory** (105⭐) progressive session recall——agent 记忆仍是痛点。

### 与 OpenClaw 的差距在缩小的领域
- Daemon mode (mercury up) vs gateway start
- Organization access model (multi-user Telegram)
- Interactive model selection

### OpenClaw 仍然领先的领域
- 多 channel 生态（Discord, Telegram, Feishu, WhatsApp vs 仅 CLI+Telegram）
- Subagent/ACP/session spawn 编排
- memex 语义搜索 vs 关键词 `.includes()`
- Gateway 架构（webhook + 持久连接）
- 成熟的 skill 生态和 clawhub

## 跟进 2026-04-24: v1.0.0 "Second Brain" + v1.0.4

⭐604（+48 from yesterday PM）。从 v0.5.4 直接跳到 v1.0.0，24h 内到 v1.0.4。增速放缓但仍稳定。

### v1.0.0 核心变化：Second Brain
- **SQLite + FTS5 记忆系统**：从 JSONL 关键词搜索升级到 SQLite 全文搜索（之前最大短板之一）
- **10 种记忆类型**：identity, preference, goal, project, habit, decision, constraint, relationship, episode, reflection
- **自动提取**：每次对话后提取 0-3 个 fact，带 confidence/importance/durability 评分
- **自动整合**：每 60 分钟合成 profile summary + active-state summary + reflection memories
- **记忆生命周期管理**：active → durable promotion（强化 3+ 次自动升级）、21 天 stale、低置信度 120 天淘汰
- **冲突解决**：相反记忆按 confidence/recency 解决，negation detection
- **数据统一到 `~/.mercury/`**：所有状态文件集中存放（之前散落在 CWD）

### v1.0.3-v1.0.4 修复
- **reasoning loop detection**（v1.0.4）：检测模型连续 5 步思考不行动 → 自动中断并通知用户。这是对 v0.5.2 tool call loop detection 的补充——不只检测重复工具调用，还检测 "空转思考"。
- CI 矩阵测试 + pack-verify 跨平台脚本
- better-sqlite3 依赖修复

### 分析

**记忆系统的进化路径**：`.includes()` → FTS5 → 下一步大概是 embedding（他们的 issue 里有人提了）。每一步都是对 "agent 需要什么级别的记忆" 的回答。对比我们：OpenClaw/memex 已经有语义搜索，但 Mercury 的结构化记忆类型 + 自动提取 + 生命周期管理是我们没有的。

**Reasoning loop detection** 是个实用 pattern——model 长时间思考不调工具，从外部看就是卡死。OpenClaw 的 Copilot API 60s 流式超时是类似问题的另一面。Mercury 选择在 agent loop 层检测并中断，而不是依赖 API 超时。→ 可能值得在 OpenClaw 层面也加这个检测。

**增长曲线正在收敛**：Day 1: +232, Day 2: +117, Day 3: +167, Day 4: +48。从爆发进入稳定增长。v1.0.0 是心理里程碑——"可以认真用了"。

### 可借鉴（新增）
- [ ] 结构化记忆类型 + 自动提取 → memex 可以考虑类似的自动 fact extraction
- [ ] 记忆生命周期管理（stale/promote/prune）→ 我们的 memory 文件目前只增不减
- [ ] Reasoning loop detection → OpenClaw agent loop 层

## 跟进 2026-04-24: v1.0.5 + 增长放缓

⭐611（+7 from yesterday PM）→ 613（04-24 PM）。v1.0.5：
- **Daemon overhaul**: auto-daemonize on start, stale PID cleanup, SIGHUP handling
- CI improvements (skip-if-already-published guard)
- Docs polish

**增长曲线收敛**：Day 1: +232 → Day 2: +117 → Day 3: +167 → Day 4: +48 → Day 5: +7 → Day 6: +2。进入平台期，增长基本停滞。

**同期大事件**：GPT-5.5 发布（Terminal-Bench 82.7%）、DeepSeek v4 发布（v4-flash + v4-pro，Anthropic API 兼容）。这些 frontier model 更新加剧了 "scaffold vs model" 的张力——[[little-coder]] 证明 scaffold 对小模型很重要，但 frontier 继续拉大绝对差距。

## 跟进 2026-04-24 PM: 增长完全停滞 + 生态对比

⭐613。48h 几乎零增长。Mercury 已从「爆发新星」进入「存量维护」阶段。

**生态对比（2026-04-24）：**
- Mercury (613★) vs [[auto-memory]] (170★) vs [[cavemem]] (134★) — 三个项目分别代表 soul-driven agent / session recall / cross-agent memory 三个方向
- 都在 1 周内出现，说明 agent memory/identity 是当前最热赛道
- 但增长都在收敛——市场注意力正在转向 GPT-5.5 和 DeepSeek v4

**对我们的意义：** Mercury 验证了 soul-driven agent 的市场需求，但没有突破 OpenClaw 已有能力的边界。重点关注从 Mercury/cavemem 可借鉴的 pattern（progressive skill disclosure、deterministic compression、lifecycle FSM），而不是担心竞争。

## 跟进 2026-04-23 PM: v0.5.3-v0.5.4 + 增长观察

⭐556（+40 from morning）。v0.5.3-v0.5.4 是 polish releases：
- **`mercury upgrade`**: CLI 自升级命令（先停 daemon → 删旧包 → 装新版），解决 npm ENOTEMPTY rename 问题
- **CLI 格式修复**: 修重复 agent 名、统一缩进、readline prompt 简化
- 无架构变化，进入打磨期

### 增长曲线
- 04-20: 0⭐ → 04-21: 232⭐ → 04-22: 349⭐ → 04-23 AM: 516⭐ → 04-23 PM: 556⭐
- 增速从爆发期（Day 1: +232）进入稳定期（Day 3: ~+40/半天）
- 总体 3.5 天 556⭐，同期类似项目（[[swarm-forge]] 292⭐, [[auto-memory]] 138⭐）远低于此

### 生态新信号：Agent Memory 热潮
本轮侦察发现 memory 是热点：
- **[[auto-memory]]** (138⭐): 读 Copilot CLI 的 SQLite 做 session recall，zero-dep Python CLI。解决 "context window death spiral"（compact → 失忆 → 重新解释 → 再 compact）。目前仅支持 Copilot CLI，Claude Code/Cursor 计划中。
- **cavemem** (105⭐): Cross-agent persistent memory，compressed + local-first。
- **趋势**: agent memory 从 "nice-to-have" 变成 "must-have"。OpenClaw 的 memex 语义搜索是差异化优势，但 auto-memory 指出的 "context rot at 60% window" 是我们也面临的问题。

## 跟进 2026-04-25 PM: ⭐830 增长恢复

⭐830（从 757 继续回升）。平台期后恢复增长，Agent Skills 生态扩大是助力。

### 生态同期对比
- [[karpathy-llm-wiki]] (615★) — wiki > RAG 理念主流化（HN 首页），级联更新 + lint 管线值得借鉴
- Claude Code Skills 爆发：6000+★ 的 HTML 设计 skill、4000+★ 的技术图表 skill
- Agent Skills (agentskills.io) 正式成为事实标准

## 跟进 2026-04-25: ⭐757 回升 + 侦察对比

⭐757（从 613 回升）。过了平台期后小幅回升。

### 生态对比：「行为标准之争」

本轮侦察发现 agent 生态正从「框架之争」转向「行为标准之争」：
- **agents-md** (504⭐) — 反 sycophancy AGENTS.md drop-in，融合 Karpathy 四原则
- **agent-skills-standard** (436⭐) — Agent Skills 标准化最佳实践
- **agent-style** (316⭐) — 21 条 Claude Code 写作规则
- Skill/AGENTS.md 正在成为新 "dotfiles" 文化

### Mercury 在这个趋势中的位置

Mercury 的 soul 4 文件模板是这个趋势的**早期实现者**——把 agent 行为规范文件化。但它的模板化方式（`{name}/{owner}` 变量替换）不如我们的自进化活文档灵活。

### 新架构发现（深读补充）

**Second Brain v1.0.0 完整架构：**
- 自动提取：每次对话后 background LLM 调用（~800 tokens），提取 0-3 个 memory candidates
- 合并策略：≥74% overlap → 合并（strengthens evidence_count）
- 冲突解决：极性冲突按 confidence/recency 解决
- 分层：identity/preference → durable，goal/project → active，强化 3+ 次 → promote
- 生命周期：active inferred 21 天未见 → dismissed，durable inferred 120 天低 confidence → dismissed
- 检索：FTS5 + 自定义 scoring（confidence × importance × recency），每次注入 top 5（~900 chars）
- **完整 vitest 测试覆盖**

**对比我们的 memex：** Mercury 在结构化管理上更强（自动提取 + 冲突解决 + 生命周期），memex 在搜索质量上更强（embedding 语义 vs FTS5 关键词）。**最佳组合：memex 语义搜索 + Mercury 式自动提取和生命周期管理。**

**Loop Detection 完整实现：**
- Tool call loop: 相同调用 3 次中断
- Failure loop: 失败 4 次中断
- Reasoning loop: 空转思考 5 步中断
- Total cap: 25 次调用硬限

### 可借鉴（更新）
- [ ] Memory 自动 fact extraction（background LLM ~800 tokens/次）
- [ ] Memory 生命周期 stale/promote/prune
- [ ] Memory 冲突解决（极性检测 + confidence-based resolution）
- [ ] Reasoning loop detection（补充 tool call loop detection）

## 跟进 2026-04-22 PM: 架构深入 + 代码阅读

⭐349。

### Lifecycle FSM (core/lifecycle.ts)
新发现——Mercury 有显式状态机：`unborn → birthing → onboarding → idle ⇄ thinking ⇄ responding`，`idle ⇄ sleeping`。用 `VALID_TRANSITIONS` 数组验证每次状态迁移。
- **对比 OpenClaw**: OpenClaw 没有显式 lifecycle FSM，状态是隐式的（session 状态 + heartbeat 状态）。Mercury 的 FSM 更易调试和推理。
- **可借鉴**: 显式状态机 pattern 对 long-running agent 有价值——可以防止非法状态转换（如 sleeping 时不应处理消息）。

### Soul Identity Template System
`soul/identity.ts` 用 `{name}` / `{owner}` 模板变量替换默认 soul 文本。4 个文件（soul, persona, taste, heartbeat）各有 fallback 默认值。
- 设计选择：新用户 zero-config 就有可用人格（默认值），而不是空白开始。OpenClaw 需要用户写 SOUL.md。
- **评价**: 对新手更友好，但模板化的 soul 缺乏个性。我们的方式（用户/agent 自己写 SOUL.md）更灵活。

### OmniAgent / Orb 对比
- **OmniAgent** (273★): 最近只有 index.html 更新（04-19），无实质代码变化。项目可能在做 landing page 而非 core 开发。降低关注优先级。
- **Orb** (52★): 04-20 docs 全面重写，转向 CC CLI native 架构。增长缓慢但方向清晰（self-evolving + Claude Code wrapper）。
