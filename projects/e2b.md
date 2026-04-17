# E2B (e2b-dev/E2B)

> Cloud sandbox infrastructure for AI agents. 11k+ stars.

## 概述
- **语言**: Python SDK + JS/TS SDK (monorepo)
- **包管理**: pnpm (monorepo), changesets for versioning
- **测试**: vitest (JS), pytest (Python)
- **CI**: Vercel deploy (needs maintainer auth for forks)

## 维护者
- Core team: mishushakov, jakubno, ben-fornefeld, ValentaTomas, mlejva, sitole, tomassrnka
- External PR merge: 有但不多 (dobrac, matthewlouisbrockman, travismarceau)
- 需要观察 merge 速度

## 贡献要求
- CONTRIBUTING.md 极简 ("open a PR, issue, or start a discussion on Discord")
- 需要 changeset（changeset-bot 会提醒）
- 项目用 pnpm，不要用 npm（会生成 package-lock.json，不被跟踪）

## PR 历史
| PR | Issue | 状态 | 备注 |
|---|---|---|---|
| #1276 | #1154 | pending | shell injection fix in MCP config |

## 踩坑记录
- npm install 会 OOM (内存不够) 且生成 package-lock.json — 用 pnpm
- Vercel deploy check 对 fork 会 fail（"Authorization required"）— 这是正常的，不是 CI 失败
- Claude review bot 对 fork 禁用，需要 maintainer 手动 @claude review

## 下次注意
- 用 pnpm 安装依赖
- 安全类 issue 的 PR 描述要包含 Before/After 对比和 PoC
