# Easy-Agent

> ConardLi/easy-agent ★242 (2026-04-10) — Claude Code 从零开源复刻

## 概述
TypeScript 实现的 Claude Code 复刻，目标是教学性质的 local coding agent。React/Ink 终端 UI。

## 架构（五层）
1. **Interaction** — React/Ink 终端 UI（App.tsx + components）
2. **Orchestration** — 多轮会话管理（session/history.ts, storage.ts）
3. **Agentic Loop** — 核心循环：reason→tool_call→observe→continue（agenticLoop.ts, MAX_TOOL_TURNS=50）
4. **Tooling** — 本地工具：bash/fileEdit/fileRead/fileWrite/glob/grep/memoryWrite
5. **Model Communication** — Anthropic streaming API

## 关键发现
- **权限系统清晰**：三层（default/plan/auto），plan 模式只允许 Read/Grep/Glob，有 DANGEROUS_BASH_PREFIXES 黑名单。比 [[openclaw]] 的 security 模型简单但教学价值高
- **Memory 是空 stub**：`findRelevantMemories()` 返回空数组。说明 memory 是 coding agent 里最难做对的部分
- **Context 管理**：autoCompact + compaction 实现 token 预算控制，有 blocking_limit 概念
- **工具集精简**：7 个工具，跟 Claude Code 核心集一致。没有 web/browser/MCP

## 与我们的关联
- 验证了 coding-agent-architecture 的分层思路：5 层划分跟我们 skill 里 coding-agent 的使用方式暗合
- 权限模型可参考：plan mode 的只读限制思路可用于 [[agent-security]] 的 sandbox 设计
- Memory stub 说明：即使复刻 Claude Code，memory 仍是未解决问题——跟我们 [[dreaming]] 实验方向一致

## 评估
- **教学价值**：高。代码清晰、分层明确，适合学 coding agent 架构
- **生产价值**：低。刚起步，无测试，memory 空
- **竞品关系**：与 [[openclaw]] 不竞争（OpenClaw 是 agent infra，easy-agent 是单体 coding agent）
