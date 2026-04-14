# Claude Managed Agents

> Anthropic 官方 API 级 agent 托管服务（2026-04 发布）

## 核心能力

- **沙盒执行环境** — 隔离代码运行
- **持久 Memory Stores** — agent 跨 session 记忆
- **Tool Use** — 内置工具（bash, edit, web_search, web_fetch 等）
- **多 Agent 编排** — 多个 agent 各自独立 session + 记忆
- **Session 管理** — 创建 session、发消息、SSE 实时流式
- **Skills** — 动态加载能力（文档导航已有 Skills Overview/Quickstart/Best practices/Skills in the API）

## 文档

- 官方: `docs.anthropic.com/en/docs/agents/managed-agents`（国内需代理）
- API: `platform.claude.com/docs/en/managed-agents/quickstart`

## 生态（2026-04-14 snapshot）

| Repo | Stars | 说明 |
|---|---|---|
| CelestoAI/agentor | 165 | Python agent 框架，自称开源版但更像通用框架 |
| linear/claude-managed-agents-demo | 59 | Linear 官方集成示例 |
| vercel-labs/claude-managed-agents-starter | 13 | Vercel 官方模板 |
| 0xArx/claude-managed-agents-skill | 12 | Claude Code skill |
| rogeriochaves/open-managed-agents | 7 | **真正的 1:1 开源替代** |
| oguzbilgic/posse | 6 | Web UI 管理面板 |
| BayramAnnakov/factory-agent | 3 | Linear issue → Agent → GitHub PR |
| aiwhiteteam/harnessgate | 3 | 消息平台桥接（类 OpenClaw channel adapter） |

## Open Managed Agents 深度分析

> `rogeriochaves/open-managed-agents` — 自托管、多 LLM、1:1 API 兼容、AGPL-3.0

### 技术栈

- **Server**: Hono + zod-openapi（自动生成 OpenAPI spec）
- **Frontend**: React + Vite + Tailwind v4（暗色主题，克隆 Anthropic console UI）
- **DB**: SQLite（本地）/ Postgres（生产），dialect-aware schema
- **LLM**: Vercel AI SDK 统一抽象层
- **CLI**: `oma` 命令，Commander.js
- **部署**: Docker Compose / Helm chart / pnpm monorepo + turbo
- **测试**: 387 个测试（server 195 + web 165 + cli 24 + scenario 3）

### 架构（3 层）

**1. Engine（agent 执行引擎）** — 628 行
- `runAgentLoop()`: 经典 tool-use 循环
  - 发 LLM → 处理 tool call → 存 event → 再发 LLM
  - 最多 20 轮迭代
  - 每轮检查 DB session status → cooperative cancellation
- MCP tool routing: `__mcp__<connector>__<tool>` 前缀
- Custom tool 支持 user-in-the-loop（agent 暂停等用户提供 tool result）
- 所有操作记录为 event（model_request_start/end, agent.message, tool_use, tool_result）

**2. Provider 抽象**
- 统一 `LLMProvider.chat()` 接口 → `{content, stop_reason, usage}`
- 7 providers: Anthropic, OpenAI, Google, Mistral, Groq, OpenAI-compatible, Ollama
- Per-agent provider 选择

**3. Event Streaming — SSE**
- 所有 event 持久化到 DB + SSE 推送
- 前端两个 view: Transcript（对话）+ Debug（全部 event 含 token usage + timing）

### 企业治理层

- Org → Team → Project 三级层级
- RBAC: admin / member / viewer
- Per-team LLM provider 访问控制（RPM 限制 + 月预算 USD）
- Per-team MCP connector 策略（allow / block / require_approval）
- 全量审计日志（every mutation logged）
- Governance as Code: `governance.json` 一键加载
- AES-256-GCM 加密 credential vault
- 12 内置 MCP connectors（Slack, Notion, GitHub, Linear, Sentry, Asana, Amplitude, Intercom, Atlassian, Google Drive, PostgreSQL, Stripe）

### 功能亮点

- **Agent Builder Wizard**: 4 步引导（选模板→创建→配环境→开 session）
- **10 个预置模板**: Deep Researcher, Support Agent, Incident Commander 等
- **Session bulk archive**: 多选批量操作
- **Usage analytics**: provider/agent 维度的用量和成本统计

### 局限

- Engine 只有 628 行，**无真正沙盒执行**（web_fetch 直接 Node fetch，web_search 是 stub）
- 没有 channel/messaging 层（纯 Web UI + API + CLI）
- Skills 在 agent config 有字段但 **engine 未实现 skill loading**
- **AGPL-3.0** — 商用需开源

## 跟 OpenClaw 的对比

| 维度 | Claude Managed Agents | Open Managed Agents | OpenClaw |
|---|---|---|---|
| **定位** | Anthropic 云托管 | 企业自托管 agent 平台 | 个人 agent 运行时 + 消息桥 |
| **交互** | API + Console | Web UI + API + CLI | Channel adapters（Discord/飞书/WhatsApp） |
| **LLM** | Claude only | 7 providers | 多 provider（config 驱动） |
| **执行** | Anthropic 沙盒 | 本地 loop + SSE | 本地 session + tool execution |
| **多 agent** | 多 agent 各自 session | 同上 | 单 agent + subagent spawn |
| **Memory** | Memory Stores | 无持久记忆 | Memory plugin + MEMORY.md |
| **MCP** | 内置 | 12 connector | MCP server 支持 |
| **Skill** | 有 | 有（未实现） | AgentSkill 规范（已实现） |
| **治理** | Anthropic 管 | 完整 RBAC + 审计 | 无（个人用） |
| **消息桥** | 无 | 无 | ✅ 核心能力 |
| **License** | 商业 | AGPL-3.0 | MIT |

## 对 Workshop 的启发

1. **Session + Event 模型** — 所有操作记录为 event，前端实时渲染，Workshop 可复用
2. **Agent Builder 引导流** — 4 步 wizard 比纯配置文件友好
3. **Debug View** — 同时看对话和底层 tool call，对 agent 开发者有价值
4. **Governance as Code** — JSON 配置文件加载企业策略，Workshop 做多租户时可参考
5. **harnessgate 项目** — 消息平台桥接思路跟 OpenClaw channel adapter 重叠，值得关注

## 战略观察

- Anthropic 用 managed infra 切 agent 平台市场
- Linear、Vercel 等头部公司第一时间出集成 — 企业工作流场景是主战场
- 开源替代已经出现（open-managed-agents），说明自托管是刚需
- OpenClaw 的差异化在**消息桥 + channel adapter**层 — 这是 managed agents 生态目前没覆盖的
- Workshop 如果做成 "managed agents + messaging bridge"，定位会很独特

---

*2026-04-14 首次记录 — 来自 Luna 要求研究 Claude Managed Agents*
