
## OpenClaw Gateway 协议要点（2026-04-02 调通）

### 连接认证
- `client.id: "openclaw-tui"` + `mode: "ui"` = Control UI 身份，scopes 保留
- `client.id: "cli"` + `mode: "backend"` = token auth 下 scopes 被清空（无 device identity）
- `gateway.controlUi.dangerouslyDisableDeviceAuth: true` = 允许无 device identity 的 Control UI 连接
- token auth + no device identity → `shouldClearUnboundScopesForMissingDeviceIdentity` 清空 scopes

### 事件格式
- Gateway 对 TUI/Control UI 客户端发 `event: "chat"`（state: delta/final/error, message 对象）
- Gateway 对所有人广播 `event: "agent"`（stream: assistant/lifecycle/tool, data 对象）
- 两种格式 payload 结构完全不同！

### Session Key
- chat.send 的 sessionKey 传 `workshop:product`
- Gateway 内部变成 `agent:kagura:workshop:product`
- 事件 payload 里的 sessionKey 是内部格式（带 agent 前缀）
- 必须同时匹配两种格式

### 多 Agent 路由（2026-04-02 发现）
- **一个 gateway 连接可以路由到多个 agent**！不需要每个 agent 一个 WS 连接
- 机制：`parseAgentSessionKey` 从 session key 解析 agent ID
- `agent:kagura:workshop:product` → kagura agent
- `agent:anan:workshop:product` → anan agent
- Workshop 只需在 `chat.send` 时指定不同的 session key 前缀
- 当前机器上已有：kagura、anan、ruantang 三个 agent，共享一个 gateway (port 18789)
