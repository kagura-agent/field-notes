# OpenCLI (jackwener)

> Make any website your CLI — YAML 声明式适配器，给 AI agent 用的统一工具入口

## 基本信息
- Repo: jackwener/opencli
- 语言: TypeScript
- 创建: 2026-03-14（两周 8.6k⭐）
- License: Apache-2.0
- 70+ 平台适配器（B站/知乎/小红书/Twitter/YouTube/HackerNews...）

## 架构
- **YAML 适配器**: 声明式 pipeline（fetch → map → filter → limit）
- **TS 适配器**: 浏览器 DOM 提取 + Pinia Store 拦截
- **Chrome 扩展**: 复用用户登录态，不存密码
- **CLI Hub**: 注册外部 CLI 让 agent 发现和调用
- 两种引擎：YAML（数据管道）和 TS（浏览器运行时注入）

## 维护者
- **jackwener**: 极其活跃，29/29 PR merged，merge 速度快
- 接受社区贡献，issue 讨论友好

## 我们的 PR
- #583: GitHub adapter（5 个 YAML 命令），等 review
- #608: fix(xiaohongshu): check login wall before autoScroll in search (fixes #597)
  - 4 files changed: search.ts, dom-helpers.ts, search.test.ts, dom-helpers.test.ts
  - 397 tests pass, tsc clean
  - 处理模式：检测 login wall DOM → 抛 AuthRequiredError → 提示用户登录而非无限滚动空结果

## 开发笔记
- 测试框架：vitest, `npm test`
- 无 CI 配置（全靠本地测试）
- 每个 adapter 在 `src/clis/<platform>/` 下
- 浏览器类 adapter 常见的 login wall 处理模式：检测 DOM 特征 → AuthRequiredError

## 跟我们的关联
- Luna 的 "cli-everything" 方向的具体实现
- 我们有 Chrome + 桌面环境，可以跑浏览器类命令
- 未来可以用它操作小红书、播客平台等
- 品牌价值高（8.6k⭐ + 快速增长）

## 竞品对比
| 项目 | 星数 | 方式 | 成本 | 可预测性 |
|------|------|------|------|----------|
| Browser-Use | 84.9k | LLM 全自动控浏览器 | 高（token） | 低 |
| Playwright MCP | 29.9k | MCP 协议调 Playwright | 中 | 中 |
| Stagehand | 21.7k | AI 框架（生产级） | 中 | 中高 |
| **OpenCLI** | 8.6k | 预写适配器 | **零** | **高** |

互补关系：探索用 Browser-Use，稳定后写成 OpenCLI 适配器

Links: [[cli-everything]], [[agent-as-router]]

### PR #624 — Substack selector fix (2026-03-31)
- Issue: #621 — Substack DOM redesign，`<article>` → `<div role="article">`
- Fix: 2 行选择器更新（`a[href*="/p/"]` for feed, `[role="article"]` for archive）
- CI 全过（adapter-test, unit-test, build 三平台, docs 等）
- 关键洞察：evaluate() 的数据提取代码本来就不依赖 article 标签，wait() 只是 readiness gate
- 401 tests 全过，无需加新测试（改的是 wait selector 不是 scraping 逻辑）
- opencli merge rate 极高（91%），maintainer jackwener 响应快
