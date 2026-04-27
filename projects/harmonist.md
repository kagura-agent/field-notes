# Harmonist

- **Repo**: [GammaLabTechnologies/harmonist](https://github.com/GammaLabTechnologies/harmonist)
- **Stars**: 709 (2026-04-27, 创建于 ~04-21)
- **Language**: Python (stdlib only), Bash
- **License**: MIT
- **First seen**: [[agent-ecosystem-scout-2026-04-25]] (357★)

## What It Does

Portable AI agent orchestration for Cursor/Claude Code/Copilot，核心卖点是 **mechanical protocol enforcement**——用 IDE hook 而非 prompt 强制 agent 遵守规则。

## Architecture

### Mechanical Enforcement via IDE Hooks

Cursor hooks（`sessionStart`, `afterFileEdit`, `subagentStart`, `subagentStop`, `stop`）在每个 agent 动作前后运行 Python/shell 脚本。核心门禁在 `stop` hook：

- 检查 reviewer agent 是否运行过
- 检查 memory 是否更新且 schema-valid
- 检查 session-handoff.md 是否有匹配 correlation_id 的条目
- 不通过 → 返回 `followup_message` → agent 被迫重试（`loop_limit: 3`）

**关键洞察**：这不是"建议" agent 遵守规则，而是状态机硬门禁。agent 无法 bypass——它只收到一个 followup message，必须完成缺失步骤。

### State Machine on Disk

`session.json` 追踪：writes, reviewers_seen, correlation_id, task_seq。全部 stdlib Python，零运行时依赖。

### Supply-Chain Verification

`MANIFEST.sha256` 哈希每个 agent 定义文件。安装/升级时 SHA 校验，篡改的 agent 文件被拒绝。

### Memory Schema + Secret Scanning

结构化 memory entries 带 frontmatter（id, correlation_id, kind, status, author）。correlation_id 由 hook 生成（`<session_id>-<task_seq>`），LLM 不可伪造。

Secret pattern 扫描：~30 类 credential patterns（AWS keys, GitHub PATs, Stripe tokens 等），防止 agent 不小心把密钥写入 memory。

### 186 Agent Catalog

16 个类别的角色卡。本质是 **persona prompt + YAML metadata**，不是功能性 agent。包含小众领域（Roblox Luau, 小红书, WeCom）。

## Assessment

### Strengths

1. **"Enforcement as hooks" 是真实创新**。解决了 prompt-based governance 的根本缺陷。
2. **零依赖**。纯 stdlib Python + bash，任何环境都能跑。
3. **Memory 防伪造**。correlation_id 由基础设施生成，不信任 LLM。

### Red Flags

1. **单 commit + 单作者**。整个 repo 是一次性提交，709 stars/week 增速异常。可能是 AI 生成 + star farming。
2. **Cursor 绑定**。hook API 是 Cursor 专有的，不可移植到其他 IDE/agent 框架。
3. **186 agents 是虚荣指标**。大部分是模板化 persona prompt，不是真正的能力差异。

## Relation to Our Direction

### 对比 [[OpenClaw]] ACP

| 维度 | Harmonist | OpenClaw ACP |
|------|-----------|-------------|
| Enforcement 机制 | IDE hooks (Cursor 专有) | Session spawn + approval flows |
| Agent catalog | 186 persona prompts | ClawHub skills (功能性) |
| 可移植性 | 仅 Cursor | 跨 IDE/agent |
| Memory 保护 | Schema + secret scan | memex (语义搜索) |
| 依赖 | 零 | Node.js runtime |

### 值得借鉴

- **Secret scanning for memory writes**：我们的 memex/wiki 写入没有 credential 泄露检查。可以在 wiki-lint 里加 secret pattern 扫描。
- **Correlation ID 不信任 LLM**：我们的 session tracking 已有类似机制，但 memex 写入没有防伪造。

### 不需要借鉴

- Hook-based enforcement：ACP 已有更灵活的机制
- Agent catalog 数量：质量 > 数量

## Ecosystem Position

- **竞争**：[[agentskills-io-standard|AgentSkills.io]]、[[clawhub|ClawHub]] 在 agent catalog 层面
- **互补**：hook enforcement 概念可以跟任何框架结合
- **定位**：Cursor 专属 governance layer，不是通用 agent 框架

---

*Updated: 2026-04-27 — deep read from quick scout*
