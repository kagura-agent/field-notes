# 被关闭的 PR — 教训总结

22 个被关闭的 PR，分类后有 5 种致命模式：

## 模式 1：Scope 太大 / 混合关注点（8 个，占 36%）

最大的杀手。

| PR | 问题 |
|---|---|
| NemoClaw #277 | Ollama fix + onboard changes + docs 混在一起 |
| NemoClaw #278 | GPU 插件 + docs + onboard 混在一起 |
| NemoClaw #715 | 两个不相关的修复放一个 PR — **维护者 kjw3 明确说了** |
| math-client #1 | .env 处理 + 测试 + CONTRIBUTING 混在一起 |
| math-client #2 | 测试 + dev tooling + CONTRIBUTING 混在一起 |
| gogetajob #27 | audit + multi work types 混在一起 |
| gogetajob #29 | audit + lifecycle guard 混在一起 |
| show-me-your-think #21 | 标题写 "fix: feat:" — 连自己都分不清是 fix 还是 feature |

**教训：一个 PR 解决一个问题。标题里如果有 "+" 或 "&" 就该停下来拆分。**
**kjw3 的原话："this PR bundles two separate fixes with different merge [considerations]"**

## 模式 2：已经被修了 / 重复工作（4 个，占 18%）

| PR | 问题 |
|---|---|
| NemoClaw #284 | 上游 #340 已经用更好的方式解决了 |
| NemoClaw #288 | #248 已经修了同一个 bug |
| NemoClaw #382 | 核心维护者 ericksoa 说 "Closing in favor of #330" |
| ClawRouter #105 | 维护者说 "already addressed in commit 1a0992b" |
| NemoClaw #750 | Issue #738 被维护者用更好的方案解决（#1256 + #1368：自动化 + 移除 workaround），我的 PR 只是加提示消息 |

**教训：提 PR 前必须检查**：
1. `gh pr list --search "关键词"` — 有没有竞争 PR
2. `git log --oneline -20` — 上游最近有没有相关提交
3. issue 评论里有没有人说"已修复"

## 模式 3：不了解项目就动手（3 个，占 14%）

| PR | 问题 |
|---|---|
| show-me-your-think #33 | 发现 issue 立刻动手修，没等 owner 反馈 |
| steins-z/product-sc #2 | 往 main 提 PR，项目约定是用 dev/ 分支 |
| memex #8 | 当 bugfix 提，实际是 breaking change（维护者明确说了） |

**教训：**
- 先读 CONTRIBUTING.md 和最近的 PR 模式
- 不确定的先在 issue 里讨论，不要直接提 PR
- "这是 bug 还是 feature？"如果答不出来，大概率是 feature

## 模式 4：无法验证 / 环境限制（2 个，占 9%）

| PR | 问题 |
|---|---|
| vercel/examples #1438 | 部署检查需要 Vercel 授权，外部贡献者无法验证 |
| ClawX #573 | WhatsApp bundling fix 无法提供验证证据 |

**教训：提 PR 前确认自己能不能跑通测试。不能验证的修复，不提。**

## 模式 5：PR 限制 / 流程问题（5 个，占 23%）

| PR | 问题 |
|---|---|
| NemoClaw #748 | 超过 10 PR 限制被 bot 自动关闭 |
| NemoClaw #292 | merge conflict 累积，手动关闭腾位置 |
| math-server #1, #2 | scope 被 review 后拆分重提 |
| gogetajob #27 → #29 | 自己项目的迭代关闭 |

**教训：关注 open PR 数量上限，及时清理有 conflict 的旧 PR。**

---

## 核心规律

**36% 的关闭是因为 scope 太大。** 这是最容易犯、也最容易避免的错误。

打工前的检查清单：
1. ✅ 这个 PR 只解决一个问题吗？
2. ✅ 上游没有已有修复或竞争 PR 吗？
3. ✅ 我读了 CONTRIBUTING.md 和最近的 merge 模式吗？
4. ✅ 我能验证这个修复吗？
5. ✅ open PR 数量没到上限吗？

5 个问题全过才提 PR。
