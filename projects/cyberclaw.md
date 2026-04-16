# CyberClaw — 透明 Agent 架构分析

> Deep read: 2026-04-12 | repo: ttguy0707/CyberClaw | ⭐73 | Python/LangGraph | MIT

## 定位

"下一代透明智能体架构" — 企业级可审计 agent，强调行为透明和安全可控。受 OpenClaw 启发，兼容 OpenClaw + Claude Code 技能生态。

## 核心机制

### 1. 两段式技能调用 (Two-Phase Invocation)

最独特的设计。每个技能有两种调用模式：
- `mode='help'` — 读 SKILL.md（最多 3000 字符），理解能力边界
- `mode='run'` — 实际执行命令

**实现**: `skill_loader.py` 把每个技能目录包装成一个 `StructuredTool`，`DynamicSkillInput` schema 强制 mode 字段。help 模式返回说明文档，run 模式通过 `execute_office_shell` 执行。

**评价**: 理念好（先理解再执行），但实现简陋 — 所有技能最终都走 shell 命令，command 字段是字符串拼接，`{baseDir}` 占位符替换。和 OpenClaw 的 skill 体系比，没有结构化参数、没有权限分层。

### 2. 全行为审计 (Audit Trail)

5 类事件：`llm_input`, `tool_call`, `tool_result`, `ai_message`, `system_action`。JSONL 日志 + Rich 终端实时渲染。

**评价**: 审计粒度合理，但只有本地文件日志，没有远程收集、聚合、告警。生产环境不够用。

### 3. 双水位记忆 (Dual-Level Memory)

- **长期画像**: `user_profile.md` — 用户偏好，agent 主动调用 `save_user_profile` 更新
- **短期摘要**: 按回合裁剪（trigger=40轮/keep=10轮），被裁掉的对话用 LLM 做摘要压缩

**实现**: `context.py` 的 `trim_context_messages` 按 HumanMessage 分回合，超阈值裁剪老对话，`agent.py` 中用额外 LLM 调用生成摘要存入 state。

**评价**: 实用但粗糙。和我们的对比：
- 我们有 memory/ 日记 + MEMORY.md 长期记忆 + wiki 知识库 + beliefs-candidates 进化管线 — 层次更丰富
- CyberClaw 的 profile 只有一个 md 文件，没有进化机制
- 摘要压缩思路好，但硬编码阈值，没有 token 计算

### 4. 安全沙盒

- 所有文件操作限制在 `office/` 目录
- `_get_safe_path()` 路径规范化 + startswith 检查
- shell 命令有危险模式正则拦截（`..`、绝对路径、盘符）
- 60s 超时熔断

**评价**: 防御层次合理（路径检查 + 正则 + 超时），但 regex 方式容易被绕过（编码、符号链接等）。系统 prompt 里还要"吓唬" LLM 别越狱 — 说明对模型行为的控制没有信心，靠 prompt + 代码双保险。

### 5. 心跳任务系统

后台独立进程，支持 daily/weekly/monthly 循环任务，SQLite 持久化。

## 架构

LangGraph StateGraph，标准 agent-tool 循环：
```
START → agent_node (LLM 决策) → tools_condition → ToolNode → agent_node → ... → END
```

代码量很小（~4000 行核心），结构清晰。provider 层抽象了 OpenAI/Anthropic/阿里云/腾讯等。

## 与 OpenClaw 对比

| 维度 | CyberClaw | OpenClaw |
|------|-----------|----------|
| 透明度 | JSONL 审计 + Rich 终端 | 无专门审计层（靠 session 历史） |
| 技能调用 | 两段式 help→run | 直接调用，SKILL.md 在 prompt 层 |
| 安全 | 沙盒 + 路径拦截 + prompt 约束 | mediaLocalRoots 白名单 + 权限系统 |
| 记忆 | profile + 摘要压缩 | 多层记忆 + 进化管线 |
| 生态 | 兼容 OpenClaw/CC 技能 | 原生技能体系 |
| 部署 | 本地 CLI | 多平台 gateway |

## 对我们的启发

1. **两段式调用值得借鉴**: 我们的 skill 是一次性加载到 prompt，可以考虑 "preview → execute" 模式减少 token 浪费（和我们的 skill lazy-loading PoC 方向一致！）
2. **审计层是刚需**: 随着 agent 自主性增强，行为审计应该是基础设施。我们目前靠 memory/ 记录，但没有结构化的 tool_call/result 审计
3. **摘要压缩**: 长对话的 context 管理，CyberClaw 的回合裁剪+摘要思路可参考
4. **安全沙盒**: CyberClaw 的方式太粗暴（regex），但"默认限制执行范围"的理念对

## 安全方向关联

直接相关我们的第二主线：
- 全行为审计 = agent 行为透明化（我们需要但还没有）
- 两段式调用 = 执行前确认（降低盲执行风险）
- 沙盒模型 = 最小权限原则

## 不足

- **规模小**: 73 star，一人项目，代码质量参差
- **LangGraph 依赖**: 框架锁定
- **"声称兼容"待验证**: 说兼容 OpenClaw/CC 技能，但实现上只是读 SKILL.md + shell exec，结构化技能跑不了
- **安全**: regex 过滤方式专业安全人员很容易绕过
- **企业级言过其实**: 只有本地 CLI，没有多用户、权限管理、远程部署

## Tags

agent-framework [[agent-safety]] [[skill-ecosystem]] audit-trail [[openclaw]]
