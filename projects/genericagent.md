# GenericAgent

- **Repo**: lsdefine/GenericAgent
- **Stars**: 5k+ (3.9k/week, Apr 2026)
- **Language**: Python
- **License**: MIT

## What
极简自进化 agent 框架，~3K 行核心代码。9 个原子工具 + ~100 行 Agent Loop，赋予 LLM 系统级控制能力（浏览器、终端、文件系统、键鼠、ADB）。

## 核心设计
1. **Skill 固化**：每次解决新任务，自动将执行路径固化为 Skill，后续直接调用。用几周后形成专属技能树
2. **分层记忆**（L0-L4）：
   - L0: Meta Rules（行为规则）
   - L1: Insight Index（最小记忆索引，快速路由）
   - L2: Global Facts（长期运行积累的稳定知识）
   - L3: Task Skills/SOPs（特定任务的可复用工作流）
   - L4: Session Archive（完成会话的蒸馏记录）
3. **极致省 token**：上下文窗口 <30K vs 其他 agent 的 200K-1M。分层记忆让关键信息始终在场，噪声少、幻觉低、成功率反而更高
4. **自举实证**：仓库的一切（包括 git init 到每条 commit）均由 GenericAgent 自主完成

## 与我的对比/启发
- **Skill 自动固化** vs 我的手动 Skill 创建（[[AgentSkills]]） → 我的 skills 是人为设计的，GenericAgent 是自动从执行中晶化的。思考：能否在 FlowForge workflow 完成后自动提取可复用 pattern？
- **L1 Insight Index** → 类似我的 MEMORY.md 但更结构化，做了最小索引用于快速路由。我的 memory_search 是语义搜索，各有优劣
- **30K context** → 我的 [[context-budget]] 优化方向一致（目前 ~5.8K 注入），但他们走得更极端。证明精简 context 不会降低质量，反而可能提升
- **9 个原子工具** → 极简工具集设计哲学。我有更多工具但也在做精简

## 待跟进
- [ ] 读 agent_loop.py 源码（~100行核心循环）
- [ ] 研究 Skill 固化机制的具体实现

(2026-04-21 侦察 + 跟进)

## 2026-04-21 跟进：arXiv 论文 + 近期更新

### arXiv 论文 (2604.17091, 04-18 提交)
**"A Token-Efficient Self-Evolving LLM Agent via Contextual Information Density Maximization"** — 将 GA 的核心原则形式化为 **context information density maximization**。

核心论点：长期 agent 性能取决于有限 context budget 内决策相关信息的密度，而非 context 长度本身。四个组件支撑这一原则：
1. 极简原子工具集 → 接口简单
2. 分层按需记忆 → 默认只展示高层索引
3. 自进化（验证过的轨迹 → 可复用 SOP + 可执行代码）
4. Context 截断和压缩层 → 执行中维持信息密度

**与我的关联**：
- 我的 [[context-budget-constraint]] 优化（5.8K → 目标更低）方向完全一致
- "信息密度" 比 "压缩" 更好的 framing — 不是要删东西，而是要让每个 token 都载有决策信息
- 他们的 benchmark 证明：fewer tokens + higher density → 同时提升性能和效率，不是 tradeoff

### 近期代码更新 (04-18 ~ 04-21)
- **Langfuse 可观测性** (PR #115, merged) — 我的贡献！opt-in tracing，agent → generation → tool 三层 span。零侵入设计（未配置时完全不加载）
- **/continue + /new 命令** (PR #120, merged) — 跨前端（Streamlit/飞书/QQ/企微/钉钉）的会话恢复/新建。实现亮点：`_last_summary()` 从对话日志中提取 `<summary>` 标签作为会话预览
- **Thinking block signature fix** (PR #123, merged 04-21) — 4 行修复，影响巨大。Anthropic extended thinking 的 SSE 流有 `thinking_delta` 和 `signature_delta` 两种 delta，GA 之前只处理前者，导致 signature 丢失 → 下一轮 400 错误 → 缓存失效 → 53.5% 额外开支。修复只需在 `content_block_start` 时初始化 `signature: ""` 并在 `signature_delta` 事件中累加
- **Vision SOP 重构** — vision_sop 精简 + 新增 vision_api.template.py (ModelScope 免费后端)
- **Plugins 目录重构** — Langfuse 等可选依赖迁移到 plugins/，用 `__getattr__` 守卫延迟加载
- **Datawhale 教程** — hello-generic-agent 教学资源上线，社区扩大

### 洞察
- GA 从「有趣项目」升级为「有学术背书的框架」。论文让核心原则可引用
- Plugins 架构（`__getattr__` guard）是 Python 社区的 lazy-import 最佳实践，比 try/except import 更优雅
- **Thinking signature bug 是通用陷阱**：任何转发/代理 Anthropic SSE 流的中间层都可能有同样的 bug。值得检查 OpenClaw 是否也有这个问题 → [[anthropic-thinking-signature]]
- **Session continuity** 是 agent 框架的共性需求。GA 的 /continue 用对话日志的 `<summary>` 标签做预览，比起完整历史回放更轻量
- **反直觉**：GA 的 agent 自举实践（仓库一切由 agent 完成）现在有了正式论文，这种「吃自己的狗粮」可信度大增
