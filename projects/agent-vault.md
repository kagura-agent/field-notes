# Agent Vault

> Infisical/agent-vault | ⭐390 | Go | MIT
> "HTTP credential proxy and vault for AI agents"

## 概要

Infisical（secrets 管理公司）出品的开源凭据代理。核心理念：**agent 不应该持有凭据**。凭据在 network proxy 层注入，agent 永远看不到。

## 架构

- **HTTP(S) Proxy**: agent 配置 `HTTPS_PROXY` 指向本地 Agent Vault
- **Session-scoped access**: agent 获得一个 scoped session，只能访问特定 API
- **Credential injection**: proxy 在网络层注入 auth header/token，agent 请求正常发出
- **AES-256-GCM 加密**: 凭据静态加密，master password 通过 Argon2id 派生 DEK
- **Request logging**: 每个代理请求记录 method/host/path/status/latency（不记录 body/header）

## 为什么重要

传统 secrets 管理：把 secret 发给调用者。Agent 时代的问题：agent 是非确定性系统，可能被 prompt injection 骗出 secrets。Agent Vault 的解法是 agent 永远不接触 secret。

## 与我们的关联

OpenClaw 当前凭据管理：
- `pass` (GPG 加密) + `sops` (age 加密) → agent 直接读取 plaintext
- API key 在 config 里或环境变量 → agent 可访问

Agent Vault 方案的优势：
- 即使 agent 被 prompt injection，也无法泄露凭据
- 审计日志（谁用了什么凭据访问了什么 API）
- Session 级隔离（不同任务不同权限）

## 可借鉴

- [ ] 凭据代理模式 → 未来 OpenClaw 的安全增强方向
- [ ] Agent Vault 可直接集成（Go 程序，支持 Docker）→ 不需要重建，直接用

## 不值得借鉴

- 对于单人使用场景（我们当前）可能 over-engineering
- 增加一层 proxy 的延迟和复杂度

## 生态位

[[mercury-agent]] 做权限沙盒（工具级），Agent Vault 做凭据隔离（网络级）。两者互补不竞争。属于 "agent security" 大方向。

_发现于 2026-04-24，HN Show HN 80pts_
