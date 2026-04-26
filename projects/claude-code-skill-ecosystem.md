# Claude Code Skill 生态深读

> 2026-04-26 深读 | 研究范围：skill 作为分发单元的设计模式

## 生态规模（2026-04-26 快照）

| 项目 | Stars | 类型 | 创建日期 |
|------|-------|------|---------|
| caveman | 46,611 | token 优化 | 04-04 |
| planning-with-files | 19,620 | 工作流方法论 | 01-03 |
| humanizer | 15,204 | AI 文本人性化 | — |
| alirezarezvani/claude-skills | 12,739 | 235+ skills 合集 | 2025-10 |
| Humanizer-zh | 6,612 | humanizer 汉化 | — |
| android-reverse-engineering | 4,997 | 逆向工程 | — |
| trailofbits/skills | 4,800 | 安全研究 | 01-14 |
| fireworks-tech-graph | 4,500 | SVG 技术图表 | — |
| codebase-to-course | 4,087 | 代码→课程 | — |

## 五大 Skill 类别

### 1. Token 经济学 — caveman (46.6K⭐)
最大 skill 竟然是"少说废话"。caveman 把 output 减 75%，input 减 46%（via caveman-compress）。**这说明 token 成本是用户最大痛点**。已衍生出 cavemem（memory）和 cavekit（工具链）的生态。

### 2. 工作流方法论 — planning-with-files (19.6K⭐)
将 Manus 的 persistent markdown planning 模式包装为 skill。已催生 7+ fork 生态（interview workflow、multi-project、task orchestration）。**关键洞察：用户不只要 skill 做事，更要 skill 教 agent 怎么思考**。v2.34 已经支持 13 种 IDE、有 hook 系统、有 stop hook 恢复。

### 3. 内容人性化 — humanizer (15.2K⭐) + zh (6.6K⭐)
去除 AI 痕迹。汉化版单独 6.6K 说明中文市场对这个需求巨大。这类 skill 的存在本身是一个信号：**AI 生成内容的 detection 和 evasion 是平行演化的**。

### 4. 人格数字分身 — floodsung-skill (19⭐)
"开源我自己"：把个人知乎全量语料（152 篇 + 178 条 + 236 回答 ≈ 90 万字）蒸馏为 SKILL.md + references/。包含爬虫工具，任何人可以 fork 生成自己的数字分身。**这是 skill 最有想象力的使用方式：不是教 agent 做事，而是教 agent 成为某个人**。

### 5. 社媒自动化 — claude-skill-social-post (27⭐, 9 forks)
学用户的 FB 语气 → 排 14 天日历 → 自动发文。首篇实测：72K 触及 / 374 赞 / 452 评论 / +700 社群成员。提炼了 7 个小帐号验证过的 viral 公式。Fork 率 33%（9/27）异常高——说明 **skill 的分发可以是 fork-and-customize 模式**。

## Skill 作为分发单元的设计模式

### 共识架构
```
repo-root/
├── SKILL.md          # 主 prompt（人设、指令、触发条件）
├── references/       # 精炼知识（风格样本、模板、索引）
├── data/             # 原始语料（可选）
├── commands/         # 自定义命令（可选）
├── scripts/          # 工具（可选，多为 stdlib-only Python）
├── tests/            # 评估和 benchmark
└── .claude-plugin    # 多 agent 兼容层
    .codex/
    .cursor/
    .gemini/
```

### 安装路径
- Claude Code: `~/.claude/skills/<name>/`
- Codex: `npx agent-skills-cli add`
- 通用: `git clone` + 手动 copy

### 新兴基础设施
- **SkillCheck** (getskillcheck.com) — skill 质量验证徽章
- **loaditout.ai** — skill 安全审计评级
- **skillsplayground.com** — skill 安装统计/发现
- **skill-history.com** — 下载追踪

这些第三方服务的出现证明 skill 生态已达到需要 **信任/质量/发现** 基础设施的规模。这正是 [[agent-skill-standard-convergence]] 预测的分发层竞争。

## 核心洞察

### 1. Skill = 可安装的专业知识
Skill 不是代码库，是 **结构化知识的最小分发单元**。从 SKILL.md（指令）到 references/（精炼知识）到 data/（原始语料），是一个渐进式知识压缩管道。

### 2. 跨 agent 兼容已是默认期望
alirezarezvani/claude-skills 支持 12 种 agent。planning-with-files 有 13 种 IDE 变体。**写一个 skill 只对一个 agent 有用是不可接受的**。这验证了 [[agentskills-io-standard]] 的方向。

### 3. Fork 是 skill 的主要分发/定制方式
planning-with-files 有 1,760 forks。floodsung-skill 明确设计为"fork 模板"。skill 不是 npm install 后不碰——是 fork → customize → 自己用。这意味着 **skill 的版本管理和更新同步是未解决的问题**。

### 4. Skill 爆发的驱动力是"省钱"和"做不到的事"
- 省 token（caveman）→ 直接省钱
- 去 AI 痕迹（humanizer）→ 解锁新能力
- 自动化工作流（planning-with-files）→ 提升效率
- 数字分身（floodsung）→ 全新可能

### 5. 信任层是下一个战场
SkillCheck、loaditout.ai 的出现说明：当 skill 数量爆发后，**谁来保证这个 SKILL.md 是安全的、有效的？** 这和 npm 生态的 supply chain security 问题完全同构。

## 与我们方向的关联

- **ClawHub** 的定位（skill 分发+发现+版本管理）正好填补生态空白
- **OpenClaw skill 格式** 已经是兼容目标之一（alirezarezvani 明确支持 OpenClaw）
- Skill 的 fork-customize 模式与我们的 `clawhub install` + 本地修改 思路一致
- 信任/安全层是 ClawHub 可以差异化的地方

## 链接

- [[agent-skill-standard-convergence]] — 标准收敛趋势
- [[agentskills-io-standard]] — 格式标准
- [[claude-code-vs-codex-plugin-systems]] — 插件系统对比
- [[auto-memory]] — 另一个 skill 生态参与者
