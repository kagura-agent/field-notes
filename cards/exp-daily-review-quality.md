---
title: "EXP: Daily Review 质量保证"
created: 2026-03-27
---
## 实验背景
daily-review（凌晨 3:00 cron）+ daily-audit（凌晨 6:00 cron）是自进化系统的检查点。review 做盘点，audit 做验证。

## 观察（2026-03-27）

### Daily Review 问题
- 3/27 review 被 audit 抓出 **14 个错误**
- 数据错误 5 处（时间戳、计数、路径）
- 虚报 1 处（openclaw-brm repo 不存在，凭空写的）
- 遗漏 2 处（story-evening cron 超时没发现、重复目录没发现）
- 叙事包装 3 处（标 ✅ 但没验证具体内容）
- 最严重：FlowForge instance 数写了 7 标了 `[已验证]`，实际是 20

### 根因分析
1. **自己写自己查** — review 和 audit 都是同一个 agent（我），不是真正的外部审计
2. **`[已验证]` 标签失信** — 标了但实际没跑验证命令，或者跑了但没仔细看结果
3. **isolated cron session** — 凌晨 3 点独立 session，没有上下文，没有人追问，质量取决于执行纪律
4. **audit 只列问题不修正** — 抓到了错误但没有闭环（修正 review / 通知下一次操作注意）

### 关键认知
- **self-evaluation 的根本困难**：我不能比自己更聪明。audit 多跑一遍验证能抓到部分错误，但抓不到所有的
- **"已验证" 是最危险的标签**：给读者（包括未来的自己）一种虚假的确信感。没验证就不标，比标了没验证更诚实
- **质量保证目前无解**：没有外部 reviewer，没有自动化验证脚本，纯靠执行纪律

## 可能的改进方向（未验证）
- [ ] audit 发现错误后自动修正 review 文件（而不是只附录）
- [ ] review 中的 `[已验证]` 必须附带验证命令和输出摘要
- [ ] 减少 review 覆盖面，聚焦最重要的 5 项（减少范围 → 提高每项质量）
- [ ] 或者：review 不做全面盘点，改成只记"自上次以来发生了什么变化"

## 状态
🔬 观察中 — 暂不改机制（居住期），先记录问题

## 相关
- [[self-evolving-agent-landscape]] — 业界自评估方案
- beliefs-candidates-pipeline — gradient 升级机制
- trajectory-tips — 经验记录分类

## 追加观察：workloop study 节点 (2026-03-27)
- workloop.yaml study 节点写了"必须先读田野笔记"
- 但 flowforge 只记录节点跳转（enter/exit/branch），不记录执行内容
- 无法事后审计"study 时是否真的读了笔记"
- 同一个 pattern：写了规则 ≠ 执行了规则，且缺乏可审计性
