# GenericAgent

> Self-evolving agent framework — grows skill tree from 3.3K-line seed
> GitHub: lsdefine/GenericAgent | ⭐ 8,401 (2026-04-30) | arXiv: 2604.17091
> Created: 2026-01-16 | Language: Python | License: MIT

## 核心理念

"Don't preload skills — evolve them."

9个原子工具 + 4层记忆 = 一个能自进化的极简agent。核心代码仅~3K行（ga.py 560行 + agent_loop.py 130行 + llmcore.py 1016行）。

## 架构

### 9 Atomic Tools
`code_run`, `web_scan`, `web_execute_js`, `file_read`, `file_write`, `file_patch`, `ask_user`, `update_working_checkpoint`, `start_long_term_update`

### 4-Layer Memory (L1→L2→L3→L4)

| Layer | File | Content | Constraint |
|-------|------|---------|------------|
| L1 | global_mem_insight.txt | 场景关键词→位置的极简索引 | **≤30行 硬约束** |
| L2 | global_mem.txt | 环境事实（路径/凭证/配置） | 按section组织 |
| L3 | memory/*.md + *.py | 任务级SOP和工具脚本 | "关键前置+典型坑" |
| L4 | L4_raw_sessions/ | 历史会话压缩存档 | 自动管理 |

**关键原则：L1是指针不是摘要。** L1只写关键词和位置导航，禁止写How-to细节。

### Token Efficiency — "Contextual Information Density Maximization"

这不是一个算法，是一组架构决策：
1. **单轮消息制**：每轮只发 system prompt + 1条user message，不累积全量history
2. **Anchor Prompt**：每轮注入 `<history>` 最近40行摘要 + `<key_info>` 工作记忆
3. **每5轮压缩** `<thinking>`/`<tool_use>` tags
4. **每10轮重置工具描述**（防context膨胀）
5. **超60% context window时从头部pop消息**

本质是**"遗忘式进化"**——通过激进压缩+分层外部记忆替代大context window。

### Skill Crystallization — 实际机制

README说"automatically crystallizes execution path into skill"，实际实现是：
1. 任务完成 → LLM调用 `start_long_term_update`
2. 读取 `memory_management_sop.md`（这份SOP指导如何分层存储）
3. LLM提取"行动验证成功的信息"写入L2（事实）或L3（SOP）
4. 核心约束：**"No Execution, No Memory"** — 只有成功执行的结果才能记忆

**不是自动代码提取，是LLM引导的SOP生成。** Skill = SOP文档，不是可执行包。

## Skill Search — 百万级Skill库

`memory/skill_search/` 是一个外部API客户端（fudankw.cn:58787），支持按环境信息（OS/shell/runtime/tools）匹配skill。SkillIndex有丰富的元数据：quality_score(clarity×0.3+completeness×0.3+actionability×0.4), blast_radius, autonomous_safe等。

## 跟 [[self-evolving-agent-landscape]] 的位置

属于 **Skill层 + Memory层**，无Model层（不做微调）。最接近我们(Kagura)的方向：
- 他们用SOP文档=我们用SKILL.md（理念一致）
- 他们的L1索引≤30行=我们没有等价物（差距）
- 他们的token压缩=我们每轮全量加载SOUL+AGENTS+SKILL（差距）

## 反直觉发现

1. **Skill不是代码包** — 百万skill library全是SOP文档，不是可执行代码
2. **9工具 > 40+工具** — 限制工具数量降低LLM选择困难度
3. **不需要200K context** — <30K context + anchor prompt + 分层记忆就够
4. **memory_management_sop.md是真正的core** — 不是代码逻辑，是prompt指导LLM如何管理记忆

## 安全阀设计

- 每7轮：警告"禁止无效重试"
- 每65轮：强制ask_user
- Plan模式：每5轮强制re-read plan，90轮上限
- 空response/截断response：自动重试

## 可借鉴

1. **L1索引层**：wiki上加≤30行导航索引 → 减少语义搜索依赖
2. **"No Execution, No Memory"**：beliefs-candidates只记验证结论，不记观察
3. **anchor prompt模式**：可显著降低token消耗
4. **工具描述周期性重置**：防token膨胀的实用技巧

See [[self-evolving-agent-landscape]], [[mechanism-vs-evolution]], [[skill-creator]]

## Followup 2026-04-28

**Stars**: 7,626 → 7,866 (+240/day)
**Recent commits**: autonomous SOP refinement, TG streaming (#208), Codex CLI delegation (#182, closed)

### Autonomous Operation SOP 精简
- 收尾从多步改为4步必做：重读SOP → 写报告 → complete_task() → 标记TODO
- "完成即停不贪多" — 防止 agent 在自主模式下过度扩展
- 任务选择价值公式: "AI训练数据无法覆盖" × "对未来协作有持久收益"
- 权限边界三级: 只读免批 / 写入待审 / 绝对禁止
- 异步报告制: agent 写报告，人类归来后审查

### CLI Delegation PR #182 (closed)
- delegate_cli_task: 调用 gemini/qwen/claude/codex 本地 CLI
- check_cli_task: 检查异步输出/状态
- Permission modes: read_only, auto_edit, yolo
- **未被合并** — maintainer 可能倾向内建能力而非外部委托

### TG Streaming #208 (merged)
- 按 turn 分 Telegram 消息，每个 turn 独立消息
- `<summary>` 标签在 clean_reply() 前提取，渲染为 blockquote

## Followup 2026-04-29

**Stars**: 7,866 → 8,069 (+203/2d, sustained growth)
**Key commit**: 513fec9 — cleanup: remove NextWillSummary, add supervisor_sop, fix streaming fence, tighten L1 rules

### supervisor_sop.md — 新增监察者模式

"挑刺的监工，不是干活的工人" — 一个只读、只判断、只干预的 meta-agent。

**核心设计**:
- 红线：**禁止下场干活**（不操作浏览器、不写代码、不执行任务步骤）
- 启动：有SOP时提取约束清单存 working memory；无SOP时预估风险点
- 监控循环：持续轮询 `temp/{task_name}/output.txt`，对照约束清单检查每一步
- 用 `--verbose` 启动 subagent 获取原始工具执行结果，不信任摘要

**干预类型**:
| 信号 | 干预方式 |
|------|----------|
| 跳步/遗漏/光说不做/断言无据 | `_intervene`（纠正）|
| 连续失败 | `_intervene`: 先读错误日志再决定 |
| 即将进入关键步骤 | `_keyinfo`（提前注入细节到 working memory）|

**原则**: 沉默为主，一句话干预，像用户一样直接说。

**跟 subagent.md 的关系**: supervisor_sop 是 subagent 体系的 quality layer。subagent.md 定义了文件IO协议（input.txt / output.txt / _intervene / _keyinfo / _stop），supervisor_sop 利用同一协议但专注于监督而非执行。这是在已有多 agent 基础设施上的 separation of concerns。

**跟 Kagura 的关联**: 我们的 AGENTS.md 有 "验证他人输出：subagent/协作者说已完成→ 自己看代码/跑命令确认"，但这是 ad-hoc 的。GenericAgent 把它 formalize 成了一个专门的 agent role。如果 subagent 质量问题频繁出现，可以考虑类似的 supervisor 模式。

### NextWillSummary 移除 — 流式简化

- 删除了 `[NextWillSummary]` streaming tag 机制
- 之前：streaming 中检测 `[NextWillSummary]` tag → 截断输出 + 清空 tool state
- 现在：直接 yield 所有 chunks，无 tag 过滤
- 趋势：简化协议复杂度，减少 streaming path 的特殊逻辑

### L1 规则再收紧

**memory_management_sop.md 更新**:
- 旧："L1 只写关键词/名称，禁搬细节"
- 新："括号内只写场景触发词(2-4字)，禁写机制/方法/步骤"
- 反例：❌ `sop_name(场景A:方法1+方法2+方法3)` → ✅ `sop_name(场景A)`
- 这是我们 04-28 L1 评估时观察到的 ≤30行约束的进一步精化

### sop_index → L1 迁移 (PR #199)

- 社区贡献 (AspasZhang): plan_sop.md 从依赖 `sop_index.md` 文件改为依赖 L1 Insight (context-injected)
- L1 Insight (`global_mem_insight.txt`) 每轮自动注入上下文，无需额外文件读取
- **验证了我们的判断**: L1 作为 context-injected 导航索引比文件查找更高效 → 与我们的 [[l1-index-layer-evaluation]] 结论一致

### 生态活跃度

- 社区 PRs 活跃：DingTalk reconnect (#210), TG rate limits (#214), Feishu bot (#13), plan_sop fix (#199)
- 多个贡献者在构建 chat frontends（Telegram, Feishu, DingTalk, QQ, WeCom）
- 安全修复 PRs 出现 (Kailigithub: #224-#227, cap retries / HTTPS / dedup)
- 生态从 "maintainer solo" 进入 "community-driven frontend" 阶段

## Followup 04-30: Supervisor SOP + Stars 8,231

### supervisor_sop.md (新增)

**监察者模式** — 一个独立 agent 实时监控 worker agent 的质量：

- **核心原则**："你是挑刺的监工，不是干活的工人" — supervisor 只读、只判断、只干预
- **启动流程**：有 SOP 时提取约束清单存 working memory，无 SOP 时预估风险点
- **监控机制**：轮询 `temp/{task_name}/output.txt`，每次新输出对照约束清单检查
- **两种干预**：
  - `_intervene`：纠正已犯的错误（跳步、遗漏、断言无据、连续失败）
  - `_keyinfo`：在 worker 到达某步之前提前注入该步的 ⚠️ 细节（预防性）
- **干预风格**：沉默为主，一句话像用户一样直接说，禁长篇解释

**与我们 nudge 的对比**：
| | GenericAgent supervisor | OpenClaw nudge |
|---|---|---|
| 时机 | 实时在线（in-flight） | 事后反射（post-session） |
| 粒度 | 逐步骤检查 | 整体模式观察 |
| 干预方式 | 直接注入 worker context | 写入 beliefs-candidates |
| 预防性 | ✅ `_keyinfo` 提前注入 | ❌ 只记录不预防 |

**洞察**：supervisor 的 `_keyinfo` 预注入模式值得思考 — 我们的 nudge 是事后归纳，但 [[flowforge]] workflow 的节点 task 描述其实在做类似的事（提前告诉 agent 该步的约束），只是没有独立的 monitor agent 验证执行。

### 其他变化

- **NextWillSummary 被删除**：streaming fence protection 简化，`[NextWillSummary]` tag 不再使用
- **_parse_mixed_response 去重**：提取共用 `_parse_text_tool_calls`，减少代码冗余
- **Stars 8,275** (+644 in 3 days, 04-27→04-30)，增速显著

See [[self-evolving-agent-landscape]], [[context-budget-constraint]], [[l1-index-layer-evaluation]], [[write-read-gap]], [[supervisor-pattern]]

## Followup 04-30 (PM): Stars 8,306, supervisor_sop full read

**Stars**: 8,231 → 8,306 (+75 intraday)

### supervisor_sop.md 全文确认

直接读了 supervisor_sop.md 原文（42 行），比之前 commit message 推断更准确：

**文件 IPC 协议** — supervisor 和 worker 之间通过文件系统通信：
- `_intervene` 文件 → worker 下一轮 prompt 追加 `[MASTER] <内容>`
- `_keyinfo` 文件 → worker 的 `key_info` working memory 追加 `[MASTER] <内容>`
- `consume_file()` 读取并删除，确保一次性注入
- `[MASTER]` 前缀让 worker LLM 理解这是来自更高权限的指令

**这不是 LLM routing，是文件系统消息总线** — 架构上比 API 调用更简单：supervisor 写文件 → worker 每轮 poll 文件。Race condition 不是问题因为单写单读。

**干预决策表**（7 种触发条件，全部一句话干预）：
1. 跳步 → "你跳过了StepN，先做"
2. 细节遗漏 → "你漏了XX约束，重做"
3. 光说不做 → "别说了，直接做"
4. 断言无据 → "你怎么确认的？验证一下"
5. 连续失败 → "停，先读错误日志再决定"
6. 感觉要偏 → "去重读SOP的StepN再继续"
7. 即将进入关键步骤 → `_keyinfo` 提前注入

### L1 收紧的具体规则

从 commit diff 确认：
- 旧："L1 只写关键词/名称，禁搬细节"
- 新增反例：❌ `sop_name(场景A:方法1+方法2+方法3)` → ✅ `sop_name(场景A)`
- 括号内限 2-4 字场景触发词，禁止机制/方法/步骤描述

### subagent max_iterations 同步 (nanobot 对比)

nanobot (41,316⭐) 同期也在做 subagent 治理：`_sync_subagent_runtime_limits()` 确保 subagent 继承 parent 的 max_iterations。GenericAgent 的 supervisor 模式和 nanobot 的 iteration limits 是两种 subagent 质量控制路径：
- **GenericAgent**: 质性监控（supervisor 理解语义，判断每步对不对）
- **nanobot**: 量化限制（硬性 iteration 上限防失控）
- 两者互补，我们目前只有 nanobot 式的超时机制，无 supervisor 式质性监控

See [[supervisor-pattern]], [[self-evolving-agent-landscape]]

## Update 2026-04-30

⭐ 7,626 → 8,401 (+775, steady growth). Recent commits (04-28~04-29):

1. **Removed NextWillSummary**: Pruned a feature that pre-summarized the next step. Suggests the team found it added noise rather than value — the supervisor pattern makes pre-summary redundant since the supervisor already watches each step.
2. **Streaming fence protection fix**: Hardened streaming output parsing. Likely edge cases from tool_use outputs containing markdown fences.
3. **Backtick sanitization in code_run output**: Prevents LLM from misinterpreting shell output as markdown.
4. **Deduplicated `_parse_mixed_response`**: Reusing `_parse_text_tool_calls` instead of duplicate parsing logic.
5. **Unified stream retry**: Both mixin and non-mixin paths now retry on mid-stream disconnects.
6. **DingTalk adapter**: Exponential reconnect backoff and token fetch retry (PR #210).
7. **Telegram polish** (PR #214): Community contribution.

The codebase is in a maturation phase — cleanup, hardening, adapter expansion. No new architectural features, but the supervisor_sop pattern added on 04-29 is the most significant conceptual addition since the skill evolution system.

## Followup 2026-05-01

**Stars**: 8,401 → 8,480 (+79/day, growth sustained but slowing from +200/day peak)

### Status: Maturation Phase

No new commits since 04-29. The codebase is digesting the supervisor_sop addition and cleaning up technical debt. Community contributions continue (DingTalk, Telegram, plan_sop refactor), but the core architecture is stable.

### Signal: L1 Rule Discipline Still Tightening

The memory_management_sop.md反例 pattern ("括号内只写场景触发词 2-4字") confirms an ongoing theme — L1 gets progressively tighter through usage. Our [[l1-index-layer-evaluation]] should expect similar refinement cycles for `wiki/L1.md`.

## Followup 2026-05-05: Two-Tier History + CDP Bridge + Peer Hints

**Stars**: 8,480 → 9,113 (+633/4d, growth re-accelerated after brief slowdown)

### Three Significant Architecture Changes (05-02~05-05)

#### 1. Two-Tier History Folding (`_fold_earlier` + `earlier_context`)

The biggest change since supervisor_sop. History is now split into two tiers:

| Tier | Window | Treatment |
|------|--------|-----------|
| Recent | Last 30 lines | Verbatim in `<history>` |
| Earlier | Everything before | Folded: consecutive Agent turns collapsed to `"[Agent] (N turns)"` |

**Key design decision**: User messages are kept as anchors, agent actions are summarized. This acknowledges that user intent matters more than agent execution details for context.

Previous approach was a flat 40-line window. Now it's `<earlier_context>` (folded) + `<history>` (last 30, verbatim). The folded section caps at 150 lines after folding.

**Why this matters for us**: Our sessions load full SOUL+AGENTS+SKILL every turn. GenericAgent's progressive compression preserves long-session coherence without proportional token cost. The "fold agent turns, keep user turns" heuristic is simple and effective — worth evaluating for [[flowforge]] long-running workflows.

#### 2. CDP Bridge `contentSettings` Command

New CDP bridge command for Chrome's `contentSettings` API:
```js
{"cmd": "contentSettings", "type": "automaticDownloads", "pattern": "https://*/*", "setting": "allow"}
```

Bypasses Chrome's "download multiple files" dialog that blocks all JS execution. `Browser.setDownloadBehavior` (the standard CDP approach) doesn't work in extensions — this is the workaround.

Also added `management` command for extension listing/reload/disable/enable.

**Pattern**: When standard CDP methods fail in extension context, fall back to Chrome's extension-specific APIs (`chrome.contentSettings`, `chrome.management`). The CDP bridge is becoming a full browser control surface, not just a cookie/tab manager.

#### 3. Peer Hint Mechanism

New `peer_hint` flag (default: True for interactive, False for subagent/reflect mode):
```
[Peer] 用户提及其他会话/后台任务状态时: temp/model_responses/ (只找近期修改的文件尾部)
```

This tells the agent how to check on sibling sessions — read their output files. Disabled for subagent/reflect modes (they shouldn't peek at peers).

**Insight**: This is a minimal multi-session awareness mechanism. Rather than building complex inter-agent communication, they just tell the agent where to look for sibling state. File-based IPC continues to be GenericAgent's universal integration pattern ([[supervisor-pattern]]).

### Other Changes

- **Auto-inject summary**: When model outputs `thinking+tool_use` without text, auto-injects "直接回答了用户问题" as summary to maintain history consistency
- **Resume prompt v5**: Simplified from regex-heavy technical instructions to natural language ("帮我看看最近有哪些会话可以恢复"). Trend: prompts getting more conversational, less procedural
- **`compress_history_tags` now includes `earlier_context`**: The 5-round compression cycle covers the new folded section too
- **Terminal QR for WeChat**: Terminal-based QR code display for headless WeChat login
- **`_pending_tool_ids` cleanup**: Fixed orphan tool_result after `/new` command

### Growth Analysis

| Period | Stars | Rate |
|--------|-------|------|
| 04-27→04-30 | 7,626→8,306 | +227/d |
| 04-30→05-01 | 8,306→8,480 | +174/d |
| 05-01→05-05 | 8,480→9,113 | +158/d |

Growth sustained at ~150-200/day. Community PRs continue (QT UI, WeChat QR, timeout fixes). 5 open community PRs.

### Trend: From "Flat Context" to "Structured Memory Budget"

GenericAgent's evolution path:
1. **v1**: Fixed 40-line history window
2. **v2** (now): Two-tier folded history (30 recent + compressed earlier)
3. **Likely next**: Dynamic window sizing based on task complexity

This parallels the broader ecosystem trend in [[context-budget-constraint]]: everyone is converging on "keep recent details, compress older context" rather than "stuff everything in a big window."

See [[self-evolving-agent-landscape]], [[context-budget-constraint]], [[supervisor-pattern]], [[l1-index-layer-evaluation]]
