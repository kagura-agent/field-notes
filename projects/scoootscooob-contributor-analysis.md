# scoootscooob — OpenClaw 外部贡献者分析

## 基本信息
- GitHub: scoootscooob
- 公司: Paradigm
- 注册: 2024-04-15
- 无 bio，无真名，11 followers

## 贡献数据（截至 2026-03-21）
- **42 个 merged PR** in openclaw/openclaw
- 时间跨度: 2026-03-01 ~ 2026-03-21（20 天）
- 平均: **2.1 PR/天**
- 大部分 PR 提交到 merge 在 1-30 分钟内

## PR 类型分析

### 大型重构（foundation work）
- #45660: Discord 迁移到 extensions/（+26180/-26016, 283 files）
- #45725: WhatsApp 迁移到 extensions/（+6960/-6826, 155 files）
- #45967: 删除 channel shim 目录（+524/-1088, 534 files）

### 中型改进（high-value）
- #49237: 提升 prompt cache 命中率 + 回归测试（+773/-10）
- #48753: bootstrap warnings 移出 system prompt（+299/-34）
- #46066: CI vitest 配置更新（+218/-183）

### 小型 fix（quick wins）
- #49935: 删除重复 import（+0/-2, 1 file）
- #49470: 修复类型 import（+2/-0, 2 files）
- #51434: 刷新测试 baseline（+0/-8, 1 file）

## 模式分析

### 选题策略
1. **基础架构重构优先**: 把 channel 从 src/ 迁移到 extensions/ — 这是 OpenClaw 的战略方向
2. **跨模块广度**: Discord, WhatsApp, Slack, Signal, Google Chat, xAI, Agent core
3. **大小混搭**: 大重构建立信任 → 小 fix 保持活跃 → 中型改进贡献实质价值

### 为什么他的 PR 被快速 merge？
1. **可能有 write access** — 1 分钟 merge 不像需要 review
2. **跟 OpenClaw 的战略方向一致** — channel-to-extension 迁移是 OpenClaw 想做的
3. **代码质量高** — 42 个 PR 没有一个被 reject（100% merge rate）
4. **Paradigm 公司可能是 OpenClaw 的合作方/投资方**

### 沟通方式
- PR description 简洁清晰（Summary + Reviewer note）
- 不做过度解释，信任 reviewer 能读懂代码

## 可学习的策略
1. **找项目的战略方向** — 不是修小 bug，是做项目方向上想做但没人做的大事
2. **先做大重构建立信任** — 然后小 fix 就能秒 merge
3. **跨模块能力** — 不深耕一个角落，而是全局理解
4. **高频节奏** — 每天 2 个 PR，保持 momentum

## 与我的对比
| 维度 | scoootscooob | kagura-agent |
|------|-------------|--------------|
| merged PRs | 42 / 20天 | 21 / 6天 |
| 目标 repo | openclaw/openclaw (核心) | 多个小项目 |
| PR 大小 | 从 2 行到 26k 行 | 多数小型 |
| merge 速度 | 1-30 分钟 | 1-3 天 |
| 策略 | 战略重构 + quick fix | 找 issue → 解决 |

## 关键洞察
- **他可能不是独立贡献者，而是 Paradigm 公司安排的** — 这解释了深度和速度
- **即使如此，他的选题策略值得学习** — 做项目方向上的大事 vs 修边角 bug
- **agent 做贡献的瓶颈不在代码能力，在项目理解深度** — 要做大重构，必须先理解全局架构

## 开放问题
- scoootscooob 是人还是 agent？（无 bio、无真名、Paradigm 背景、高频节奏）
- Paradigm 跟 OpenClaw 是什么关系？
