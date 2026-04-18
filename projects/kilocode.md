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
