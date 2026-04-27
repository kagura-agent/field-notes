# Wiki Health Check

> 概念:定期检查知识库健康度,发现腐化(broken links, orphans, stale content)
> 来源:[[obsidian-wiki]] 的 wiki-status skill

## 指标

1. **Broken links** - `[[target]]` 指向不存在的文件
2. **Orphan files** - 没有被任何其他文件引用的笔记
3. **Stale files** - 超过 N 天未更新的项目笔记(项目可能已变化)
4. **Link density** - 每篇笔记平均多少个 `[[wikilinks]]`,越低越孤立

## 2026-04-18 Baseline

- 总文件数: 375
- Broken links: 15(含 `[[]]` 空链接、`[[wiki-maintenance]]` 等未创建目标)
- 值得修的:`[[agent-self-evolution]]`, `[[coding-agent-ecosystem]]`, `[[multi-agent-coordination]]` - 都是高频概念,应该有对应卡片
- 可忽略的:`[[#section]]` 内部锚点、大小写不一致(`[[gbrain]]` vs `gbrain.md`)

## 2026-04-25 - wiki-lint Pipeline 上线

新建 `scripts/wiki-lint.py`,6 项自动检查:

| Check | Result | Notes |
|-------|--------|-------|
| Broken wikilinks | 68 broken | 多数是 placeholder 链接(wikilinks, design, postmortem)或已删文件 |
| Index consistency | 178 files missing from index | 近两周大量新增未 regen |
| Orphan detection | 55 orphans (21 cards, 34 projects) | scout 笔记天然孤立 |
| Stub files | 0 | 清洁 |
| Duplicate slugs | 6 pairs (cards/ vs projects/) | agent-memory-benchmark 等概念卡与项目卡重名 |
| cards-index.md staleness | 99 cards not indexed | cards-index.md 仅覆盖 phase-2 时的 98 张 |

**数据**:469 files, 1319 wikilinks, 197 cards, 218 projects

**关键发现**:
- Duplicate slugs 是真问题 - [[wikilinks]] 解析有歧义(cards/skillclaw vs projects/skillclaw)
- Orphan 不全是坏事:scout 笔记按日期命名,天然无 inbound link
- 大部分 broken links 是 placeholder 双链(写的时候假设卡片存在但没建)

**下一步**:
- [x] 修复 top-20 高价值 broken links - 2026-04-25 完成(30+ links fixed, 7 stubs created)
- [x] 解决 6 对 duplicate slugs - 2026-04-25 完成(convention: repos→projects/, concepts→cards/)
- [ ] 定期自动跑 lint(cron 或 CI)

## 行动

- [x] 创建 3 个高价值缺失卡片(agent-self-evolution, coding-agent-ecosystem, multi-agent-coordination)- 2026-04-18 完成
- [x] 建立自动化 lint 管线 - 2026-04-25 完成(wiki-lint.py)
- [x] 重新生成 index.md - 2026-04-25 完成
- [ ] 修复空 `[[]]` 链接
- [x] 解决 duplicate slugs - 2026-04-25 完成
- [ ] 定期跑健康检查(每月 or CI)

## 2026-04-25 - Broken Links + Duplicate Slugs 修复

**Broken links 修复**(33 files, ~30 links):
- Case normalization: OpenClaw→[[openclaw]], GBrain→[[gbrain]], SkillClaw→[[skillclaw]], GenericAgent→[[genericagent]], Acontext→[[acontext]], Evolver→[[evolver]]
- Redirect: 双链→[[wikilinks]], AgentSkills→[[skill-ecosystem]]
- Created stubs: [[coding-agent]], [[claude-code]], [[frozen-trust-vs-time-decay]], [[test-time-compute]], [[reasoning]], [[recurrent-depth]], [[pi-agent]]

**Duplicate slugs 解决**(6 pairs):
| Slug | Kept in | Rationale |
|------|---------|----------|
| agent-memory-benchmark | projects/ | Specific repo |
| agentskills-io-standard | projects/ | Specific standard |
| capability-evolver | projects/ | Specific ClawHub skill |
| claude-subconscious | projects/ | Specific repo |
| eval-driven-self-improvement | cards/ | Cross-project concept |
| skillclaw | projects/ | Specific repo |

**Convention established**: repos/tools → `projects/`, abstract concepts/patterns → `cards/`

## 2026-04-25 Evening - wiki-lint.sh + Round 2 Fixes

**wiki-lint.sh 上线**(替代 wiki-lint.py,纯 bash,无依赖):
- 路径:`wiki/scripts/wiki-lint.sh`
- 5 项检查:broken wikilinks, orphans, duplicates, .md suffix errors
- 当前状态:42 broken / 40 orphans / 0 duplicates

**Round 2 链接修复**(6 links):
- Case fixes: `[[OmniAgent]]`→`[[omniagent]]`, `[[RivonClaw]]`→`[[rivonclaw]]`, `[[SwarmForge]]`→`[[swarm-forge]]`
- Suffix fix: `[[beliefs-candidates.md]]`→`[[beliefs-candidates]]`
- Slug fix: `[[打工]]`→`[[gogetajob]]`

**Broken links 分析**:
- 42 remaining broken 中,~30 是 tag-style 引用(`[[anthropic]]`, `[[deepseek]]` 等),非真实卡片需求
- ~5 是示例文本中的占位符(wiki-health-check.md 自身的例子)
- ~7 是可能值得创建的概念卡(`[[agent-daemon-mode]]`, `[[hub-first-backlink-weaving]]` 等)

**下一步**：
- [x] 设置 GitHub Actions CI 自动跑 wiki-lint.sh — 2026-04-25 完成
- [x] tag-style 引用处理：统一改为纯文本（不值得为 anthropic, deepseek 等创建 stub cards）— 2026-04-25 完成

## 2026-04-25 Night — CI 上线 + 全部 44 Broken Links 清零

**GitHub Actions CI**（`.github/workflows/wiki-lint.yml`）：
- 触发：push/PR to main
- 策略：duplicates → fail, broken links → warn
- wiki-lint.sh 改进：跳过 backtick-quoted 引用（文档示例不算 broken link）

**Round 3 全量修复**（44→0 broken links）：
- Tag-style refs → plain text: MoE, ACT, deepseek, llm-api, anthropic, postmortem, reasoning-effort, design, html-prototyping, looped-transformers, recurrent-depth
- Case/slug fixes: FlowForge→flowforge, Orb→orb, ClawHub→text, agent-memory→agent-memory-taxonomy, chat-infra→chat-infra-survey
- External refs → plain text: aider, Milvus
- Concept refs → plain text: strategy, daily-review, guardian, minions, agent-daemon-mode, hub-first-backlink-weaving, openclaw-66399, opencode-compaction, wiki-maintenance, team-memory, awesome-design-md, reactive-framework-antipatterns, agent-workflow-memory, link
- Stale links removed: agent-ecosystem-scout-2026-04-22/23

**决策：tag-style 引用的处理策略**
- 结论：**改为纯文本**，不创建 stub cards
- 理由：tag 类引用（anthropic, deepseek 等）是分类标记而非知识节点，创建空 card 会增加维护负担且无知识价值
- 例外：如果某个 tag 概念积累了足够内容（≥3 处有实质讨论），再升级为 card

**最终状态**：0 broken / 40 orphans / 0 duplicates ✅

## 2026-04-26 — 新参考: WUPHF `/lint` + Stash confidence decay

[[wuphf]] wiki 后端实现了类似健康检查，暴露为 MCP tool (`run_lint` + `resolve_contradiction`)，agent 可在对话中主动触发。与我们的 CLI wiki-lint 不同，他们还有 contradiction resolution。

[[stash]] 的 confidence decay 机制：facts 随时间自动降低置信度，未被 reinforced 的 fact 最终过期。这是我们缺少的：wiki cards 没有时效性概念，旧 fact 和新 fact 权重相同。

**可做的事**：
1. wiki-lint 暴露为 MCP tool / memex subcommand
2. cards 加 `last_verified` metadata，超过 30 天未验证的在 lint 中 flag
3. 矛盾检测自动化（写新卡时语义搜索矛盾）

## 关联
- [[obsidian-wiki]] - wiki-status 概念来源
- [[generic-agent]] - 也有知识自动维护
- [[karpathy-llm-wiki]] - lint 管线灵感来源
- [[wuphf]] - MCP lint 参考
- [[stash]] - confidence decay 参考
- [[confidence-decay-design]] - 我们的 staleness 设计方案
- [[skill-context-compression]] - 相关 token 优化实验

## 2026-04-26 — Staleness Check 实装

**可做的事** section 中第 2 项实现：wiki-lint.sh 新增 staleness check。

实装结果：
- Projects 阈值 14 天，Cards 阈值 30 天
- 基于 `last_verified` 或 `created` 前置字段
- 首次跑发现 88 个 stale 文件（70 cards + 18 projects）
- 详细设计 → [[confidence-decay-design]]

剩余未做：
- [ ] 定期自动跑 lint（cron — 可整合进 daily-audit workflow）
- [ ] wiki-lint 暴露为 MCP tool / memex subcommand
- [ ] 矛盾检测自动化

## 2026-04-27 — wiki-lint.py 假阳性修复 + 新检查项

**修复了 3 个假阳性来源**：
1. **`[[slug|display]]` 管道方向错误**（最大的 bug）：代码取 `|` 后面当 slug，但 wikilink 惯例是前面是 slug、后面是显示文本。修复后消除 7 个假阳性
2. **代码块中的 `[[]]`**：fenced code blocks 和 inline code 中的 `[[` 被误判为 wikilink。新增 `strip_code_blocks()` 过滤，消除 ~8 个假阳性
3. **`[[#section]]` 锚点链接**：内部锚点不应被检查为 broken link
4. **markdown link regex 假阳性**：`(Drop-in AGENTS.md)` 被 `\(.*\.md\)` 匹配，改为要求 `](` 前缀

**新增检查项**：
- Check 7: **Frontmatter consistency** — cards 应有 title + created 前置字段（发现 87 张缺失）
- Check 8: **Link density stats** — 每文件平均 4.0 个 wikilinks，12 张 cards 零出链

**状态**：31 errors → 2 errors（eval/probe-set.md 的 2 个未建概念卡），22 warnings
