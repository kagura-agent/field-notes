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
- **Subagent 驱动**: 每个工程任务一个 fresh subagent，然后 review — 类似 [[flowforge]] spawn 节点
- **Plugin marketplace 模式**: 通过 marketplace 分发 skills

## 深读笔记 (2026-04-11)

### 规模与增长
- 145k⭐, 12.5k forks — 本周 trending 没上榜但稳定巨大
- 语言: Shell（技巧性的——skills 就是 markdown，不需要编译）
- 零依赖设计：不引入任何第三方库

### Skill 架构细节
- **SKILL.md 结构**: YAML frontmatter（name + description）+ markdown body
- **触发机制**: description 字段以 "Use when..." 开头，agent 根据意图匹配
- **Skill 工具调用**: Claude Code 用 `Skill` tool，Gemini 用 `activate_skill`，Copilot 用 `skill` tool
- **强制性**: "even 1% chance a skill might apply → MUST invoke" — 极端强制策略
- **优先级**: User instructions > Superpowers skills > Default system prompt

### Skill 创建哲学 — TDD for Skills
- **核心洞察**: Writing skills = TDD applied to process documentation
- RED: 跑 baseline，看 agent 没有 skill 时怎么犯错
- GREEN: 写 skill，让 agent 遵守
- REFACTOR: 找新的绕过方式，堵住
- **反模式**: 不先看 agent 失败就写 skill = 不写测试就写代码

### PR 管理 — 94% 拒绝率
- 明确反对: bulk PRs, speculative fixes, compliance rewrites, fork syncs
- 要求: 真实问题驱动，人类审查 diff，搜索已有 PR
- **教训**: 高星项目的 contribution bar 极高，agent 打工需要精准

### 对我们 skill 系统的启示
1. **description 字段规范**: 我们的 SKILL.md 也用 description 匹配，superpowers 证明这个模式有效
2. **TDD for skills**: 我们可以借鉴——写 skill 前先看 agent 不用 skill 时犯什么错
3. **零依赖哲学**: skill 就是 markdown，越简单分发越广
4. **强制 vs 建议**: superpowers 极端强制（1% 就触发），我们偏温和（"clearly applies"）

## 与我们的关联

- **[[agentskills]] 的同路人**: 都在做 composable agent skills，但 superpowers 专注 coding workflow
- **自动触发 vs 显式调用**: superpowers 靠意图识别自动触发 skill，[[openclaw-architecture]] 靠 SKILL.md description 匹配 — 理念一致
- **Marketplace**: superpowers 已经在多个平台的 plugin marketplace 上线，是 skill-distribution 的参考案例
- **对比 [[Archon]]**: Archon 做 harness builder（构建 agent），superpowers 做 skill framework（增强 agent）— 不同层
- **反直觉**: 不是新 framework，是寄生在现有 coding agent 上的 skill 层 — 暗示 skill 层比 framework 层有更大的分发优势

## 应用记录

### 2026-04-11: TDD for Skills → coding-agent SKILL.md
- **RED（失败模式识别）**: 从 beliefs-candidates.md 提取 5 个已记录的 coding-agent 失败：手写代码×2、不测试就 push×2、误杀 --print 进程×1
- **GREEN（写规则）**: 新增 Rule #10（test-before-push）、#11（never-hand-write-code）、扩展 #3（--print patience）
- **REFACTOR（防绕过）**: 加入 "Known Failure Modes" 表，每条失败映射到规则，让未来的 agent 有具体案例参考而非抽象规则
- **验证**: 规则可直接 grep 检查——如果 subagent 输出包含 `edit` 而非 `claude`/`codex`，说明 #11 被违反
- **效果预期**: 减少"改了没测"和"自己动手写"两类最高频错误
