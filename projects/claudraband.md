# Claudraband — Claude Code for Power Users

> 田野笔记 2026-04-13

## 基本信息
- **Repo**: halfwhey/claudraband
- **Stars**: ~143 (2 days old, 2026-04-11 created)
- **语言**: TypeScript (monorepo: claudraband-cli + claudraband-core)
- **License**: 未注明
- **HN**: Show HN post, 97 points

## 定位
Claude Code TUI 的会话管理层——保持 session alive、resume、远程控制、HTTP daemon、ACP server。

## 核心功能
1. **Resumable non-interactive workflows**: `cband continue <session-id> 'question'`（本质是 `claude -p` + session 持久化）
2. **HTTP daemon**: `cband serve --host 127.0.0.1 --port 7842`，远程无头 session 控制
3. **ACP server**: 给编辑器和替代前端提供集成接口
4. **TypeScript library**: 可嵌入自己的工具
5. **Terminal runtime**: 优先 tmux，备选 xterm.js (实验性)

## 架构
```
claudraband-core (library)
├── session management (create, resume, list)
├── terminal runtime (tmux / xterm.js)
├── ACP server
└── HTTP daemon API

claudraband-cli (CLI wrapper)
├── cband "task"          → one-shot
├── cband sessions        → list
├── cband continue <id>   → resume
├── cband serve           → daemon mode
└── cband attach <id>     → interactive attach
```

- 内置 `@anthropic-ai/claude-code@2.1.96`（可通过 `CLAUDRABAND_CLAUDE_PATH` 覆盖）
- tmux 作为 session 持久化基础（跟我们的 tmux skill 类似的思路）

## 跟我们的关系
- **我们已经有类似能力**：OpenClaw 的 coding-agent skill 用 `claude --print --permission-mode bypassPermissions` + PTY，但没有 session persistence
- **差异**：Claudraband 保持 Claude Code 的完整 TUI session alive（可以 resume 问后续问题），我们是 fire-and-forget
- **潜在启发**：如果需要多轮 Claude Code 会话（如 iterative debugging），Claudraband 的 tmux-backed session 模式比我们的 one-shot 更灵活
- 但我们当前的 one-shot 模式已经够用（subagent delegation + FlowForge 多步骤）

## 竞品定位
- 类似 [[nanobot]]/ralph 的思路（wrap CLI agent as infrastructure），但更窄（只 Claude Code）
- 跟 OpenClaw ACP 有功能重叠（Claudraband 的 ACP server ↔ OpenClaw 的 ACP runtime）
- 2 天 143 stars 说明有真实需求，但可能是 Claude Code 热度的长尾效应

## 不值得深追的原因
- 太新（2 天），架构可能大变
- 只支持 Claude Code（不是 multi-agent orchestrator）
- 我们有 OpenClaw 做 orchestration，不需要另一层 Claude Code wrapper

## 关联
- coding-agent skill — 我们当前的 Claude Code 集成方式
- [[claude-code-plugins]] — Claude Code 的官方扩展机制
- [[claude-mem]] — 另一个 Claude Code 生态工具
