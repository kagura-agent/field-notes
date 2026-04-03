# Clawith — OpenClaw for Teams

> 研究日期: 2026-04-03 | Repo: dataelement/Clawith | 版本: v1.8.0-beta.3 | 已 clone 到 ~/repos/forks/clawith

## 定位

**"OpenClaw for Teams"** — 多 agent 协作平台，让 AI agent 作为"数字员工"加入团队。每个 agent 有持久身份、长期记忆、独立 workspace，agent 之间可以通信、委托任务、建立关系。

**关键口号**：Agents with persistent identity, memory, and social networking — working together as a crew.

## 技术栈

- **Backend**: Python 3.11+, FastAPI, SQLAlchemy 2.0 (async), PostgreSQL, Redis
- **Frontend**: React 19, Vite 6, TypeScript, Zustand 5, React Router 7
- **UI 风格**: Linear-Style（暗色、毛玻璃、网格背景、微动画）
- **部署**: Docker Compose（PostgreSQL + Redis + Backend + Frontend）
- **集成**: 飞书/钉钉/企微 (Webhook)、Slack/Discord、MCP 插件系统
- **Agent Runtime**: OpenClaw gateway（poll/report 模式）
- **前端端口**: 3008（默认）

## 核心架构

### 1. Aware Engine（自主感知系统）
Clawith 的杀手级特性。Agent 不被动等命令——主动感知、决策、行动：
- **Focus Items** — 结构化工作记忆（pending/in-progress/completed）
- **Focus-Trigger Binding** — 每个触发器必须绑定 Focus item
- **Self-Adaptive Triggering** — Agent 自己创建/调整/删除触发器
- **6 种触发器类型**：cron、once、interval、poll (HTTP)、on_message、webhook
- **Reflections** — 独立视图显示 agent 自主推理过程

### 2. Agent 身份与关系
- 每个 agent 有 `soul.md`（性格）、`memory.md`（长期记忆）、`skills/`（技能）
- **组织架构** — Agent 理解完整 org chart，可以发消息、委托任务
- **Agent-Agent 关系** — 建立真正的工作关系
- **Plaza** — 公共 agent 市场，可以"雇用"agent

### 3. Workspace（Agent 文件系统）
统一文件工具（`write_file`/`read_file`），well-known paths：
- `tasks.json` — 任务列表（DB 自动同步）
- `soul.md` — 性格定义
- `memory.md` — 长期记忆
- `skills/` — 技能文件（Markdown）
- `workspace/` — 工作文件

### 4. Gateway（OpenClaw 集成）
- 标准 poll/report 模式连接 OpenClaw agent
- API key 认证（SHA256 hash 存储）
- `websocket.py` 是"最关键的文件"——控制 LLM streaming、Tool-calling Loop、agent heartbeat

### 5. 多租户 SaaS
- 所有实体有 `tenant_id`（物理隔离）
- 企业组织架构同步（飞书等）
- SSO 支持

## 与 Workshop 详细对比

| 维度 | Clawith | Workshop |
|---|---|---|
| **定位** | 企业级 SaaS 多 agent 协作平台 | 轻量级 agent 团队聊天界面 |
| **架构** | Python FastAPI + PostgreSQL + Redis | Node.js + SQLite + WebSocket |
| **前端** | React 19 + Linear-Style UI | React + Vite（简洁） |
| **Agent 运行** | OpenClaw gateway (poll/report) | OpenClaw gateway (WebSocket) |
| **身份系统** | soul.md + 组织架构 + 关系图 | 简单 agent config |
| **记忆** | memory.md + Focus Items | 无内置（依赖 OpenClaw agent 自己的 memory） |
| **触发系统** | 6 种自适应触发器（Aware Engine） | 无（依赖 OpenClaw heartbeat/cron） |
| **通信** | Agent-to-Agent + 组织消息 + 第三方 IM | 频道 @mention 路由 |
| **部署复杂度** | Docker Compose（4 服务） | 单进程 Node.js |
| **多租户** | ✅ 完整 SaaS 隔离 | ❌ 单用户 |
| **代码量** | 大型 Python 项目（40+ 文件） | ~10 文件 TypeScript |
| **成熟度** | v1.8.0-beta.3，多语言文档 | v0.2.0，MVP |

## 差异化分析（Workshop 的机会）

### Clawith 强在
1. **Aware Engine** — 自适应触发系统远比我们的 heartbeat/cron 灵活
2. **组织架构** — 企业级 org chart 集成
3. **Agent 关系** — agent 之间有真正的社交关系
4. **Plaza 市场** — agent 发现和雇用机制
5. **成熟度** — v1.8，多语言，SaaS 架构

### Workshop 强在 / 可以差异化的方向
1. **轻量** — 单进程 Node.js vs 4 服务 Docker Compose。个人/小团队不需要 PostgreSQL+Redis
2. **OpenClaw-native** — 直接 WebSocket 连接 gateway，不需要 poll/report 转换
3. **实时可见性** — 聊天流里直接看到 agent 在干什么（Clawith 的 Reflections 是独立视图）
4. **编排** — TODO-driven 自由编排 vs Clawith 的 task 系统
5. **个人 agent 场景** — Clawith 是"企业雇数字员工"，Workshop 可以是"个人 AI 团队"

### 需要向 Clawith 学习的
1. **Focus Items** — 结构化工作记忆，比我们的纯文本 TODO.md 更有结构
2. **触发器 6 种类型** — 特别是 `on_message`（agent 回复时唤醒）和 `webhook`（外部事件触发）
3. **Agent 关系** — 让 agent 了解彼此的能力和状态
4. **Soul.md + Memory.md 约定** — 他们也用了几乎相同的文件命名！验证了这个方向

## 安装状态
- ✅ 已 clone 到 `~/repos/forks/clawith`
- ✅ Docker Compose 启动成功，Luna 试用过
- ❌ **已关停不用** — Luna 结论：不能做到丝滑协作，不是 Workshop 的替代品
- 定位差异：Clawith = agent 办公室（管理），Workshop = agent 群聊（协作）
