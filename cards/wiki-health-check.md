# Wiki Health Check

> 概念：定期检查知识库健康度，发现腐化（broken links, orphans, stale content）
> 来源：[[obsidian-wiki]] 的 wiki-status skill

## 指标

1. **Broken links** — `[[target]]` 指向不存在的文件
2. **Orphan files** — 没有被任何其他文件引用的笔记
3. **Stale files** — 超过 N 天未更新的项目笔记（项目可能已变化）
4. **Link density** — 每篇笔记平均多少个 `[[wikilinks]]`，越低越孤立

## 2026-04-18 Baseline

- 总文件数: 375
- Broken links: 15（含 `[[]]` 空链接、`[[wiki-maintenance]]` 等未创建目标）
- 值得修的：`[[agent-self-evolution]]`, `[[coding-agent-ecosystem]]`, `[[multi-agent-coordination]]` — 都是高频概念，应该有对应卡片
- 可忽略的：`[[#section]]` 内部锚点、大小写不一致（`[[gbrain]]` vs `gbrain.md`）

## 2026-04-25 — wiki-lint Pipeline 上线

新建 `scripts/wiki-lint.py`，6 项自动检查：

| Check | Result | Notes |
|-------|--------|-------|
| Broken wikilinks | 68 broken | 多数是 placeholder 链接（[[wikilinks]] [[design]] [[postmortem]]）或已删文件 |
| Index consistency | 178 files missing from index | 近两周大量新增未 regen |
| Orphan detection | 55 orphans (21 cards, 34 projects) | scout 笔记天然孤立 |
| Stub files | 0 | 清洁 |
| Duplicate slugs | 6 pairs (cards/ vs projects/) | agent-memory-benchmark 等概念卡与项目卡重名 |
| cards-index.md staleness | 99 cards not indexed | cards-index.md 仅覆盖 phase-2 时的 98 张 |

**数据**：469 files, 1319 wikilinks, 197 cards, 218 projects

**关键发现**：
- Duplicate slugs 是真问题 — [[wikilinks]] 解析有歧义（cards/skillclaw vs projects/skillclaw）
- Orphan 不全是坏事：scout 笔记按日期命名，天然无 inbound link
- 大部分 broken links 是 placeholder 双链（写的时候假设卡片存在但没建）

**下一步**：
- [ ] 修复 top-20 高价值 broken links（被多处引用的）
- [ ] 解决 6 对 duplicate slugs（cards/ vs projects/ 冲突）
- [ ] 定期自动跑 lint（cron 或 CI）

## 行动

- [x] 创建 3 个高价值缺失卡片（agent-self-evolution, coding-agent-ecosystem, multi-agent-coordination）— 2026-04-18 完成
- [x] 建立自动化 lint 管线 — 2026-04-25 完成（wiki-lint.py）
- [x] 重新生成 index.md — 2026-04-25 完成
- [ ] 修复空 `[[]]` 链接
- [ ] 解决 duplicate slugs
- [ ] 定期跑健康检查（每月 or CI）

## 关联
- [[obsidian-wiki]] — wiki-status 概念来源
- [[generic-agent]] — 也有知识自动维护
- [[karpathy-llm-wiki]] — lint 管线灵感来源
