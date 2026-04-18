# SkillAnything

> Meta-skill: 一个能生成 Skill 的 Skill。自动为任何软件生成 OpenClaw/Claude Code/Codex 兼容技能。

- **repo**: AgentSkillOS/SkillAnything
- **创建**: 2026-04-06
- **语言**: Python (~3.3k LOC)
- **Stars**: 70 (一周内)

## 核心机制

7 阶段自动化 pipeline：
1. **Analyze** — 自动检测目标类型（CLI/API/Library/Workflow/Service），跑 `--help`、fetch OpenAPI spec、读 README
2. **Design** — 从分析结果生成架构 JSON（分 section、trigger 定义、tool 映射）
3. **Implement** — 用模板脚手架生成 SKILL.md + scripts/
4. **Test** — 自动生成测试用例（trigger eval：给 prompt 看 agent 是否正确激活 skill）
5. **Benchmark** — 跑 eval 对比基线
6. **Optimize** — 用 LLM loop 优化 description（让 trigger 更精准）
7. **Package** — 多平台打包（claude-code/openclaw/codex/generic 各一份）

## 架构洞察

- **Agent-as-pipeline-worker**: 每个阶段有独立的 agent prompt（`agents/analyzer.md` 等），Python 脚本做编排和 I/O，LLM 做判断。这比纯 LLM chain 更可控。
- **Trigger eval 是关键创新**: 不只测 skill 能不能用，还测"给一句自然语言，agent 会不会选中这个 skill"。这是 skill 质量的核心度量。
- **多平台适配是差异化**: `package_multiplatform.py` 知道每个平台的约定差异（路径、格式、能力声明），一次生成多份。

## 跟我们的关联

- 我们的 [[wiki-to-skill-automation]] 想法是"从 wiki 笔记提取 operational contract → 生成 SKILL.md"。SkillAnything 做的是"从任意软件 → 生成 SKILL.md"。方向互补：
  - SkillAnything: 外部软件 → skill（让 agent 能用新工具）
  - 我们: 内部知识 → skill（让 agent 能用自己积累的经验）
- 我们的 [[skill-creator]] 是手动/半自动，SkillAnything 全自动但可能质量不如手写
- **Trigger eval** 的思路值得借鉴——我们现在没有系统化测试 skill 的 trigger 精准度

## 生态位置

- 竞争：跟各平台自己的 skill authoring 工具竞争
- 互补：给 OpenClaw/Claude Code 生态扩大 skill 供给
- 上游：依赖 LLM API（用 Claude Sonnet 做 optimize loop）

## 反直觉发现

- 项目只有 70 星但结构非常完整（有 promo/ 目录准备了 Product Hunt pitch、Twitter thread、中文社媒文案），说明作者有系统推广计划，可能快速增长
- `obfuscate.py` 脚本——可以混淆生成的 skill？用途不明，可能是防止 skill 被直接抄走

## 更新 (2026-04-18)

- Stars: 70 → 176（12 天 2.5x），但**零代码更新**自 v1.0.0 (04-06)
- 增长全靠 README + promo/ 材料，验证了之前"有系统推广计划"的判断
- 同期新竞品: [[orb]] (44★), asgard-ai-platform/skills (116★, 263 skills 打包)

## 待验证

- [ ] 实际跑一次 pipeline 看生成质量
- [ ] 对比手写 skill vs SkillAnything 生成 skill 的 trigger 准确率
