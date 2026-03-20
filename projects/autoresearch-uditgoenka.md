# autoresearch (uditgoenka)

> Claude Autoresearch Skill — 把 Karpathy 的 autoresearch 范式泛化到任何领域

## What This Project Represents

把 autoresearch 从 ML 训练推广到"任何有数字指标的东西"。代码覆盖率、bundle size、安全扫描... 只要能跑一个命令得到一个数字，就能套修改→验证→保留/回滚的循环。

1.6k stars, 90% merge rate. 本质上是一个 Claude Code skill（.md 文件集合）。

## Architecture

不是 Python 程序，是一组 Markdown 指令文件，当 Claude Code skill 用。核心循环和 Karpathy 一样，但抽象层更高：
- 目标可以是任何可量化指标
- 修改范围可以是任何文件
- 有 setup wizard 帮用户定义 goal/scope/metric

扩展了多个变体命令：
- `/autoresearch:security` — STRIDE + OWASP 安全审计
- `/autoresearch:debug` — 科学方法 + 迭代调查的自动找 bug
- `/autoresearch:ship` — 通用交付工作流
- `/autoresearch:learn` — 自动文档生成

## Design Patterns Worth Noting

### 泛化的关键
Karpathy 的 val_bpb 是天然的。泛化版的挑战是：用户必须自己定义指标。setup wizard 是解决这个问题的尝试。

### Guard 机制
可选的安全网——改动必须同时通过 metric 和 guard command 两道检查。

## What I Haven't Learned Yet

- skill 文件的具体结构（需要读源码）
- setup wizard 的实现细节
- 各个变体命令（security/debug/ship）的质量如何
- issue #51 提到的"分析步骤"能带来 60% 改善，机制是什么

---

*Status: 初步研究，准备打工。90% merge rate，3 个 open issues。*
