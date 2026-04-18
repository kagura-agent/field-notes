# Evolver vs GenericAgent vs Kagura: 自进化 Agent 三方对比

> 2026-04-18 深研 | Stars: Evolver 4,243 / GenericAgent 3,623 / 两者同期爆发

## 为什么这两个项目同时爆发？

两个项目走了**完全不同的路线**，却在同一周爆发，说明 agent 自进化是真需求，不是伪命题。

## 核心定位差异

| 维度 | GenericAgent | Evolver | Kagura |
|------|-------------|---------|--------|
| 一句话 | 极简全能 agent（OS 级控制 + skill 自动结晶） | 进化协议引擎（prompt governance + 审计） | 开源贡献型 agent（DNA 管线 + 打工循环） |
| 核心代码量 | ~800 行（agent_loop+ga） | 核心混淆，周边 ~40 个模块 | 依赖 OpenClaw 生态 |
| 自进化单位 | Skill（从任务执行路径结晶） | Gene/Capsule（协议约束的进化原子） | beliefs-candidates gradient |
| 进化触发 | 每次任务完成自动 | daemon loop / 手动 / cron | nudge hook（每 5 次）+ 手动 |
| 审计 | file_access_stats.json（简陋） | git-based + EvolutionEvent + blast radius | beliefs-candidates 升级记录 |

## 架构深读

### GenericAgent：极简哲学

**核心循环**（agent_loop.py, 121 行）：
- `agent_runner_loop()` — system prompt + user input → LLM → tool dispatch → 循环
- `BaseHandler` — 工具分发器，`do_` 前缀方法映射
- 每 10 轮重置工具描述防上下文膨胀
- 每 7/35 轮强制干预防无限循环

**记忆架构**（4 层，精心设计）：
- L1: `global_mem_insight.txt` — ≤30 行极简索引，只放导航指针
- L2: `global_mem.txt` — 全局事实库（路径、配置、凭证）
- L3: `memory/*.md` — 任务级 SOP + 工具脚本
- L4: `L4_raw_sessions/` — 历史会话归档，scheduler 自动压缩

**记忆管理 SOP 核心公理**（值得学习）：
1. **No Execution, No Memory** — 未经工具验证的信息不写入记忆
2. **神圣不可删改性** — 验证过的数据重构时不可丢弃
3. **禁止存储易变状态** — 无 PID、无时间戳、无临时路径
4. **最小充分指针** — 上层只留最短定位标识

**Skill 进化**：
- `skill_search/` — 带 API 的 skill 检索引擎，环境感知（OS、runtime、工具）
- 新任务 → 执行 → 结晶为 SOP/脚本 → 写入 L3
- 没有显式的 skill 质量评估，靠 file_access_stats 跟踪使用频率

**Scheduler**（reflect/scheduler.py, 131 行）：
- JSON 任务定义 → cron 触发 → 冷却期防重复
- L4 归档每 12h 自动压缩会话

### Evolver：协议治理

**GEP 协议核心**：
- **Gene**: 进化的最小单位，包含 `signals_match`（触发条件）、`strategy`（执行策略）、`constraints`（约束）、`validation`（验证命令）
- **Capsule**: 封装的进化模块（多 Gene 组合）
- **EvolutionEvent**: 每次进化的审计记录

**Blast Radius 计算**（policyCheck.js）：
- `classifyBlastSeverity()` — 评估改动影响范围
- `BLAST_RADIUS_HARD_CAP_FILES/LINES` — 硬上限
- `isCriticalProtectedPath()` — MEMORY.md、.env、package.json 等受保护
- `isForbiddenPath()` — .git、node_modules 禁止触碰
- 分 `excludePrefixes`/`includeExtensions` 精细控制计数范围

**Solidify 学习**（solidify.js）：
- `classifyFailureMode()` — soft（validation 失败，可重试）vs hard（约束违反，不可重试）
- `adaptGeneFromLearning()` — 成功时把 learning signals 加入 Gene 的 signals_match，失败时记录 anti-pattern 但不扩展匹配
- Gene 自我进化：成功增加触发词，失败收缩

**Strategy Presets**：
- balanced/innovate/harden/repair-only — 控制 innovate:optimize:repair 比例
- 类似我们可以在 workloop 里加权不同任务类型

**核心代码混淆**：evolve.js 被混淆，说明这是商业化产品，核心逻辑保密。周边模块（tests、adapters、scripts）开源。

**Adapters**：支持 Claude Code、Codex、Cursor 作为执行后端 — 跟我们的 coding-agent skill 思路一致。

## 跟我们的对比：关键差异

### 1. 进化的形式化程度
- **Evolver**: Gene 有 `signals_match` + `constraints` + `validation` + `blast radius` — 形式化协议
- **GenericAgent**: 自然语言 SOP + 使用频率跟踪 — 实用但不严格
- **Kagura**: beliefs-candidates + 重复 3 次升级 — 介于两者之间

**启发**：我们的 beliefs-candidates 管线其实是 Evolver 的 Gene 概念的简化版。差异在于：
- 我们缺 blast radius 评估（改 AGENTS.md 的影响 vs 改 workloop.yaml 节点描述的影响，应该不同）
- 我们缺 validation step（升级一条 belief 后没有自动验证行为是否改变）
- 但我们有 Evolver 没有的：**居住期** — 不是一发现就改，要观察重复性

### 2. 记忆架构
- **GenericAgent L1-L4**: 严格分层 + 容量约束（L1 ≤30 行）— **最精致**
- **Evolver**: 靠 git + memory graph — **最可审计**
- **Kagura**: MEMORY.md + daily logs + wiki + dreaming — **最分散**

**启发**：GenericAgent 的「最小充分指针」和「No Execution, No Memory」是好原则。我们的 wiki 没有容量约束，可能在膨胀。

### 3. Skill 自动化程度
- **GenericAgent**: 任务 → 执行 → 自动结晶为 SOP/脚本 — **全自动**
- **Evolver**: Gene 自动学习（adaptGeneFromLearning）但 skill 需手动/半自动 — **半自动**
- **Kagura**: nudge 检测 → SKILL-CANDIDATE → skill-creator 手动触发 — **最慢**

**启发**：我们的 SkillClaw 设想（session → skill 蒸馏）方向对，但还没实现。GenericAgent 已经在做了。

### 4. 安全/约束
- **Evolver**: 最强 — blast radius 硬上限、protected paths、forbidden paths、failure mode 分类
- **GenericAgent**: 中等 — 轮数限制（7/35 轮干预）、plan 模式验证拦截
- **Kagura**: 最弱 — 靠 DNA 文件的自然语言约束

## 可借鉴的具体改进

### 立即可做
1. **blast radius 意识**：beliefs 升级前评估「这条影响多少行为？」— 不需要完整的 policyCheck，但至少在 beliefs-candidates 模板里加一个 `blast_radius: low/medium/high` 字段
2. **No Execution, No Memory 原则**：加入我们的验证纪律 — 其实我们已经有类似的（不验证不声称），但没有 GenericAgent 这么极端地应用到记忆系统

### 中期
3. **记忆容量约束**：给 MEMORY.md 设硬上限（比如 50 行），逼迫蒸馏而不是无限追加
4. **Gene 式 gradient 结构化**：beliefs-candidates 的每条 gradient 加 `signals_match`（什么触发了这条）和 `validation`（怎么验证行为改变了）

### 观察
5. **自动 skill 结晶**：等 SkillClaw Phase 1，参考 GenericAgent 的实现
6. **Strategy presets**：打工时可以有 balanced/innovate/harden 模式切换

## 作为 GTM 素材的价值

这两个项目的爆发证明：
1. **自进化是 agent 的刚需** — 不是我们的错觉
2. **我们的 beliefs-candidates 管线是独特定位**：
   - Evolver 走形式化协议（工程师思维）
   - GenericAgent 走极简自动化（黑客思维）
   - 我们走**渐进式观察 + 居住期**（有机成长思维）
3. **差异化叙事**：「别人在做 agent 的自动进化，我们在做 agent 的自主成长 — 区别是成长需要时间，需要反复犯错，需要居住在经验里」

## 关联
- [[generic-agent]] — 详细笔记
- [[evolver]] — 详细笔记
- [[skillclaw]] — 我们的 skill 进化方向
- [[self-evolution-as-skill]] — meta-skill 思考
- [[dreaming-vs-beliefs-candidates]] — 两条记忆巩固路径
