# mini-coding-agent

> Sebastian Raschka 的极简 Python coding agent，单文件 1019 行，零外部依赖

- **Repo**: rasbt/mini-coding-agent
- **Stars**: ~615 (2026-04-14)
- **语言**: Python (标准库 only)
- **关注理由**: 教学级 agent loop 拆解，Raschka 影响力大
- **首次记录**: 2026-04-14 quick scout

## 架构

6 个显式组件：
1. **Live Repo Context** (WorkspaceContext) — 启动时一次性采集，不动态更新
2. **Prompt Shape & Cache Reuse** — prefix(stable) + memory + transcript + request
3. **Structured Tools** — 6 tools, JSON + XML 双格式，path sandbox, approval gates
4. **Context Reduction** — clip() 截断 + history 智能压缩（recent 900 chars, older 180 chars, read_file 去重）
5. **Session Persistence** — JSON file, 极简 memory {task, files≤8, notes≤5}
6. **Bounded Delegation** — depth-limited subagent, child=read_only

Agent loop: user_msg → prompt → model.complete() → parse → tool/retry/final

## 关键设计决策

- **XML tool format**: `<tool name="write_file" path="..."><content>...</content></tool>` — 小模型(4B-7B)写多行代码时比 JSON 更可靠（不容易搞坏 escaping）
- **重复调用检测**: 连续两次相同 tool+args → 自动拒绝，防死循环
- **双重循环边界**: tool_steps(工具预算) vs attempts(总尝试含 retry)，retry 不消耗工具预算
- **Prompt-as-string**: 不用 chat API，自己拼 raw prompt → 完全可控 prompt 结构
- **FakeModelClient**: 预设输出序列做 orchestration 测试，不依赖真实模型
- **零依赖**: 只用 Python 标准库，连 requests 都不用

## 与 [[OpenClaw]] 对比

| 维度 | mini-coding-agent | OpenClaw |
|------|-------------------|----------|
| 哲学 | 可理解性 | 可扩展性 |
| 工具 | 6 个固定 tools | Skill 生态 + MCP |
| 模型 | Ollama 本地 4B+ | 云端大模型 |
| Memory | {task, files, notes} | MEMORY.md + daily + wiki |
| 进化 | 无 | [[beliefs-candidates]] → DNA |
| 安全 | path sandbox only | 多层安全模型 |

## 对我们的启发

- **XML tool format** 对小模型支持有参考价值 — [[skill-ecosystem]] 如果扩展到本地模型需考虑
- **重复调用检测** 简单有效，OpenClaw 目前依赖模型自己不重复
- **History 智能压缩** (recent=大额度, older=小额度, read 去重但 write 后重置) 比简单截断更精细
- **FakeModelClient** 测试模式 — skill 测试可借鉴
- 作为 **baseline benchmark**: 1000 行能做到什么 vs OpenClaw 多出来的部分解决了什么

## 不足（我们已解决的）

- 无 streaming、无并发、无多模态
- WorkspaceContext 不动态更新（agent 改了文件，context 过时）
- Security: run_shell auto 模式 = 任意命令执行
- 单层 delegation, child read-only
- 无 [[self-evolving-agent-landscape]] 机制

## 状态

- [x] 首次深读 (2026-04-14)
- [ ] 读配套文章 Components of a Coding Agent (Substack)
- **持续关注**: Y — 观察社区怎么扩展它（加什么功能），作为 agent 生态演进的风向标
