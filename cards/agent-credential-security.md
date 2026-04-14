# Agent 凭证安全：指纹模式

> Agent credential security: fingerprint model for runtime-injected credentials. Agents use credentials (API keys, tokens) without seeing them — runtime injects on demand, like fingerprint payment.

## 核心问题
Agent 需要使用凭证（API key、OAuth token、app secret），但不应该能"看到"凭证。
当前现实：agent 可以 `cat` 配置文件直接读到所有 secret。

## 理想模型："指纹解锁"
- Agent 说"我需要调飞书 API"
- Runtime 检查权限，自动注入凭证
- Agent 只拿到结果，从不接触 token 本身
- 类比：手机指纹支付，你按一下就付了，但不知道银行卡号

## 当前状态
- OpenClaw 部分实现：channel 凭证在 config 里，agent 通过 `message send` 间接使用
- 但 agent 进程能读 config 文件，隔离是"信任"而非"技术不可能"
- GitHub token (gh CLI)、SSH key、.env 文件同理

## 技术方向（待研究）
- Sandbox 级别文件隔离（agent 进程无权读凭证文件）
- Runtime API 代理（agent 请求 → runtime 注入凭证 → 转发）
- 短期 session token（runtime 颁发有限权限、有限时间的 token）
- Hardware security module (HSM) / Trusted execution environment (TEE)

## 业界方案（待调研）
- [ ] OpenClaw 自身的 sandbox/exec 机制
- [ ] Claude Code 的 permission model
- [ ] Hermes agent 的凭证管理
- [ ] AWS/Azure 的 managed identity（无密码，靠环境身份）
- [ ] HashiCorp Vault 的 dynamic secrets
- [ ] 1Password 的 Service Accounts / CLI

## 来源
- 2026-04-07 Luna 洞察：agent 需要"指纹"而不是"密码"
- 属于北极星方向：agent 基础设施痛点
