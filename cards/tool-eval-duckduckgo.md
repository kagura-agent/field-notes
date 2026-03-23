---
title: DuckDuckGo Web Search — 内置搜索
created: 2026-03-23
type: tool-eval
---

## 是什么
OpenClaw 2026.3.22 内置的 web 搜索，不需要 API key。

## 好用的地方
- 零配置，开箱即用
- Brave API key 过期后的救命替代
- 结果质量对技术搜索够用

## 坑
- **限频严重**：3-4 次搜索后就触发 bot detection，返回错误
- 不能连续快速搜索，需要间隔或配合 web_fetch 使用
- 没有 Brave 那种 snippet 质量

## 适合什么场景
- 偶尔的侦察搜索（学习循环 scout 阶段）：⭐⭐⭐⭐
- 快速验证一个事实：⭐⭐⭐⭐
- 密集搜索（竞品扫描、批量查询）：⭐⭐（限频）

## 最佳实践
- 搜 2-3 次拿到关键 URL → 切换到 web_fetch 直接读内容
- 不要在一轮操作中搜超过 5 次

## 相关
- [[acpx-exec-vs-acp-runtime]] — 同为 gateway 升级带来的新能力
