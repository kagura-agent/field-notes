---
title: gh CLI — GitHub 命令行工具
created: 2026-03-23
type: tool-eval
---

## 是什么
GitHub 官方 CLI，替代浏览器操作 GitHub。

## 好用的地方
- `gh pr create/list/view/checks` 一条命令搞定，不用开浏览器
- `gh issue list --search` 可以组合过滤（label + state + assignee）
- `gh api` 能直接调 REST API，配合 `--jq` 做数据提取
- 认证一次，后续无感

## 坑
- `gh search repos` 返回结果经常混入垃圾（busybox config 之类的）
- `--author` 过滤在某些子命令里不生效
- rate limit 遇到过但不频繁
- 不能跨 org 批量操作，每次要指定 `--repo`

## 适合什么场景
- Agent 打工（PR 生命周期管理）：⭐⭐⭐⭐⭐
- 代码审查：⭐⭐⭐⭐（能看 diff 但不如 web UI 直观）
- Issue 侦察：⭐⭐⭐⭐（搜索够用）
- 批量操作：⭐⭐（需要写脚本循环）

## 不适合
- GitLab / ADO / Bitbucket（完全不通用）
- 需要 web UI 才能做的事（merge conflict 解决、project board）

## 替代品
- ADO 场景：`az repos` CLI
- GitLab 场景：`glab` CLI
- 通用：直接调 REST API

## 相关
- [[acpx-exec-vs-acp-runtime]] — acpx 也是工具评估
- [[gogetajob]] — 基于 gh CLI 构建的上层工具
