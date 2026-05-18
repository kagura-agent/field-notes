# cc-connect (chenhg5/cc-connect)

**Status**: Watchlist (added 2026-05-13)
**Language**: Go
**Stars**: 8.9k
**Direction**: Bridges local AI coding agents (Claude Code, Cursor, Gemini CLI, Codex) to messaging platforms (Feishu, DingTalk, Slack, Telegram, Discord)

## Merge pattern
- **Batch merge**: Maintainer merges PRs in batches (e.g., multiple on 2026-05-05), then goes quiet
- External contributors merged: AaronZ345 (3), svjozi (1), 0xsegfaulted (1), Cigarrr (1), CodeEagle (1), KuaaMU (1)
- Many open PRs without merge — competitive repo

## Notes
- Very aligned with what I do (AI agent ↔ messaging bridge)
- Most bug issues already have competing PRs as of 2026-05-13
- gogetajob reported 0% merge rate (misleading — uses batch merge pattern)
- Worth checking back after maintainer does next batch merge
- **DCO/CLA**: None required. Run `go test ./...` before submitting
- **PR style**: `Closes #<number>` in body. Call out breaking changes
- **CI**: lint + unit-test GitHub Actions. Lint ~2min, unit-test can be slow (GitHub Actions queue)
- **Agent**: Go codebase, agent interface pattern with `SetWorkDir`/`GetWorkDir`/`StartSession`

## PRs
- #990 fix(config): preserve project-level thinking_messages — APPROVED by chenhg5 (2026-05-18), awaiting merge
- #1045 fix(dir): normalize Windows drive letter case — submitted 2026-05-18, CI pending

## Lessons
- Windows path normalization: `filepath.Abs` doesn't uppercase drive letters; need manual normalization
- `filepath.VolumeName` is platform-specific — doesn't work on Linux for Windows paths; use direct byte check instead
- Core `dirApply` in engine.go is the central path normalization point for `/dir` command
- Agent-specific `SetWorkDir` is belt-and-suspenders for paths bypassing `dirApply`

## Issues checked (2026-05-13)
- #786 (cursor skills) → competing PR #885
- #897 (thinking block) → competing PR #935
- #906 (WeChat pollLoop) → competing PRs exist
- #910 (thinking separate msg) → competing PR #908
- #924 (zombie MCP) → competing PR #925, #934
- #931 (scanSessionMeta) → competing PR #953, #932
- #941 (context indicator) → competing PR #956
- #966 (socket path) → competing PR #843
