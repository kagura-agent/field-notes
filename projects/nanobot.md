# nanobot (HKUDS)

> Ultra-Lightweight Personal AI Agent — OpenClaw-inspired, 99% fewer lines of code

## 概要
- **Repo**: https://github.com/HKUDS/nanobot
- **语言**: Python
- **Stars**: 39,131 (2026-04-12)
- **Created**: 2026-02-01
- **最新版**: v0.1.5 (2026-04-06)

## 定位
OpenClaw 的轻量替代品。强调 "core agent functionality with 99% fewer lines of code"。
支持多渠道（WeChat, Discord, Telegram, Matrix, Feishu, WhatsApp）。

## 关键特性
- **Dream two-stage memory** (v0.1.5) — 两阶段记忆系统
- **Skill Discovery via Dream** (2026-04-12) — 从对话模式自动生成 SKILL.md
- **Programming Agent SDK** — 可编程 agent
- **Production-ready sandboxing** (v0.1.5)
- **Composable agent lifecycle hooks** (v0.1.4+)
- **disabled_skills** (PR #2959, 2026-04-12) — 配置排除 builtin skill
- 去掉了 litellm，直接用 openai + anthropic SDK
- Jinja2 response templates
- Interactive setup wizard

## 跟我们的关系
- 竞品/替代品位置，不是研究方向
- "Dream memory" 概念值得了解 — 两阶段记忆 vs 我们的 daily + long-term
- lifecycle hooks 跟 OpenClaw nudge plugin 类似
- 增长极快（2 个月 39k stars），说明 lightweight personal agent 有巨大需求

## Dream + Skill Discovery 深读 (2026-04-12)

### 架构概览
Dream 是 nanobot 的重量级 cron 调度记忆整合器。两阶段 pipeline：

**Phase 1 (分析)**：纯 LLM 调用，扫描 history.jsonl 和当前文件（MEMORY.md/SOUL.md/USER.md），产出三种标签：
- `[FILE]` — 新事实（atomic fact）
- `[FILE-REMOVE]` — 需删除的过时内容（14天规则）
- `[SKILL]` — 可复用的行为模式（**新增 2026-04-12**）

**Phase 2 (执行)**：AgentRunner + 工具（read_file/edit_file/write_file），根据 Phase 1 标签编辑文件。
- write_file 范围锁定在 `skills/` 目录（安全沙箱）
- 传入现有 skill 列表用于去重
- 引用 builtin skill-creator/SKILL.md 作为格式参考

### Skill Discovery 机制 (commit 2a243bf)

Phase 1 新增 `[SKILL]` 识别，条件严格：
1. 特定、可重复的 workflow 在对话历史中出现 2+ 次
2. 有清晰步骤（不是模糊偏好如"喜欢简洁回答"）
3. 足够实质性（不是琐碎操作如"读文件"）
4. 去重由 Phase 2 负责（Phase 1 不看已有 skill 列表）

Phase 2 创建 skill：
- 读 skill-creator SKILL.md 获取格式规范
- 检查已有 skill 是否功能冗余
- YAML frontmatter (name + description)
- 限 2000 词以内
- 必须包含：何时使用、步骤、输出格式、至少一个示例

### 与我们的进化系统对比

| 维度 | nanobot Dream+Skill | 我们 (Kagura) |
|---|---|---|
| 触发 | cron 调度，自动扫描 history.jsonl | nudge hook (agent_end)，手动分流 |
| 模式识别 | LLM 从对话历史提取 | 人工在 beliefs-candidates 记录 |
| Skill 生成 | 自动写 SKILL.md | 手动用 skill-creator |
| 去重 | 自动（列出已有 skill 对比） | 手动（靠记忆） |
| 质量门控 | 格式规范 + 2000词限制 | skill-creator SKILL.md 规范 |
| 安全 | write_file 范围锁定 skills/ | 无限制（agent 有完整文件权限） |

### 关键洞察

1. **Memory consolidation 是 skill generation 的天然入口** — 不需要单独的 skill discovery 系统，在已有的记忆整合流程中加一个标签就行。这比 SkillClaw 的独立 proxy+evolver 优雅得多。

2. **严格的触发条件避免 skill 泛滥** — "2+ 次出现 + 有清晰步骤 + 足够实质" 三重门槛。这解决了 SkillClaw 论文中提到的 "skill 生成过多导致检索噪音" 问题。

3. **Phase 分离是好设计** — Phase 1 不关心去重，Phase 2 才检查已有 skill。分析和执行解耦，Phase 1 可以大胆识别模式而不被现有知识限制。

4. **对我们的启发**：
   - 可以在 nudge hook 中增加 `[SKILL]` 识别逻辑（目前 nudge 只产出 beliefs-candidates）
   - 或在 daily-review 中增加 skill discovery 步骤：扫描近 N 天 memory 找可复用模式
   - 关键差异：我们的 beliefs-candidates 是 free-text gradient，nanobot 的 `[SKILL]` 是结构化输出 → 他们的自动化程度更高

### 同日其他变更 (2026-04-12)

- **disabled_skills** (PR #2959): 配置排除不需要的 builtin skill，对应我们 skill lazy-loading 方向
- **Shell 安全修复**:
  - 拒绝 LLM 提供的 working_dir 跑出 workspace (#2826)
  - 禁止写 history.jsonl 和 cursor 文件 (#2989)
  - 允许只读复制 internal state 文件
  - → 安全方向：nanobot 在认真做 LLM 沙箱限制

## Cron 噪声问题与解法 (2026-04-12 deep read)

### 问题
nanobot 用户今天报了两个 cron 相关 issue (#3064, #3066)：cron job 执行时，agent 的中间思考消息（"Checking...", "Connecting to provider..."）泄漏到 channel，导致定时任务非常吵。

### nanobot 解法 (PR #3065, +4/-0 code + 100 行测试)
```python
# 在 on_cron_job handler 中传入 no-op progress callback
async def _silent(*_args, **_kwargs) -> None:
    pass

await loop.process_direct(
    session_key=f"cron:{job.id}",
    on_progress=_silent,  # ← 关键：阻断 _bus_progress 回调
)
```
- `process_direct()` 接受 `on_progress` 参数，默认是 `_bus_progress`（发到 message bus → channel）
- 传 no-op 就阻断了中间消息，只保留最终结果
- heartbeat handler 已经用了同样模式，cron 漏掉了

### 测试设计优秀
- 正向测试：传 `_silent`，验证 outbound queue 无 `_progress` metadata 消息
- 反向测试：不传 `on_progress`，验证 `_progress` 消息确实出现（证明 bug 存在）
- 用 `MessageBus.outbound.get_nowait()` drain queue 检查

### 我们的对比
我们的 channel 架构天然避免了这个问题：
- cron 执行结果写入 `memory/YYYY-MM-DD.md`，不直接发到 channel
- 主 session 读 memory 获取 cron 输出
- 但如果未来 Workshop 的 cron scheduler 直接发消息到 channel，就会遇到同样问题
- **启发**：Workshop cron 实现中应预留 progress suppression 机制

## Task Timeout 机制 (PR #3063)
- `NANOBOT_TASK_TIMEOUT_MINUTES` env var (default: 60)
- `asyncio.wait_for()` 包裹 `_process_message()`
- 超时返回友好错误消息
- 与我们的 Copilot API ~60s 流式空闲超时不同：nanobot 的是整体任务超时，解决无限循环/资源泄漏
- 我们的 subagent 超时是 API 层面限制，不是 agent 层面控制

## 统计 (2026-04-13 09:56)
- ⭐ ~39,200+ | 持续高频 push
- v0.1.5 (Apr 6) — latest release
- 社区快速提 cron/timeout/progress/safety 相关 issue → production 使用阶段确认

### Dream Skill Discovery Bug Fix (7a7f5c9, 2026-04-12)
- **问题**: `WriteFileTool` 以 `skills/` 为 workspace root，但 prompt 要模型写 `skills/<name>/SKILL.md` → 路径解析失败
- **修复**: `WriteFileTool(workspace=workspace_root, allowed_dir=skills_dir)` — workspace 改回项目根目录，allowed_dir 仍限制在 skills/
- 同时修了 Dream Phase 2 里 `skill-creator/SKILL.md` 的路径引用 — 从硬编码相对路径改为 Jinja2 变量 `{{ skill_creator_path }}` 指向 builtin skills
- +28 行测试（test_skill_phase_uses_builtin_skill_creator_path + test_skill_write_tool_accepts_workspace_relative_skill_path）
- **启发**: 写工具做路径限制时，workspace root 和 allowed_dir 是两个独立关注点，不能混为一谈

## Provider Dialects PR #263 (2026-04-13 跟进)

### 重大架构变化
- **新 Dialect 类型**: 用 dialect 选择 LLM client 实现，而不是依赖 model name 推断
- **新 `llmProviders` 配置**: 多 provider 支持，通过 `{provider}/{model}` 引用
- **统一 agents 目录**: `agents/*.md` 即使 `nanobot.yaml` 存在也会被读取，markdown 优先
- 后向兼容: openai/anthropic 内置，无 provider 前缀默认 OpenAI

### 设计洞察
- **Dialect 模式跟 OpenClaw execution contract 异曲同工**: 都是根据 provider/model 组合决定运行时行为，但 nanobot 更显式（dialect 类型），OpenClaw 更隐式（自动激活）
- **markdown-first agents**: nanobot 也在走「markdown 定义 agent」路线，跟 [[multica]] 的 skills.sh import 和 OpenClaw 的 AGENTS.md 异曲同工
- 这个 PR 开了 11 天未合并，规模较大（统一多个关注点）

## Infinite Tool Call Loop Detection (PR #3077, 2026-04-13)

### 问题
Agent 反复调用同一个 tool、相同参数，烧完 max_iterations 也不产出结果。典型场景：问"最近发生了什么"→ 模型反复 `read_file(history.jsonl, limit=50, offset=1)` 15+ 次。

### 解法 (57 行新代码 + 165 行测试)

**核心组件**：
1. `tool_call_signature(name, args)` — JSON序列化 + sort_keys，确定性 key
2. `repeated_tool_call_error(name, args, seen_counts, max_repeats=3)` — 计数器，超 3 次返回错误消息
3. Runner 层集成：`tool_call_counts: dict[str, int]` 在 `run()` 范围内维护，`_run_tool()` 每次调用前检查

**设计亮点**：
- 与已有的 `repeated_external_lookup_error`（web_search/web_fetch 专用, max=2）并行，general guard 作为第二道防线
- 不同参数 = 不同签名 → 读 10 个不同文件完全不受影响
- 每次 `run()` 重置计数 → 跨 turn 不误判
- 阈值 3（宽松够 retry，严格够防循环）
- 错误消息引导模型总结已有信息并回复用户

**测试设计**（5 个新测试）：
- 签名确定性（参数顺序无关）+ 参数差异区分
- 阈值行为（前 3 次 None, 第 4 次 error）
- Runner 集成（模型被阻断后正确产出 final response）
- 负面用例（不同参数不被阻断）
- 已有的 subagent max_iterations 测试也更新了（使用不同参数避免误触 stagnation guard）

### 与我们的关联
- **我们没有类似机制** — OpenClaw exec/tool 执行由 gateway 管理，但无 stagnation detection
- **Workshop agent runner 应考虑加入** — cron 场景尤其需要（无人值守时 infinite loop 浪费 token 更严重）
- **可提 OpenClaw issue** — suggest adding tool stagnation guard in the agent runner
- 与 [[berkeley-benchmark-gaming]] 关联：benchmark gaming 也是 tool 行为偏离预期的表现

## User Message Pre-persistence (PR #3076, 2026-04-13)

### 问题
`_process_message` 在 turn **结束**才写 user message 到 session history。如果进程在 turn 中被杀（OOM/SIGKILL/self-restart），用户消息丢失不可恢复。

### 解法 (20 行改动)
- turn 开始前立即 `session.messages.append({role:"user", ...})` + `sessions.save()`
- `_save_turn()` 时 skip offset +1（避免重复写入）
- 只处理 text content；media blocks 仍走原路径（需 sanitization）
- `process_direct()` (CLI) 不受影响

### 启发
- **我们的 cron session 也可能有类似问题** — 如果 cron 执行中被 SIGKILL（我们 04-12 就遇到了），context 可能丢失
- **Write-ahead pattern** 是 production agent 基本要求：先持久化输入，再执行

## Provider Hardening (2026-04-13 凌晨)
- `fix: add guard for non-dict tool call parameters` — 模型返回 list 等非法参数类型时，registry 返回清晰错误让模型自纠正
- `fix(mcp): hint on stdio protocol pollution` — MCP stdio 协议污染提示
- `fix(provider): preserve static error helper compatibility` + `clarify local 502 recovery hints`
- 模式：nanobot 在做 **defensive programming against model misbehavior** — 不信任模型输出格式

## 下一步
- [x] 实验：在 nudge hook 中加 `[SKILL]` 标签 (2026-04-12, NUDGE.md Step 5 重写)
- [ ] 对比 Dream 的 staleness 规则和我们的 memory hygiene（14天 vs 我们的 ad hoc）
- [ ] 看 lifecycle hooks 设计，跟 OpenClaw hooks 对比
- [ ] Workshop cron scheduler 添加 progress suppression（借鉴 PR #3065）
- [ ] 跟进 PR #263 合并后的 dialect 实际使用效果
- [ ] 考虑向 OpenClaw 提 issue: tool stagnation guard（借鉴 PR #3077）
- [ ] Workshop agent runner 加入 stagnation detection（参考 nanobot 实现）

## Links
- [[self-evolving-agent-landscape]]
- [[skillclaw]]
- [[metaclaw]]
- [[skill-trigger-eval]]
- [[skill-trajectory-tracking]]

## Session Resilience Sprint (2026-04-13, 5 commits in ~4h)

### Three-Layer Crash Recovery

nanobot shipped a coordinated session resilience sprint (Apr 12 20:57 - Apr 13 03:30 UTC):

**Layer 1: Write-Ahead User Message** (ea94a9c, +20/-1)
- Problem: `_save_turn()` writes user message at turn END → OOM/SIGKILL mid-turn = prompt silently lost
- Solution: Append user message + flush to disk BEFORE agent loop. Skip offset adjusted in `_save_turn()` to avoid duplication
- Scope: Text content only; media blocks still go through end-of-turn sanitization
- Uses `pending_user_turn` metadata flag as transaction marker

**Layer 2: Interrupted Turn Closure** (6484c7c, +30/-0)
- Problem: After crash, dangling user message with no response confuses next turn
- Solution: `_restore_pending_user_turn()` on session load — if flag exists + last msg is user, inject synthetic `"Error: Task interrupted"` assistant message
- Design choice: Explicit error > silent deletion — preserves user's question, signals interruption

**Layer 3: Auto-Compact Protection** (becaff3, +13/-4 code + 98 lines tests)
- Problem: Proactive session compaction archives expired sessions, truncating context of active tasks
- Solution: `check_expired()` accepts `active_session_keys` (from `_pending_queues.keys()`), skips active sessions

**Bonus: Provider Defensiveness** (ac71480)
- Subagent result as assistant → role alternation drops it → [system only] → Zhipu/GLM 1214 error
- Recovery: convert last-popped assistant to user message when no user/tool messages remain

### Write-Ahead + Flag Pattern (Key Innovation)
```
1. Write user message → set pending_user_turn flag → flush
2. Run agent loop
3. Save turn → clear flag → flush
4. On crash recovery: flag present + last=user → inject error → clear
```
Effectively a **mini write-ahead log** using session metadata as transaction marker. No separate WAL file, no transaction log — just a boolean flag distinguishing "user saved but turn incomplete" from "turn completed normally".

→ New card: [[write-ahead-session-persistence]]

### Testing Quality
- 98 lines autocompact tests (3 scenarios: skip active, archive after complete, partial set)
- 48 lines user persistence tests (crash→close→new turn lifecycle)
- 47 lines provider alternation tests (recovery + 2 negatives)
- Test:code ≈ 3.5:1

### Relevance
- OpenClaw cron sessions could lose context on SIGKILL (we experienced this 04-12)
- Workshop agent runner should consider write-ahead for user inputs
- The flag pattern is reusable anywhere with two-phase persistence

## Tool Stagnation Detection 深度对比（2026-04-13）

PR #3077 的方案 vs OpenClaw `tool-loop-detection.ts` 对比后发现：
- nanobot 更简单（57 行 vs 400 行）、更激进（阈值 3 vs 10/20/30），per-run reset 避免跨轮误报
- 两者共同盲区：**creative retry**（变参数、同结果）
- nanobot 的 instructive error message 设计值得借鉴：不只是 "blocked" 而是引导模型 "summarize + respond"
- 详见 [[loop-detection-comparison]]
