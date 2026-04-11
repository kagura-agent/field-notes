# CyberClaw

> 下一代透明智能体架构，专注安全审计和可控性。受 OpenClaw 启发。

- **repo**: ttguy0707/CyberClaw
- **创建**: 2026-04-07
- **语言**: Python (LangChain/LangGraph)
- **Stars**: 70 (4天)

## 核心机制

1. **两段式安全调用** (help → run): 先看 SKILL.md 说明，再决定执行。可反悔。类似 dry-run 模式。
2. **5类事件审计**: llm_input, tool_call, tool_result, ai_message, system_action → JSONL 日志 + Rich 终端
3. **双水位记忆**: 长期画像 (user_profile.md) + 短期摘要 (SQLite, 每 N 轮自动摘要)
4. **心跳任务**: 后台独立进程，daily/weekly/monthly，持久化
5. **跨平台**: Unix + Windows，路径拦截（禁 ../绝对路径）

## 安全设计值得借鉴

- **两段式调用**：OpenClaw 的 approval 机制类似但更粗粒度（approve/deny）。CyberClaw 的 help→run 让 agent 先理解工具再用，减少误用
- **路径拦截**：所有操作限制在 office/ 目录内。简单粗暴但有效
- **Shell 命令安全**：危险命令正则匹配 + 60s 超时熔断 + 强制非交互

## 生态位置

- 明确声称兼容 OpenClaw + Claude Code 技能生态
- 基于 LangChain/LangGraph，定位企业级
- 跟 OpenClaw 是互补关系：OpenClaw 是平台，CyberClaw 是上面的一种 agent 架构

## 对我们的启发

- "P0 事故率降 80%" 这个指标框架值得学——我们也可以量化安全改进
- 审计日志的 5 类事件分类比我们的更细
- 两段式调用的 UX 比 approve/deny 更柔和
