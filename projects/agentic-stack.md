# agentic-stack — 深读笔记

> codejunkie99/agentic-stack | 154★ | Python+Markdown | 2026-04-17 深读

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
- **竞品**：[[GBrain]]（更重，PostgreSQL + dream cycle）、我们的 SOUL.md/AGENTS.md 体系（更轻，文件即一切）
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

## 待跟进

- [ ] 考虑给 beliefs-candidates 升级流程加 rationale 约束
- [ ] 研究 Jaccard 聚类是否适合我们的 gradient 自动聚合
- [x] ~~观察 stars 增长，判断 portable agent brain 是否成为趋势~~ → 已确认是趋势（154→401/天）
- [ ] 贡献测试（仍无 test 目录）
- [ ] 用 Toby Ord 框架评估自己的打工 hourly cost
