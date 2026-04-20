# Kilocode (Kilo-Org/kilocode)

> VS Code AI coding extension, forked from Roo Code / Cline lineage. 18k+ stars.

## 基本信息
- **语言**: TypeScript (Bun monorepo)
- **构建**: `bun install && bun dev`
- **测试**: `bun test` (bun:test)
- **要求**: Bun 1.3.10+, changesets for user-facing changes
- **Repo 结构**: `packages/opencode` (核心), `packages/kilo-vscode` (VS Code 插件), `packages/app`, `packages/kilo-ui`

## PR 历史

### PR #9155 — fix(agent): resolve agents by display name when slug lookup fails
- **Issue**: #9096 — Agent Slug vs name inconsistency
- **状态**: OPEN (2026-04-18)
- **改动**: 
  - `packages/opencode/src/kilocode/agent/index.ts`: 新增 `resolveAgentKey()` 三级 fallback（exact slug → case-insensitive slug → name field match）
  - `packages/opencode/src/agent/agent.ts`: `Agent.get()` 改用 `resolveAgentKey`
  - 新增 `test/kilocode/resolve-agent-key.test.ts` 单元测试
  - changeset: patch
- **CI**: 大部分 checks skipping（fork PR），Kilo Code Review pending

## 维护者风格
- 活跃维护者: @lambertjosh, @johnnyeric, @marius-kilocode, @alex-alecu
- 用 changesets 管理版本
- PR 标题格式: `fix(scope): description` / `feat(scope): description`
- kilocode 标记改动: `// kilocode_change` 注释
- 内部 AI review: Kilo Code Review (app.kilo.ai)

## 注意事项
- Repo 很大，sparse checkout 不太好使（monorepo 依赖互相引用）
- 建议用 GitHub API 直接提交改动，不本地 clone
- `resolveKey` 只做 build→code，新增功能要用 `resolveAgentKey`
- agents map 按 slug（文件名）做 key，`name` 字段可以不同
- fork PR 的 CI checks 大部分 skip，不影响 review

## 下次打工注意
- 看 Kilo Code Review 的反馈模式
- 如果需要本地测试，要 full clone（~大 repo）
- gogetajob import 对新 PR 有延迟，等几分钟再试
- 大 repo 用 GitHub API 直接提交改动效率最高
- keybinding 相关 bug 需要理解 opentui 的匹配顺序（first-match）

### PR #9156 — fix(cli): Shift+Enter newline
- **Issue**: #9055 — Shift+Enter sends message
- **状态**: OPEN (2026-04-18)
- **改动**: `textarea-keybindings.ts` 重排 keybinding 数组，config bindings 优先于 hardcoded fallback
- **根因**: hardcoded `{ name: "return", action: "submit" }` 在 config bindings 之前，匹配所有 Return 变体

### PR #9161 — fix(suggest): auto-dismiss after timeout to prevent stuck sessions
- **Issue**: #9150 — Suggest tool can leave a session in false queued state
- **状态**: OPEN (2026-04-18)
- **改动**:
  - `packages/opencode/src/kilocode/suggestion/index.ts`: 添加 server-side timeout（默认 5 分钟），`show()` 启动 setTimeout 与 promise 竞争，超时自动调用 `dismiss()`，accept/dismiss 前清 timer
  - 新增 3 个测试：timeout auto-dismiss、accept 清 timer、dismiss 清 timer
  - changeset: patch
- **CI**: fork PR checks skip（正常），Kilo Code Review pending
- **根因分析**: suggest tool 的 promise 永不 resolve 当用户关闭 VS Code 或忽略 suggestion → session 卡在 "queued" 状态
- **方法**: server-side timeout 比 client-side recovery 更可靠（不依赖 VS Code 重连）

### PR #9178 — fix(session): clamp output token count to prevent negative values
- **Issue**: #9168 — Negative output token count when reasoning > outputTokens
- **状态**: OPEN (2026-04-19)
- **改动**:
  - `packages/opencode/src/session/index.ts`: `Math.max(0, outputTokens - reasoningTokens)` 防止负值
  - 添加 warning log 当 `reasoningTokens > outputTokens`
  - changeset: patch (`@kilocode/cli`)
- **根因**: Moonshot kimi-k2.5 via Kilo gateway 报告 reasoningTokens > outputTokens，违反 AI SDK v6 约定
- **影响**: TUI/extension/export 显示负数，stats 聚合偏低
- **方法**: 防御性 clamp + 日志监测频率

## 踩坑记录
- kilocode repo 巨大（>1GB），shallow clone + sparse checkout 都超时，用 GitHub API 直接提交改动效率最高
- gogetajob import 有延迟，新 PR 可能几分钟后才能被搜到

### PR #9182 — fix(plan): prevent "Continue here" popup from repeating
- **Issue**: #9144 — Plan exit's "continue here" option repeatedly pops up
- **状态**: OPEN (2026-04-19)
- **改动**:
  - `packages/opencode/src/kilocode/session/prompt.ts`: `shouldAskPlanFollowup()` 加 agent guard — 如果 lastUser.agent ≠ "plan" 则跳过（"Continue here" 注入的 user msg 用 agent="code"）
  - `packages/opencode/test/kilocode/plan-exit-detection.test.ts`: 新增测试验证 "Continue here" 后不再触发
  - changeset: patch
- **根因**: `shouldAskPlanFollowup` 只检查 plan_exit tool 是否在 last user 之后的 assistant 消息中，没有考虑 "Continue here" 已经注入了 agent="code" 的用户消息
- **方法**: 最小改动 — 加一行 agent 检查，不动其他逻辑

### PR #9181 — fix(provider): use 'low' instead of 'minimal' reasoning effort for GitHub Copilot
- **Issue**: #9143 — Enhance Prompt/Title Generation fails for GPT-5-Mini with "reasoning_effort 'minimal' not supported"
- **状态**: OPEN (2026-04-19)
- **改动**:
  - `packages/opencode/src/provider/transform.ts`: `smallOptions()` 分离 `@ai-sdk/github-copilot`，GPT-5 用 `"low"` 而非 `"minimal"`
  - `packages/opencode/test/provider/transform.test.ts`: 3 个新测试覆盖 Copilot smallOptions 行为
- **根因**: `smallOptions()` 把 OpenAI 和 Copilot 混在一起，但 Copilot API 不支持 `"minimal"`。`variants()` 已正确处理（用 WIDELY_SUPPORTED_EFFORTS）
- **Kilo Code Review**: No Issues Found, Recommendation: Merge
- **方法**: 最小改动 — 只分离 Copilot 分支，不改其他 provider 逻辑
- **教训**: `smallOptions()` 和 `variants()` 对同一 provider 的 effort 列表应保持一致。检查时对比两个函数的 case 分支

### PR #9232 — fix(ignore): match unrooted .kilocodeignore patterns at any tree depth
- **Issue**: #9228 — .kilocodeignore does not work for single files
- **状态**: OPEN (2026-04-20)
- **改动**:
  - `packages/opencode/src/kilocode/ignore-migrator.ts`: 新增 `isUnrooted()` 判断 gitignore 模式是否应匹配任意深度；`buildPermissionRules()` 对 unrooted 模式同时生成 root 级和 `*/` 前缀两条规则
  - `packages/opencode/test/kilocode/ignore-migrator.test.ts`: 8 个新测试覆盖 isUnrooted 分类和 buildPermissionRules 子目录变体
  - changeset: patch (`@kilocode/cli`)
- **根因**: `convertToGlob("secret.txt")` 返回 `"secret.txt"`，`Wildcard.match` 用 `^secret\.txt$` 正则只匹配 root 路径。gitignore spec 规定无 `/` 分隔符的模式应匹配任意深度
- **方法**: 对每个 unrooted 模式额外生成 `*/pattern` 规则

## 踩坑记录
- kilocode repo 巨大（>1GB），shallow clone + sparse checkout 都超时，用 GitHub API 直接提交改动效率最高
- gogetajob import 有延迟，新 PR 可能几分钟后才能被搜到
- **大 repo 用 git cat-file 恢复缺失包源码时，会覆盖已修改的文件。应先 commit 改动，再恢复依赖**
