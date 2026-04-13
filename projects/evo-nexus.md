# evo-nexus

> EvolutionAPI/evo-nexus | 227⭐ | Python+React | 2026-04-08
> "The open source operating system for AI-powered businesses — built on Claude Code"

## 核心定位

多 agent 运营层，把 Claude Code CLI 变成一个 38 agent 团队。目标用户：独立创始人/CEO。

## 架构

### Agent 层
- 38 个专业 agent = 17 业务 + 21 工程
- 业务：Ops/Finance/Community/Marketing/HR/Legal/Product/Data/Learning/Sales/Strategy/Personal/Knowledge/CS/Courses
- 工程：19 个来自 oh-my-claudecode (Yeachan Heo) + 2 自有（Helm 指挥 + Mirror 回顾）
- 每个 agent = `.claude/agents/xxx.md` 文件（纯 markdown，无代码）
- Slash commands: `/clawdia`, `/flux`, `/pulse`, `/apex`

### Routine 层 (ADWs = Automated Daily Workflows)
- Python runner (`ADWs/runner.py`) 调 Claude Code CLI `--print` + `--json`
- 每个 routine 一个 .py，调 `run_skill()` 传 skill name + agent name
- 调度：make scheduler（Python cron），daily/weekly/monthly 三层
- 核心 7 个 + 用户自定义（custom-* gitignored）
- 日程示例：07:00 morning briefing → 18:00 social → 19:00 finance → 21:00 EOD → 21:15 memory sync → 21:30 dashboard
- **JSONL 日志 + metrics.json 成本追踪**（每 routine 累计 tokens/cost/success rate）
- Telegram 通知完成/失败

### Memory 层
- 二层：`CLAUDE.md`（热缓存 ~100 行）+ `memory/`（完整知识库）
- `memory/index.md`（自动分类目录）+ `log.md`（追加时间线）+ `glossary.md`（术语表）+ `people/` + `projects/` + `context/` + `trends/`
- 核心用途：**内部语言解码** — "ask todd about the PSR for phoenix" → 全称+上下文
- Memory lint: 周日自动检查一致性
- Memory sync: 每日自动将当日上下文整理归档
- 可选 [[MemPalace]] 接入（ChromaDB 本地向量搜索）

### Dashboard 层
- React + Flask，Docker 部署
- 功能：agent 管理、routine 调度、成本追踪、集成配置、provider 切换、web terminal
- 19 个集成（Google Calendar/Gmail/GitHub/Linear/Discord/Telegram/Stripe 等）
- Auth + roles

### Skill 层
- 175+ skills，markdown 文件，按域前缀组织
- 前缀：social-/fin-/int-/prod-/mkt-/gog-/obs-/discord-/pulse-/sage-/hr-/legal-/ops-/cs-/data-/pm-
- 兼容 OpenClaw SKILL.md 格式
- create-agent / create-routine / create-command 三个 meta-skill

## 多 provider 支持
- 默认 Anthropic claude CLI
- 通过 OpenClaude (npm 包) 支持 OpenRouter/OpenAI/Gemini/Bedrock/Vertex/Codex Auth
- Dashboard 可热切换 provider（写 config/providers.json，无需重启）

## 跟 Workshop 对比

| 维度 | evo-nexus | Workshop (kagura) |
|------|-----------|-------------------|
| 目标用户 | CEO/创始人 | 同（One Person Company）|
| Agent 管理 | .md 文件, 38 预设 | WebSocket CRUD, 按需 |
| Routine/Cron | Python runner + make | Channel cron + FlowForge |
| 内存层 | CLAUDE.md + memory/ | AGENTS.md + memory/ + wiki/ |
| Dashboard | React + Flask (完整) | React + Express (v0.3.0) |
| 集成 | 19 个（社交/支付/ERP/CRM） | Discord/飞书（少） |
| Skill | 175+ | ~15（精但少） |
| 自进化 | ❌ 无 | ✅ beliefs-candidates → DNA |
| 可观测性 | JSONL + metrics.json + cost | memory/ 日志 |
| Multi-provider | ✅ via OpenClaude | ❌ (Copilot API) |
| 成熟度 | 更完整（dashboard/集成/routine） | 更有深度（自进化/skill 生态/学习） |

## 洞察

1. **量 vs 深度的路线分歧**：evo-nexus 走"38 agent + 175 skill + 19 集成"的广度路线，我们走"自进化 + 学习 + 深度 skill"路线。两个方向都有市场，但解决不同问题
2. **routine runner 设计值得借鉴**：metrics.json 按 routine 追踪 tokens/cost/success rate，这是我们缺的可观测性维度
3. **内部语言解码是 killer feature**：他们把"memory"用在了最实际的地方——让 agent 理解公司内部术语/人名/缩写。比我们的"记住发生了什么"更有即时价值
4. **OpenClaude multi-provider 有参考价值**：dashboard 热切换 AI provider，无需重启
5. **skill 生态相似但方向不同**：他们的 175 skill 偏业务操作（财务报表/社区监控/法务），我们的偏 agent 自我管理（FlowForge/pulse-todo/skill-creator）
6. **对我们不构成直接竞争**：虽然目标用户都是"一人公司"，但 evo-nexus 是"给 CEO 一个运营团队"，我们是"给 agent 一个成长系统"。如果要竞争，是在 Workshop 层面——谁能做出更好的 agent 编排 dashboard

## 可借鉴

- [ ] Routine metrics tracking（tokens/cost/success rate per cron job）→ 可加到 FlowForge 或 cron 系统
- [ ] 内部语言解码模式（glossary.md + hot cache）→ 我们的 MEMORY.md 可以加一个"术语表"区
- [ ] Dashboard provider 热切换
- [ ] Memory lint + memory sync 作为 routine（他们 weekly lint + daily sync）

## 不借鉴

- 38 agent 预设太多，运营开销大，我们保持精简
- Python runner 包装 Claude CLI 是 workaround，不如 OpenClaw gateway 原生调度
- 175 skill 多数是业务模板，不符合我们"agent 自主进化"方向
