# Little Coder

> itayinbarr/little-coder | ⭐337 (2026-04-24) | TypeScript | Created 2026-04-11
> "A coding agent optimized to smaller LLMs"

## 概要

Little Coder 是一个专为小型本地 LLM 优化的 coding agent，构建在 [[pi-agent]] 之上。核心论点：**scaffold-model fit matters** — 用正确的 scaffold 设计，9.7B Qwen3.5 可以在 Aider Polyglot 上达到 45.56%（vanilla baseline 19.11%），2.4x 提升。

## 为什么现在？

小模型 coding agent 是一个被低估的方向。当所有人都在追 frontier model 时（GPT-5.5、Claude Opus 4.7），little-coder 证明了 scaffold 设计可以弥补模型能力差距。这对本地运行、隐私敏感、低成本场景有实际价值。

## 架构要点

### Pi 基座
- [[pi-agent]] 是极简 agent substrate：agent loop, multi-provider API, TUI, session tree, compaction, extension model
- 4 个内建工具：read / write / edit / bash + ~1000 token system prompt
- Little-coder 不 fork Pi，而是在 `.pi/extensions/` + `skills/` + `benchmarks/` 上扩展

### Load-Bearing Mechanisms（论文核心）
1. **Write-vs-Edit tool invariant** — 小模型容易混淆 write/edit 语义，这个约束强制正确使用
2. **Per-turn tool-skill injection** — 不一次注入所有 skill，而是每轮只注入当前 step 需要的（类似 [[mercury-agent]] 的 progressive skill disclosure）
3. **Algorithm cheat-sheet injection** — 给小模型提供算法参考（大模型内化的知识小模型需要外部注入）
4. **Thinking-budget cap** — 限制 reasoning token，防止小模型在思考上浪费 budget
5. **Output repair** — 后处理修复格式错误（小模型 JSON/code block 格式不稳定）
6. **Quality monitor** — 运行时质量检测 + 自动重试
7. **Per-benchmark profiles** — 不同 benchmark 用不同配置（承认 one-size-fits-all 不 work）

### Benchmark 进化
| Version | Model | Benchmark | Result |
|---------|-------|-----------|--------|
| v0.0.2 | Qwen3.5-9B (Ollama) | Aider Polyglot (225) | 45.56% |
| v0.0.5 | Qwen3.6-35B-A3B (llama.cpp) | Aider Polyglot | 78.67% |

## 反直觉发现

1. **Scaffold > Model size**：2.4x 性能提升来自 scaffold 设计而非更大模型。这挑战了 "换更好模型就行" 的思维模式。
2. **Per-turn injection vs full context**：跟 [[mercury-agent]] 的 progressive disclosure 和 [[openclaw]] 的 available_skills 注入形成对比。小模型不能处理大 context，但大模型也浪费 token 在不相关的 skill 描述上。
3. **Algorithm cheat-sheet**：大模型内化的知识对小模型需要外部注入——暗示 frontier model 的 "能力" 部分是 memorization，scaffold 可以替代。

## 生态位

与 [[aider]] 的关系：aider 假设 frontier model，little-coder 证明 scaffold 可以让小模型接近 aider 的表现。
与 [[openclaw]] 的关系：互补。OpenClaw 做 agent 编排和生命周期，little-coder 做 coding 执行层优化。如果 OpenClaw 用户跑本地模型（Ollama），little-coder 的 scaffold 技巧有参考价值。
与 [[pi-agent]] 的关系：上层应用，展示 Pi 的扩展性。

## 可借鉴

- [ ] Per-turn skill injection — 与 OpenClaw #66576（workspace files 选择性注入）相关
- [ ] Output repair pattern — 对任何使用小模型的场景有价值
- [ ] Thinking-budget cap — 可能帮助解决 [[openclaw]] 的 Copilot API 60s 流式超时问题

## 相关

- 论文: [Honey, I Shrunk the Coding Agent](https://open.substack.com/pub/itayinbarr/p/honey-i-shrunk-the-coding-agent)
- [[mercury-agent]] — progressive skill disclosure 类似 per-turn injection
- [[context-rot]] — token 效率是共同主题
