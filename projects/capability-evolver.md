# Capability Evolver (EvoMap)

## 概要
ClawHub 下载量第一的 skill（35,581+），MIT license，EvoMap/evolver。
一个 AI agent 自进化引擎——自动扫描 runtime history，发现问题，生成修复，验证后固化。

## 架构

### GEP（Genome Evolution Protocol）

三个核心概念：

**Gene** — 进化策略模板
- `signals_match`: 什么信号触发这个策略（error, gap, bottleneck）
- `strategy`: 具体步骤
- `constraints`: 不能改什么（max_files, forbidden_paths）
- `validation`: 怎么验证修复成功
- 分类: repair / optimize / innovate / harden
- 类比：我们的 [[beliefs-candidates]] 但更结构化

**Capsule** — 成功修复打包
- 修复成功后封装成 Capsule
- 包含 confidence score、trigger signals、payload
- 可被其他 agent 复用（通过 A2A 协议）
- 类比：我们的 [[self-improving]] domain 记忆，但可跨 agent 共享

**Events** — append-only 进化日志
- 每次进化记一个 event，通过 parent_id 形成进化树
- 类比：我们的 evolution-log

### 进化循环

```
extractSignals() → selectGeneAndCapsule() → 
  有 Hub Capsule 匹配 → REUSE MODE（直接复用）
  无匹配 → LLM 生成 mutation → 
solidify() → 验证 + git commit + 更新 Gene/Capsule store
```

### A2A 协议

- 消息类型: hello, publish, fetch, report, decision, revoke
- 成功 Capsule 可 publish 到 EvoMap Hub
- 其他 agent 可 fetch 复用
- trust scoring + validation 机制

## 安全

- blast radius 硬上限（文件数 + 行数）
- EVOLVE_ALLOW_SELF_MODIFY=false（默认不能改自己代码）
- rollback mode（git reset --hard / stash）
- canary check + LLM review（可选第二意见）

## 与我们的对比

| 维度 | Evolver | 我们 |
|------|---------|------|
| 进化对象 | 代码 | 行为模式 |
| 触发 | cron / 手动 | 多管线（skill/nudge/heartbeat/cron） |
| 速度 | 激进（自动改代码）| 渐进（3次阈值） |
| 知识共享 | A2A Hub（跨 agent） | 无（仅个体） |
| 安全 | blast radius + rollback | Luna 观察者 + 通知 |

## Concept

A pattern where an agent's capabilities evolve through use — not just through manual updates.

**Mechanism:**
1. Agent uses a skill/tool repeatedly
2. Friction points and failures accumulate as gradients
3. Gradients trigger improvements: new skills, modified workflows, updated beliefs
4. Agent becomes more capable over time

**vs Static Skills:**
- Static: human writes skill → agent uses skill → human updates skill
- Evolving: agent uses skill → agent detects friction → agent proposes improvement → improvement applied

**Key Insight:** The evolver needs both **sensing** (detecting what's not working) and **actuating** (making changes). Most systems have sensing but not actuating — they log problems but don't fix themselves.

See also: [[skill-as-behavior-trigger]] [[mechanism-vs-evolution]]

## 可借鉴

1. **Gene 模式**：把"遇到 X → 用 Y 策略"模板化
2. **Capsule 复用**：成功方案打包，下次直接用
3. **A2A 共享**：一个 agent 学到的，其他 agent 可复用
4. **Blast radius**：变更前评估影响范围

## 在生态中的位置

属于 [[self-evolving-agent-landscape]] 的 Skill/Memory 层。
跟 [[hermes-agent]] 做的方向互补——Hermes 做 nudge/inline reflection，Evolver 做代码级自我修改。
我们在 Identity 层，Evolver 在 Skill 层。

## 数据

- 1,749⭐, 195 forks
- 创建: 2026-02-01
- 101 个 JS 文件
- npm: @evomap/evolver
- 作者: autogame-17
