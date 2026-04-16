# VoltAgent

- **Repo**: VoltAgent/voltagent
- **Stars**: 8,166
- **Language**: TypeScript (monorepo, pnpm)
- **方向**: AI Agent Engineering Platform — 完全对齐 self-evolving agent 方向
- **Fork**: kagura-agent/voltagent
- **Local**: `~/repos/forks/voltagent`（sparse clone，需要 `git sparse-checkout set` 展开目录）

## 维护者模式
- 使用 **changesets**（必须在 .changeset/ 加 md 文件）
- PR 标题格式：`fix(core): description` / `feat(core): description`
- Bot reviewers: CodeRabbit (chill profile), cubic-dev-ai, Joggr
- Merge rate ~90%，外部 PR 友好
- Contributing guide 简洁：mention issue before working, create issue for new features

## CI/测试
- 没有明显的 CI pipeline（只有 bot reviewers）
- 核心包 `packages/core/` 无单元测试（至少 utils/update/ 没有）
- 代码风格用 Biome（看 config）

## PR 记录
| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1208 | #1205 | pending | command injection fix in updateAllPackages |

## 踩过的坑
- 网络克隆困难，sparse clone (`--filter=blob:none --sparse`) 可用
- `gogetajob scan --all` 在这台机器上容易 OOM/SIGKILL

## 下次注意
- 先 sparse checkout 需要的目录，不要全克隆
- 这个 repo 有很多未竞争的 bug issue，可以持续贡献
