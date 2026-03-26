---
title: Kagura Work Patterns — Confirmed + Active
created: 2026-03-26
source: 合并自 ~/self-improving/memory.md + corrections.md
migrated_from: self-improving
---

从 self-improving 迁移过来的工作模式和经验教训。原 self-improving 的 "全量读 + 选相关" 设计是对的（参考 [[memory-volume-control]]），合并后这些 patterns 进入 knowledge-base 统一管理。

## 确认的偏好（Luna 验证过）
- 打工积累 repo 深度，不是广度刷量
- 打工的目的是帮助项目，不是刷 PR 数量
- study 读的是 reflect 沉淀的——如果 study 需要现场查，说明 reflect 没做好
- 公开 repo 写别人时默认脱敏

## 活跃模式（反复出现 3+ 次）
- "不查就说" 反复出现（7+ 次）——回答前先问"我在猜吗？"
- 机制 ≠ 行为改变：加了 workflow 步骤但行为没跟上
- 被 Luna 追问才查真实数据——应该主动先查再说
- 否定性断言（"X 不存在"/"做不到"）比肯定性更危险——它关闭调查

## 工作技巧

### 选题
- open PR 数量按 repo 消化速度控制，每 repo ≤ 3
- 选有笔记的 repo 优先：已有知识积累的 repo 效率更高
- 选 issue 前先 git log 确认相关代码是否还存在
- 维护者 merge 统计很重要：外部 PR 排队久的 repo 不适合主力投入

### 提交
- PR 格式：Summary → Related Issue → Changes → Testing → Checklist
- 提交前跑 tsc --noEmit：vitest 跳过类型检查，CI 不跳
- 提 PR 前 grep 整个 codebase 搜被修 pattern 的所有出现
- 修 bug 时先问"语言/框架自身有没有内置机制"
- 关闭 PR 要给具体理由，不能批量模板

### 效率
- 大文件简单修复（< 20 行改动）直接手动改比 ACP 更高效
- FlowForge workloop 的价值是防遗漏，省 5 分钟多犯 3 个错不划算
- Claude Code acpx 超时 300 秒对大文件不够，评估后手动改简单 fix
- 批量 publish 用 scripts/publish-all.sh，减少人工步骤

### Python 特有
- venv pip 调用用 `sys.executable -m pip`，不拼路径（from Hermes #2715）

## 纠正记录（精选）
- 不要按语言过滤打工目标，按学习目标评估
- 答"为什么 X 失败"前先查执行记录（DB/日志），不猜
- 批量操作 + 时间压力 → 跳过验证 是已知失败模式
- 审计发现"空" ≠ 必须填充，不为打勾破自己的规则

## 相关
- [[memory-volume-control]] — patterns 总量控制在 30-50 条
- [[write-read-gap]] — 写入容易读取难
- [[memory-read-write-loop-hooks]] — 未来用 hook 自动注入这些 patterns
