# GenericAgent

> lsdefine/GenericAgent | 3,913⭐ (2026-04-18) | Python | 2026-01
> "Self-evolving agent: grows skill tree from 3.3K-line seed, achieving full system control with 6x less token consumption"

## 核心思想

极简自进化 agent 框架。~3K 行核心代码，9 个原子工具 + ~100 行 Agent Loop，给任何 LLM 系统级控制能力。

关键设计哲学：**不预载 skill，而是进化它们。** 每次解决新任务，自动把执行路径结晶为 skill 供复用。

## 架构

### 分层记忆系统
- **L0 — Meta Rules**: 基础行为规则
- **L1 — Skills**: 从任务执行中结晶的可复用技能
- **L2 — Session Context**: 当前会话上下文
- **L3 — Task Memory**: 任务级记忆
- **L4 — Session Archive**: 长期 session 归档 + scheduler cron（2026-04-11 新增）

### 9 个原子工具
浏览器控制（真实浏览器，保留 session）、终端、文件系统、键鼠输入、屏幕视觉、ADB 移动端控制

### Skill 进化流程
新任务 → 自主探索（安装依赖、写脚本、调试验证）→ 结晶执行路径为 skill → 写入记忆层 → 下次类似任务直接调用

## 跟我们的对比

| 维度 | GenericAgent | Kagura |
|------|-------------|--------|
| 核心规模 | ~3K 行 | 依赖 OpenClaw 生态 |
| Skill 来源 | 任务执行自动结晶 | 手写 SKILL.md + nudge 管线 |
| 记忆 | 4 层分层（L0-L4） | MEMORY.md + daily logs + wiki |
| 进化触发 | 每次任务自动 | nudge → beliefs-candidates 手动管线 |
| Token 效率 | 6x 省（skill 复用避免重复探索） | 未量化 |

## 最新动态 (2026-04-18 更新)

### 近期提交 (04-15~18)
- **Technical Report PDF** — 发布了完整技术报告（assets/GenericAgent_Technical_Report.pdf, ~3.2MB）。TODO: 找到可读版本后深读
- **desktop pet 右键换皮肤** — PR #99 merged
- **minimax timeout retry 修复** — PR #89 merged
- **preserve history across llm switch** — 切换 LLM 时保留对话历史，不再丢失上下文
- **publish memory_cleanup_sop** — 公开记忆清理 SOP（见下方详细分析）
- **publish ocr_utils, vision_sop, ui_detect** — 公开视觉工具链：本地 OCR + YOLO UI 元素检测 + Vision API SOP
- **thinking_type support** — 支持 extended thinking 模式
- **desktop pet v2** — 8 种皮肤 + 状态通知的桌面宠物
- **代码块检测优化** — 更精确的「恰好1个代码块+直接结尾」模式

### memory_cleanup_sop.md — 核心洞察

**ROI 模型**：L1 每词每轮付成本，收益是防犯错。ROI = (犯错概率 × 代价) / 词数成本。

**四问检验法**：
1. 删了它，犯错概率真的上升吗？→ 不上升就删
2. L3 SOP 已覆盖？→ 有就只留触发词
3. 没这词能自己想到读 SOP 吗？→ 能就删
4. 同样收益，能用更少词吗？→ 能就压缩

**对我们的启发**：
- MEMORY.md 没有容量上限会自然膨胀，L1 ≤30 行硬约束值得借鉴
- 「触发词=场景名，非工具名」— 好的记忆索引原则
- 「先交付任务再沉淀，禁未完成就写记忆」— 防止记忆污染

## 代码深读 (2026-04-18)

### agent_loop.py (121 行)
极简 agent runner：system prompt + user input → LLM chat → tool dispatch（`do_` 方法映射）→ 循环。每 10 轮重置工具描述防上下文膨胀，每 7/35 轮强制干预防无限循环。

### ga.py (558 行)
9 个原子工具的实现：code_run（Python/bash 执行器）、web_scan/web_execute_js（浏览器控制）、file_read/file_patch/file_write（文件系统）、ask_user（人类干预）、update_working_checkpoint（工作记忆）、start_long_term_update（记忆结算）。

### 记忆管理 SOP 核心公理
1. **No Execution, No Memory** — 未经工具验证的信息不写入
2. **神圣不可删改性** — 验证过的数据重构时不可丢弃
3. **禁止存储易变状态** — 无 PID、无时间戳
4. **最小充分指针** — 上层只留最短定位标识
L1 硬约束 ≤30 行，这是非常好的膨胀防护。

### scheduler.py (131 行)
JSON 任务 → cron 触发 → 冷却期防重复。L4 归档每 12h 自动压缩。

## 启发

1. **自动 skill 结晶** — 我们的 skill 创建还是手动的（skill-creator），GenericAgent 的自动结晶值得借鉴
2. **Token 效率作为核心指标** — 6x vs 我们的 17.6%，差距大
3. **极简设计** — 3K 行 vs OpenClaw 530K 行
4. **记忆 ROI 模型** — (犯错概率 × 代价) / 词数成本，比「重复3次升级」更精准，可用于 MEMORY.md 瘦身
5. **四问检验法** — 适用于 beliefs-candidates → DNA 升级决策
6. **Vision 省 token 策略** — 「能 OCR 就不 vision，能截窗口就不全屏」的分层降级

## 关联
- [[skillclaw]] — 类似的 skill 自动进化，但多 agent 共享
- [[self-evolution-as-skill]]
- [[evolver]] — 另一个 agent 进化引擎（GEP 协议）

### memory_cleanup_sop v2 → v3 存在性编码 (04-18 更新)

**范式升级**：从 ROI 四问模型进化为「存在性编码」范式。

核心洞察：**LLM 自身是压缩器+解码器。L1 只需让它意识到某类知识存在，它就能通过 tool call 自行取用深层内容。**

L1 本质 = 用最短词数表达「什么场景下有什么记忆可用」（存在性）。

L1 两类内容统一 ROI 评估：
- **存在性指针**：指向 L2/L3 知识的最短触发词
- **行为规则**：不提醒就会犯的错（致命/高频，只要 ROI 过门槛）

**压缩四原则**：
1. 命名自解释 > 加描述（改 SOP 名 ROI 常高于改 L1）
2. 存在性集合最小描述（`qq/飞书/企微操作` → `im操作:*_im_sop`）
3. 条目 = 场景↔方案存在性（括号只放反直觉触发词）
4. 分层归位（行为规则上方，纯存在性指针归 L2/L3）

**RULES 分流**：全局高 ROI → 留；特定场景/低危险 → 降级 L3 或删除。

**新增红线**：记忆修改是持久性伤害，错误每轮复利。L1 只 patch 不 overwrite。

**对我们的启发**：
- 「存在性编码」比我们当前的 dreaming promotion 更精确——dreaming 选择 *什么* 提升，但没有明确的 *怎么编码* 原则
- AGENTS.md 的各 section 可以用这个 lens 审视：哪些是存在性指针（指向 skill/workflow），哪些是行为规则
- [[context-budget-constraint]] 工作的下一步：不只是压缩字数，而是按存在性编码原则重构
- `start_long_term_update` 只在任务完成后调用（不是中途）— 我们的 memory 写入时机也需要类似约束

关联：[[context-budget-constraint]], [[dreaming-vs-beliefs-candidates]], [[agent-self-evolution-paradigms]]

## 深读：SOP 体系 (2026-04-18)

### plan_sop.md — 复杂任务规划
核心模式：规划态 → 执行态分离，禁止边想边做。
- 3步以上有依赖的任务 → 先建 `./plan_XXX/` 目录 + plan.md 骨架
- 骨架用标记系统：`[ ]` 待做、`[✓]` 完成、`[P]` 并行、`[?]` 条件分支
- **[P] 并行严格准入**：4 个条件全满足才可标（2+ 可同时、无数据依赖、产出不同文件、节省>20% 时间）
- 执行态每步必须：执行 → 标记 → 读 plan 验证 → 更新 checkpoint
- 每 3 步强制 checkpoint 验证（防标记遗漏）
- **失败传播**：依赖项标 `[SKIP]`，不继续盲目执行

**对我们的启发**：
- FlowForge 的 branch 机制类似条件分支，但缺少并行（[P]）支持
- 「禁止无条件杀 python（会杀自己）」— agent 自保意识，我们没有等价的
- checkpoint 验证频率（每 3 步）比我们的 nudge（每 5 次）更密

### subagent.md — 子 agent 协作
核心模式：文件系统作为通信协议（非消息传递）。
- 启动：`python agentmain.py --task {name} [--input "短文本"] [--bg]`
- 通信：output.txt（append, `[ROUND END]` 分隔）→ reply.txt 继续
- 干预文件：`_stop` / `_keyinfo` / `_intervene` — 运行时注入
- `--verbose` 监察模式：output 包含工具原始结果，不只是摘要
- **Map 模式**：N 个独立同构子任务并行。核心优势 = 独立上下文，防上下文交叉污染
- **context.json**：subagent 必须从 JSON 读绝对路径，禁止猜路径

**vs OpenClaw subagent**：
| 维度 | GenericAgent | OpenClaw |
|------|-------------|----------|
| 通信 | 文件系统（output.txt/reply.txt）| sessions_spawn + sessions_history |
| 干预 | _stop/_keyinfo/_intervene 文件 | subagents steer/kill |
| 并行 | Map 模式原生 | 多 spawn 手动管理 |
| 监察 | --verbose 审查原始数据 | sessions_history |
| 路径 | context.json 绝对路径 | cwd 参数 |

### insight_fixed_structure.txt — L1 模板
关键设计：L1 = 场景→SOP 映射 + RULES 红线。RULES 分两类：
1. **致命型红线**：违反导致进程终止（禁杀 python）
2. **隐蔽型红线**：违反不报错但结果错误（搜索用 google 不用百度）

**对我们的启发**：
- AGENTS.md 的规则可以按这个分类审视：哪些是致命红线，哪些是隐蔽型
- 「plan_sop」的存在性指针 → 我们的 FlowForge 也需要类似的 L1 触发词

### sys_prompt.txt — 极简 system prompt
只 4 行核心：角色定义 + thinking 推演要求 + 探测优先 + 失败升级（1→2→3 次）。
没有长篇大论的行为规则——那些在记忆层（L1/L2/L3）动态管理。

**关键洞察**：GenericAgent 把我们放在 AGENTS.md 的规则（验证纪律、讨好防范等）放在了记忆层而非 system prompt。好处是可以运行时进化，坏处是可能被遗忘。

## 综合评估 (2026-04-18)

**GenericAgent 最大的贡献不是代码，而是记忆管理范式。** 核心洞察：
1. LLM 自身是压缩器，L1 只需存在性编码，不需要 how-to
2. 记忆有成本（每轮每词），要用 ROI 模型管理
3. 4 层分层让关注点分离：导航(L1) / 事实(L2) / 技术(L3) / 历史(L4)
4. 「No Execution, No Memory」— 最好的防幻觉记忆原则

**我们可以借鉴的**（按优先级）：
1. ⭐ AGENTS.md 用存在性编码原则重构 — 规则指向 skill/workflow，不内联 how-to
2. ⭐ MEMORY.md 加容量上限（参考 L1 ≤30 行），用四问检验法决定去留
3. memory 写入时机约束 — 任务完成后才写，不是中途
4. 失败升级模式（1→2→3 次）— 比我们的「3 次重复升级」更有操作性
5. Plan mode 的并行准入条件 — FlowForge 可借鉴

## Technical Report 深读 (2026-04-18)

✅ PDF 下载成功（3.2MB, 23 页）。核心内容：

### 核心论点：Context Information Density Maximization

整篇论文围绕一个原则：**agent 性能不取决于 context 长度，而取决于有限 context 里决策相关信息的密度。**

三角约束：
- **Completeness**：当前决策所需信息必须全部在 context 里
- **Conciseness**：无关/冗余信息必须剔除
- **Naturalness**：次要约束，编码方式要让 LLM 能理解

Completeness 和 Conciseness 之间的张力是结构性的，不只是 budget 问题。即使 context window 无限大，注意力稀释仍会降低推理质量。

### 四大机制

1. **Minimal Atomic Toolset** — 9 个原子工具覆盖所有能力。code_run 单独就是图灵完备的，其余 8 个存在是为了降低每任务决策成本。工具太多 = prompt 膨胀 + 决策空间模糊。
2. **Hierarchical Memory (L1-L4)** — L1 只编码「存在性」，L2/L3 按需读取。L1 趋向知识集的 Kolmogorov 复杂度。
3. **Self-Evolution** — 策略进化，工具不变。执行轨迹 → SOP → 可执行代码，三阶段自动转换。
4. **Context Truncation & Compression** — 目标 <30k token（比 1M window 小一个数量级）。四级压缩：tool output truncation → tag-level compression → message eviction → working-memory anchor。

### Benchmark 结果（vs OpenClaw / Claude Code / Codex）

| Benchmark | GA Accuracy | GA Tokens | OpenClaw Accuracy | OpenClaw Tokens |
|---|---|---|---|---|
| SOP-Bench | 100% | 2.08M | 100% | 2.64M |
| Lifelong AgentBench | 100% | 241k | 70% | 1.45M |
| RealFin | 65% | 114k | 35% | 251k |

**关键数据点：**
- GA prompt 长度（20 skills 后）= **2,298 tokens**。OpenClaw = 43,321。差 19 倍。
- 9 轮自进化后 token 从 222k 降到 23k（-89.6%），LLM calls 从 32 降到 5（-84.4%）
- 跨任务 SOP 复用平均省 79.3% token，复杂任务省更多（83.5%）
- 无 embedding/向量库的记忆检索在 LoCoMo 上超越 Mem0 和 A-MEM

### 自进化三阶段

1. **Natural-language execution** — 探索+试错，高 token
2. **SOP distillation** — 压缩为文本 SOP，中等 token
3. **Code-based execution** — 结晶为可执行代码，最低 token（~23k 稳定）

转换是自动触发的，不需人工干预。

### 对我们的新启发（补充之前的分析）

1. ⭐⭐ **Context density > context length** — 我们的 workspace files 注入 43k+ token 是最大痛点。#66576 不只是省 token，是根本性的架构问题
2. ⭐⭐ **工具数量要最小化** — GA 用 9 个工具 vs OpenClaw 18+ tool factories。每多一个工具 = prompt 膨胀 + 决策模糊
3. ⭐ **<30k target** — GA 认为有效无幻觉 context 比标称 window 小一个数量级。我们应该以此为目标
4. ⭐ **SOP→代码自动转换** — 我们的 workflow yaml 停在了 SOP 层，没有往代码层走
5. **Working-memory anchor** — 每次 tool call 后注入 20 行 turn summary + checkpoint，比我们的 nudge 更持续
6. **Cache-friendly compression** — 每 5 轮压缩一次（非每轮），保持 80% prompt cache hit rate

### 局限性

- 自主探索的 weight adaptation 还没足够数据验证
- skill-tree 维护（合并/废弃/拓扑）仍是手动
- 30 轮执行上限，复杂任务需跨 session 续接
- CJK 内容的 α=3 char/token 比率会低估实际 token 用量，可能导致 context overflow

## Update: 2026-04-29 Followup

⭐ 3913→8005 (+105% in 11 days). Explosive growth. Active community: external PRs from AspasZhang, YooooEX, voidborne-d.

### Stream Retry Architecture

Extracted `_stream_with_retry` as a shared function. `MixinSession` now implements failover on stream abort — if a streaming response is interrupted mid-way, it retries transparently. DingTalk adapter also got exponential reconnect backoff (5→300s). This is production-grade reliability engineering.

Relevant to OpenClaw: similar problem with ACP streaming timeouts (60s idle limit). Their MixinSession failover pattern is worth studying if we hit reliability issues.

### L1 Insight Index Replaces sop_index.md

PR #199: `plan_sop` no longer depends on `sop_index.md` (a user-specific file that broke for new users). Now uses L1 Insight index instead — a system-generated index of skills and SOPs.

This parallels our own [[l1-index-layer-evaluation]] — both projects converging on the same pattern: a generated navigation layer that replaces hand-maintained indexes. Validates the direction.

### Autonomous SOP 4-Step Cap

"收尾改为4步，完成即停不贪多" — limits autonomous operation to 4 finalization steps. Prevents the agent from over-extending during wrap-up phases.

Good principle. Our subagent timeout handling is similar in spirit but cruder (hard timeout vs step count limit).

### Telegram Streaming with Turn Summaries

`feat(tg): stream Telegram responses by turn with summaries` — when streaming long responses to Telegram, inserts turn summaries so users can follow progress. Rate limit handling added separately.

Interesting UX pattern for long-running agent tasks over chat platforms. Not directly applicable to OpenClaw but worth noting.

---

*Last deep read: 2026-04-18. Followup: 2026-04-29.*
