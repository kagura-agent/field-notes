# CrabTrap

> Brex 开源的 LLM-as-a-judge HTTP proxy，保护 AI agent 的出站流量。

- **Repo**: brexhq/CrabTrap ⭐314 (2026-04-23)
- **语言**: Go + React/TS
- **License**: MIT

## 它在解决什么问题？

AI agent 调外部 API（Slack、Gmail、GitHub 等）时，没有统一的安全网。Agent 可能发错邮件、删错数据、泄露敏感信息。CrabTrap 作为 **forward proxy** 拦截所有出站 HTTP/HTTPS 请求，两层评估后决定放行或拦截。

## 核心架构

```
Agent → HTTP_PROXY=CrabTrap → [TLS MITM] → [Static Rules] → [LLM Judge] → External API
                                                ↓                ↓
                                           PostgreSQL audit log
```

### 两层评估（Two-tier evaluation）
1. **Static rules**: URL pattern（prefix/exact/glob）+ HTTP method filter，命中即决定，不调 LLM
2. **LLM judge**: 没有 static rule 命中时，用自然语言安全策略让 LLM 判断放行/拒绝

### 关键设计决策
- **MITM proxy**: 生成 per-host TLS 证书，解密看请求内容（agent 需信任其 CA）
- **SSRF protection**: 屏蔽 RFC 1918、loopback、link-local 等私有网络 + DNS rebinding 防护
- **Circuit breaker**: LLM 连续 5 次失败后 trip，10s cooldown，可配 fallback（deny/passthrough）
- **Policy builder**: agentic loop 分析历史流量自动生成安全策略
- **Eval system**: 回放 audit log 测量策略准确率

### 明确不做的
- 不是 WAF（只管出站，不管入站）
- 不 redact 敏感数据（信任边界是 proxy 本身）
- 不提供 human-in-the-loop 审批
- 不过滤 API 响应
- 不检查 WebSocket frames

## 跟我们的关系

| 维度 | CrabTrap | OpenClaw |
|------|----------|----------|
| 定位 | 出站安全代理 | Agent 运行时平台 |
| 安全模型 | proxy 层拦截 | tool policy + guard spec |
| 关系 | 互补：CrabTrap 可以作为 OpenClaw agent 的出站安全层 |

### 可借鉴的
1. **Static rules → LLM fallback 模式**: 先用确定性规则快速判断，不命中才用 LLM。和我们 guard-spec 的思路一致，但 CrabTrap 在网络层做
2. **Policy builder**: 从历史行为自动生成策略，这个思路可以用在 OpenClaw 的 tool policy 自动生成上
3. **Eval system**: 回放历史决策测量策略质量，和我们 dreaming eval 的思路类似

## Links
- [[agent-safety]]
- [[guard-spec-format]]
- [[tool-execution-policy-enforcement]]
