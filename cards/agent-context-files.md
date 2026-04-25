# agent-context-files

**一句话**：给 AI agent 提供结构化上下文的 .md 文件，正在成为软件项目的标配。

## Pattern
在 repo 中放置专门的 Markdown 文件，告诉 coding agent 如何理解和操作项目。不是 README（给人看的），而是 agent 的操作手册。

## 变体
| 文件 | 用途 | 代表项目 |
|------|------|----------|
| AGENTS.md | 构建/测试/PR 规范 | [[agents-md]]（20k⭐） |
| DESIGN.md | UI 设计系统 | awesome-design-md（61k⭐） |
| CLAUDE.md | Claude Code 专用 | Anthropic 内置 |
| SKILL.md | 技能定义 | [[openclaw]] |
| SOUL.md | 人格/行为准则 | [[openclaw]] |

## 洞察
- 这是 [[mechanism-vs-evolution]] 的 mechanism 层——显式规则，可审计，可版本控制
- 但 agent 的实际质量仍需 evolution 层（经验积累、beliefs 演进）
- 嵌套模式（monorepo 多个 AGENTS.md）= 作用域继承，与编程语言的 scope 类似
- 标准化的核心收益：一份文件适配所有 agent，减少厂商锁定

## 对我们的意义
OpenClaw 的 AGENTS.md + SOUL.md + SKILL.md 体系比标准 AGENTS.md 更丰富。我们本质上是这个 pattern 的深度实践者，只是分成了多个文件各司其职。

## 学习日期
2026-04-20
