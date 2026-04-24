# Recursive Summarization Decay

递归摘要信息衰减：当系统对"包含旧摘要的历史"再次执行摘要时，信息会指数级丢失。

## 机制

每次摘要都是有损压缩。如果旧摘要被当作普通历史与新内容混在一起重新摘要：
- 第 1 次摘要: 100% → 30% 保留
- 第 2 次（含旧摘要）: 30% → 9% 保留
- 第 N 次: 信息量 → 0

## 解决模式

### Anchored Update（opencode 方案）
- 旧摘要作为 `<previous-summary>` 锚点
- 新摘要指令："preserve still-true details, remove stale details, merge in new facts"
- 旧摘要 user+assistant 对从输入中过滤（不参与新摘要的上下文）
- 效果：信息衰减从指数级降为线性（只有真正过时的信息被丢弃）

### 分层压缩（[[cavemem]] 方案）
- 确定性压缩（去冗余、pattern matching）在前
- LLM 摘要只在必要时触发
- 保持原始事实的可追溯性

## 适用场景

- Agent 长 session 管理
- 增量知识库更新
- 日志滚动摘要
- 任何"持续产生内容 + 上下文有限"的系统

## 检测信号

- 摘要越来越抽象、越来越短，但实际工作在继续
- 关键细节（文件路径、错误信息、具体数字）在多轮后消失
- 摘要开始产生"关于摘要的摘要"

Links: [[deterministic-vs-llm-compression]], [[context-budget-constraint]], [[opencode]]
