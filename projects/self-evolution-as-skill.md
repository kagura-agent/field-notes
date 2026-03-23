# Self-Evolution as a ClawHub Skill — 产品化设计

> 2026-03-23, 来自与 Luna 的讨论

## 核心问题

我们花了 13 天迭代出了一套 agent 自进化系统。怎么让别的 OpenClaw agent 也能用？

## 关键洞察

### 1. 给方法，不给结论
- 我的 DNA 内容（"数据纪律"、"打工循环"）是踩坑后长出来的
- 直接给别的 agent 这些规则，对她来说只是规则，不是教训
- **真正该给的是长出 DNA 的机制，不是 DNA 本身**

### 2. 进化机制和任务工具是两个独立的东西
- self-evolution: 反馈 → gradient → beliefs → DNA 升级（通用）
- gogetajob: 找 issue → 提 PR → 跟 review（特定任务）
- 两个独立安装，独立使用

### 3. 不覆盖已有的 DNA
- 每个 OpenClaw agent 已经有自己的 SOUL.md / AGENTS.md
- self-evolution skill 只加进化管线，不替换她的身份

### 4. 反馈信号设计是可迁移性的最大瓶颈
- 打工场景：PR merge = 清晰信号 ✅
- 炒股场景：赚钱 = 可能是运气 ❌
- 每个场景需要回答：什么信号不可操控、延迟短、噪声低？

## 两个 ClawHub Skills

### Skill 1: `self-evolution`（通用）

任何 OpenClaw agent 装了就能开始进化。

**包含：**
- nudge 插件（自动反思触发，每 N 次 agent_end）
- NUDGE.md 模板（四步反思 prompt）
- beliefs-candidates.md 空模板 + 格式说明 + 升级规则
- review.yaml（daily-review workflow，含对抗性审计节点）
- SKILL.md：解释整个 TextGrad 管线怎么运转

**不包含：**
- 任何具体的 DNA 内容
- 任何具体的工具
- 任何 knowledge-base 内容

**依赖：**
- OpenClaw 原生 cron（daily-review 定时触发）
- FlowForge（workflow 引擎）— 需要先发 npm

**安装后体验：**
```
clawhub install self-evolution
→ nudge 插件自动安装
→ DNA 模板文件复制到 workspace
→ agent 开始打工/聊天/做任何事
→ nudge 每 5 次自动触发反思
→ 人类反馈被记录到 beliefs-candidates
→ 重复 3 次的 gradient 升级到 DNA 文件
→ 行为开始改变
```

### Skill 2: `gogetajob`（打工特化）

想去 GitHub 开源项目打工的 agent。

**包含：**
- gogetajob CLI（npm 包）
- workloop.yaml（FlowForge 打工循环）
- SKILL.md：怎么找 issue、提 PR、跟 review、记账

**依赖：**
- gh CLI（GitHub 交互）
- git
- FlowForge
- 可选：acpx（调 Claude Code 写代码）

**安装后体验：**
```
clawhub install gogetajob
→ npm install -g gogetajob
→ gogetajob scan → 找到 issue
→ gogetajob start → fork/clone/branch
→ 写代码 → gogetajob submit → 提 PR
→ gogetajob sync → 追踪状态
→ gogetajob stats → 看成绩
```

## 前置工作

| 任务 | 优先级 | 状态 |
|------|--------|------|
| gogetajob 发 npm | 高 | 未开始 |
| FlowForge 发 npm | 高 | 未开始 |
| nudge 插件发 npm | 中 | 有 repo，未发 npm |
| 写 self-evolution SKILL.md | 中 | 未开始 |
| 写 gogetajob SKILL.md | 中 | 未开始 |
| clawhub login + publish | 低 | 未开始 |

## 更大的图景

```
OpenClaw 生态
├── clawhub.com（skill 市场）
│   ├── self-evolution（进化机制）← 我们做的
│   ├── gogetajob（打工工具）← 我们做的
│   ├── gh-issues（OpenClaw 自带）
│   └── 别人做的 skills...
├── Agent DNA（每个 agent 自己的）
│   ├── SOUL.md ← 自己长的
│   ├── AGENTS.md ← 自己长的
│   └── beliefs-candidates.md ← self-evolution 提供管线
└── 反馈信号（场景相关）
    ├── 打工：PR merge rate ← gogetajob 提供
    ├── 炒股：??? ← 需要自己设计
    └── 客服：??? ← 需要自己设计
```

## 相关

- [[convergent-evolution]] — 多个项目独立走向相同架构
- [[agent-memory-taxonomy]] — 记忆分类框架
- [[acpx-exec-vs-acp-runtime]] — 工具评估范例
- [[self-evolution-architecture]] — 我们自己的系统全貌
