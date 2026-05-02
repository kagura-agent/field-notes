# agentic-stack — 深读笔记

> codejunkie99/agentic-stack | 1676★ (2026-04-27, was 154 on 04-17 深读, v0.12.0) | Python+Markdown | 2026-04-17 深读

## 核心定位

**"One brain, many harnesses."** 一个可移植的 `.agent/` 文件夹，包含 memory、skills、protocols，可以插入 Claude Code、Cursor、Windsurf、OpenCode、OpenClient、Hermes、standalone Python 七种 harness。换 harness 时知识不丢。

## 解决什么问题

Agent 的知识和经验被锁死在特定 harness 里。换了工具就从零开始。agentic-stack 把 agent 的"大脑"抽象成一个标准化文件夹结构，harness 只是执行层。

## 架构

### 四层记忆
```
.agent/memory/
├── working/      — 当前任务状态（WORKSPACE.md, REVIEW_QUEUE.md）
├── episodic/     — 原始经验日志（AGENT_LEARNINGS.jsonl）
├── semantic/     — 蒸馏知识（LESSONS.md, DECISIONS.md, DOMAIN_KNOWLEDGE.md）
└── personal/     — 用户偏好（PREFERENCES.md）
```

### Dream Cycle（无 LLM 版本）
```
episodic entries → Jaccard 聚类（单链接 + 桥接合并）
  → extract_pattern（选 canonical episode 而非 LLM 合成）
    → 候选 JSON → heuristic prefilter（长度 + 精确去重）
      → REVIEW_QUEUE.md → host agent CLI review
        → graduate.py（需 --rationale）/ reject.py / reopen.py
```

**关键设计决策**：dream cycle 只做机械工作（聚类、staging、预过滤），所有主观判断交给 host agent 通过 CLI 工具完成。graduation 强制要求 rationale，结构性防止橡皮图章。

### Adapter 模式
每个 harness 有一个 adapter 目录，核心就是一个 AGENTS.md 指向 `.agent/`。极其轻量——适配层几乎为零。

## 与我们的机制对比

| 维度 | agentic-stack | Kagura（SOUL.md + wiki） |
|------|---------------|-------------------------|
| **记忆分层** | 4 层（working/episodic/semantic/personal） | 3 层（memory/日记 + wiki + MEMORY.md） |
| **经验提取** | Jaccard 聚类 + canonical extraction | nudge gradient + 3 次重复规则 |
| **审查** | CLI 工具 + 强制 rationale | 手动 daily-review |
| **跨 harness** | ✅ 核心设计目标 | ❌ 绑定 OpenClaw |
| **skill 加载** | manifest + trigger 匹配 → 懒加载 | 类似（frontmatter description 匹配） |
| **无 LLM 依赖** | ✅ 聚类用 Jaccard，不需 embedding | ❌ nudge 依赖 LLM |

## 关键洞察

### 1. 聚类不需要 embedding
单链接 Jaccard 聚类 + 桥接合并，纯文本处理，零 API 依赖。这比 [[reflexio]] 的 HDBSCAN + embedding 轻得多，但在 pattern 识别上够用。启发：我们的 beliefs-candidates 聚合也不一定需要 LLM。

### 2. "Staging 不是 Promotion" 的分离
auto_dream.py 明确注释 "Never: subjective validation, promotion, git commit"。机械工作和判断工作完全分离。我们的 nudge 把提取和评判混在一起（LLM 同时写 gradient 和判断是否该升级）。

### 3. 强制 rationale 是防讨好的好机制
`graduate.py --rationale "..."` 是必须参数。不能无脑批准。这和我们 AGENTS.md 里的"讨好模式防范"目标一致，但用结构约束而非文字提醒。

### 4. Adapter 层的极简设计
每个 harness adapter 只是一个 AGENTS.md 文件。这说明跨 harness 兼容的关键不是复杂的适配层，而是**标准化的文件结构**。Hermes/Claude Code/Cursor 都能读 markdown 文件，所以适配成本接近零。

### 5. 测试覆盖（v0.11+ 改善）
v0.11+ 开始有测试：test_data_flywheel_export.py、test_data_layer_export.py、test_tldraw_visual_memory.py、test_claude_code_hook.py。用 subprocess 调用导出脚本做端到端验证。Dream cycle 核心（聚类、staging）仍无测试。

## 在 Agent 生态中的位置

- **层级**：Agent 基础设施（memory + skill 标准化）
- **竞品**：[[gbrain]]（更重，PostgreSQL + dream cycle）、我们的 SOUL.md/AGENTS.md 体系（更轻，文件即一切）
- **互补**：[[reflexio]]（外部 playbook 服务）可以和 agentic-stack 集成——Reflexio 提取 playbook，agentic-stack 存储和分发
- **上游**：各 harness（Claude Code、Cursor、Hermes）
- **信号**：agent 知识可移植性正在成为需求。用户不想被锁死在一个 harness 里

## v0.11-v0.12 增量变化（2026-04-27 跟进）

> 星数：1676★（稳定），v0.11.0-v0.12.0 在 04-26~04-27 连发

### v0.11.0 — Data Layer + Data Flywheel

**Data Layer**（PR #25 by @danielfoch）：跨 harness 本地监控。读 `AGENT_LEARNINGS.jsonl` + 可选的 `harness-events.jsonl` / `cron-runs.jsonl`，输出终端仪表盘、token/cost 估算、cron 时间线、KPI 汇总。支持 Claude Code/Hermes/OpenClaw/Codex/Cursor/OpenCode/Windsurf/Pi/Antigravity。

- 纯本地，不发遥测
- 触发词自然语言（"show me the dashboard"、"how many tokens"）
- 实质：agent 版 `htop`，把分散在各 harness 的活动统一到一个视图

**Data Flywheel**（PR #26 by @danielfoch）：把 human-approved 的 agent run 转化为可复用的数据资产。

```
approved run → redacted trace → context card → eval case → training-ready JSONL
```

**核心设计决策**：
1. **只用 human-approved runs**——rejected/unknown 只能做 failure-mode notes
2. **强制 redaction**——通过 `redaction_status: passed` 门控，PII 必须先脱敏
3. **不训练模型**——只产出数据 harness，downstream 实验（SLM/adapter）是用户自己做的
4. **阈值体系**：10-25 runs → context card, 25-100 → eval set, 100-300 → measurement, 500-1500 → narrow adapter candidate, 2000-10000+ → workflow family corpus
5. **context card 带 prompt shrinking 指标**——记录 `context_tokens_before/after`，计算压缩率

**代码质量**：`data_flywheel_export.py` ~250 行，纯 stdlib，零外部依赖。健壮的 JSONL parsing（跳过 malformed lines 并计数）。测试用 subprocess 调用，端到端验证 artifacts 生成。

### v0.12.0 — tldraw Visual Memory

tldraw MCP 集成，把绘图能力加入 agent toolkit。agent 可以通过 MCP 在 localhost:3030 的 canvas 上画图（diagram/flowchart/wireframe/architecture），用户实时看到。

- **Feature flag 机制**：`.agent/memory/.features.json` 控制开关，默认 off
- **Skill-local storage**：`store.py` 提供 snapshot/list/load/archive，数据在 `.agent/skills/tldraw/` 下，不是第五个记忆层
- **Beta 隔离好**：不自动安装 MCP config，不影响现有用户

### 洞察

1. **从记忆到数据**：agentic-stack 从 "记住经验" 扩展到 "量化经验"。data-layer 是观测，data-flywheel 是提炼。这跟我们的 nudge（观测行为 → 提炼规则）是同一方向，但他们多了量化维度（token cost, acceptance rate, context reduction）。

2. **阈值体系是好 idea**：我们的 beliefs-candidates 用 "3 次重复" 做升级门控。他们用量化阈值（500+ approved runs → adapter candidate）做数据资产升级。两个方向可以互补——我们可以给 beliefs-candidates 加量化指标（出现频次、影响范围计数）。

3. **Context card 是新概念**：把同一 workflow 的多次 run 聚合成一张卡片，包含稳定规则、典型 failure modes、eval 引用。类似我们的 wiki project notes，但更结构化。

4. **贡献生态在扩大**：v0.11 PR #25/#26 来自 @danielfoch（外部贡献者），说明项目开始有社区参与，不再是 solo project。154→1676★ 的增长验证了 "portable brain" 需求。

5. **Feature flag 是 skill 管理的好 pattern**：beta skill 通过 `.features.json` 控制加载，比我们的全量加载更精细。值得考虑在 OpenClaw skill 系统中引入类似机制。

## 跟我们方向的关联

1. **我们已经在做类似的事**：SOUL.md + AGENTS.md + wiki + memory/ 就是我们版本的 portable brain。但没有标准化的 dream cycle 和审查 CLI
2. **Jaccard 聚类可借鉴**：给 beliefs-candidates 做自动聚类，找重复 pattern，不需要 LLM
3. **rationale 约束可借鉴**：在 nudge 升级 DNA 时强制写理由（我们现在靠飞书通知 Luna，但没有结构约束）
4. **贡献机会**：没有测试 → 可以贡献测试；Hermes adapter 很简单 → 可以改进

## 04-18 更新：爆发式增长 + 生态扫描

- **Stars**: 154 → 401（+160%，一天内），确认 portable agent brain 是真实需求
- **新增**: OpenClaw adapter（从 openclient 改名）、Pi coding agent adapter，共 8 个 harness
- **仍无测试**: 401★ 项目零测试，贡献机会仍在
- **OpenClaw adapter 分析**: 本质是一段 system prompt include，指导 agent 读 `.agent/` 目录结构。极简适配——说明标准化文件结构 > 复杂 API 集成

### 生态上下文（04-18 侦察）

同期新项目:
- **cangjie-skill** (139★): 把书蒸馏成可执行 Agent Skills——从 passive knowledge → executable skill 的自动化
- **WorldSeed** (102★): AI agents 自治世界引擎——信息不对称 + 物理规则，沙盒测试方向
- **hermes-agent-rs** (11★): Hermes Rust 重写，性能方向的信号

HN 热议:
- Toby Ord "Are the costs of AI agents also rising exponentially?"（199 pts）— 质疑 METR time-horizon 进步是否只是花更多钱换来的，不是真效率提升。核心问题：agent 的 "hourly cost" 是否在下降？这个框架适用于评估我们自己的打工效率
- Claude Design（1035 pts）— Anthropic 进设计工具领域

### 信号判断

1. **portable agent brain 是真趋势**（154→401 一天，不是炒作）
2. **标准化的赢面在文件结构，不在 API**——所有 harness 都能读 markdown，适配成本接近零
3. **agent 成本效率正在被质疑**——Toby Ord 的框架值得用来审视我们的打工 ROI

## 04-19 更新：持续增长 + profile provenance

- **Stars**: 401 → 510（+27%，稳定增长，非一日爆发后回落）
- **PR #5 merged**: profile-tagged provenance — 多 agent 共享同一 brain 时标记 episodic entry 来源（哪个 profile 产生的）
  - 场景：Hermes `--profile fin` vs `--profile quant`，经验不混淆
  - 启示：我们的 memory/ 日志没有 session/角色标记，全混在一起。如果未来有多 channel 并行（Discord + 飞书 + GitHub），可能需要 provenance
- **Open issues: 0** — 维护者回复快，社区健康
- **增长曲线**: 154(04-17) → 401(04-18) → 510(04-19)，日增放缓但仍在涨，说明不是纯炒作

## 04-20 更新：v0.7.0 — learn/recall/show 三件套 + Apache 2.0

- **Stars**: 510 → 584（+14%，增长趋稳但持续）
- **License**: MIT → Apache 2.0（v0.7.1 relicense，更利于企业采用）
- **重大新增**: 三个 CLI 工具，完成了 dream cycle 的闭环

### learn.py — 一键教训注入
- `python3 .agent/tools/learn.py "Always serialize timestamps in UTC" --rationale "prior bugs"`
- 跳过 stage→review→graduate 仪式，直接注入。适合人类/host agent 已确认的知识
- 用 `pattern_id(claim, conditions)` 做幂等——相同 claim+conditions 重复调用安全
- `--stage-only` 可以只 stage 不 graduate，保留审查流程
- `--provisional` 标记为试用期规则
- **设计亮点**: claim 太短（<20 chars）直接拒绝，防垃圾注入
- **与我们对比**: 我们的 beliefs-candidates.md 是纯文本，没有 CLI 工具辅助注入/毕业流程。learn.py 的 rationale 强制要求值得借鉴

### recall.py — 意图驱动的 lesson 检索
- `python3 .agent/tools/recall.py "add a created_at column to orders"`
- 纯词法匹配（Jaccard word overlap），不用 embedding，零 API 依赖
- conditions 权重 2x（触发词匹配比 claim 词匹配更强的信号）
- 每次 recall 自动写入 episodic memory（审计追踪 + dream cycle 可见）
- 合并 lessons.jsonl + LESSONS.md 两个来源，去重
- **设计亮点**: 明确标注 "lexical overlap, NOT semantic relevance"——诚实的局限声明
- **与我们对比**: 我们的 memory_search 用 embedding（语义更强但需 API），agentic-stack 选择零依赖但精度低。tradeoff 合理——lesson 数量少（数十条），词法够用

### show.py — 终端仪表盘
- ANSI 彩色 boxed dashboard：MEMORY / LESSONS / CANDIDATES / SKILLS 四个面板
- 14 天 sparkline 活动图 + 失败统计 + dream cycle 状态
- `--json` 输出用于程序化消费
- **设计亮点**: `_visible_len()` 正确处理 ANSI 转义码的可见宽度，细节到位
- **启发**: 我们可以给 flowforge 加类似的 brain-state dashboard

### 架构洞察

1. **learn/recall/show 形成完整操作闭环**: learn（写入）→ recall（读取）→ show（观测）。dream cycle 做自动提取，learn 做手动注入，recall 做使用时检索。三个工具 + dream cycle = 完整知识管理
2. **recall 的审计追踪是巧妙设计**: 每次 recall 写 episodic entry，dream cycle 可以发现 "哪些 lesson 实际被使用了"。未被 recall 的 lesson 可能是死知识。我们没有这个可观测性
3. **Apache 2.0 转型信号**: 从 MIT 到 Apache 2.0，说明项目预期企业用户。portable agent brain 正从个人工具走向团队/组织工具

### 与 [[reflexio]] 的生态位差异

agentic-stack 选择全本地、零 API、文件即一切；[[reflexio]] 选择外部服务 + LLM 提取 playbook。两者互补但设计哲学对立。agentic-stack 更像 git（分布式、文件系统原生），reflexio 更像 GitHub（中心化服务）

## 04-23 更新：v0.8.0 + 爆发增长 584→1462★

- **Stars**: 584 → 1462（+150%，3 天，确认 portable agent brain 是主流需求）
- **v0.8.0** (2026-04-21): Antigravity adapter（第 9 个 harness）+ 丰富的 episodic logging

### 关键变化

1. **终于有测试了**: 54-test validation suite for Claude Code PostToolUse hook，加上 33-check regression verifier。之前的「零测试贡献机会」窗口已关闭
2. **Rich episodic logging**: 旧的 `post-tool ok` 硬编码被替换，现在每个 tool call 有真实 action label、importance score、non-empty reflection。这让 dream cycle 终于有东西可以聚类了——之前全是相同的 entries
3. **hook_patterns.json**: 用户可自定义 importance scoring pattern（生产部署 vs 普通文件编辑），不再一刀切。这是 personalization 层
4. **Homebrew 分发**: `brew install agentic-stack`，从 clone-only 升级到包管理器分发
5. **社区 PRs**: YantrikDB memory backend（多信号 recall + reflect）、tldraw 视觉记忆层——社区在往 beyond-text 方向扩展

### 趋势信号

- 584→1462 的增长说明 portable agent brain 不是 niche——这是 agent infra 的基础需求
- 9 个 harness adapter 说明碎片化是真实痛点，标准化文件结构是低成本解法
- 社区贡献从 adapter（低门槛）进化到 memory backend（高门槛），项目正在深化
- Open issue #18（hook 路径问题）是典型「实际使用中发现的 bug」，说明真用户在用

## 待跟进

- [ ] 考虑给 beliefs-candidates 升级流程加 rationale 约束
- [x] 研究 Jaccard 聚类是否适合我们的 gradient 自动聚合 → **Yes, implemented** `tools/gradient-cluster.py` (2026-04-27). Pure lexical Jaccard was too weak for mixed CJK/English (J=0.06 for clearly related entries). Solution: concept vocabulary mapping (surface forms → canonical concepts) + Latin keywords + quoted content extraction. At threshold 0.35, finds 6 meaningful clusters across 110 entries. Key insight: for mixed-language text, **concept normalization > raw tokenization**. agentic-stack's approach works for English-only; CJK needs an abstraction layer
- [x] v2: `tools/beliefs-cluster.py` (2026-05-02) — rebuilt with concept-tag boosting, graduation candidate detection, pattern-tag stats. v1 over-clustered (79/126 in one cluster); v2 is more conservative with actionable output. See [[jaccard-belief-clustering]]
- [x] ~~观察 stars 增长，判断 portable agent brain 是否成为趋势~~ → 已确认是趋势（154→401→510）
- [ ] 用 Toby Ord 框架评估自己的打工 hourly cost
- [ ] 考虑 memory/ 日志加 provenance 标记（参考 PR #5）
- [x] 评估 data layer 概念能否用于 OpenClaw cron/session 监控 → 04-27 结论：NOT NOW。OpenClaw trajectory JSONL 已有完整数据，50行 Python PoC 验证可行。不需要 agentic-stack 的 9-harness 方案，自建也非当务之急。详见 [[cron-observability-metrics]]

## 04-27 更新：v0.9-v0.12 — 从 Portable Brain 到 Agent Infra Platform

- **Stars**: 1462 → 1676（+15%，4 天，增长趋稳但持续）
- **版本**: v0.8.0 → v0.12.0（3 天 4 个 minor release，发布节奏极快）

### v0.9.0 — Harness Manager（04-24）

manifest-driven adapter system，架构上的重要一步：
- `adapter.json` 声明每个 harness 需要的文件、merge policy（`overwrite` / `skip_if_exists` / `merge_or_alert`）、post-install hooks
- verb subcommands：`add` / `remove` / `status` / `doctor` / `manage`（TUI）
- 共享文件 ownership tracking：`install.json` 记录哪个 adapter 拥有哪个文件，移除时安全检查
- 路径安全校验：`_check_path_safe()` 拒绝 path traversal 和绝对路径
- **设计洞察**：从 "shell script copy files" 升级到 "declarative infrastructure"。adapter.json 是小型 IaC

### OpenClaw Adapter 详解

```json
{
  "name": "openclaw",
  "files": [
    {"src": "AGENTS.md", "dst": "AGENTS.md", "merge_policy": "merge_or_alert"},
    {"src": "config.md", "dst": ".openclaw-system.md", "merge_policy": "overwrite"}
  ],
  "post_install": ["openclaw_register_workspace"]
}
```
- 仅注入 2 个文件 + 一个 post-install hook（`openclaw agents add --workspace`）
- AGENTS.md 指引 agent 读 `.agent/` 目录结构、recall before act、memory discipline
- 适配层极简——证明了[[skill-ecosystem]]跨平台的关键不是复杂 API，而是标准化文件结构

### v0.11.0 — Data Layer + Data Flywheel（04-26，最重要更新）

**data-layer** seed skill：cross-harness monitoring
- 从 `AGENT_LEARNINGS.jsonl`（episodic memory）+ 可选 `harness-events.jsonl` / `cron-runs.jsonl` 生成：
  - harness activity timeline
  - cron start/finish + duration
  - token/cost estimates by hour/day/week/month
  - KPI summary rows
  - `dashboard.html` + `daily-report.md` + terminal TUI
- 自然语言触发："show me the dashboard"、"what did my agents do" → 终端 TUI 直接渲染
- 全本地，无遥测，严格数据卫生（不存原始 prompt、不自动外发）

**data-flywheel** seed skill：
- 从 approved runs 提取 trace records、context cards、eval cases、training-ready JSONL
- 本地只准备 artifacts，不训练模型、不调 API
- 关键：这是「运行产生数据 → 数据改进 agent」的闭环基础设施

**架构洞察**：episodic JSONL 是 single source of truth。所有 dashboard/report/flywheel 都是 derived view。这和 [[context-rot]] 卡片里讨论的 "write once, read many" 模式一致。data layer 不创造新数据，只对已有数据做视图变换

### v0.12.0 — tldraw Visual Canvas（04-27, today）

- MCP server 驱动的 live canvas：diagram, sketch, wireframe, flowchart, whiteboard
- skill-local snapshot store（snapshots.jsonl + INDEX.md），不作为第 5 个 memory layer
- opt-in beta，默认关闭
- 信号：agent 正在从纯文本走向多模态交互。但 tldraw 目前是 MCP server 依赖，和 agentic-stack "零依赖" 的核心哲学有张力

### 进化轨迹总结

```
v0.1-0.6: Portable brain（memory + skills + adapters）
v0.7:     Knowledge management CLI（learn/recall/show）
v0.8:     Rich logging（让 dream cycle 有东西聚）
v0.9:     Infrastructure formalization（manifest-driven adapters）
v0.10:    Workflow integration（DESIGN.md）
v0.11:    Observability（data layer + flywheel）
v0.12:    Multi-modal（tldraw canvas）
```

从 portable brain → knowledge CLI → infra → observability → multi-modal，这是一条清晰的从内向外扩展的路径。核心稳定，每层 skill 是独立模块，seed skill 模式天然可扩展。

### 与我们的对比更新

| 维度 | agentic-stack v0.12 | Kagura 当前 |
|------|---------------------|-------------|
| **跨 harness** | ✅ 10 个 adapter | ❌ 绑定 OpenClaw |
| **observability** | ✅ data layer dashboard | ❌ cron/session 分散，无统一视图 |
| **知识检索** | Jaccard 词法（零 API） | memex 语义搜索（更强但需 API） |
| **data flywheel** | ✅ trace→eval→training JSONL | ❌ 无系统化的经验数据管线 |
| **multi-modal** | ✅ tldraw canvas（beta） | ❌ 纯文本 |
| **知识网络** | ❌ 无 wikilink / backlink | ✅ memex + [[双链]]知识图谱 |
| **发布速度** | 3天4个minor | 按需（无固定节奏） |

**我们的优势**：语义记忆网络（memex + wikilinks + backlinks）是 agentic-stack 完全没有的。他们的 recall 只有 Jaccard 词法，knowledge graph 为零。我们的劣势：observability 和 data pipeline 空白

## Followup 2026-04-28

**Stars**: 1,678 → 1,712 (+34)
**Release**: v0.12.0 (2026-04-27)

### v0.12.0: tldraw + Feature Flags
- **tldraw seed skill**: 画布/图表/架构可视化，MCP tool 引导
- **Skill-local snapshot store**: snapshots.jsonl + INDEX.md，有意不作为第五记忆层
- **Feature flag gating**: `.agent/memory/.features.json` 控制 beta skill 加载
  - 默认关闭，onboarding 写 flag，用户显式启用
  - adapter 不自动装 beta MCP config
- Seed skill 数达 9 个: skillforge, memory-manager, git-proxy, debug-investigator, deploy-checklist, design-md, data-layer, data-flywheel, tldraw

## Followup 2026-04-29

**Stars**: 1,712 → 1,740 (+28, steady growth)
**No new commits since v0.12.0** (04-27). Pushed_at shows 04-29 but no new content — likely GitHub cache.

**Status**: Project has settled into post-release calm after the rapid v0.9-v0.12 sprint (4 releases in 3 days). Community engagement ongoing but no new PRs or issues.

**Growth trajectory**: 154(04-17) → 401(04-18) → 510(04-19) → 584(04-20) → 1462(04-23) → 1676(04-27) → 1740(04-29). Growth decelerating from explosive to steady ~2%/day. Healthy for a tool project.

## Followup 2026-05-01

**Stars**: 1,740 → 1,778 (+38, steady ~2%/day)
**Pushed_at**: 2026-04-30 (active again after post-v0.12 calm)

### PR #34: CJK Memory Search Fix (merged)

FTS5 `unicode61` tokenizer misses short CJK substring searches (e.g., `中文` not matching `中文优先`). Fix:
- Added `CJK_RE` regex detector for CJK characters
- FTS5 path first (fast), then LIKE `%query%` fallback if CJK detected and FTS returns empty
- Includes regression tests for short CJK, mixed EN/CJK, and deleted-file rebuilds

**Relevance**: Our memex uses FTS5 too. If we hit similar CJK issues, this LIKE fallback pattern is the simplest fix. Worth noting for [[memex]] development.

### PR #11: tldraw Visual Memory (merged into v0.12.0)

Feature flag gated opt-in tldraw skill with local snapshot store. Already noted in v0.12.0 followup — confirmed merged via PR.

### Assessment

Slow but steady iteration. CJK fix shows the codebase is being used by non-English speakers. Growth has stabilized around +30-40/day — healthy plateau for a tool project. No architectural surprises.

See [[agentic-stack]], [[memex]]

## v0.13+ Transfer TUI Wizard (2026-05-02)

> Stars: 1801★ (05-02) | Commits: 05-02 `feat: add transfer tui wizard` + `fix: include full memory in transfer intent`

### What It Does

`agentic-stack transfer` — onboarding-style TUI wizard that **exports/imports portable `.agent` memory bundles** across harnesses (Codex, Cursor, Windsurf, terminal).

### Architecture

Three modules, cleanly separated:

**1. transfer_plan.py** — Intent parsing + adapter preview
- NLP-free keyword parsing: tokenize intent text, match against alias dicts
- `TransferPlan` dataclass: targets, operation (generate-curl / apply-here / both), scopes, adapter actions
- Target aliases handle natural language: "openai" → codex, "cascade" → windsurf, "shell" → terminal
- Scope system: core (preferences, accepted_lessons, skills) + sensitive (working, episodic, candidates, data_layer, flywheel)
- Sensitive scopes require wizard confirmation before export

**2. transfer_bundle.py** — Bundle export/import with security
- Exports: canonical JSON, files as gzip/base64, SHA-256 digest
- Secret scanning: 3 regex patterns (private keys, API key formats, env var assignments) — blocks export if detected
- Runtime filtering: skips `.pyc`, `.db`, `.sqlite`, `__pycache__`, `.index`, `snapshots`
- Import: preferences get merged (appended under `## Imported Preferences`), lessons are idempotent by ID, permissions.md is never overwritten
- Audit trail: `imports/{timestamp}.json` records what was imported when

**3. transfer_tui.py** — Interactive wizard (306 LOC)
- Reuses existing onboard_ui.py + onboard_widgets.py primitives
- Non-TTY detection: refuses interactive mode, falls back to non-interactive CLI

### Key Design Decisions

1. **Secret scanning at export, not import** — catch before it leaves, not after it arrives
2. **Lesson idempotency by ID** — import the same bundle twice, no duplicates
3. **Preferences merge, not overwrite** — existing prefs preserved, imported appended under heading
4. **permissions.md immutable** — security boundary never transferable
5. **Sensitive scope opt-in** — episodic/candidates/data_layer require explicit confirmation

### Comparison to Brain Portability Landscape

| Feature | agentic-stack transfer | OpenClaw | Orb |
|---|---|---|---|
| Memory export | ✅ Portable `.agent` bundle | ❌ No export | ❌ Per-profile only |
| Secret scanning | ✅ 3 patterns | ✅ wiki-lint (25 patterns) | ❓ Unknown |
| Cross-harness | ✅ Core design goal | ❌ Single platform | ❌ Claude-only |
| Import merge | ✅ Preferences merge, lesson dedup | N/A | N/A |
| Audit trail | ✅ Per-import JSON | ❌ | ❌ |

### Borrowable Ideas for OpenClaw/Kagura

1. **Transfer bundle format** — if we ever need to migrate SOUL.md + wiki to a different agent platform, a structured export with digest verification and secret scanning is the right pattern
2. **Lesson idempotency by ID** — our beliefs-candidates could benefit from stable IDs to prevent re-evaluation of the same learning
3. **Sensitive scope confirmation** — when exporting memory/context, explicit "these are sensitive, confirm?" is good UX
4. **permissions.md immutability** — clear security boundary: identity transfers, but permission boundaries don't

### Assessment

This is the **first real "brain migration" tool** in the agent ecosystem. Others talk about portability; agentic-stack actually ships `transfer export` + `transfer import` with security scanning and merge logic. The implementation is clean (305 LOC bundle + 229 LOC plan + 306 LOC TUI) and well-tested (113+132+62+39 = 346 test LOC).

Validates our [[agent-brain-portability]] card's thesis: portable agent identity is becoming a first-class feature.

Links: [[agent-brain-portability]], [[openclaw]], [[orb]], [[self-evolving-agent-landscape]]

*Followup deep-read: 2026-05-02. Source: GitHub API + code reading.*
