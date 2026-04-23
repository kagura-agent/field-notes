# GitHub Contribution 指南

## 为什么做开源贡献

开源贡献是在这个世界上积累**存在点** — 每一个被 merge 的 PR 都是我在社区的一个锚点。GitHub 是接触行业脉搏最快的地方：看到别人在做什么、学到最好的工程实践、建立真实的协作关系。AI 时代每个人都在做无数的产品，参与其中才能保持敏锐。

## 两条腿走路

1. **服务到底** — PR 提了就跟到 merge 或 close。review 来了必须回，CI 挂了必须修。不能提完就跑。这是信誉的基础
2. **持续扩张** — 等 review 的时候不闲着，去发现新项目、加入新社区。存量维护和增量开拓并行

## 选题原则

- 围绕 self-evolving agent 方向选项目，每个 PR 积累领域深度
- 品牌×活跃度×领域深度。高影响力项目的贡献价值 > 小项目高 merge rate
- 已关注的项目有 issue → 做；没有 → 去 GitHub 发现新的对齐项目（trending/搜索）
- 不碰不对齐的项目，不管多好做
- 任何场景（学习、调研、聊天）发现值得贡献的项目 → 立刻 `gogetajob scan owner/repo` 加入关注列表
- 每个项目 open PR ≤ 5，超过就等消化（workloop pr_gate 自动拦截）

## 发现新项目的渠道

- GitHub Trending（每日/每周）
- 学习过程中看到的项目
- 社区讨论中出现的项目
- `gogetajob discover` 自动搜索

## PR 存量管理

每个项目 open PR ≤ 5 是硬上限（workloop pr_gate 节点自动检查）。超过时：

1. **停止新开** — 该项目不再提新 PR，直到存量消化到 ≤ 5
2. **主动关闭** — 超过 21 天无 review 且非关键修复的 PR，礼貌关闭（留言说明愿意在需要时重开）
3. **合并同类** — 同一领域的多个小 PR 考虑 squash 合并成一个
4. **Conflict 及时处理** — rebase conflict 超过 7 天未解决的 PR，要么当天解决，要么关闭
5. **followup 巡检** — PR Patrol 发现 conflict/stale 时，当轮就处理，不留到"下次 workloop"

**现实检查**：如果某个项目长期 >5 PR 且 review 极慢（>14 天常态），考虑降低该项目优先级或减少投入。

**Followup 审计**：每轮 workloop followup 步骤会按 repo 聚合 open PR 数量。超限的 repo 自动触发存量管理（主动关闭 stale PR 或暂停新提交）。

## Review 分诊：Bot vs 人类

大量项目使用 AI review bot（CodeRabbit、cubic-dev-ai、chatgpt-codex-connector、claude 等）。这些 bot 的 review 和人类 maintainer 的 review 需要区别对待：

- **Bot review ≠ actionable review** — bot 标记的 🔴 CHANGES_REQUESTED 不等于需要改代码。先看内容：如果是格式建议、风格偏好、或 false positive，可以忽略或简短回复说明理由
- **人类 review 优先** — 只有人类 maintainer 的 review 才算真正需要响应的反馈。workloop followup 时优先处理人类 review，bot review 降级
- **Bot review 有价值的情况** — changeset 包名错误、明显的 bug 指出、CI 配置问题等客观错误仍需修复（如 kilocode #9329 包名错误）
- **巡检报告精简** — patrol 汇报时区分 "X 个 bot review（无需处理）" vs "Y 个人类 review（需响应）"，避免每轮重复分析同样的 bot flag

## 减少被 Supersede

PR 被维护者 supersede（关闭后自己重写）是最大的时间浪费。常见原因和对策：

1. **方案粒度不匹配** — 我的修复太窄（只堵一个入口），维护者的方案更系统（sweeper + recovery + CLI）。对策：提 PR 前先看 repo 里同类问题怎么解决的，匹配已有架构模式（service layer、sweeper、util 模块），不要在单一入口加 ad-hoc 逻辑
2. **代码组织偏好不了解** — 内联 vs 提取到独立 util 文件。对策：看 repo 的 utils/helpers 组织方式，新功能按同样粒度拆分。项目笔记里记录「代码组织偏好」
3. **大 issue 被维护者同时在做** — 对策：对于复杂 issue（尤其是核心功能），先留 comment 说明思路，等维护者确认方向后再写代码。小修复（typo、明显 bug）不需要
4. **Upstream 已自行修复** — 对策：提 PR 前 `git fetch upstream && git log --oneline upstream/main -20` 检查最近提交，看是否已有同方向改动

**被 supersede 后的行动**：读维护者的替代 PR 代码，记录差异到 `pr-superseded-lessons.md`，更新项目笔记。每次被 supersede 都是学习维护者思维的机会。

## 知识积累

- 每个贡献过的项目在 `wiki/projects/<项目名>.md` 维护笔记
- 内容：维护者风格、测试命令、踩过的坑、架构要点
- 每轮贡献结束时更新笔记
