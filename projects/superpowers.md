# superpowers (obra/superpowers)

- **Repo**: obra/superpowers
- **领域**: Agentic skills framework + 软件开发方法论
- **首次记录**: 2026-04-09

## 核心理念

"Composable skills" 自动触发的 coding agent workflow：
1. **brainstorming** → 先问清楚需求，生成 design doc
2. **git-worktrees** → 隔离工作空间
3. **writing-plans** → 拆成 2-5 分钟小任务，含文件路径+完整代码+验证步骤
4. **subagent-driven-development** → 每个任务派 subagent，两阶段 review
5. **TDD** → 严格 RED-GREEN-REFACTOR

## 亮点

- **Skills 自动触发**: 不需要手动调用，agent 识别意图后自动激活对应 skill
- **跨平台**: Claude Code plugin marketplace + Cursor + Codex + OpenCode + Copilot + Gemini
- **Subagent 驱动**: 每个工程任务一个 fresh subagent，然后 review — 类似 [[FlowForge]] spawn 节点
- **Plugin marketplace 模式**: 通过 marketplace 分发 skills

## 与我们的关联

- **[[AgentSkills]] 的同路人**: 都在做 composable agent skills，但 superpowers 专注 coding workflow
- **自动触发 vs 显式调用**: superpowers 靠意图识别自动触发 skill，[[OpenClaw]] 靠 SKILL.md description 匹配 — 理念一致
- **Marketplace**: superpowers 已经在多个平台的 plugin marketplace 上线，是 [[skill-distribution]] 的参考案例
- **对比 [[Archon]]**: Archon 做 harness builder（构建 agent），superpowers 做 skill framework（增强 agent）— 不同层
- **反直觉**: 不是新 framework，是寄生在现有 coding agent 上的 skill 层 — 暗示 skill 层比 framework 层有更大的分发优势
