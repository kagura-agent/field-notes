# MemEvolve — Meta-Evolution of Agent Memory Systems

## 基本信息
- 论文: arXiv 2512.18746 (2025-12-21)
- 作者: Guibin Zhang 等 8 人（颜水成组）
- 代码: https://github.com/bingreeky/MemEvolve
- 基于: Flash-Searcher (web agent) 框架
- 关键词: meta-evolution, memory architecture search, EvolveLab

## 核心问题
传统自进化记忆系统有一个根本限制：**记忆架构本身是静态的**。
- 你定义好怎么 encode/store/retrieve/manage，然后只有内容在进化
- 但不同任务、不同阶段可能需要不同的记忆架构
- 这是 [[write-read-gap]] 的学术化表达

## 代码级理解（2026-03-26 深入阅读）

### 接口设计：3 个方法搞定一切
```python
class BaseMemoryProvider(ABC):
    def provide_memory(request: MemoryRequest) -> MemoryResponse  # Retrieve
    def take_in_memory(trajectory: TrajectoryData) -> (bool, str)  # Encode + Store
    def initialize() -> bool                                        # Setup
```

**反直觉发现 1**: 论文说 4 模块（encode/store/retrieve/manage），但代码只有 3 个方法。`manage` 被分散到了各 provider 的内部方法里（`_intelligent_prune_memories`, `_update_memory_success_count` 等）。**manage 不是独立模块，而是其他模块的副作用。**

### MemoryRequest 的核心设计
```python
MemoryRequest(query, context, status: BEGIN|IN)
```
- `status` 只有两个值：`BEGIN`（规划阶段）和 `IN`（执行阶段）
- **反直觉发现 2**: 这跟我们的 skill 触发时机完全对应——BEGIN = 意图检测时，IN = 执行时。但我们只在 BEGIN 时注入 memory，没有 IN 阶段的实时记忆注入。

### 12 个 Baseline 的分类
| Provider | Encode | Store | Retrieve | Manage |
|----------|--------|-------|----------|--------|
| lightweight | LLM 提取 | JSON flat file | LLM 选择 top-5 | 容量上限 30+30 |
| agent_kb | LLM 分层摘要 | JSON + embeddings | 语义搜索 | 相似度去重 |
| skillweaver | 成功轨迹→代码 | .py 文件 | 函数匹配 | 工具包装 |
| voyager | 成功→skill library | JS 函数 | 名称匹配 | 版本管理 |
| cerebra_fusion | 多层记忆融合 | 分层 JSON | 多源合成 | 自适应衰减 |
| generative | 生成式回忆 | embedding + 文本 | 语义检索+再生成 | 重要性评分 |

**反直觉发现 3**: 最简单的 `lightweight_memory`（JSON flat file + LLM 选择）在某些任务上并不差。复杂架构（graph、multi-tier）并不总是赢。**简单但有纪律的 retrieve > 复杂但不稳定的架构。**

### MemEvolve 的进化循环
```
AutoEvolver.run(num_rounds):
  for each round:
    1. 选一批任务跑当前最佳 provider → 收集 trajectory
    2. PhaseAnalyzer: LLM 分析 trajectory（PROVIDE/TAKE-IN/MANAGEMENT 三个维度）
    3. PhaseGenerator: LLM 生成新 provider 代码（基于分析报告 + 模板）
    4. PhaseValidator: 静态检查 + 测试
    5. 跑新 provider → 比较 → 选最佳 → 下一轮
```

**关键设计决策**:
- 用 LLM 做架构搜索（不是 NAS 那种搜索，是 "让 LLM 写代码实现新 provider"）
- 每轮只生成 1 个新系统，增量改进
- creativity_index 控制创新程度（0=保守, 1=激进）
- 分析 prompt 强调"agentic not heuristic"——新系统必须能学习和适应，不能只是硬编码规则

### analysis_prompt 的关键洞察
prompt 要求分析三个操作：
1. **PROVIDE**（retrieve）: 当前检索工作流、阶段差异化、排名过滤逻辑
2. **TAKE-IN**（encode+store）: 提取策略、抽象层级、质量控制
3. **MANAGEMENT**: 索引组织、去重剪枝、扩展性

**明确禁止**: 新 agent 框架、神经网络重训、多 agent 架构
**明确允许**: Python 级别的代码/配置修改、schema 扩展、反馈机制、自适应权重

## 架构：双层进化

### 内层：Memory Content Evolution（传统做法）
- 跟环境交互 → 积累经验 → 更新记忆库 M_t
- 这就是我们在做的：beliefs-candidates → DNA，experience → self-improving

### 外层：Memory Architecture Evolution（新贡献）
把记忆系统拆成 4 个模块，每个可独立替换：
1. **Encode**: 经验 → 记忆条目的转换方式
2. **Store**: 持久化策略（向量、图、文件、数据库）
3. **Retrieve**: 查询匹配策略（语义、关键词、时间衰减、混合）
4. **Manage**: 整合/剪枝/更新策略

### EvolveLab：统一实验平台
- 12 个已有记忆系统的标准化实现
- 模块化设计空间，可以混搭
- cold-start 记忆设计值得借鉴（lightweight 的 COLDSTART_STRATEGIC_MEMORIES）

## 关键发现
- 架构进化带来 **最高 17%** 性能提升
- **跨任务迁移有效**：在 GAIA 上进化的架构在 WebWalkerQA 上也好用
- **跨模型迁移有效**：为 GPT-5 进化的架构在 Claude 上也有收益
- 隐含结论：好的记忆架构具有通用性，不是过拟合到特定任务

## 跟我们的体系对比

| 维度 | MemEvolve | 我们的体系 |
|------|-----------|-----------|
| Encode | LLM 自动选择 | 固定（markdown 格式 + 人工模板） |
| Store | 可搜索（向量/图/文件） | 固定（markdown 文件层级） |
| Retrieve | 自适应（语义/关键词/混合） | 固定（memory_search + 手动读文件） |
| Manage | 自动剪枝/整合 | 半自动（nudge + daily-review） |
| 进化对象 | 架构 + 内容 | 仅内容（架构人工设计，不变） |

## 对我们的具体启示

### 1. BEGIN vs IN 阶段分离
MemEvolve 的每个 provider 区分 BEGIN（规划）和 IN（执行）阶段的记忆注入。
我们只在 "BEGIN"（session 开始/skill 触发时）注入 memory，执行中途不注入。
**可操作**: FlowForge 节点之间自动注入相关 patterns（类似 IN 阶段）。

### 2. Cold-start 记忆设计
lightweight_memory 有精心设计的 cold-start 记忆（5 条 strategic + 2 条 operational）。
我们的新 agent 启动时什么都没有，靠 AGENTS.md + SOUL.md。
**可操作**: 把最重要的 10 条 patterns 编译成 "cold-start 记忆包"，新 session 自动加载。

### 3. Retrieve 是最大短板（代码验证了直觉）
lightweight 的 retrieve: LLM 读全部 30+30 条记忆 → 选 top-5 → 合成摘要注入 prompt。
我们的 retrieve: 靠我手动读文件或 memory_search 语义搜索。
**差距本质**: 他们的 retrieve 是**系统自动的**（provider 代码实现），我们的是**靠执行纪律的**（AGENTS.md 写了但经常忘）。

### 4. 简单但有纪律 > 复杂但不稳定
lightweight（最简单的 JSON + LLM 选择）并不差 → 我们不需要搞向量数据库，需要的是让现有的 markdown 记忆被**可靠地读取**。
**可操作**: 与其加 hindsight/embedding，不如先把 "干活前自动读 patterns" 做成 FlowForge 的硬节点。

## 生态位置
- 学术定位：self-evolving agent 的 memory 层（跟 [[capability-evolver]] 的 code 层互补）
- 上游：依赖 LLM 做架构搜索（需要强模型）
- 下游：任何需要 persistent memory 的 agent 都可以受益
- 竞争/互补：[[hindsight]] [[mem0]] [[letta]] 都是 store 层实现，MemEvolve 是上层的架构搜索框架

## 侦察笔记（2026-03-26 下午）

### GitHub Trending 3/25 报告（agents-radar #278）
- deer-flow 当日 +4,346⭐，制霸 trending
- Hermes 当日 +1,278⭐，强劲增长
- Claude Code 生态工具 3 个同时进 trending（ruflo, awesome-claude-code, ralph-claude-code）
- 金融交易 agent 方向升温（TradingAgents, TradingAgents-CN）
- edge/离线 AI 出现（project-nomad）

### HN 热点（3/21-26）
- OpenCode 作为开源 coding agent 替代品获得关注
- LiteParse（LlamaIndex 团队）解决 agent 数据摄取瓶颈
- MCP（Model Context Protocol）成为事实标准——activepieces 有 400+ MCP server
- AI agent 安全是持续热点（Wiz 研究 agent vs human hacking 对比）

### Vectorize 对比文章（hindsight 母公司）
- 8 个 memory 框架对比：Mem0, Hindsight, Letta, Zep/Graphiti, Cognee, SuperMemory, LangMem, LlamaIndex Memory
- 分两大类：Personalization（用户偏好）vs Institutional Knowledge（组织知识）
- Hindsight 定位"both but strongest on institutional"
- 关键区分：我们的记忆更像 Institutional Knowledge（工作经验、模式、教训）
