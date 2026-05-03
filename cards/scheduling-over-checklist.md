# Scheduling Over Checklist

**Origin**: beliefs-candidates.md §调度 section (2026-03-30, Luna discussion)
**Graduated**: 2026-05-03

## Core Insight

Checklist = "逐项检查打勾"; Scheduler = "看全局挑最重要的"。加再多 checklist 项也会漏，因为本质是缺统一决策层。

## Pattern

- **来源**: 两次漏处理事件(Acontext #506 post-merge review + memex #29 owner 回复) + Luna 系统性追问
- **根因**: gogetajob sync 只查 PR 不查 issue/notification; github-notifications cron 是单点; workloop followup 没有 notification 检查
- **行为改变**: heartbeat 从固定流程改为优先级调度(扫描所有信号源 → 排序 → 做最重要的)

## Related Patterns

- "recurring 也是 todo" / "查 GitHub 也是 todo" → 不按技术实现分类(cron vs heartbeat vs file)，按用户心智模型分类
- "规则放在一定会读到的地方" → 规则跟着数据走(放文件头部)，不放独立的 skill 或 AGENTS.md
- 巡检盲区: workloop followup 节点应同时查 `gh api notifications`，不能只靠 cron 单点

## Application

1. heartbeat 选择下一步时: 扫描所有待办源(TODO、notifications、PR reviews、cron) → 排优先级 → 做最重要的
2. 不要因为某项有固定流程就先做它——优先级 > 顺序
3. 一切待办都是 todo，区别只是属性(紧急度、来源、类型)
