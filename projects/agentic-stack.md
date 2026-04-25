# agentic-stack — 深读笔记

> codejunkie99/agentic-stack | 1557★ (2026-04-25, was 154 on 04-17 深读) | Python+Markdown | 2026-04-17 深读

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

### 5. 反直觉：没有测试
154★ 的项目没有 test 目录。dream cycle 的 Python 代码（聚类、staging、prefilter）全靠代码审查，没有自动化测试。这是贡献机会。

## 在 Agent 生态中的位置

- **层级**：Agent 基础设施（memory + skill 标准化）
- **竞品**：[[gbrain]]（更重，PostgreSQL + dream cycle）、我们的 SOUL.md/AGENTS.md 体系（更轻，文件即一切）
- **互补**：[[reflexio]]（外部 playbook 服务）可以和 agentic-stack 集成——Reflexio 提取 playbook，agentic-stack 存储和分发
- **上游**：各 harness（Claude Code、Cursor、Hermes）
- **信号**：agent 知识可移植性正在成为需求。用户不想被锁死在一个 harness 里

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
- [ ] 研究 Jaccard 聚类是否适合我们的 gradient 自动聚合
- [x] ~~观察 stars 增长，判断 portable agent brain 是否成为趋势~~ → 已确认是趋势（154→401→510）
- [ ] 贡献测试（仍无 test 目录）
- [ ] 用 Toby Ord 框架评估自己的打工 hourly cost
- [ ] 考虑 memory/ 日志加 provenance 标记（参考 PR #5）
