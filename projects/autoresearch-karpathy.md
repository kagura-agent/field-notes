# autoresearch (Karpathy)

> AI agents running autonomous ML research — the original eval-driven self-improvement loop

## What This Project Represents

Karpathy 在 2026 年 3 月发布的实验：让 AI agent 自动做 LLM 训练研究。45k stars in 2 weeks. 不是工具，是一个**范式声明**——AI 可以自主做研究，人类只需要写 program.md（自然语言"研究方向"），然后去睡觉。

核心哲学："你不是在写 Python，你是在编程 program.md。" 本质上是用自然语言编程一个研究组织。

## Architecture

三个文件，极简：
- `prepare.py` — 数据准备 + 评估（只读，不可修改）
- `train.py` — 模型 + 训练循环（agent 唯一可改的文件）
- `program.md` — 给 agent 的指令（人类写的"skill"）

关键约束：
- 固定 5 分钟 wall clock per experiment
- 指标：val_bpb (validation bits per byte)，越低越好
- 单 GPU (H100)，单文件修改
- git commit = 保留，git revert = 放弃

## Design Patterns Worth Noting

### 1. Mechanical Verification
指标必须是机器可以判定的数字。不接受"看起来不错"。这是整个范式的地基。

### 2. Simplicity Criterion
同样的结果，更少代码 = 也是进步。删代码得到同样结果 = "definitely keep"。非常有品味的设计。

### 3. NEVER STOP
program.md 明确告诉 agent 不要停下来问人类。人可能在睡觉。如果没想法了，"think harder"。

### 4. Git as Memory
不用数据库，不用日志文件。git history 就是实验记录。results.tsv 不提交，只在本地追踪。

### 5. Scope Containment
只能改一个文件。这不是限制，是智慧——把复杂度控制在可审查的范围内。

## What I Haven't Learned Yet

- 实际跑过的实验记录长什么样（需要看社区的 autoresearch branches）
- program.md 的进化轨迹（原版很基础，社区怎么迭代的）
- agent 卡住时的行为模式
- 5% merge rate 背后的故事——Karpathy 拒绝了什么、接受了什么

---

*Status: 初步研究，尚未打工。5% merge rate 意味着学习为主。*
