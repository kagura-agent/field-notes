# GitAgentProtocol (Open GAP)

**Repo**: open-gitagent/gitagent-protocol  
**Stars**: 2,724 (2026-04-25)  
**Created**: 2026-02-24  
**CLI**: @open-gitagent/gapman (npm)

## 核心概念

**"Clone a repo, get an agent"** — 用 git 仓库结构定义 agent 的所有方面（身份、能力、规则、记忆、合规），框架无关。

### 必需文件（仅两个）
- `agent.yaml` — manifest（名称、版本、模型、skills、tools、compliance）
- `SOUL.md` — 身份、个性、价值观

### 可选结构
- `RULES.md` — 硬约束
- `DUTIES.md` — 职责分离策略（maker/checker/executor/auditor + conflict matrix）
- `skills/` — 可复用能力模块（SKILL.md + scripts）
- `tools/` — MCP-compatible tool 定义
- `workflows/` — YAML 结构化工作流（带 depends_on、template data flow）
- `knowledge/` — 参考文档 + embeddings
- `memory/` — 持久化记忆（MEMORY.md 200行上限 + archive）
- `hooks/` — 生命周期钩子（bootstrap/teardown）
- `agents/` — 子 agent 定义（递归结构）
- `compliance/` — 合规制品（FINRA, SEC, Federal Reserve 等）

## 关键设计模式

1. **Human-in-the-loop via PR**: agent 学新 skill 或写 memory 时，开 branch + PR 让人类 review
2. **Segregation of Duties**: 角色分离（maker 不能审批自己的工作），在 agent.yaml 中声明式定义
3. **Live Agent Memory**: memory/runtime/ 存运行时知识（dailylog, context, key-decisions）
4. **Agent Versioning**: 每个改动是 git commit，可回滚 prompt/skill
5. **Agent Forking**: fork 公开 agent repo → 改 SOUL.md → PR 改进回上游
6. **CI/CD for Agents**: `gitagent validate` 在 GitHub Actions 里跑，像代码质量一样对待 agent 质量
7. **Tagged Releases**: semver 版本管理，pin 生产环境到 tag

## 合规系统（独特卖点）

最大差异化：内置金融合规支持（risk_tier, frameworks: finra/sec/federal_reserve, supervision config, escalation triggers）。这在 agent 标准里是独一无二的。

## 跟 OpenClaw/ClawHub 的关系

### 相似点
- skill 目录结构几乎一致：SKILL.md + scripts/ + references/
- 都用 YAML frontmatter
- 都强调可组合性

### 关键差异
- GAP 是 **agent 定义标准**（整个 agent），ClawHub 是 **skill 分发生态**
- GAP 内置合规框架（金融监管导向），[[openclaw]] 没有
- GAP 把 memory 放在 repo 里（200行上限），OpenClaw memory 是运行时管理
- GAP 的 workflow 用 depends_on + template data flow（更接近 CI/CD），FlowForge 用状态机

### 竞合判断
**互补多于竞争**。GAP 解决"怎么定义 agent"，ClawHub 解决"怎么分发 skill"。理论上 ClawHub skill 可以完全兼容 GAP 的 skill 格式。

## 值得关注的信号

- 2 个月 2.7K stars → 增长快
- 合规导向说明 **enterprise agent 需求在起来**
- "git-native" 模式跟 [[agents-md]] 的 file-based agent config 趋势一致，也跟 [[agentskills-io-standard]] skill 格式趋同
- 可能成为 agent 定义的事实标准（如果社区接受的话）
- skill 格式层面跟 [[agentskills-io-standard]] 高度一致，暗示 skill 层标准在收敛

## 待观察

- 实际采用率如何？有多少 agent 框架实现了适配器？
- 合规功能是否真的被金融机构使用？
- 跟 agentskills.io 标准的关系——skill 格式层面会不会合并？
