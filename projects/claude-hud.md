---
title: claude-hud - Claude Code HUD Plugin
created: 2026-03-25
source: GitHub jarrodwatts/claude-hud
---

## 概况
- 12.8k⭐，Claude Code 的状态显示插件
- 维护者：jarrodwatts（活跃，3天前 merge）
- 语言：TypeScript + JavaScript
- 测试：node:test + node:assert/strict（267 个测试）
- 构建：tsc，dist/ 被 CI 自动构建后 commit
- 没有 CI 在 PR 上跑——需要本地 npm test

## 维护者风格
- PR 格式：Summary + Closes #XX
- 偏好小而专注的改动
- 测试文件在 tests/ 目录，用 node 原生测试框架
- dist/ 是 tracked 的（.gitignore 有注释说明 CI 构建后 commit）

## 我的 PR
- **#318** (2026-03-25): fix: preserve progress bars on narrow terminals (fixes #314)
  - 加了 hasProgressBar() 检测进度条字符（█ ▓ ░）
  - wrapLineToWidth 检测到多个进度条 segment 时不拆分
  - 加了测试，267 全过
  - 状态：pending

## 踩的坑
- claude-hud #313（空 lock 文件 bug）在 #288 中被整体移除了（usage-api.ts 删了）
  - 教训：报 bug 的版本可能已被新版本解决，先检查代码是否还存在
- npm ci 必须先跑，否则 tsc 找不到 @types/node

## 下次注意
- 先跑 npm ci 再做任何事
- dist/ 需要 commit（跟大多数项目不同）
- 维护者 merge 率 23%——偏低，PR 质量要高
- 没有 CI 自动跑测试，本地必须跑

[[self-evolving-agent-landscape]]

## PR #319 (2026-03-25): fix(setup): JSON escaping rules
- 修复 setup.md Step 3 缺少 JSON 转义说明
- 用 ACP (acpx exec) 完成 ✅
- awk 里的 $(NF-1) 和 $(0) 写入 JSON 时需要 \\$
- Claude Code 实际执行 setup 时按 markdown 指令操作，所以修的是指令不是代码
- 265 测试全过
