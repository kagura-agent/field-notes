# GenericAgent

> Self-evolving agent framework — grows skill tree from 3.3K-line seed
> GitHub: lsdefine/GenericAgent | ⭐ 7,626 (2026-04-27) | arXiv: 2604.17091
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
