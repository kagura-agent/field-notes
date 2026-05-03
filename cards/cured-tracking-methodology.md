# Cured Tracking Methodology

**Origin**: beliefs-candidates.md §治愈追踪 section (2026-04-17 引入, inspired by no-no-debug)
**Graduated**: 2026-05-03

## Purpose

升级到 DNA 后的 gradient 不是自动消失——需要验证行为是否真的改变了。

## State Machine

```
Active → Upgraded → Cured / Recurring
```

- **Active**: 在 beliefs-candidates.md 中观察中
- **Upgraded**: 已升级到 DNA/Workflow/Wiki，用 ~~删除线~~ 标记
- **Cured**: 升级后 ≥3 周无同类 pattern 复发 → 标记 `[CURED yyyy-mm-dd]`
- **Recurring**: 升级后同类 pattern 仍在复发 → 标记 `[RECURRING]`

## Judgment Method

搜索同一 `pattern:` 标签在升级日期之后是否有新条目。有 → Recurring，无 → Cured 候选。

## Ratchet Strategy (from darwin-skill, 2026-04-20)

RECURRING 状态不能只标注——必须在同一审计轮次选择行动:
1. **加强**: 改写 DNA 规则使其更具体/更有约束力
2. **换载体**: 规则从 DNA 移到 Workflow（执行时强制检查，比被动原则更有效）
3. **Revert**: 规则本身有问题 → git revert DNA 改动，pattern 回到 Active

连续 2 次审计仍为 RECURRING → 必须升级行动等级。每次 revert 记录审计轨迹。

## Historical Tracking Table (as of 2026-04-20)

| Pattern | 升级日期 | 状态 | 备注 |
|---------|----------|------|------|
| 验证纪律 (verify-*) | 04-10 | 改善中 📈 | 最后违反 04-17 |
| skip-own-tools | 04-10 | CURED ✅ | 升级后无复发 |
| check-before-invest | 04-09 | CURED ✅ | 升级后无复发 |
| 数据纪律 | 04-09 | 改善中 📈 | 最后违反 04-13 |
| observation-without-action | 04-10 | 改善中 📈 | 最后违反 04-17 |
