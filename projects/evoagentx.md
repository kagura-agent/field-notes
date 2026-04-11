# EvoAgentX

> Workflow autoconstruction + self-evolution engine
> GitHub: EvoAgentX/EvoAgentX | ⭐ 2.7k

## 架构概要

EvoAgentX 自动构建和进化 multi-agent workflow：给定任务目标，自动生成 agent 拓扑和协作流程，然后通过运行反馈迭代优化 workflow 结构。

优化器体系（`evoagentx/optimizers/`）：
- **SEWOptimizer** — 自进化 workflow
- **AFlowOptimizer** — 自动工作流优化
- **TextGradOptimizer** — 文本梯度优化 prompt
- **MiproOptimizer / WorkFlowMiproOptimizer** — MIPRO 风格优化
- **MapElitesOptimizer** — quality-diversity 优化（2026-04-08 新增）

所有优化器共享 `engine/` 基础设施：`BaseOptimizer` + `ParamRegistry` + `EntryPoint` decorator。

## MAP-Elites Optimizer 深读（2026-04-09）

### 核心设计

**Individual = 配置字典 (cfg)**。不是 agent 也不是 prompt 对象，而是一组 key-value 参数。通过 `ParamRegistry` 绑定到实际程序对象的属性上（可以是 prompt template、workflow 参数、任何 Python 属性）。

**架构分层：**
```
ParamRegistry.track(obj, "attr")  →  绑定可优化参数
EntryPoint decorator              →  标记程序入口
evaluator(output) → metrics       →  评估函数返回 metrics dict
MapElitesOptimizer.optimize()     →  主循环
```

### 五个关键问题

**a) Individual 是什么？**
`Dict[str, Any]` — 参数配置。例子中是 `{"x": 3, "y": 4}`。实际用途中可以是 prompt 参数、模型选择、temperature 等任何通过 `ParamRegistry` 注册的可变参数。

**b) Feature space 怎么定义？**
用户指定：
- `feature_dimensions: List[str]` — metrics dict 中哪些 key 作为行为特征维度
- `feature_ranges: Dict[str, (min, max)]` — 每个维度的值域
- `feature_bins: int | Dict[str, int]` — 每个维度分几个格子

Feature space 是离散网格。`_cell_from_metrics()` 把连续 metrics 值映射到格子坐标 `Tuple[int, ...]`。

**c) Fitness function 是什么？**
用户提供的 `evaluator(output) → float | Dict[str, Any]`。如果返回 dict，从中取 `fitness_key`（默认 "score"）作为 fitness。同一个 dict 也提供 feature dimensions 的值。

**d) 变异/交叉怎么做？**
**只有变异，没有交叉。** `_mutate_cfg()` 随机选一个参数 key，从 search_space 中随机换一个不同的值。非常简单的单点变异。

主循环逻辑：
- 以 `exploration_ratio` 概率做随机采样（exploration）
- 否则从 archive 随机选 parent → 变异（exploitation）

**e) Archive 怎么维护？**
`Dict[Tuple[int, ...], ArchiveEntry]` — cell 坐标到最佳 entry 的映射。新 entry 只在该 cell 为空或 fitness 更高时替换。经典 MAP-Elites 规则。

### 代码质量评估

**优点：**
- 干净、独立、约 150 行核心逻辑
- 与 EvoAgentX 框架解耦良好（通过 BaseOptimizer + ParamRegistry 抽象）
- 类型标注完整

**局限：**
- 变异策略过于简单（单参数随机替换，无渐变、无交叉）
- 无并行 evaluation
- 无 archive 可视化 / 分析工具
- search_space 是离散枚举列表，不支持连续空间
- 没有自适应 exploration_ratio

### 与我们的 self-evolution 对比

| 维度 | MAP-Elites (EvoAgentX) | 我们的 DNA 系统 |
|---|---|---|
| **进化对象** | 参数配置（prompt/workflow params） | 行为原则（beliefs → DNA rules） |
| **变异来源** | 随机搜索空间采样 | gradient（经验/纠错反馈） |
| **选择压力** | fitness function（自动评估） | 人工审查 + 重复次数阈值（3次） |
| **多样性保留** | feature space grid（显式） | beliefs-candidates.md 候选池（隐式） |
| **evaluation** | 程序化执行 + metrics | 实际工作中的行为观察 |
| **迭代速度** | 几秒内跑完 N 轮 | 跨 session，天级别 |

### 关键洞察

1. **MAP-Elites 最有价值的思想是 quality-diversity tradeoff**：不只要最优解，要在不同行为特征下都保留好解。这跟我们 beliefs 系统其实暗合——我们不会只保留"最高效"的规则，而是保留不同场景下有用的规则。

2. **可以借鉴的地方：显式定义 feature dimensions**。我们的 beliefs 升级目前只看"重复次数"，没有按维度分类保留多样性。可以考虑给 beliefs 加标签维度（如 "safety" / "efficiency" / "social" / "code-quality"），确保各维度都有代表。

3. **不适合直接搬用的原因：**
   - 我们的 "fitness" 很难程序化评估（行为原则的好坏需要长期观察）
   - search space 不是离散枚举（beliefs 是自然语言，空间无限）
   - 每次 "evaluation" 成本极高（需要实际工作执行，不是函数调用）

4. **如果要用在 prompt/skill 优化上**，MAP-Elites 更直接可用：
   - Individual = prompt 变体 / skill 配置参数
   - Feature dimensions = 响应长度、使用工具数量、完成时间等
   - Fitness = 任务成功率
   - 但需要自动化 evaluation pipeline，这是主要工程成本

### 打工可行性

项目活跃度回升（4/8 刚 merge MAP-Elites PR）。MAP-Elites optimizer 本身比较完整，但有改进空间：
- 连续空间支持
- 交叉算子
- archive 可视化
- 并行 evaluation

可以考虑贡献，但需评估 maintainer 响应速度。

## 跟我们的关系

关键区分：**EvoAgentX 进化的是 workflow 结构（谁做什么、怎么连接），不是 agent 身份。**

我们的 DNA 系统（SOUL.md / beliefs-candidates.md）进化的是 agent 的性格、原则、行为模式——是身份层。两者互补但不同层：

- EvoAgentX → workflow topology（任务编排）+ parameter optimization
- 我们的 DNA → agent identity（行为准则）

MAP-Elites 的 quality-diversity 思想对我们有启发价值，特别是"多样性保留"这个概念。

## 关联

- [[openclaw]] — 都涉及 agent 系统，但层次不同
- [[hermes-agent]] — workflow 层面有概念重叠

## MAP-Elites → beliefs-candidates 应用（2026-04-09）

**应用场景**: 把 MAP-Elites 的 quality-diversity 思想用于自身 beliefs-candidates.md 管理

**具体做法**:
- 定义 7 个特征维度: V-验证 / C-工程 / O-社交 / E-执行力 / A-自治 / R-创意 / S-安全
- 对 77 个 pattern 进行分类，生成热力图
- 在 beliefs-candidates.md 头部加入维度表和进化策略

**发现**:
1. V-验证维度最密集(15条)但 DNA 覆盖最低 — 典型的"重复多但分散识别"问题
2. O-社交和 A-自治维度零 DNA 升级 — 盲区
3. R-创意维度最薄弱(6条) — 可能是反馈缺失

**与 [[mechanism-vs-evolution]] 的联系**: MAP-Elites 不是新机制，是给已有管线加了一个分析视角。改的是"怎么看"不是"怎么做"。

## 跟进 (2026-04-11)

### PR #222 MAP-Elites 正式 merge (2026-04-08)

之前深读时看的是 PR 阶段代码，现在已正式合入 main。实现与之前分析一致：
- 539 行新增，14 文件变更
- 含 demo (`examples/optimization/map_elites_demo.py`) 和测试
- 依赖 PR #221 (deps refactoring) 和 #225 (SiliconFlow race condition fix) 同期 merge

代码与之前深读分析完全一致，无额外变化。

### 同期 PR #225: SiliconFlow response race condition fix
- 修复 SiliconFlow provider 的流式响应竞态条件
- 说明项目在积极维护多 LLM provider 支持

### Multica v0.1.22-v0.1.23 动态 (同期观察)
- v0.1.22: **per-tab memory router** — 桌面端每个 tab 独立 `createMemoryRouter`，用 React Activity API 保持 DOM/state
- v0.1.23: 项目视图改进（sidebar properties panel, completion progress）
- Multica 迭代速度极快（3 天 3 个 release），agent 自动提 PR（PR #699 from `agent/j/696a5ce1`）
- 值得关注的模式：Multica 用自己的 agent 给自己提 PR，实现了 self-contribution loop
