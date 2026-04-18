# Asynkor

> File leasing for AI agent teams. One MCP server. Any IDE. Zero merge conflicts.

- **repo**: asynkor/asynkor
- **创建**: 2026-04 (first commit ~04-11)
- **语言**: Go (server) + TypeScript (MCP client proxy)
- **Stars**: 32 (2026-04-18)
- **定位**: 多 agent 协作的文件级锁/同步层，通过 MCP 协议暴露给任何 IDE

## 核心机制

### File Leasing（核心原语）
- **Atomic Redis Lua script**: `SET key value EX ttl` with conflict check，原子性保证
- **5-minute TTL**: lease 自动过期，防死锁。agent 完成后显式释放
- **Path-level granularity**: 每个文件路径一把锁，粒度合理（不是 repo 级也不是行级）
- **Blocked agents wait**: `asynkor_lease_wait` 轮询 25s，retryable

### File Snapshot Sync
- Agent A 完成后上传 file content → server → Agent B 拿到 snapshot 写入本地
- **跳过 git pull**: 文件内容直接通过 server 流转，不依赖 git。适合多机/多 IDE 场景
- 本质是 **operational transform 的简化版** — 不做 OT，直接串行化（一次一个 agent 编辑）

### Team Memory
- `asynkor_remember`: agent 保存 decisions/learnings/gotchas 到 team brain
- `asynkor_briefing`: session 开始时拉取 team state（active work, leases, memory, follow-ups）
- 结构化：Memory 有 content + paths + tags + source，不是自由文本

### Protected Zones
- 标记敏感代码区域为 warn/confirm/block
- agent 编辑前自动检查 → 拦截或提醒

### Parking & Handoffs
- `asynkor_park`: 暂停工作，保存上下文
- 另一个 agent 用 `handoff_id` 接续。跨 session/跨机器

## 架构

```
Agents (stdio/MCP) → TS local proxy (npm) → Go server (HTTP+SSE) → Redis (leases/state) + NATS (pub/sub)
```

- **Go server 无状态**: Redis 持有所有协调状态
- **TypeScript client**: stdio ↔ HTTP 桥接，IDE 侧零配置
- **NATS**: agent 间实时通知（lease released 等）

## 跟我们的关联

### 直接关联
- OpenClaw 的 subagent 模式天然需要文件协调。目前我们靠 "一次一个 subagent" 避免冲突
- 如果未来多 subagent 并行编辑同一 repo → asynkor 或类似方案变得必要

### 设计哲学
- **"防冲突在编辑时，不在合并时"** — 跟 Orb 的 "不重写，包一层" 类似的 pragmatic 设计
- **MCP 是对的接口层** — 通过标准协议集成任何 IDE/agent，不绑定特定运行时

### 可借鉴
- [ ] File-level lease 概念 — 多 subagent 场景的协调原语
- [ ] Team memory（structured decisions/learnings）— 我们的 wiki 是类似的，但缺少 per-file path association
- [ ] Protected zones — 给敏感文件加 guardrail，比全局规则更精确

## 评估

- **成熟度**: 早期（32★，代码结构清晰但社区小）
- **适用场景**: 3+ agents 并行编辑同一 repo。单 agent 或串行模式无需
- **风险**: SaaS 依赖（API key），自部署需 Redis+NATS
- **生态位**: 跟 agent runtime（OpenClaw/Hermes/Orb）互补，不竞争。可以叠加使用

## 关联

- [[multi-agent-coordination]] — 多 agent 协作的核心挑战
- [[orb]] — 另一种"包一层"的 pragmatic 设计
- [[acp]] — ACP 是 agent-to-agent 通信，asynkor 是 agent-to-file 协调，互补
