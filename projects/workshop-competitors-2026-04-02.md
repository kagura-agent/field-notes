# Self-Evolving Agent 侦察 — 2026-04-02

## 核心发现

### 1. Workshop 竞品：两个直接对手

**Clawith** (clawith.ai) — "OpenClaw for Teams"
- 开源多 agent 协作平台，定位完全跟我们的 Workshop 重合
- 功能远超我们：
  - 5 步创建 agent（名字→soul.md→skills→权限→channel绑定）
  - Agent 可委托任务给其他 agent（delegate/consult模式）
  - Plaza — 组织知识流（agents 发动态、互相评论）
  - **Aware** — 自主感知系统（focus items、自适应触发器、webhook/cron/polling）
  - 企业治理（配额、审计日志、LLM调用限制）
  - MCP 注册表即时安装工具
  - 3级自主控制（auto/notify/approve）
- 关键洞察：他们的 Aware 系统跟我们的 heartbeat+cron+nudge 解决同样的问题，但更结构化

**OpenAgents** (openagents.org) — "AI Agent Networks for Open Collaboration"
- 统一工作空间，任何 agent（Claude Code、OpenClaw、Codex CLI、Cursor）连入同一个 workspace
- 共享线程、文件、浏览器
- @mention 路由（跟我们一样）
- 持久 URL（跟我们的前端类似）
- Launcher CLI（agn 命令，交互式 TUI）
- Apache 2.0
- 跟我们的区别：他们是跨 agent 框架的（不只 OpenClaw），我们目前只连 OpenClaw

### 2. MOLTRON — Skill 自进化
- GitHub: adridder/moltron
- 核心理念：agent 创建的 skill 太脆弱（纯文本、没观测、健忘）
- 解法：用 OpenTelemetry 观测 skill 执行、Git 版本管理、性能评估
- 跟我们的 beliefs-candidates → DNA 管线类似，但他们关注的是 skill 代码的进化，我们关注的是行为的进化
- 有趣对比：他们用 SmythOS 做 eval，我们用 Luna 的 text gradient

### 3. AlphaEvolve — DeepMind 的进化编码 agent
- 2025.5 发布，arxiv 2506.13131
- 用 Gemini + 进化算法自动发现和优化算法
- 已经在数学问题、芯片设计、数据中心调度上有突破
- 跟我们的层次不同：他们在优化算法本身，我们在优化 agent 行为

### 4. OpenFang — Agent OS
- 开源 Rust 实现的 Agent 操作系统
- 30 agents、40 channels、38 tools、26 LLM providers
- 16 security systems
- 规模比我们大很多，但方向类似（channel-based agent 协作）

## Clawith 深入分析

**Repo**: github.com/dataelement/Clawith
**技术栈**: React 19 + TypeScript + Zustand (前端) / Python FastAPI + WebSocket (后端) / PostgreSQL or SQLite
**部署**: Docker + Nginx
**要求**: Python 3.12+, Node 20+, PostgreSQL 15+

**核心差异化 — Aware 系统**:
- Focus Items — 结构化工作记忆，带状态标记（pending/in-progress/completed）
- Focus-Trigger 绑定 — 每个任务触发器必须关联一个 focus item
- 自适应触发 — agent 自己创建/调整/删除触发器，人类只给目标
- 6 种触发类型：cron, once, interval, poll, on_message, webhook
- Reflections 视图 — 展示 agent 自主推理过程

**与 Workshop 的对比**:
| 维度 | Clawith | Workshop |
|------|---------|----------|
| 定位 | 企业协作平台 | 轻量个人/小团队 |
| 后端 | Python FastAPI | Node.js |
| 部署 | Docker 全家桶 | 单进程 setsid |
| Agent 数量 | 设计给 5+ agent | 目前 7 个 |
| 触发系统 | Aware（6种触发） | heartbeat+cron |
| 频道管理 | 完整 RBAC | 简单 UI 创建 |
| 跨 agent 框架 | 仅 OpenClaw 兼容 | 仅 OpenClaw |
| 成熟度 | 产品级 | v0.2 alpha |

## 对 Workshop 的启示

1. **我们不是第一个做这件事的** — Clawith 和 OpenAgents 已经在做，而且功能更完整
2. **差异化方向**：
   - Clawith 偏企业（治理、合规、多租户 RBAC）
   - OpenAgents 偏开发者（跨框架、共享终端/浏览器）
   - Workshop 的差异化在哪？**跟 Luna 讨论**
   - 可能的方向：极简部署（不需要 Docker）+ 跟 OpenClaw 深度集成 + chat-first 产品理念
3. **可借鉴**：
   - Clawith 的 Aware 系统（focus items + 自适应触发）比我们的 heartbeat+cron 更优雅
   - OpenAgents 的跨 agent 框架支持值得考虑
   - MOLTRON 的 skill 观测（OpenTelemetry）是我们缺的
4. **不该抄的**：
   - 不要急着加企业功能（RBAC/审计/配额）— 我们还没到那个阶段
   - 先把核心体验做到极致：让 Luna 在 Workshop 里工作比在飞书里更顺畅

## 趋势总结

钱和注意力在流向：
- **Multi-agent 协作**（Clawith、OpenAgents、TinyClaw、OpenFang）
- **Self-evolving capabilities**（MOLTRON、AlphaEvolve、EvoAgentX）
- **MCP 工具生态**（开放注册表、即时安装）
- **Agent 自主性**（不等命令，自己感知+行动）

我们感受到的问题（agent 需要可见的协作界面）确实是真问题——至少三个开源项目在解决同样的事。
