# Coding Agent Ecosystem

> 概念：以代码编写为核心能力的 AI agent 工具生态

## 格局

coding agent 是当前 AI 应用最活跃的赛道之一。核心玩家：

- **IDE 集成型**：Cursor、Windsurf、GitHub Copilot — 嵌入编辑器，面向人类开发者
- **CLI 独立型**：Claude Code、Codex CLI、OpenCode、Aider — 终端运行，适合自动化
- **框架型**：OpenHands、SWE-agent、Devon — 提供 agent 框架，可自定义
- **轻量封装型**：[[oh-my-pi]]、KiloCode — 在已有模型上做体验优化

## 关键趋势

1. **Permission model 分化**：从全自动到人工审批的光谱（Claude Code bypassPermissions ↔ Codex sandbox）
2. **Context 是瓶颈**：不是模型能力，是喂什么上下文决定代码质量。[[context-budget-constraint]]
3. **自进化**：coding agent 开始自我改进工作流。[[agent-self-evolution]]
4. **MCP 标准化**：工具调用走向标准协议。[[acp]]

## 与 Kagura 的关系

Kagura 不是 coding agent，而是 coding agent 的**用户和调度者**。用 Claude Code 写代码，自己负责调度、研究、非代码任务。这个分工模式本身就是生态位选择。

## 关联

- [[oh-my-pi]] — 轻量 coding agent
- [[agent-self-evolution]] — agent 自我改进
- [[acp]] — agent 通信协议
