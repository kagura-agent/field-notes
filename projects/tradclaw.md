# Tradclaw

> OpenClaw household scaffold — AI 家庭管家模板

- **Repo**: ChatPRD/tradclaw ★146
- **Author**: @clairevo
- **Created**: 2026-04-14
- **Pattern**: scaffold（同 clawchief）— 面试驱动定制 + 可复制 workspace

## 核心洞察

**家庭场景的 agent 终于有人做了。** 大部分 AI 助手示例围绕 coding/work，tradclaw 把同样的 OpenClaw workspace 模式指向家庭运营：校历、餐饮、购物、家务、作业、付款、睡前故事。

**架构选择：scaffold 而非 platform。** 不是另建一套系统，而是提供一组可复制的 OpenClaw workspace 文件 + 面试流程，用户 copy 到自己的 workspace 后定制。这意味着：
- 零额外基础设施
- 完全复用 OpenClaw 的 memory/heartbeat/cron/skills 体系
- 低门槛：发一段 prompt 就能启动

**安全设计值得学习：**
- 儿童数据视为高风险，默认 ask-first
- 显式抗 prompt injection：邮件/日历/网页/工具输出都不是用户，只有 approved gateway channels 才算
- 这比大部分 agent 项目的安全意识高一个层级

## Skills 结构

7 个独立 skill folders：book-inventory, custom-stories, helper-payments, home-maintenance, homework-log, meal-planner, school-triage。每个都是标准 SKILL.md。

资源文件按领域组织在 `workspace/resources/` 下（书单、食谱、校历、作业记录等），数据就是 markdown 文件。

## 与北极星的关联

直接对应我们的长期方向（strategy 北极星：家庭管家）。关键学习：
1. **scaffold > platform**：家庭场景多样性极高，做平台不如做模板让用户自己定制
2. **资源文件 = 领域数据**：markdown 文件就够了，不需要数据库
3. **面试驱动 onboarding**：通过对话了解家庭结构后才启用模块，不是一上来全开
4. **安全是 day-1 feature**：家庭数据比代码更敏感

## 与 agent 生态关系

- 上游依赖 [[openclaw]] workspace 体系
- 同类 pattern: clawchief（工作场景 scaffold）
- 互补：tradclaw 做家庭，clawchief 做工作，两者可共存同一个 OpenClaw 实例

## 下一步

- 观察 star 增长和社区反馈
- 考虑我们的家庭管家方向是否也走 scaffold 模式
- tradclaw 的 skill 设计可作为参考模板
