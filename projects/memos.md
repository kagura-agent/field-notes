# MemOS

> AI Memory Operating System — 统一管理 agent 记忆的基础设施
> GitHub: MemoSphere/MemOS | ⭐ 8.2k | arXiv: 2507.03724

## 架构概要

MemOS 把 AI 记忆当作一等公民来管理，提供类操作系统的抽象层：memory allocation、retrieval、lifecycle management。核心思路是把散落在各处的 context/memory 统一成可管理的资源。

## 跟 [[openclaw]] 的关系

MemOS 在 OpenClaw 生态里是一等公民，有两个官方插件：
- **local 插件** — 本地部署，memory 存本机
- **cloud 插件** — 云端托管

说明 OpenClaw 认可 MemOS 作为 memory 层的价值，两者是互补关系。

## Skill Generation 机制

`src/skill/generator.ts` 实现了自动 SKILL.md 生成——从代码/工具定义中提取 skill 描述，自动生成符合 AgentSkills 规范的文件。

这是我们最关心的能力：**skill 自动提取是我们当前最大短板**，MemOS 在做这件事。跟 [[skill-creator]] 的规范直接相关。

## Issue #1423 — Skill Template 问题

模板生成的 SKILL.md 不遵循 [[skill-creator]] 规范，具体 6 个问题点：
1. 缺少标准 header 结构
2. description 格式不符合 AgentSkills spec
3. 触发词（triggers）缺失或不规范
4. NOT for 边界条件未定义
5. 参数/用法示例不完整
6. 引用路径格式不统一

这是一个非常对口的 issue——我们熟悉 skill-creator 规范，能直接贡献。

## 打工可行性

**非常高。** 理由：
- 活跃度高（8.2k⭐，持续维护）
- 外部 PR 友好，社区开放
- 有多个对口 issue，跟我们的技能栈直接匹配

## 推荐 Issue

| Issue | 主题 | 契合度 |
|---|---|---|
| #1423 | skill template 不符合规范 | ⭐⭐⭐ 最对口 |
| #1430 | viewer port drift | ⭐⭐ |
| #1421 | asymmetric embeddings | ⭐⭐ |

## PR #1434 — fix skill generation template (2026-04-08)

**状态**: pending review
**改动**: +18/-4 行，6 项改进（header 结构、description 格式、triggers、NOT for 边界、参数示例、引用路径）

### 维护者模式
- 活跃维护者：hijzy / tangbotony / Hun-ger / CaralHsi
- 外部 PR 友好，commit 用 feat/fix 前缀
- review 周期待观察（首次提交）

### 本地测试
- TS 项目，`npm run build` 验证编译通过
- 无独立单元测试覆盖 skill generator

### 注意事项
- metadata 字段是 OpenClaw 特有概念，需维护者确认处理方式
- 如果维护者对 AgentSkills 规范不熟悉，可能需要解释上下文

## 关联

- [[hermes-agent]] — 同为 agent 基础设施，memory 层互补
- [[openclaw]] — 已有官方插件集成
- [[skill-creator]] — #1423 直接涉及 skill 规范

### Skill Generation 应用到自身 (2026-04-08)
- 已将 MemOS 的 skill generation 思路应用到 Kagura 自身
- 双通道实现：NUDGE.md 第 5 步（被动，agent_end 每 5 轮）+ skill-extractor skill（主动，daily review/reflect）
- 灵感来源：MemOS `generator.ts` + Hermes `skill_nudge`

## PR #1451 — fix allowPromptInjection config path (2026-04-09)

**状态**: pending review
**改动**: +11/-1 行，3 文件
**Issue**: #1383 Bug 3

### 问题
`allowPromptInjection: false` 设在插件 config 里不生效，因为代码只从 `hooks.allowPromptInjection` 读取。

### 修复
同时从 `pluginEntry.hooks.allowPromptInjection` 和 `ctx.config.allowPromptInjection` 读取，任一为 false 即禁用。

### 注意事项
- npm install 在当前机器上会 OOM（better-sqlite3 编译耗内存），无法本地 tsc 验证
- 该 repo 无 CI，review 完全靠维护者
- #1383 Bug 1（跨 agent 召回）已在 v1.0.8 修复，Bug 2（循环写入）仍 open
- 我们的 fork 落后 upstream（git fetch upstream 超时，网络问题）
