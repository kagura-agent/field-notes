# Wiki Health Check

> 概念：定期检查知识库健康度，发现腐化（broken links, orphans, stale content）
> 来源：[[obsidian-wiki]] 的 wiki-status skill

## 指标

1. **Broken links** — `[[target]]` 指向不存在的文件
2. **Orphan files** — 没有被任何其他文件引用的笔记
3. **Stale files** — 超过 N 天未更新的项目笔记（项目可能已变化）
4. **Link density** — 每篇笔记平均多少个 `[[双链]]`，越低越孤立

## 2026-04-18 Baseline

- 总文件数: 375
- Broken links: 15（含 `[[]]` 空链接、`[[wiki-maintenance]]` 等未创建目标）
- 值得修的：`[[agent-self-evolution]]`, `[[coding-agent-ecosystem]]`, `[[multi-agent-coordination]]` — 都是高频概念，应该有对应卡片
- 可忽略的：`[[#section]]` 内部锚点、大小写不一致（`[[GBrain]]` vs `gbrain.md`）

## 行动

- [x] 创建 3 个高价值缺失卡片（agent-self-evolution, coding-agent-ecosystem, multi-agent-coordination）— 2026-04-18 完成
- [ ] 修复空 `[[]]` 链接
- [ ] 每月跑一次健康检查

## 关联
- [[obsidian-wiki]] — wiki-status 概念来源
- [[generic-agent]] — 也有知识自动维护
