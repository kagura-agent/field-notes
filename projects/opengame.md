# OpenGame

> leigest519/OpenGame | ⭐548 (2026-04-23) | Python + Node.js | Apache-2.0
> "Open Agentic Coding for Games" — CUHK MMLab

## 概要

学术 agent 框架，从自然语言 prompt 端到端生成可玩 web 游戏。核心贡献不是游戏生成本身，而是 **Game Skill**——一种自进化的 agent 能力系统。

## 架构

### Game Skill（核心创新）
两个互补组件：
1. **Template Skill** — 从成功项目积累项目骨架库。agent 每完成一个游戏，模板库增长。下次遇到类似需求时复用骨架而非从零开始。
2. **Debug Skill** — 维护"经过验证的修复协议"（living protocol of verified fixes）。不是存 error → fix 对，而是维护跨文件集成错误的系统性修复方案。

**关键洞察**：传统 code agent 把 debug 当 syntax-level 补丁，但游戏开发的 bug 大多是 **集成错误**（跨文件状态不一致、场景接线断裂、逻辑不连贯）。Debug Skill 专门解决这类问题。

### GameCoder-27B
专用代码 LLM，三阶段训练：
1. Continual pre-training（游戏引擎代码语料）
2. SFT（游戏开发任务对）
3. **Execution-grounded RL**（关键——用实际运行结果做奖励信号，不是静态代码评估）

### OpenGame-Bench（评估框架）
150 个游戏 prompt，三维评分：
- **Build Health** — 能编译、能跑
- **Visual Usability** — 在 headless browser 里截图 + VLM 评判可用性
- **Intent Alignment** — 生成物是否符合 prompt 意图

用 headless browser + VLM judging 做自动化评估——比人工评分更可规模化。

## 与 agent 生态的关联

### 自进化 Skill 模式
Game Skill 的 Template + Debug 双组件模式和 [[browser-harness]] 的 domain-skills 自生成、[[darwin-skill]] 的 agent-authored skills 方向一致。但 OpenGame 更结构化：
- browser-harness: agent 直接编辑 helpers.py
- darwin-skill: agent 创建新 SKILL.md
- **OpenGame: 分离模板积累（成功经验）和修复积累（失败经验）** ← 这是更成熟的设计

### Execution-grounded 评估
用实际运行结果（不是代码静态分析）判断 agent 输出质量。这和 [[openclaw]] 打工流程里"没测试不 push"的原则一致——实际执行是唯一可靠的质量信号。

### 跨文件一致性问题
LLM 在单文件编辑上表现好，但多文件集成经常崩溃。OpenGame 的 Debug Skill 专门解决这个问题——对大型项目的 code agent 都有参考价值。

## 可借鉴

- [ ] **Template + Debug 分离**：成功经验和失败经验用不同机制积累。我们的 skill 系统可以考虑类似设计——skill 不只记"怎么做"，还记"常见坑和验证过的修复"
- [ ] **Execution-grounded evaluation**：自动化质量评估用实际运行而非 LLM 自评。可以用在我们的打工 PR 质量检查中

## 局限

- 学术项目，不太可能长期维护
- 专注 web 游戏这个垂直领域
- GameCoder-27B 需要大量计算资源训练

---
*首次记录 2026-04-23*
