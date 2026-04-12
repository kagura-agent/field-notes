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

## 实际审计发现（2026-04-12 首轮）

详见 [[skill-trigger-eval-audits]]。两个 skill 审计后的关键发现：

1. **中文触发词普遍缺失** — agent-memes description 全英文，中文用户说"发表情包"时匹配弱
2. **Proactive trigger 是 blind spot** — agent-memes 要求"主动发"，但 trigger eval 方法论只测被动触发（用户说X → 选中Y）。需要额外的 proactive trigger 测试层
3. **NOT-for 声明能大幅提升 precision** — discord-ops 的"any Discord infrastructure task"太宽泛
4. **竞争测试最有价值** — agent-memes vs discord-ops 的"发表情包到 Discord" case 暴露了 domain 边界模糊

### Proactive Trigger（新发现的第5层测试）

传统 trigger eval 假设用户主动发起请求。但部分 skill（如 agent-memes）要求 agent **主动判断**是否使用。

测试方法：列 session 场景片段，问：agent 应该在这里主动使用这个 skill 吗？

```
# 例：agent-memes
🟢 完成了一个大任务 → 应该发 celebration meme
🟢 遇到荒谬 bug → 应该发 facepalm meme
🔴 用户在等紧急结果 → 不应该发 meme
🔴 讨论严肃话题 → 不应该发 meme
```

## 与 skill-creator 的集成

在 skill-creator 的审计/创建流程中，增加 trigger eval 步骤：
- 创建新 skill → 必须附带 5 正例 + 3 反例
- 审计现有 skill → 检查 description 是否通过 trigger eval
- 优化 description → 基于实际使用数据调整关键词
- 有 proactive 触发的 skill → 额外做 proactive trigger 测试

## 与 [[skill-trajectory-tracking]] 的闭环

- Phase 0 手动记录提供定量数据（invocations, success/fail）
- trigger eval 提供定性分析（description 质量）
- 两者结合：trajectory 数据发现异常（invocations=0 或 fail 高）→ 触发 trigger eval 审计
- 2026-04-12 首次数据点验证了闭环可行性
