# agents.md (agentsmd/agents.md)

- **URL**: https://github.com/agentsmd/agents.md | https://agents.md
- **Stars**: 20k+ (2026-04-20, was 206 when first noted)
- **Status**: Linux Foundation Agentic AI Foundation 管理的开放标准

## 概要
AGENTS.md 是给 coding agent 的 README——标准化的 Markdown 文件，放在 repo 根目录，告诉 agent 怎么构建、测试、提 PR。

## 核心设计
- **与 README 分离**：README 给人看，AGENTS.md 给 agent 看（构建命令、代码规范、测试步骤等）
- **跨 agent 兼容**：Codex、Cursor、Jules、Amp、Factory 等都支持
- **嵌套支持**：monorepo 每个子目录可放自己的 AGENTS.md，最近的优先
- **无固定 schema**：纯 Markdown，没有必填字段
- **冲突规则**：最近的 AGENTS.md > 远的；用户 chat 指令 > 文件

## 推荐内容
1. 项目概述
2. 构建和测试命令
3. 代码风格指南
4. 测试说明
5. 安全注意事项
6. PR/commit 规范

## 与 [[OpenClaw]] 的关系
OpenClaw 的 AGENTS.md 就是这个模式的实践。我们的 AGENTS.md 更像 "agent 的操作手册 + 行为准则"，比标准模板更丰富（包含记忆管理、安全红线、DNA 自治等）。对比 [[SkillClaw]]——SKILL.md 本质上是 domain-specific 的 AGENTS.md。

## 启发
- **嵌套 AGENTS.md**：OpenAI 主 repo 有 88 个 AGENTS.md。对我们的 skill 目录可以借鉴——每个 skill 目录的 SKILL.md 本质上就是嵌套的 AGENTS.md
- **标准化收益**：一份文件适配多个 agent，减少维护成本。与 [[mechanism-vs-evolution]] 相关——AGENTS.md 是 mechanism（显式规则），但 agent 的实际行为仍需 evolution（beliefs-candidates 积累）
- 从 206⭐ 到 20k⭐ 的爆发说明 "agent 需要项目上下文" 是刚需
- 参考 [[awesome-design-md]]（VoltAgent, 61k⭐）——同一 pattern 扩展到 UI 设计系统

## 学习日期
2026-04-20
