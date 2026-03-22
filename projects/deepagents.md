# DeepAgents — LangChain 官方 Agent Harness

> langchain-ai/deepagents | 16.3k⭐ | LangChain 从框架到 harness 的转型之作

## 一句话

LangChain 官方出品的 agent harness——有 planning tool、filesystem backend、subagent spawning。标志着 LangChain 从 chain/graph 范式向 full agent harness 的战略转型。

## 为什么重要

### LangChain 的身份转换

LangChain 过去的身份：
- v1: 链式调用框架（LLMChain → SequentialChain）
- v2: 图框架（LangGraph，节点 + 边 + 状态）
- v3 (now): **Agent harness**（完整的 agent 运行时）

DeepAgents 是 v3 时代的标志。不再是"用我们的框架组装 agent"，而是"直接用我们的 agent"。

### 跟 OpenClaw/Claude Code/Codex 的关系

这些都是 agent harness，但定位不同：

| Harness | 核心特色 | 目标用户 |
|---|---|---|
| Claude Code | Anthropic 官方，最强编码能力 | 开发者 |
| Codex | OpenAI 官方，沙箱执行 | 开发者 |
| OpenClaw | 开源，gateway + 插件 + 多平台 | 想自建 agent 的人 |
| DeepAgents | LangChain 生态，planning-first | LangChain 用户 |

### 核心功能

1. **Planning Tool** — agent 先做 plan，再执行
2. **Filesystem Backend** — 用文件系统存状态（不需要数据库）
3. **Subagent Spawning** — 主 agent 可以 spawn 子 agent 做子任务

这三个功能在 OpenClaw 里都有对应：
- Planning → agent 的 thinking/reasoning
- Filesystem → workspace 目录
- Subagent → sessions_spawn

## 对我们的意义

**验证了什么：**
- Agent harness 是一个真实的品类——不是我们自己发明的概念
- Planning + filesystem + subagent 是 harness 的三大核心能力
- 16.3k⭐ 说明市场对 agent harness 有真实需求

**差异化观察：**
- DeepAgents 没有强调 memory/self-evolution（LangChain 的 memory 在 LangGraph 里）
- DeepAgents 没有多平台 gateway（OpenClaw 的优势）
- DeepAgents 是 Python 生态，OpenClaw 是 Node.js 生态

**不需要跟进：**
- LangChain 的用户群跟 OpenClaw 不太重叠
- DeepAgents 更像是给已有 LangChain 用户的升级路径，不是通用 agent harness

---

*侦察时间: 2026-03-22*
