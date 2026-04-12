---
title: "Skill Trigger Eval — 技能触发测试方法"
created: 2026-04-12
source: "study apply — SkillAnything trigger eval 思路"
tags: [skills, testing, eval, quality]
links: [skillanything, skill-creator]
---

# Skill Trigger Eval

## 核心思路

来自 [[skillanything]] 的关键创新：不只测 skill 能不能执行，还测**给一句自然语言，agent 会不会选中这个 skill**。

## 为什么重要

- Skill 的 `description` 是唯一决定触发的字段
- 写得太窄 → 该触发时不触发（漏用）
- 写得太宽 → 不该触发时触发（误用，浪费 context）
- 没有系统化测试 → 只能靠直觉判断 description 质量

## 测试方法

### 1. 正例测试（Should Trigger）

列 5-10 个用户会说的自然语言 prompt，验证 description 能覆盖：

```
# 例：github skill
✅ "check PR status for openclaw"
✅ "list open issues with bug label"
✅ "what's the CI status?"
✅ "create an issue about..."
✅ "review the latest PR comments"
```

### 2. 反例测试（Should NOT Trigger）

列 3-5 个容易误触发的 prompt：

```
# 例：github skill
❌ "write a GitHub README" → 不需要 gh CLI
❌ "explain how git branching works" → 知识问题，不需要 skill
❌ "push my code" → git 操作，不是 gh 操作
```

### 3. 边界测试（Ambiguous）

列 2-3 个边界 case，明确期望行为：

```
# 例：github skill
🔶 "check if my code passed tests" → 触发（CI 状态）
🔶 "merge this branch" → 触发（gh pr merge）
```

### 4. 竞争测试（Skill Collision）

当多个 skill 的 description 可能重叠时，验证优先级是否合理：

```
# 例：coding-agent vs github
"fix this bug and open a PR" → coding-agent（代码工作为主）
"check PR review comments" → github（纯 GitHub 操作）
```

## 实操检查清单

创建/编辑 skill 时：

1. 写完 description 后，列 5 个正例 prompt
2. 对每个 prompt，问自己：**仅凭 description 文本，这个 skill 会被选中吗？**
3. 检查 description 中的 trigger 关键词是否覆盖用户的常用表达
4. 检查是否与现有 skill 的 description 冲突
5. 如果是高频 skill，description 要包含常见的同义表达（中英文）

## 量化指标（未来）

- **Trigger Precision**: 触发的次数中，多少次是真正需要的
- **Trigger Recall**: 需要触发的场景中，多少次成功触发
- 数据来源：[[skill-trajectory-tracking]] Phase 0 手动记录

## 与 skill-creator 的集成

在 skill-creator 的审计/创建流程中，增加 trigger eval 步骤：
- 创建新 skill → 必须附带 5 正例 + 3 反例
- 审计现有 skill → 检查 description 是否通过 trigger eval
- 优化 description → 基于实际使用数据调整关键词
