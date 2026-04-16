# pew — AI 编程工具的 contribution graph

> nocoo/pew · MIT · TypeScript (Bun) · npm: @nocoo/pew
> 追踪本地 AI 编程工具的 token 用量，聚合上传至 SaaS 仪表盘

## 一句话

GitHub 的 contribution graph，但计数单位是 token 而非 commit。从本地日志只读解析，增量同步到云端仪表盘。

## 核心架构

五阶段数据管线：

```
Raw Logs → ParsedDelta[] → QueueRecord[] (30min bucket) → HTTP Upload → D1 Upsert
```

**关键设计决策：**
- 只读——绝不修改用户的 AI 工具日志
- 幂等上传——服务端 upsert，重复上传不会数据膨胀
- 游标先写——crash 后宁可丢一次数据也不 double-count（见 sync-resilience）

## 支持的 AI 工具（7 种）

| 工具 | 日志格式 | 增量策略 | Token 模型 |
|------|----------|----------|-----------|
| Claude Code | JSONL（绝对值） | 字节偏移 | input + cache_creation → inputTokens; cache_read → cached |
| Gemini CLI | JSON session（累积值） | 数组索引 + cumulative diff | thoughts → reasoning; tool → output |
| OpenCode | 单文件/msg JSON（累积值） | inode+size+mtime 三重检查 + cumulative diff | cache.write → input; reasoning 独立 |
| OpenClaw | JSONL（绝对值） | 字节偏移 | cacheRead+cacheWrite → cached（与 Claude 不同！） |
| Codex CLI | — | — | — |
| VS Code Copilot | — | — | 估算模型（见 doc 19） |
| GitHub Copilot CLI | — | — | — |

## 四维 Token 计数模型

```
total_tokens = input_tokens + cached_input_tokens + output_tokens + reasoning_output_tokens
```

设计哲学：
1. **缓存 token 算实际工作**——模型确实读了 KV cache 做 attention
2. **跨源统一公式**——不做 source-specific 分支
3. **直觉语义**——"我用了多少 token" 应该反映模型 touch 的一切

与 vibeusage 对比：vibeusage 的 `billable_total_tokens` 对 Claude/OpenCode 用相同公式，但名字误导（不是真正的计费金额）。

## 增量同步机制

三种游标策略：

| 策略 | 适用 | 原理 |
|------|------|------|
| **ByteOffsetCursor** | Claude Code, OpenClaw（JSONL） | 记录已读字节偏移，下次从偏移处继续 |
| **GeminiCursor** | Gemini CLI（累积值 JSON） | 数组索引 + 上次累积值，diff 计算增量 |
| **OpenCodeCursor** | OpenCode（散文件+累积值） | inode+size+mtime 三重检查 + 目录级 mtime 优化跳过 ~66K 文件 |

容错：
- 单文件解析失败 → try/catch 隔离，跳过该文件，不影响其他
- 游标先于 queue 写入 → crash 后不会 double-count

## 会话统计（独立管线）

与 token 管线完全独立——独立游标、独立队列、独立 API 端点。

- 会话是**快照**（每次 sync 全量覆盖），不是累加
- 区分 human（Claude/Gemini/OpenCode）vs automated（OpenClaw）
- 追踪：时长、消息数、项目引用、主用模型

## 技术栈

Bun 运行时 + citty CLI · Next.js 16 Web · Cloudflare D1 + Workers · 90% 覆盖率目标 · 三层测试（Unit/API E2E/BDD E2E）

## 对 gogetajob 的借鉴价值

1. **增量解析模式**——gogetajob 如果要统计打工数据，ByteOffsetCursor 和 cumulative diff 是成熟参考
2. **四维 token 模型**——统一的 token 计数公式，跨工具可比
3. **游标先写的容错哲学**——宁丢不重，适用于任何增量同步场景
4. **目录级 mtime 优化**——大量小文件场景的性能优化技巧
5. **独立管线设计**——token 和 session 数据关注点分离，互不阻塞

## 链接

- GitHub: <https://github.com/nocoo/pew>
- npm: <https://www.npmjs.com/package/@nocoo/pew>
- 相关卡片: incremental-sync-patterns（待创建）

---
*来源: gh repo view + docs/03-data-pipeline, 05-token-accounting, 06-session-statistics, 04-sync-resilience · 2026-04-07*

## PR 记录

### PR #42 — feat: vscode-copilot v3 JSON support (2026-04-09)
- **状态**: PENDING
- **Issue**: #36 (VS Code 1.108+ .json v3 format not recognized)
- **改动**: 新增 v3 parser + discovery 扩展 + driver routing
- **测试**: 16 新测试全过，全套 2936/2938 pass（2 个已有 flaky）
- **注意**: 项目用 Bun，本地没装 Bun 但 vitest 可以通过 npx 跑
- **维护者**: nocoo（活跃，#41 近期 merge）
- **坑**: husky pre-commit/pre-push 需要 bun，本地没有要 --no-verify
- **下次**: 装好 bun 再打，避免 husky 绕路

### PR #74 — feat: logout support (2026-04-13)
- **状态**: ✅ MERGED (same day! by nocoo)
- **Issue**: logout/signout 功能
- **亮点**: nocoo 是活跃维护者，merge 速度极快（当天提当天合）
- **模式**: pew 的 merge rate 远高于 hermes/openclaw — 小项目、活跃 maintainer、贡献友好
- **经验**: 如果需要快速积累 merged PR，pew 是优质目标
