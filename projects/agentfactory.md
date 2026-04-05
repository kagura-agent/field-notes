---
title: AgentFactory — Self-Evolving via Executable Subagent Accumulation
created: 2026-04-05
updated: 2026-04-05
source: arxiv 2603.18000, GitHub zzatpku/AgentFactory
tags: [self-evolving, skill, code-as-memory, subagent]
depth: deep-read
---

## 概述

AgentFactory 提出一个范式转换：把成功的任务解决方案保存为**可执行的 subagent 代码**，而不是文本经验（prompt/reflection）。

核心 insight：text descriptions of how to solve a task don't guarantee reliable re-execution in complex scenarios. **Code > Text** for skill preservation.

作者：Zhang Zhang, Shuqi Lu, Hongjin Qian, Di He, Zheng Liu（北大）

## 三阶段流程

1. **Install**：分解任务 → 从零构建 Python subagent → 保存为 .py + SKILL.md
2. **Self-Evolve**：遇到相似任务 → 检索已存 subagent → 执行反馈 → 修改代码 → 更健壮
3. **Deploy**：成熟的 subagent 导出为独立 Python module，带标准化文档，可跨系统使用（LangChain, AutoGen, Claude Code）

## 架构详解（深挖）

### Meta-Agent（核心编排器）
- `meta_agent.py` — 中央控制器
- 解析 LLM 输出的 XML-style action/params 格式
- 所有操作统一为 skill 调用：`<action>skill_name</action><params>{JSON}</params>`
- **关键设计**：强制 meta-agent 先读 skill description（`get_skill_description`）才能使用 skill
  - 这跟 OpenClaw 的 "scan available_skills → read SKILL.md before use" 完全一致！
- 支持 human-in-the-loop：`--human-confirm` 选项

### Skill System（三层架构）
- **Meta Skills**（元操作）: `create_subagent`, `run_subagent`, `modify_subagent`, `finish`, `list_saved_subagents`, `view_subagent_code`, `get_skill_description`, `use_skill`
  - 存放在 `skills/meta/` 目录，每个一个 SKILL.md
- **Tool Skills**（基础工具）: `web_search`(Serper), `web_reading`(Jina), `browser_automation`(Playwright), `shell_command`
  - 存放在 `skills/tools/` 目录
- **Subagent Skills**（动态生成）: 用户任务执行后自动保存的 Python 模块
  - 存放在 `skills/subagents/` 目录
  - 每个 subagent 有自己的目录：subagent.py + SKILL.md + 辅助文件

### Skill Extraction Pipeline（核心关注点！）

**从执行到保存的完整流程：**

1. **Meta-agent 分析任务** → 判断是否有可复用的 saved subagent
2. **如果没有**：调用 `create_subagent` → LLM 生成 Python 代码 → 写入 workspace
   - 创建前必须先读取所有要用到的 tool skill 的 description
   - 代码要求通用化：`query` 参数是唯一输入，不能硬编码任务特定值
3. **执行** `run_subagent` → 在隔离 workspace 运行 → 获取结果
4. **如果出错**：调用 `modify_subagent` → 基于执行反馈修改代码 → 重试
5. **完成后**：调用 `finish` → 指定要保存哪些 subagent

**finish skill 的4种保存模式：**
- Pattern 1：保存全新 subagent（`entry_file` + `description`）
- Pattern 2：保存修改过的已有 skill（加 `skill_name`）
- Pattern 3：用新 subagent 替换旧 skill（加 `supersedes`）
- Pattern 4：不保存（已有 skill 够用，或全部失败）

**SKILL.md 生成格式：**
- YAML frontmatter: `name`, `description`, `entry_file`
- Description 包含：Problem Category, Applicable Questions, Key Features, Skills Used, Reasoning Pattern, Input/Output Format, Improved From
- **所有 workspace .py 文件都会被复制到 skill 目录**

### Workspace Manager
- 每个任务一个隔离 workspace 目录
- 防止 subagent 创建/修改时损坏共享 skill library
- 类似 Docker 思路但更轻量

### Skills 三级加载模式
- Level 1: Metadata（name, description）→ 启动时加载
- Level 2: Instructions（完整 SKILL.md body）→ 按需加载
- Level 3: Execution（运行代码）→ 使用时触发
- **跟 OpenClaw 的 available_skills → read SKILL.md → execute 完全一致**

## 数据

- 30 个真实任务（两批），Opus 4.6 + Sonnet 4.6
- Batch 2 复用 subagent 时，orchestration token **减少 57%**（对比 ReAct）
- 即使 Batch 1 内部，Opus 也能识别复用机会

| Method | Setting | Opus tokens | Sonnet tokens |
|--------|---------|-------------|---------------|
| ReAct | Batch 1 | 8298 | 6893 |
| ReAct | Batch 2 | 7022 | 7029 |
| Self-Evolving (text) | Batch 1 | 8608 | 8163 |
| Self-Evolving (text) | Batch 2 | 6210 | 8223 |
| AgentFactory | Batch 1 | 4324 | 9199 |
| AgentFactory | Batch 2 | **2971** | **3862** |

## 与 Kagura/OpenClaw 的深度对比

### 高度同构的部分
| AgentFactory | OpenClaw/Kagura |
|---|---|
| SKILL.md (YAML frontmatter + instructions) | SKILL.md (相同格式！) |
| skills/meta/, tools/, subagents/ 三级目录 | skills/ + available_skills 注入 |
| Meta-agent 先读 description 才能用 skill | "scan → read SKILL.md → follow" 相同模式 |
| `create_subagent` → workspace .py + SKILL.md | skill-creator skill |
| `run_subagent` → 隔离执行 | subagent spawning |
| `modify_subagent` → 基于反馈修改 | nudge + beliefs-candidates |
| `finish` → 批量保存 | 手动 commit + ClawHub publish |
| Workspace isolation | subagent 独立 session |

### 关键差异
1. **自动化程度**：AgentFactory 全自动（LLM 生成代码 + 自动保存），我们是半手动（nudge 文本 → 人审 → 手写 skill）
2. **Skill 表现形式**：AgentFactory 的 skill = Python 代码（可执行），我们的 skill = SKILL.md 指令文本（给 LLM 读的 prompt）
3. **进化信号**：AgentFactory 用**执行结果**（代码 pass/fail），我们用**文本反思**（nudge gradient）
4. **部署模型**：AgentFactory 生成可跨框架导出的 Python module，我们的 skill 绑定在 OpenClaw 生态

### 跟 beliefs-candidates → DNA 管线的异同
| 维度 | AgentFactory | Kagura beliefs → DNA |
|------|-------------|---------------------|
| 输入信号 | 任务执行成功/失败 | nudge 反思 + Luna 纠正 |
| 中间表示 | Python 代码 | beliefs-candidates.md 条目 |
| 输出产物 | saved subagent (.py + SKILL.md) | DNA 文件更新 / workflow 调整 / KB 笔记 |
| 筛选标准 | 执行成功且通用 | 重复 3 次以上 |
| 自动化 | 全自动 | 半自动（有规则但需判断） |
| 可验证性 | 代码可直接重跑 ✅ | 行为变化需观察 ⚠️ |

## 关键问题答案

### 能不能从 nudge/反思输出自动生成可执行 skill？

**理论上可以，但需要设计一个转换管线：**

1. **信号收集**：nudge 输出的 gradient + 任务执行 session transcript
2. **模式识别**：识别哪些 gradient 对应可复用的任务模式（而非一次性修正）
3. **代码生成**：让 LLM（如 Claude Code）从 transcript + gradient → Python/bash script + SKILL.md
4. **验证**：在沙箱中重跑验证生成的代码
5. **存储**：保存为 ClawHub skill（自动 version + publish）

**但有几个关键挑战：**
- 我们的 gradient 更多是**行为规范**（"不要讨好"、"数据必须查证"）而非**任务解法**（"怎么自动化 Docker 监控"）
- AgentFactory 的 skill 是**任务级别**的（解决一类具体任务），我们的 beliefs/DNA 更多是**元级别**的（如何做好 agent）
- 可能需要**双轨制**：任务级 skill 走 AgentFactory 路径（代码），元级 belief 走现有 DNA 路径（文本）

**最小可行方案（MVP）：**
- 在 FlowForge workloop 结束时，自动检查执行轨迹
- 如果任务成功且包含可复用模式 → 调用 Claude Code 生成 skill
- 人审后 publish 到 ClawHub
- 类似 AgentFactory 的 `finish` skill 但嵌入 FlowForge

See also: [[openspace]], [[self-evolving-agent-landscape]], [[skill-type-taxonomy]], [[metaclaw]], [[clawhub-evolution-skills]]
