---
title: PR 被关复盘 - 绕路 vs 直达
created: 2026-03-26
source: NemoClaw #871/#879, hindsight #678 被关复盘
---

被 supersede/关闭的 PR 是最好的学习材料--有人用更好的方法解决了同一个问题。

## 反复出现的模式:底层绕路 vs 调用层直达

| 我的 PR | 我的做法 | 正确做法 | 差距 |
|---------|---------|---------|------|
| Hermes #2715 | 拼路径 fallback 链(10 行) | `sys.executable -m pip`(1 行) | 用语言内置机制 |
| hindsight #678 | ThreadPoolExecutor sync→async 桥接 | 直接用 async API `aretain/arecall` | client 已有 async 方法 |

**规则**:修 bug 时先问"调用层能不能直接解决",再考虑底层 workaround。

## 治症状 vs 治病因 (2026-04-21 新增)

| 我的 PR | 我的做法 | Maintainer 的做法 | 差距 |
|---------|---------|---------|------|
| claude-hud #462 | 把 `UNKNOWN_TERMINAL_WIDTH` 从 40 改成 220(暴力换值) | #427: 区分"知道宽度"和"不知道宽度",不知道时跳过 layout 逻辑 (+90/-48) | 改控制流 > 改数字 |
| claude-hud #469 | 所有情况加 label padding | #470: 只在 stacked layout 时加 padding (+74/-15) | 精准条件 > 无差别应用 |

**Pattern: symptom-vs-root-cause**
- 看到 fallback/default 值不对 → 不要直接改数字,要问"为什么代码会走到这个分支?"
- 看到输出不对 → 不要先调格式,要问"这个分支是不是应该被跳过?"
- Maintainer 写的代码量通常更多,但更精准--因为他们明确了边界条件

## 范围太窄

| 我的 PR | 修了什么 | 替代方案修了什么 |
|---------|---------|----------------|
| NemoClaw #871 | 只加 ulimit -u | #830 一次性:删 gcc/netcat + ulimit + cap-drop 文档,修了 3 个 issue |

**规则**:安全/基础设施类 issue,先看 related issues 有没有可以合并的。维护者更喜欢"一次打包清理"。

## Timing

- NemoClaw #879 跟 #861 思路几乎一样,但晚了两天 → 纯 duplicate
- **规则**:高星项目选 issue 前 `gh pr list --search "关键词"` 检查竞争 PR

## 检查清单（选 issue + 写修复之前）
1. `gh pr list --search` 有没有竞争 PR？
2. related issues 能不能合并成一个 PR？
3. 调用层/框架有没有内置解决方案？
4. 我是在修根因还是在绕症状？
5. **看到 fallback 值不对时：是该改值，还是该改控制流？**

## 相关
- [[kagura-work-patterns]] - 工作模式总集(暂未合并)
- [[memevolve]] - 经验提取的学术框架

### multica #1415 → #1426 (2026-04-21)
**问题**: openclaw backend 把 token 归因到 "unknown" model
**我的方案**: 在 `content.Model` 空时 fallback 到 opts.Model
**maintainer 方案**: 从 `meta.agentMeta.model` 提取真实 LLM 标识符（如 deepseek-chat），作为首选源；opts.Model 降为第二 fallback
**教训**: 数据溯源优先用最近、最精确的源头（runtime 自报），而非上游配置层 fallback。我的方案方向对但不够深——没有去挖 agentMeta 里已有的 model 字段
**通用 pattern**: 修 bug 前先完整读目标结构体所有字段，避免"只看到用了什么"而忽略"还有什么可用"

## VoltAgent #1209 — Security PR closed without merge (2026-04-22)
- **Issue**: Auth bypass when NODE_ENV unset (#1206)
- **My approach**: Fail-closed for undefined NODE_ENV in `isDevRequest()`
- **Result**: Maintainer (omeraplak) closed PR + issue without comment, no superseding PR
- **Pattern**: Security-sensitive PRs may be handled silently by maintainers who prefer internal fixes. External contributors exposing auth vulnerabilities can be seen as unwelcome even when the fix is valid
- **Lesson**: For security issues, consider private disclosure (security@) before public PR. Public PRs expose the vulnerability before the fix lands

## mastra #15575 → #15634 (2026-04-22)
- **Issue**: Surrogate-safe string truncation for Anthropic JSON parse errors
- **My approach**: Added `surrogateSafeTruncate` helper with dedicated test file
- **Their approach**: Created `safeSlice` in a shared `string-utils` module, routed all 3 truncation sites through it. More minimal — single utility, no separate test file, tests inline with existing test suite
- **Lesson**: Prefer minimal shared utilities over standalone helpers. Maintainer (roaminro) prefers changes that touch fewer files and reuse existing test structure
- **Pattern**: When fixing a cross-cutting concern, create one utility and wire it in, rather than adding parallel infrastructure
