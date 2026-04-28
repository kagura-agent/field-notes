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
