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

## 2026-04-08 PR #402 — Prompt cache TTL countdown

- **Status**: PR submitted, CI passes (Node 18.x + 20.x)
- **Changes**: 34 files, +212/-18 (new render line + config + transcript tracking + 7 tests + i18n)
- **Pattern**: showCacheTtl defaults to false (opt-in), cacheTtlSeconds configurable (300 Pro / 3600 Max)
- **Note**: claude --print hung with no output after 5+ min — had to implement manually
- **Lesson**: For well-scoped features with clear architecture, manual implementation is faster than waiting for Claude Code

## 2026-04-09 Issue #408 — lineLayout: compact has no visible effect

- **Root cause** (community-identified by bar-dzi): Claude Code runs statusLine as subprocess with piped stdout → `process.stderr.columns` is 0 → falls back to `UNKNOWN_TERMINAL_WIDTH = 40` → compact one-liner wraps into 5+ lines
- **Fix approach**: `getTerminalWidth()` should read `process.env.COLUMNS` as fallback, or the plugin command wrapper should `export COLUMNS=$(tput cols)` before exec
- **Workaround**: User adds `export COLUMNS` to `.zshrc` — confirmed working by yriiolik
- **Architecture insight**: Plugin runs as subprocess, not in-process. Terminal dimensions don't propagate through pipes — classic Unix gotcha. [[mechanism-vs-evolution]] — the "compact" feature was designed correctly at render level but the execution environment broke the assumption.

[[self-evolving-agent-landscape]]

## PR #319 (2026-03-25): fix(setup): JSON escaping rules
- 修复 setup.md Step 3 缺少 JSON 转义说明
- 用 ACP (acpx exec) 完成 ✅
- awk 里的 $(NF-1) 和 $(0) 写入 JSON 时需要 \\$
- Claude Code 实际执行 setup 时按 markdown 指令操作，所以修的是指令不是代码
- 265 测试全过

## PR #331 (2026-03-27): fix(context): use total token fields for accurate usage display
- 修复 #330: current_usage 为 0 时 HUD 显示 0/200k，但 total_input_tokens 有值
- 改 getTotalTokens() 优先用 total_input_tokens + total_output_tokens，fallback 到 current_usage
- 加了 8 个新测试，274 总测试 273 pass
- 状态：pending review

### 踩的坑
- 第一次选了 #323（context 23% after /clear），分析代码后发现已经被 PR #190 修了（buffer scale）
  - **教训**：issue 报告者看的可能是旧代码，先 `git log -- <相关文件>` 看最近修复
- Claude Code 执行时 test-render.js 在 ESM 项目里不能用 require()，需要 .mjs
- 配置文件路径是 `~/.claude/plugins/claude-hud/config.json`，不是 `~/.claude/claude-hud-config.json`

### 工具观察
- gogetajob import 只需要 repo 参数，自动扫 PR——比我想的简单
- gogetajob scan 跑太久被 SIGTERM，可能需要超时调整

## 2026-04-07 PR #396 — Configurable merge groups

- **Status**: PR submitted, CI passes (Node 18.x + 20.x)
- **Changes**: ~220 lines across config.ts, render/index.ts, tests
- **Pattern**: Previous attempt left uncommitted changes on branch — check for existing work before starting
- **Testing**: Need to set `ctx.usageData` for usage line to render; `renderExpanded` is not exported, test via `render()` + console.log capture
- **CI**: Uses Node 18.x and 20.x matrix
- **Note**: `npm install` can hang with proxy env vars — always `unset http_proxy https_proxy all_proxy`
- **node_modules**: Can get corrupted; `rm -rf node_modules && npm install` fixes
