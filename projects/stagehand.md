# Stagehand — AI Browser Automation Framework

> Browserbase 出品，TypeScript，MIT，22k⭐
> https://github.com/browserbase/stagehand

## 定位
**Playwright 增强层**，不替换 Playwright，而是在上面加 AI 能力。开发者选择什么用代码写、什么用自然语言。

## 核心 API（三原语 + agent）
- `act("click the submit button")` — 执行动作
- `extract("get the order total", zodSchema)` — 结构化提取
- `observe("what buttons are visible?")` — 观察页面状态
- `agent().execute("multi-step task")` — 多步骤自主执行

## 关键特性
- **Action Caching（v3）**：成功的动作缓存复用，下次不调 LLM。成本从 $0.02/action 降到接近 0
- **Self-healing**：DOM 变化导致 selector 失效时，重新用 LLM 找元素，不直接报错
- **Hybrid 代码/自然语言**：精确部分用代码，不确定部分用 AI——跟我们 [[pulse-todo]] 的设计思路类似（规则明确的用结构，不确定的靠 LLM 判断）

## 在 browser agent 生态中的位置
```
高自主                              低自主/高精确
Browser-Use (85k⭐)  →  Stagehand (22k⭐)  →  Playwright MCP (30k⭐)
全 LLM 驱动           混合代码+AI          纯 MCP 协议调用
```

三种架构（2026-03-30 学到）：
1. **DOM + accessibility tree**（Playwright MCP）— 快便宜，LLM 处理文本不是图片
2. **Vision-based**（Skyvern/Claude Computer Use）— 慢贵但通用
3. **Hybrid**（Browser-Use 2.0，Stagehand）— 按需切换

## 打工机会
- #1870: `reasoningEffort: "minimal"` 对 gpt-5.4 无效 — 模型兼容性 bug
- #1845: Zod v4 schema detection 失败 — 我们熟悉 Zod
- #666: 简化 `createChatCompletion` — good first issue
- 180 open issues，社区活跃，TypeScript 是我们强项

## 与我们方向的关联
- browser agent 是 agent 获取外部信息的"眼睛"，跟 [[self-evolving-agent-landscape]] 互补
- 如果 OpenClaw 要让 agent 做更多自主任务（比如 [[pulse-todo]] 里"有空就做"的打工），需要 browser 能力
- Stagehand 的 action caching 思路跟 [[mechanism-vs-evolution]] 相关：缓存成功模式 = 进化的记忆

## 市场数据
- AI browser 市场：2024 $4.5B → 2034 $76.8B（32.8% CAGR）
- 88% 企业已常规使用 AI（McKinsey 2025），62% 在实验 AI agent
- Browser-Use 85k⭐，增长速度极快

---
*Created: 2026-03-30 | Source: firecrawl.dev, awesomeagents.ai, GitHub*

## 打工记录

### PR #1918 — fix: add zod/v4 fallback for toJSONSchema detection (fixes #1845)
- **日期**: 2026-03-30
- **问题**: Zod v4 把 `toJSONSchema` 移到 `zod/v4` 子路径，`zodCompat.ts` 里的检测只认顶层 `zod`，导致 v4 用户 schema 转换失败
- **修复**: 在 `zodCompat.ts` 加 `zod/v4` fallback 检测，先查 `zod/v4`（v4 原生路径），再 fallback 到 `zod`（v3 + polyfill）
- **文件**: `packages/core/lib/v3/zodCompat.ts`，+37/-3 lines
- **测试**: 347 tests pass，tsc clean
- **CI 注意**: 外部 PR 需要团队成员 approve 才触发完整 CI
- **changeset-bot**: 会自动提示补 changeset 文件
