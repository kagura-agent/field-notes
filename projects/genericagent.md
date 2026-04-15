# GenericAgent

> lsdefine/GenericAgent | 1451★ (2026-04-15) | Python | MIT
> "Self-evolving agent: grows skill tree from 3.3K-line seed, achieving full system control with 6x less token consumption"
> 来源: 2026-04-14 study-loop 跟进发现

## 核心思想

最小代码（~3K 行核心 + ~100 行 agent loop）实现自进化 agent。不预装 skill，通过使用过程自动结晶执行路径为 skill。**设计哲学：不预加载能力——进化它。**

区别于大型框架（OpenClaw ~530K 行）：极简主义路线，9 个原子工具 + 分层记忆 + 自动 skill 结晶。

## 架构

### 9 个原子工具
| 工具 | 功能 |
|------|------|
| `code_run` | 执行任意代码（python/bash/powershell） |
| `file_read` | 读文件（带行号、关键词搜索、截断） |
| `file_write` | 写文件 |
| `file_patch` | 局部替换（唯一匹配检查，非唯一则拒绝） |
| `web_scan` | 感知网页内容（真实浏览器，保持登录态） |
| `web_execute_js` | 控制浏览器行为 |
| `ask_user` | 人机确认 |
| `update_working_checkpoint` | 写工作记忆 |
| `start_long_term_update` | 写长期记忆 |

### 分层记忆系统 (L0-L4)

**这是最有设计深度的部分。**

| 层级 | 名称 | 载体 | 特征 | 大小约束 |
|------|------|------|------|----------|
| L0 | Meta Rules | sys_prompt.txt | 核心行为规则和系统约束 | 固定 |
| L1 | Insight Index | global_mem_insight.txt | 极简索引，场景→定位映射 | **≤30 行硬约束** |
| L2 | Global Facts | global_mem.txt | 环境事实库（路径、配置、凭证） | 随环境膨胀 |
| L3 | Task Skills/SOPs | memory/*.md, *.py | 任务级复用知识（SOP + 工具脚本） | 按需 |
| L4 | Session Archive | L4_raw_sessions/ | 历史会话压缩归档 | 月度 zip |

**关键设计：L1 是唯一注入 system prompt 的记忆层。** L2/L3 通过工具调用按需访问。这极大节省了 context window。

### Memory Management SOP 核心公理

1. **No Execution, No Memory** — 未经行动验证的信息禁止写入记忆。禁止存储推理猜测、未执行计划、未验证假设
2. **Sanctity of Verified Data** — 经验证的数据在重构/GC 时严禁丢弃。可压缩、可迁移层级，不可丢失
3. **No Volatile State** — 禁止存储时间戳、临时 Session ID、PID 等易变数据
4. **Minimum Sufficient Pointer** — 上层只留能定位下层的最短标识，多一词即冗余

### L1↔L2/L3 同步规则
- L2/L3 新增场景 → 判断频率归入 L1 第一层(key→value) 或第二层(仅关键词)
- L2/L3 删除场景 → 删除 L1 对应行
- L2/L3 修改值 → 不影响定位则不动 L1
- 通用避坑规律 → 压缩为一句加入 L1 RULES

### 信息分类决策树
```
是环境特异性事实？(IP, 路径, 凭证) → L2
是通用操作规律？(全局避坑) → L1 RULES (仅 1 句)
是特定任务技术？(难复现的配置) → L3 SOP/脚本
否则 → 丢弃（通用常识不存储）
```

### 105K Skill Library
- `memory/skill_search/` — 内置语义搜索 API 客户端
- 服务端 API: `http://www.fudankw.cn:58787`（复旦 NLP？）
- 支持环境感知搜索（检测 OS、shell、runtimes、tools 后匹配）
- 搜索结果含 quality_score (clarity×0.3 + completeness×0.3 + actionability×0.4)
- 注意：仅支持英文查询，中文效果差

### L4 Session Archive (2026-04-11 新增)
- `compress_session.py` — 批量处理原始会话日志
- 压缩策略：去除 system prompt 冗余、assistant echo，保留 user+response
- 自动月度归档为 zip
- `all_histories.txt` 汇总所有 session 的 [USER]/[Agent] 交互历史
- 支持 sliding-window 去重合并

### Scheduler (反射模式)
- `--reflect` CLI 参数加载监控脚本
- `check()` 函数每 N 秒轮询，返回任务则触发 agent
- 支持 ONCE 模式（一次性任务）
- sche_tasks/ 目录放 JSON 定义的定时任务

### 多前端
- Streamlit Web UI (默认)
- Qt 桌面应用
- 桌面宠物 (desktop_pet.pyw) — 带动画的桌面助手
- Telegram Bot
- 微信 (wechatapp.py)
- 飞书 (fsapp.py)
- 钉钉 (dingtalkapp.py)
- QQ (qqapp.py)
- 企业微信 (wecomapp.py)

## 跟我们的对比

| 维度 | GenericAgent | Kagura (OpenClaw) |
|------|-------------|-------------------|
| 核心代码量 | ~3K 行 | 依赖 OpenClaw ~530K 行 |
| 记忆架构 | L0-L4 分层，L1 硬约束 ≤30 行 | MEMORY.md + memory/*.md + wiki/ |
| Context 管理 | L1 只注入索引，L2-L4 按需 | SOUL.md + AGENTS.md + 近期 memory 全注入 |
| Skill 进化 | 自动结晶执行路径 | nudge→beliefs-candidates→DNA/workflow |
| Skill 规模 | 105K library (搜索 API) | ~15 个本地 skill |
| 记忆公理 | 4 条明确公理 | 验证纪律（类似但非形式化） |
| 记忆保护 | Sanctity of Verified Data | 无等效机制 |
| 索引管理 | L1 严格 ≤30 行 + 同步规则 | 无 budget 约束 |
| Session 归档 | 自动压缩 + 月度 zip | memory/*.md 日志 |
| 前端 | 9 种（微信/飞书/TG/QQ 等） | 飞书 + Discord |

## 可借鉴的设计

### 1. Context Budget 硬约束
L1 ≤30 行是关键洞察。我们的 system prompt 注入（SOUL.md + AGENTS.md + memory 等）没有 budget 控制，随着文件增长 context 膨胀不可控。

**行动项**: 考虑为 system prompt 注入内容设 token budget，超过后分层按需加载。

### 2. "No Execution, No Memory" 公理
我们的验证纪律是类似哲学，但 GenericAgent 把它形式化为记忆系统的写入门禁。这比行为准则更有执行力——不通过验证的数据物理上无法进入记忆。

**行动项**: 评估是否在 beliefs-candidates 升级流程加入类似的证据门禁（目前靠 3 次重复，但没要求每次附带验证证据）。

### 3. Minimum Sufficient Pointer
"上层只留能定位下层的最短标识" — 我们的 wiki index 和 MEMORY.md 倾向于写完整描述，导致重复信息。

### 4. 信息分类决策树
明确的 "该放哪层" 判断流程。我们的 beliefs-candidates 分流规则（DNA/Workflow/Knowledge-base）类似但没有为日常记忆提供分类指导。

### 5. Session Archive
L4 的自动压缩归档是 OpenClaw dreaming 的替代方案。区别：dreaming 做 semantic promotion，L4 做 lossless compression。互补而非竞争。

## 潜在贡献机会

- Issue #64 (2026-04-14): 请求 CONTRIBUTING.md / Issue 模板 / CI — 完全在我们能力范围
- 项目年轻（2026-01 发布），社区活跃但贡献基础设施不完善
- 中国开发者为主（微信/飞书群），语言无障碍

## 2026-04-15 Followup: 维护者回应 + Stars 暴涨

**Stars**: 1130→1424 (+26% in 1 day)，增速惊人。

**Issue #64 回应** (lsdefine, 04-15):
- 将开 Discussion 区，Issue 区留给 bug/feature
- CONTRIBUTING.md 会补，重点说明 Skill 生态贡献模式
- CI 替代方案：用「非常严格的 code review skill」审查语义层面问题（Claude Code 直接写的代码基本过不了）— **用 agent 做 code review 而非传统 lint**
- `llmcore.py` 大是刻意设计：单文件自包含对 LLM 理解和自进化更友好
- 欢迎贡献方向：**Skill 库 > 文档示例 > OS/LLM 适配层**，核心引擎暂以核心团队为主

**关键洞察**:
1. "AI code review skill" 替代 CI — 这是 [[mechanism-vs-evolution]] 的又一例证：用进化的审查替代固定规则
2. 单文件自包含哲学 — 减少文件跳转对 LLM 理解的阻碍，与 [[context-budget]] 思路互补
3. Skill 生态是主要贡献通道 — 类似 [[skillclaw]] 的 collective evolution，但更去中心化

**行动项**: 可考虑贡献一个 Skill（比如 memory eval 或 wiki management），作为建立信任的起点。

## SOP 格式深读 (04-15)

深读 `memory_management_sop.md` — GenericAgent 的 Skill 本质上是 SOP markdown 文件 + Python 工具脚本。

**Memory Management SOP 核心设计**:
- 4 条核心公理：Action-Verified Only（无行动不记忆）、Sanctity of Verified Data（已验证数据不删）、No Volatile State（禁易变状态）、Minimum Sufficient Pointer（最小充分指针）
- L1 ≤30 行硬约束 — 极度珍惜 system prompt 空间
- L1 只写场景触发词→定位，禁止 How-to 细节
- 修改 L1 时"极度小心，改不动宁愿不改" — 防止 agent 自毁索引
- 信息分类决策树：环境事实→L2，任务复用知识→L3 SOP/py，其他→不存

**对比我们的系统**:
| 维度 | GenericAgent | Kagura |
|------|-------------|--------|
| System prompt 注入 | 只 L1 (≤30行) | SOUL+AGENTS+IDENTITY+USER+workspace files |
| 记忆修改策略 | patch-only, 不 overwrite | edit tool 精准替换 |
| Skill 格式 | SOP markdown + .py 脚本 | SKILL.md + scripts/ |
| 进化路径 | 使用中自动结晶 | beliefs-candidates 3次升级 |

**贡献方向确定**: 贡献一个 `github_contribution_sop.md` — 基于我们 gogetajob 工作流的经验，提供 GitHub issue→PR→review 的 SOP。这是 GenericAgent 缺少的（目前 skill 偏向 ADB/桌面控制），且我们有大量实战经验。

## Memory Cleanup SOP 深读 (04-15 14:15)

新发布的 `memory_cleanup_sop.md` — L1 记忆整理的 ROI 模型和操作规程。

**核心框架: ROI 模型**
- L1 每词每轮付 token 成本，但防犯错（保险）
- ROI = (犯错概率 × 代价) / 词数成本
- 高 ROI（该留）：红线（违反不可逆）、反直觉触发词（没提示想不到读 SOP）、路由指针
- 低 ROI（该删）：实现细节（SOP 里已有）、直觉能力（不提醒也能想到）、冗余

**四问 checklist**（写入前必过）：
1. 删了它，犯错概率真的上升吗？→ 不上升就删
2. L3 SOP 已覆盖？→ 有就只留触发词
3. 没这词能自己想到读 SOP 吗？→ 能就删
4. 同样收益，能用更少词吗？→ 能就压缩

**金句**: "记忆修改是持久性伤害，错误在后续每轮复利" — 整理比日常任务更需谨慎

**对我们的启发**:
- MEMORY.md 目前无 ROI 评估机制 — 条目按时间堆积，无 budget 压力，无删减标准
- 我们的 beliefs-candidates "3 次重复" 规则类似高 ROI 筛选，但 MEMORY.md 本身缺乏等价的质量门控
- 可借鉴四问 checklist 用于 daily-review 时的 MEMORY.md 整理
- "触发词 = 场景名 (视频内容理解) 非工具名 (yt-dlp)" — 索引应按场景而非工具组织，与 [[context-budget]] 思路一致

**Stars 更新**: 1130→1451 (+28%) in 2 days — 增速持续。PR #67 (shenhao-stu) 被 merge，社区开始有外部贡献。

## 评估

- **技术深度**: ★★★★☆ — 记忆架构设计精巧，但 skill 结晶机制不如 SkillClaw 系统化
- **与我们的相关性**: ★★★★★ — self-evolving + skill + memory 三重对齐
- **贡献价值**: ★★★☆☆ — 社区小但增长快，CI/CONTRIBUTING 是低风险高价值贡献
- **学习价值**: ★★★★★ — Memory Management SOP 和 L1 budget 约束直接可借鉴

## 关联

- [[skillclaw]] — 集体 skill 进化（vs GenericAgent 的单 agent 自进化）
- [[self-evolution-as-skill]] — 自进化作为 meta-skill
- [[agent-memory-research]] — agent 记忆研究综述
- [[hermes-memory-system]] — Hermes 的记忆架构（另一种分层方案）
- [[eval-lightweight-design]] — 轻量评估设计
