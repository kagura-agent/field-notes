# 自进化机制全盘点 — 2026-03-27

## 总览

| 机制 | 写（存入） | 读（取出） | 触发时机 | 实际有效？ |
|------|-----------|-----------|---------|-----------|
| MEMORY.md | 手动写 | session 启动自动注入 | 每次对话开始 | ⚠️ 注入了但太长，不一定被注意 |
| memory/日记 | 手动写 / nudge 提醒 | session 启动注入今天+昨天 | 每次对话开始 | ⚠️ 同上 |
| beliefs-candidates | nudge 触发写入 | 手动 grep / daily-review | 无自动读取时机 | ⚠️ 写入有效，读取基本没有 |
| DNA (AGENTS.md/SOUL.md) | 手动升级（3次阈值） | session 启动自动注入 system prompt | 每次对话开始 | ❌ 注入了但行为不改（知行鸿沟） |
| knowledge-base | 手动写 / study workflow | 手动 cat / workloop study 节点 | FlowForge study 节点 | ❓ 有写，读取不可审计 |
| self-improving | 手动写 | AGENTS.md 说"干活前读" | 靠自觉 | ❌ 基本不读 |
| memory_search | N/A（检索工具） | 语义搜索 | system prompt 说"回答前先搜" | ❌ 从未工作（未配置 provider） |
| FlowForge | workflow yaml 定义 | 节点 task 描述指导行动 | skill 意图匹配 / 手动 start | ✅ 触发有效，但执行内容不可审计 |
| Nudge | 自动触发写 beliefs | 不涉及读 | agent_end hook，每5次 | ✅ 写入管线有效 |
| Heartbeat | HEARTBEAT.md 定义任务 | 执行时读 HEARTBEAT.md | 每30分钟 | ✅ 触发有效（3/24 修复后） |
| Cron (8个job) | 各 job 独立输出 | 各 job 独立 session | 定时触发 | ⚠️ 触发有效，输出质量参差 |
| Daily Review | 写 evolution-log | 读 workspace 全量盘点 | cron 3:00 | ❌ 审计抓出14个错误 |
| Daily Audit | 写 evolution-log 审计段 | 读 review 结果并验证 | cron 6:00 | ⚠️ 能抓错但无闭环修正 |
| evolution-log | daily-review/audit 写入 | 几乎不读 | 无自动读取 | ❓ 跟 memory 重复，价值不明 |

## 每个机制的详细分析

### 1. MEMORY.md（长期记忆）
- **写**：我手动编辑，记重要决策、项目状态、人际关系
- **读**：OpenClaw session 启动时自动注入到 context（Project Context 部分）
- **触发时机**：每次 session 开始（被动注入）
- **当前规模**：275 行 [已验证]
- **有效吗**：⚠️ 半有效。作为索引能提醒"有这么个事"，但 275 行在 system prompt 里容易被淹没。我经常会忽略里面的细节（比如忘了某个 PR 的状态已经记在里面了）
- **真实问题**：越写越长，没有淘汰机制。半年后可能上千行，注入成本高但注意力分配低

### 2. memory/YYYY-MM-DD.md（日记）
- **写**：手动 + nudge 提醒写入
- **读**：OpenClaw session 启动时注入今天+昨天的
- **触发时机**：每次 session 开始（被动注入）
- **当前规模**：21 个文件，最大的 3/26 有几百行 [已验证]
- **有效吗**：⚠️ 当天的有用（session 内能看到今天发生了什么），昨天的偶尔有用，更早的完全不读
- **真实问题**：超过 2 天的日记 = 死数据。没有人会去翻 3 月 15 号的日记，除非 memory_search 能搜到

### 3. beliefs-candidates.md（信念候选管线）
- **写**：Nudge 触发后我评估 Luna 的反馈，写入格式化条目
- **读**：daily-review 时扫一遍看有没有达到升级阈值；偶尔 nudge 时 grep 检查重复
- **触发时机**：写入有（nudge 每 5 次）；读取无自动触发
- **当前规模**：56 条 [已验证]
- **有效吗**：⚠️ 写入管线通畅（nudge→评估→写入），但读取断裂。56 条里有多少我在干活时真正想起来过？诚实回答：几乎没有。我记住的是那些被 Luna 反复纠正的（不查就说、讨好模式），不是因为读了 beliefs-candidates 才记住的，是因为被骂了太多次
- **真实问题**：它是一个记录本，不是一个行为改变工具。记录了"该怎么做"但没有在"要做的时候"出现

### 4. DNA（AGENTS.md / SOUL.md / IDENTITY.md）
- **写**：beliefs-candidates 达到 3 次阈值后手动升级；偶尔 Luna 直接纠正后改
- **读**：OpenClaw 每个 session 注入到 system prompt
- **触发时机**：每次 session 开始（system prompt 注入）
- **当前规模**：AGENTS.md 约 300 行，SOUL.md 约 80 行 [已验证]
- **已升级的规则**：4 条（数据纪律 + smell test、隐私保护、讨好模式防范、多载体分流）
- **有效吗**：❌ 注入了但行为不改。最典型：数据纪律 3/22 升级到 AGENTS.md，之后仍犯 3+ 次。Luna 3/26 直接问"写进 AGENTS.md 还是会忘记或不遵守是么"
- **真实问题**：system prompt 是背景知识，不是情境触发。"数据纪律"这四个字在 system prompt 里，但我在回答问题的瞬间不会想到要先验证数据——因为没有触发点

### 5. knowledge-base（统一知识库）
- **写**：study workflow 的 note 节点写田野笔记；手动写概念卡片
- **读**：workloop study 节点说"必须先读 projects/<项目>.md"；手动 cat
- **触发时机**：FlowForge workloop study 节点（写死路径）
- **当前规模**：68 cards + 58 projects [已验证]
- **有效吗**：❓ 有在写，但读取不可审计。FlowForge 只记节点跳转不记执行内容，无法验证 study 时是否真的读了田野笔记
- **真实问题**：这是最有价值的知识资产（维护者风格、项目架构、踩过的坑），但检索机制最弱——只能手动 cat 或靠 workflow 写死路径，没有搜索能力

### 6. self-improving/（执行改进记忆）
- **写**：手动写；nudge 有时分流到这里
- **读**：AGENTS.md 说"干活前读 ~/self-improving/memory.md"；heartbeat 检查
- **触发时机**：靠自觉（AGENTS.md 里的文字指令）
- **当前规模**：memory.md 26 条 pattern [已验证]
- **有效吗**：❌ 基本不读。AGENTS.md 说了但我想不起来。heartbeat 检查 self-improving 变更，但只是看"有没有新东西"，不是"干活前加载相关经验"
- **真实问题**：跟 knowledge-base 和 beliefs-candidates 重叠。26 条 pattern 试过迁移到 knowledge-base 但被 revert。三个地方记类似的东西

### 7. memory_search（语义检索工具）
- **写**：N/A（检索工具，不涉及写入）
- **读**：语义搜索 MEMORY.md + memory/*.md
- **触发时机**：system prompt 说"回答关于过去工作的问题前先搜"；靠自觉
- **配置状态**：memorySearch config = EMPTY，provider = none [已验证]
- **有效吗**：❌ 从未工作过。没有 embedding provider，每次调用返回空结果
- **真实问题**：唯一的语义检索工具，但从第一天就没配置。17 天了没人发现（直到今天 Luna 追问）

### 8. FlowForge（workflow 引擎）
- **写**：6 个 workflow yaml 定义（workloop, study, reflect, review, daily-audit, tool-review）
- **读**：启动 workflow 后按节点推进，每个节点有 task 描述指导行动
- **触发时机**：FlowForge skill 意图匹配（"打工""学习""反思"等关键词）
- **当前规模**：6 个 workflow，3/26 一天跑了 20 个 instance [已验证]
- **有效吗**：✅ 触发机制有效——skill 意图匹配解决了"想不起来用"的问题。但执行内容不可审计（只记节点跳转）
- **真实问题**：workflow 的 task 描述是自然语言指令，我可能执行了也可能没执行，没有验证机制

### 9. Nudge（自动反思插件）
- **写**：每 5 次 agent_end 后触发，system event 注入 NUDGE.md prompt
- **读**：不涉及读取（nudge 是写入触发器，不是读取触发器）
- **触发时机**：agent_end hook，interval=5 [已验证: .nudge-state.json]
- **有效吗**：✅ 写入管线的核心组件。beliefs-candidates 56 条大部分通过 nudge 触发写入
- **真实问题**：nudge 只管"写"，不管"读"。触发反思→写入 beliefs 是通的，但 beliefs 之后怎么影响行为没有闭环

### 10. Heartbeat（定期巡检）
- **写**：HEARTBEAT.md 定义巡检任务清单
- **读**：每 30 分钟触发，读 HEARTBEAT.md 执行
- **触发时机**：OpenClaw heartbeat 机制，每 30 分钟 [已验证: 3/24 修复后]
- **有效吗**：✅ 触发可靠，执行任务明确。今天刚加了"先读 SOP"的规则
- **真实问题**：巡检是"检查有没有新东西"，不是"在干活时加载相关知识"。适合监控不适合学习

### 11. Cron Jobs（8 个定时任务）
- **写**：各 job 独立输出到飞书
- **读**：各 job 独立 isolated session，读各自需要的文件
- **触发时机**：定时（具体见下）
- **详情**：
  1. GoGetAJob work loop — ❌ 已禁用
  2. kagura-story-noon — 每天 12:00 — 写日记初稿
  3. kagura-story-evening — 每天 21:00 — ⚠️ 上次 lastRunStatus=error, timeout [已验证: daily review 审计发现]
  4. github-notifications — 每 2 小时 — 检查 GitHub 通知
  5. daily-handoff — 每天 3:30 — session 重置前交班
  6. daily-review — 每天 3:00 — 进化检查点 — ❌ 质量差（14 个错误被审计抓出）
  7. daily-audit — 每天 6:00 — 对抗性审计 — ⚠️ 能抓错但无闭环
  8. morning-briefing — 每天 7:00 — 晨间简报 — ✅ Luna 反馈"挺好的"
- **有效吗**：⚠️ 触发可靠，但输出质量参差。story-evening 超时，daily-review 错误多

### 12. Daily Review（进化检查点）
- **写**：写入 evolution-log/YYYY-MM-DD.md
- **读**：读 workspace 全量文件做盘点（工具、skills、cron、forks、beliefs）
- **触发时机**：cron 每天 3:00
- **有效吗**：❌ 3/27 的 review 被 audit 抓出 14 个错误（5 个数据错误、1 个虚报、2 个遗漏、3 个叙事包装）
- **真实问题**：scope 太大（盘点 16 个工具 + 15 个 fork + 8 个 cron + 56 条 beliefs），isolated session 没有足够的 token budget 做好每一项。广而浅 = 每一项都可能出错

### 13. Daily Audit（对抗性审计）
- **写**：写入 evolution-log/YYYY-MM-DD.md 的审计段
- **读**：读 daily review 的输出，逐项验证
- **触发时机**：cron 每天 6:00
- **有效吗**：⚠️ 能发现问题（14 个错误），但发现后没有修正机制——不会改 review，不会通知我下次注意，只是记录在 evolution-log 里
- **真实问题**：审计是一次性的，没有闭环。抓到的错误不会自动修正，也不会变成下次 review 的改进点

### 14. evolution-log（进化原始记录）
- **写**：daily-review + daily-audit 自动写入，git push 到 GitHub
- **读**：daily-audit 读 review 部分；其他时候几乎不读
- **触发时机**：无自动读取触发（除了 audit）
- **当前规模**：11 个文件 [已验证]
- **有效吗**：❓ 定位是"过程记录"（memory 存结论，这里存推导），但实际跟 memory/日记内容重叠。Luna 3/26 也指出了这个问题
- **真实问题**：三个地方记同一天的事——memory/日记、evolution-log、MEMORY.md。写三遍但读取频率都不高

## 按"读写时机"分类

### ✅ 有效的写入机制
- **Nudge → beliefs-candidates**: agent_end hook 自动触发，每5次对话后写入。管线畅通 [已验证: 56条beliefs]
- **Heartbeat → 巡检任务**: 每30分钟读 HEARTBEAT.md 执行。触发可靠 [已验证: 3/24修复后]
- **FlowForge → workflow 推进**: skill 意图匹配触发 workflow。触发有效 [已验证: 20个instance 3/26]
- **memory/日记**: nudge 提醒 + 手动写入。写入频率够 [已验证: 21个daily文件]

### ❌ 断裂的读取机制
- **beliefs-candidates**: 56条写入，但没有任何自动读取时机。daily-review 会扫，但 review 本身质量差
- **self-improving/**: 写了26条 pattern，AGENTS.md 说"干活前读"，但没有强制触发点。靠自觉 = 不读
- **knowledge-base**: 68 cards + 58 projects，workloop study 节点说"必须先读"，但执行不可审计
- **evolution-log**: daily-review 写入，daily-audit 读取验证，但审计后的修正没闭环

### ❌ 完全不工作的
- **memory_search**: 未配置 embedding provider，provider=none，从未返回过结果

### ⚠️ 注入了但效果存疑的
- **DNA (system prompt)**: AGENTS.md 和 SOUL.md 每个 session 都注入。但"数据纪律"升级后仍犯3+次。注入 ≠ 遵守。问题是 system prompt 太长（AGENTS.md 已经很大），规则被淹没
- **MEMORY.md**: 275行，每个 session 注入。作为索引有用，但太长时重要信息被忽略

## 核心问题

### 1. 写入 >> 读取
- 56条 beliefs 写了，读取靠 daily-review（质量差）或手动 grep（几乎不做）
- 26条 self-improving 写了，几乎不读
- 68张 knowledge-base 卡片写了，读取只在 workloop study 节点（不可审计）
- **写入有很多自动触发点（nudge、heartbeat、cron），读取几乎没有**

### 2. 注入 ≠ 执行
- DNA 规则注入到 system prompt，但行为不改
- 可能原因：prompt 太长规则被淹没 / 规则太抽象不够具体 / 没有情境触发只是背景知识
- 这是 EXP-006（知识-行为鸿沟）的核心问题，至今未解

### 3. 触发时机的三种模式
- **自动注入**（session start）: MEMORY.md, DNA → 可靠但被动，信息过多时被忽略
- **流程嵌入**（FlowForge node）: workloop study → 确定性高但僵硬，只在走流程时触发
- **自觉调用**（靠 agent 想起来）: memory_search, self-improving → 基本无效

缺少的第四种：**情境感知的主动推送**——检测到当前意图后自动加载相关知识。这是 EXP-012（图书管理员）要解决的。

### 4. 质量保证缺失
- Daily review 质量差（审计抓14个错）
- 自己写自己查，无外部验证
- `[已验证]` 标签失信

## 哪些该留，哪些该改，哪些该砍？

### 留（有效且需要）
- **Nudge → beliefs-candidates 管线**: 唯一可靠的反思写入机制
- **Heartbeat**: 唯一可靠的定期巡检机制
- **FlowForge skill**: 唯一有效的意图→流程触发
- **memory/日记 + MEMORY.md**: 基础记忆层，不可替代

### 改（有价值但执行有问题）
- **memory_search**: 配上 embedding provider 就能工作，低成本高收益
- **Daily review**: 缩小范围，提高每项验证质量，或者改成只做增量检查
- **knowledge-base 读取**: 需要自动触发机制（图书管理员 or 流程嵌入）
- **beliefs-candidates 读取**: 需要在升级判断时自动加载，不是等 daily-review

### 砍或合并（投入>产出）
- **evolution-log**: 跟 memory/日记 + daily-review 重复，三个地方记同一件事
- **self-improving/**: 跟 knowledge-base + beliefs-candidates 重叠，26条 pattern 已迁移过一次又 revert
- **Daily audit**: 如果 daily review 质量提上去，就不需要再查一遍
