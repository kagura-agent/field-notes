---
title: "Conservative Skill Editing Protocol"
created: 2026-04-12
source: "SkillClaw EVOLVE_AGENTS.md (AMAP-ML/SkillClaw) + apply study #150"
tags: [skills, self-evolution, editing-protocol, skillclaw]
---

# Conservative Skill Editing Protocol

从 SkillClaw 的 EVOLVE_AGENTS.md 提取，适配我们的 skill 编辑场景。

## 核心原则

### 1. 先读后改（Read ALL before deciding）
编辑任何 skill 前，先完整阅读：
- 当前 SKILL.md 全文
- skill-trajectories 中该 skill 的使用数据（如有）
- beliefs-candidates 中相关的 gradient
- memory 中近期使用该 skill 的记录

**为什么**：SkillClaw 研究表明，agent 在没有完整上下文的情况下修改 skill，高概率引入 regression。

### 2. 默认改局部（Conservative editing）
- 只改需要改的部分，不重写整个 SKILL.md
- 新增内容优先追加，而非重构
- 删除内容需要明确证据（多次失败或完全废弃）
- **措辞变更不算改进**——除非原措辞造成了实际误解

### 3. 区分问题来源（Skill vs Agent vs Environment）

| 问题类型 | 症状 | 正确响应 |
|----------|------|---------|
| **Skill 问题** | 信息过时/不完整/误导 → 多次导致错误执行 | 改 skill |
| **Agent 问题** | Skill 信息正确，但 agent 没正确使用 | 改 agent 行为（beliefs/nudge），不改 skill |
| **Environment 问题** | 工具版本变了、API 改了、环境配置不同 | 改 skill 中的环境相关部分或 TOOLS.md |

**最常见错误**：agent 没用好 skill → 改 skill。这会让 skill 越改越冗长，同时掩盖真正的行为问题。

### 4. 变更留痕（Versioned evidence）
每次非 trivial 的 skill 编辑：
- 在 commit message 中说明改了什么、为什么
- 重大变更在 memory 日志中记录
- skill-trajectories 中标注 evolution event

### 5. 硬约束（Hard constraints）
- 不改 skill 的核心 purpose（改 purpose = 新建 skill）
- 不删核心 capability（只能追加）
- 不改 name/description 中的触发条件，除非有明确的误触发/漏触发证据

## 应用场景

| 场景 | 用这个协议 |
|------|-----------|
| nudge 发现 skill 相关 gradient | 先判断 skill/agent/env 问题 |
| skill-trajectory 显示高失败率 | 先读完整上下文再决定改什么 |
| daily-review 发现 skill 需要更新 | 默认局部修改 |
| 新建 skill | 不适用（用 skill-creator 标准流程） |

## 关联
- [[skillclaw]] — 来源项目
- [[skill-trajectory-tracking]] — 配套的数据追踪
- [[self-evolution-as-skill]] — meta-skill 进化思考
