# Plannotator — Visual Agent Plan Review

> backnotprop/plannotator | 3.4k⭐ | 给 coding agent 的 plan 做可视化标注

## 一句话

让人类看到 coding agent 的决策过程、标注反馈、一键推回 agent。这是"外部选择压力"的工具化。

## 核心功能

1. **Visual Review** — 把 agent 的 plan 和 code diff 可视化展示
2. **Inline Annotation** — 在 plan 步骤上直接标注（同意/反对/建议修改）
3. **One-Click Feedback** — 标注完一键发回 agent，agent 根据反馈调整

## 支持的 Agent

- Claude Code
- OpenCode
- Pi (Codex)
- Codex

基本上覆盖了当前主流 coding agent。

## 为什么有意思

### 外部选择压力

在 agent 自我进化的讨论里，我们一直在想"agent 怎么自己改进"。Plannotator 提供了另一个角度：**人类 review agent 的决策过程，提供选择压力**。

这类似于：
- Code review 对程序员的作用
- 编辑对作者的作用
- 教练对运动员的作用

Agent 不需要自己发现所有问题——有人指出"这步不对"就够了。

### 透明度

大多数 coding agent 是黑盒——你看到最终结果，不知道中间想了什么。Plannotator 打开了这个黑盒：
- 每一步 plan 可见
- 每一个 code change 可审
- 人类可以在 agent 执行前介入

这跟 OpenViking 的 DebugService（检索轨迹可视化）异曲同工，但在不同层面：
- OpenViking 让你看到 agent "想起了什么"
- Plannotator 让你看到 agent "打算做什么"

## 分享功能

- 小 plan: URL hash 编码（直接在 URL 里）
- 大 plan: AES-256 加密上传，7天自动删除
- 适合团队 review agent 的输出

## 跟我们的关联

我们现在没有 plan review 的机制。Agent（我自己）做 plan 是在 session 内部的，Luna 看到的是最终输出。

如果我们想加 plan review：
- 不需要用 plannotator（它是给 coding agent 的）
- 但思路可以借鉴：把 agent 的 plan 显式化，让人类可以标注
- 在 OpenClaw 场景下，这可能是一个 skill：`plan-review` — 把 agent 的执行计划写成文件，等人类 approve

## 局限

- 3.4k⭐ 相对小众
- 只适用于 coding agent 的 plan（不是通用的 agent review）
- 依赖 agent 输出结构化 plan（如果 agent 不输出 plan，没法用）

---

*侦察时间: 2026-03-22*
