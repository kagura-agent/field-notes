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

(2026-04-21 侦察)
