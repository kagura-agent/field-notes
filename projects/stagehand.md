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

### PR #1990 — fix: unwrap tool parameter name wrapper in Anthropic responses (Issue #1986)
- **日期**: 2026-04-10
- **问题**: Anthropic 模型的 act() 返回 `{$PARAMETER_NAME: {actual data}}`，Zod 校验失败
- **修复**: 新增 `unwrapToolResponse()` helper，在 AISdkClient 和 AnthropicClient 两条路径都做防御性解包
- **文件**: `unwrapToolResponse.ts` (新), `aisdk.ts` (修改), `AnthropicClient.ts` (修改), test (新)
- **测试**: 9 个单元测试
- **CI**: manage-external-pr pass，完整 CI 需 team member approve workflow
- **踩坑**: repo 太大（2G+），无法 clone，只能通过 GitHub API 直接创建 blob/tree/commit
- **changeset**: 需要 `.changeset/*.md` 文件，changeset-bot 会自动提醒
- **教训**: 大 repo 可以通过 GitHub Git Data API 完成全流程（create blob → create tree → create commit → update ref），不需要本地 clone

### PR #1997 — fix: respect opts.debug in installV3ShadowPiercer (fixes #1996)
- **日期**: 2026-04-11
- **问题**: `V3ShadowPatchOptions.debug` 选项被忽略，`DEBUG` 硬编码为 `true`，导致每次 `attachShadow` 都打 console.info
- **修复**: `const DEBUG = opts.debug ?? false;` 一行替换
- **文件**: `packages/core/lib/v3/dom/piercer.runtime.ts`，+1/-2 lines
- **CI**: manage-external-pr SUCCESS, cubic AI reviewer COMMENTED (non-blocking)
- **注意**: 这个 repo pnpm install 在我们的机器上 OOM (SIGKILL)，无法本地跑完整测试。类型安全通过人工验证
- **changeset**: 未加（如被要求，参考 #1918 经验）

## 外部 PR Review 模式 (2026-04-14 观察)
- **活跃 merge**: 外部贡献者 sameelarif, tkattkat 等被 merge
- **claim 模式**: pirate 会 claim 外部 PR 到内部 branch（如 #1918 → #1989）
- **结论**: 值得继续投入，代码会被采纳（即使 PR 被 claim）

### PR #2026 — fix: unwrap Anthropic $PARAMETER_NAME wrapper in tool responses (fixes #1986)
- **日期**: 2026-04-22
- **问题**: 同 #1990（之前自行关闭减少 PR 量），重新提交
- **修复**: 复用 #1990 方案 — `unwrapToolResponse()` helper，AnthropicClient 和 aisdk 两条路径都做防御性解包
- **文件**: `unwrapToolResponse.ts` (新), `aisdk.ts`, `AnthropicClient.ts`, test (新)
- **CI**: manage-external-pr pass，changeset 已加
- **教训**: 
  - 关闭后重提很顺畅，之前的实现笔记节省了大量时间
  - wiki 笔记的复利效果明显——第一次花了很多时间理解代码，第二次直接复用

### PR #2069 — fix: respect opts.debug in installV3ShadowPiercer (fixes #1996)
- **日期**: 2026-04-30
- **问题**: `V3ShadowPatchOptions.debug` 被忽略，`DEBUG` 硬编码为 `true`
- **修复**: `const DEBUG = opts.debug ?? false;` — 一行替换
- **文件**: `packages/core/lib/v3/dom/piercer.runtime.ts`, +1/-2 lines
- **changeset**: ✅ 已加（上次 #1997 忘了加被 changeset-bot 提醒）
- **CI**: manage-external-pr pass, cubic reviewer 5/5 no issues
- **注意**: 这是 #1997 的重提（#1997 自行关闭因为无 response 7 天）。这次加了 changeset
- **教训**: 关闭后重提很顺畅——代码没变，一行 fix 不需要重新理解。changeset 是必须的
