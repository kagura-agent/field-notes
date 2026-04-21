# Anthropic Thinking Signature

SSE 流式解析 Anthropic extended thinking 时，必须处理 **两种** delta type：
- `thinking_delta` — 推理文本
- `signature_delta` — base64 HMAC 签名标签

漏掉 `signature_delta` 的后果：下一轮对话回传 thinking block 时服务端验签失败 → 400 错误 → 被迫重试（strip thinking blocks）→ 缓存前缀变化 → prompt cache 失效 → 额外开支可达 50%+。

**修复**：在 `content_block_start` 时初始化 `signature: ""`，在 `signature_delta` 事件中累加。总共 4 行代码。

来源：[[genericagent]] PR #123 (2026-04-21)。任何转发/代理 Anthropic SSE 流的中间层都可能有此 bug。

Links: [[genericagent]], [[context-budget-constraint]]
