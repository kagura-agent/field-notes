# RivonClaw

> gaoyangz77/rivonclaw — ⭐252 (2026-04-14)
> "Easy-mode runtime and UI layer built on top of OpenClaw"

## 定位

OpenClaw 的**桌面端包装层**——把面向工程师的 OpenClaw 变成非技术用户也能用的产品。Electron tray app + React web panel + vendored OpenClaw。

**核心定位**: "OpenClaw is the engine; RivonClaw is the cockpit."

## 核心架构

### 三层规则编译 (Natural Language → Artifact)

用户写一条自然语言规则 → LLM 分类为 3 种 artifact 之一 → 各自物化:

1. **policy-fragment** — 软约束，注入 system prompt（`before_agent_start` hook）
   - 例: "Always respond in formal English"
   - 物化为 prompt prepend 文本
2. **guard** — 硬约束，拦截 tool call（`before_tool_call` hook）
   - 例: "Never write to /etc"
   - 物化为 JSON 条件 + block/confirm/modify action
   - 条件格式: `tool:<name>`, `tool:*`, `path:<pattern>`
3. **action-bundle** — 新能力，物化为 SKILL.md（写入 skills 目录，OpenClaw 自动发现）
   - 例: "Add a skill to deploy to staging"
   - 完整 SKILL.md 带 frontmatter

**编译管线**: `classifyWithLLM()` → `generateWithLLM()` → SQLite 持久化 → 物化（skill 写文件、policy/guard 注入）

### 关键设计决策

- **LLM 做分类 + 生成**，heuristic 做 fallback（无 API key 时退化为关键词匹配）
- **热重载**: API key、proxy、channel 改动不需重启 gateway
- **安全**: secrets 用 Keychain/DPAPI（非明文）；file permissions 通过 OpenClaw plugin hook 实现
- **Vendor 模式**: 不 fork OpenClaw，用 vendor + patch 脚本，可跟 upstream 更新

### 与 OpenClaw 的集成方式

不修改 OpenClaw 源码，全部通过 plugin hooks:
- `before_agent_start` → 注入 policy + guard 信息到 system prompt
- `before_tool_call` → guard evaluator 拦截工具调用
- Skills directory → action-bundle 编译后写 SKILL.md

## 对 Kagura 的启示

### 1. 规则三分法可借鉴
我们的 AGENTS.md 实际上混合了 policy（行为准则）、guard（红线）和 action（技能）。RivonClaw 的分类框架可以指导我们更清晰地组织 DNA 文件。

### 2. Guard Evaluator 是安全第二主线的参考
JSON 条件格式（tool pattern + path pattern）很简洁。我们的隐私保护规则如果能 formalize 成 guard spec，可以从 prompt 层面约束升级到 hook 层面拦截。

### 3. Skill 物化模式和我们一致
action-bundle → SKILL.md 写文件 → OpenClaw 自动发现。这跟我们的 skill 创建流程一致，但他们加了 LLM 生成步骤。

### 4. 产品化差距
RivonClaw 解决的是"OpenClaw 太 geek"的问题。这是北极星"人类伴侣"方向必须解决的——非技术用户需要 GUI。但 RivonClaw 是桌面端，我们的场景更多是 server + 聊天工具。

## 局限 / 观察

- 252★ 还比较早期
- guard 条件匹配比较简单（前缀匹配），复杂规则可能表达力不足
- LLM 编译引入延迟和成本，规则多了可能有问题
- 没看到 guard 之间冲突检测机制

## 关联

- [[SkillClaw]] — skill 进化，RivonClaw 侧重规则物化
- [[conservative-skill-editing]] — RivonClaw 的 guard 是一种约束编辑
- 北极星"人类伴侣" — 非技术用户可用是关键
- 安全第二主线 — guard evaluator 的 formalization 方式

## 下一步

- [ ] 考虑是否为 Kagura 的红线规则实现 guard spec 格式（从 prompt 约束→hook 拦截）
- [ ] 观察 RivonClaw stars 增长，判断"OpenClaw GUI 层"需求是否真实
