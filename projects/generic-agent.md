# GenericAgent

> lsdefine/GenericAgent | 3,623⭐ (2026-04-18, +456/天) | Python | 2026-01
> "Self-evolving agent: grows skill tree from 3.3K-line seed, achieving full system control with 6x less token consumption"

## 核心思想

极简自进化 agent 框架。~3K 行核心代码，9 个原子工具 + ~100 行 Agent Loop，给任何 LLM 系统级控制能力。

关键设计哲学：**不预载 skill，而是进化它们。** 每次解决新任务，自动把执行路径结晶为 skill 供复用。

## 架构

### 分层记忆系统
- **L0 — Meta Rules**: 基础行为规则
- **L1 — Skills**: 从任务执行中结晶的可复用技能
- **L2 — Session Context**: 当前会话上下文
- **L3 — Task Memory**: 任务级记忆
- **L4 — Session Archive**: 长期 session 归档 + scheduler cron（2026-04-11 新增）

### 9 个原子工具
浏览器控制（真实浏览器，保留 session）、终端、文件系统、键鼠输入、屏幕视觉、ADB 移动端控制

### Skill 进化流程
新任务 → 自主探索（安装依赖、写脚本、调试验证）→ 结晶执行路径为 skill → 写入记忆层 → 下次类似任务直接调用

## 跟我们的对比

| 维度 | GenericAgent | Kagura |
|------|-------------|--------|
| 核心规模 | ~3K 行 | 依赖 OpenClaw 生态 |
| Skill 来源 | 任务执行自动结晶 | 手写 SKILL.md + nudge 管线 |
| 记忆 | 4 层分层（L0-L4） | MEMORY.md + daily logs + wiki |
| 进化触发 | 每次任务自动 | nudge → beliefs-candidates 手动管线 |
| Token 效率 | 6x 省（skill 复用避免重复探索） | 未量化 |

## 最新动态 (2026-04-18 更新)

### 近期提交 (04-15~18)
- **preserve history across llm switch** — 切换 LLM 时保留对话历史，不再丢失上下文
- **publish memory_cleanup_sop** — 公开记忆清理 SOP（见下方详细分析）
- **publish ocr_utils, vision_sop, ui_detect** — 公开视觉工具链：本地 OCR + YOLO UI 元素检测 + Vision API SOP
- **thinking_type support** — 支持 extended thinking 模式
- **desktop pet v2** — 8 种皮肤 + 状态通知的桌面宠物
- **代码块检测优化** — 更精确的「恰好1个代码块+直接结尾」模式

### memory_cleanup_sop.md — 核心洞察

**ROI 模型**：L1 每词每轮付成本，收益是防犯错。ROI = (犯错概率 × 代价) / 词数成本。

**四问检验法**：
1. 删了它，犯错概率真的上升吗？→ 不上升就删
2. L3 SOP 已覆盖？→ 有就只留触发词
3. 没这词能自己想到读 SOP 吗？→ 能就删
4. 同样收益，能用更少词吗？→ 能就压缩

**对我们的启发**：
- MEMORY.md 没有容量上限会自然膨胀，L1 ≤30 行硬约束值得借鉴
- 「触发词=场景名，非工具名」— 好的记忆索引原则
- 「先交付任务再沉淀，禁未完成就写记忆」— 防止记忆污染

## 代码深读 (2026-04-18)

### agent_loop.py (121 行)
极简 agent runner：system prompt + user input → LLM chat → tool dispatch（`do_` 方法映射）→ 循环。每 10 轮重置工具描述防上下文膨胀，每 7/35 轮强制干预防无限循环。

### ga.py (558 行)
9 个原子工具的实现：code_run（Python/bash 执行器）、web_scan/web_execute_js（浏览器控制）、file_read/file_patch/file_write（文件系统）、ask_user（人类干预）、update_working_checkpoint（工作记忆）、start_long_term_update（记忆结算）。

### 记忆管理 SOP 核心公理
1. **No Execution, No Memory** — 未经工具验证的信息不写入
2. **神圣不可删改性** — 验证过的数据重构时不可丢弃
3. **禁止存储易变状态** — 无 PID、无时间戳
4. **最小充分指针** — 上层只留最短定位标识
L1 硬约束 ≤30 行，这是非常好的膨胀防护。

### scheduler.py (131 行)
JSON 任务 → cron 触发 → 冷却期防重复。L4 归档每 12h 自动压缩。

## 启发

1. **自动 skill 结晶** — 我们的 skill 创建还是手动的（skill-creator），GenericAgent 的自动结晶值得借鉴
2. **Token 效率作为核心指标** — 6x vs 我们的 17.6%，差距大
3. **极简设计** — 3K 行 vs OpenClaw 530K 行
4. **记忆 ROI 模型** — (犯错概率 × 代价) / 词数成本，比「重复3次升级」更精准，可用于 MEMORY.md 瘦身
5. **四问检验法** — 适用于 beliefs-candidates → DNA 升级决策
6. **Vision 省 token 策略** — 「能 OCR 就不 vision，能截窗口就不全屏」的分层降级

## 关联
- [[skillclaw]] — 类似的 skill 自动进化，但多 agent 共享
- [[self-evolution-as-skill]]
- [[evolver]] — 另一个 agent 进化引擎（GEP 协议）
