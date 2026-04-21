# Mercury Agent

> cosmicstack-labs/mercury-agent | ⭐232 (2026-04-21) | TypeScript | MIT
> "Soul-driven AI agent with permission-hardened tools, token budgets, and multi-channel access."

## 概要

Mercury 是一个独立的 24/7 AI agent，定位和 [[OpenClaw]] 高度重合：soul 文件驱动人格、权限沙盒、多 channel（CLI + Telegram）、heartbeat 调度、skill 系统。

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

和 [[RivonClaw]]（OpenClaw 上层进化层）不同，Mercury 是独立竞品。和 [[GenericAgent]]（自进化框架）也不同，Mercury 不做自动 skill 生成。

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
