# RivonClaw

> gaoyangz77/rivonclaw — ⭐253 (2026-04-15)
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

- [[skillclaw]] — skill 进化，RivonClaw 侧重规则物化
- [[conservative-skill-editing]] — RivonClaw 的 guard 是一种约束编辑
- 北极星"人类伴侣" — 非技术用户可用是关键
- 安全第二主线 — guard evaluator 的 formalization 方式

## Applied To Kagura（2026-04-14）

RivonClaw 的规则三分法已应用到 Kagura 的 AGENTS.md 红线规则：

### 分类结果

将 11 条红线规则分为：
- **4 条 guard**（今日可通过 OpenClaw hook 实现）: trash>rm、no-push-main、destructive-command-confirm、基础 exfiltration 拦截
- **3 条部分 guard**（需要额外基础设施）: PII-in-public-commit、.gitignore-first、exfiltration 语义检测
- **4 条 policy**（纯行为层面，不可程序化）: 验证纪律、数据纪律、讨好模式防范、subagent 代码规则

### 产出物

- [[guard-spec-format]] — Guard spec YAML schema + 5 条具体 guard 定义
- [[exp-017-guard-spec-prototype]] — 实验追踪（假设: 结构化 guard 降低违反率）

### 关键发现

1. **RivonClaw 的 guard 条件格式（tool pattern + path pattern + command regex）足以表达 Kagura 大部分可程序化的红线**
2. **OpenClaw 的 `before_tool_call` hook 存在 gap**: 有 approval（交互式）但没有 programmatic block（静默拦截）。hermes-agent 的 `pre_tool_call` → `{"action":"block"}` 是更好的参考
3. **约 60% 的红线是 policy 不是 guard**: 验证纪律、数据纪律、讨好模式等约束的是决策过程而非工具调用，guard 永远是安全网不是替代品
4. **Guard spec 格式本身有价值**: 即使不实现 hook，结构化表达让规则更清晰、更容易 review

### 与 RivonClaw 的差异

| 维度 | RivonClaw | Kagura |  
|------|-----------|--------|
| 规则来源 | 用户自然语言输入 | AGENTS.md 已有红线 |
| 分类方式 | LLM 分类 | 人工分类（更精确） |
| Guard 条件 | 前缀匹配为主 | 正则 + glob + JSONPath |
| 物化目标 | SQLite + plugin 注入 | YAML spec → OpenClaw plugin |
| 缺失能力 | 冲突检测 | Session 级状态追踪（"push 前跑过测试吗"） |

## SSRF Guard Bypass (v1.7.11, 2026-04-15)

OpenClaw 有 browser SSRF guard 防止 agent 被诱导访问内网服务。RivonClaw 桌面模式下直接关掉：`ssrfPolicy: { dangerouslyAllowPrivateNetwork: true }`。

**原因**: 用户的 proxy-manager 注入 HTTP_PROXY/HTTPS_PROXY env vars → OpenClaw browser 走代理 → SSRF guard 把 localhost proxy 连接当私网访问拦截 → 所有浏览器导航全挂。

**设计决策**: 桌面端用户控制浏览器，SSRF 威胁模型（attacker tricks agent into hitting internal services）不适用。服务器端仍需保留 guard。

**启示**: 安全特性必须适配部署模型。Server-first 安全假设直接搬到 desktop 会 break 正常功能。`dangerouslyAllowPrivateNetwork` 命名很好——带 "dangerously" 前缀让使用者知道在绕过什么。

## 下一步

- [x] ~~考虑是否为 Kagura 的红线规则实现 guard spec 格式~~ → Done, see [[guard-spec-format]]
- [ ] 实现最简 guard plugin（从 trash-over-rm 开始）
- [ ] 向 OpenClaw 贡献 programmatic block 能力（参考 hermes-agent）
- [ ] 观察 RivonClaw stars 增长，判断"OpenClaw GUI 层"需求是否真实
