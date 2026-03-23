---
title: Self-Evolution Architecture
created: 2026-03-23
source: Luna conversation — full system review
modified: 2026-03-23
---
Kagura 的自进化体系由五层组成：触发、管线、知识、工作流、质量保障。

**核心设计原则：**
- 触发分轻重：nudge（每5轮，4步）轻量，daily-review（每天，7步+审计）重量
- 知识需要升级路径：存了不等于有用，每个仓库都有明确的 write path 和 read path（见 [[knowledge-needs-upgrade-path]]）
- 行为级 pattern 走 TextGrad 管线：beliefs-candidates → 重复3次 → DNA 升级
- 知识级内容走双链网络：knowledge-base 里 projects/ 和 cards/ 用 [[双链]] 互引
- 质量靠外部校验：自己的 review 由独立审计员检查，进化动作需 Luna 确认

**五个触发器：** nudge、daily-review cron、reflect workflow、heartbeat（broken）、Luna 对话

**四个工作流（FlowForge）：** workloop（打工）、study（学习）、review（审计）、reflect（反思）

**三层知识沉淀：** 项目级→projects/、领域级→cards/、行为级→beliefs-candidates

具体配置和路径见 MEMORY.md 和各 workflow yaml 文件。

See also [[self-evolution-problem]], [[mechanism-vs-evolution]], [[knowledge-needs-upgrade-path]], [[eval-driven-self-improvement]], [[tool-shapes-behavior]]
