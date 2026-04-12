# Memory Consolidation as Skill Entry Point

> 记忆整合流程是 skill 自动生成的天然入口 — 不需要独立系统

## 核心洞察

Skill generation 不需要独立的检测-评估-生成 pipeline（如 [[skillclaw]] 的 proxy→Summarize→Aggregate→Execute）。在已有的 memory consolidation 流程中加一个标签就够了。

**证据**：nanobot Dream (2026-04-12 commit 2a243bf) 在 Phase 1 分析中增加 `[SKILL]` 标签，Phase 2 自动创建 SKILL.md。无需额外基础设施。

## 为什么有效

1. **数据已在手**：memory consolidation 本来就在扫描对话历史，skill 模式识别只是多一种 output type
2. **去重自然**：consolidation 知道已有文件内容，去重是内置的
3. **频率合适**：cron 定期触发，既不太频繁（每条消息都检测）也不太稀疏（月度才看）
4. **安全沙箱**：write_file 可以限定目录范围（skills/ only）

## 对比三种方案

| 方案 | 代表 | 复杂度 | 质量控制 |
|---|---|---|---|
| 独立 proxy pipeline | [[skillclaw]] | 高（proxy + evolver + validator） | 有 validation gate |
| Memory consolidation 内嵌 | [[nanobot]] Dream | 低（加一个标签类型） | 靠 prompt 规则 + 去重 |
| 手动分流 | 我们 (beliefs-candidates) | 最低 | 靠人的判断力 |

## 与我们的关联

我们的 nudge hook + beliefs-candidates 管线是最原始的版本。升级路径：
1. **最小改动**：在 nudge prompt 中加 `[SKILL]` 标签（nanobot 方案）
2. **中等改动**：在 daily-review 中扫描近 N 天 memory 找可复用模式
3. **最大改动**：实现 SkillClaw 式的独立 evolver（不推荐，过度工程）

## 适用条件

- Agent 已有定期 memory 整理机制
- Skill 格式标准化（如 SKILL.md frontmatter）
- 对话历史足够长（能看到重复模式）

## Links
- [[nanobot]]
- [[skillclaw]]
- [[metaclaw]]
- [[skill-trajectory-tracking]]
- [[mechanism-vs-evolution]]
