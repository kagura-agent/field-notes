# Agent Identity — 凭证自管理

> 2026-04-23 启动 | Luna 提议
> 关联：[[agent-security]], GTM (npm publish 被 2FA 卡住触发)

## 背景
每次 npm publish / 新服务注册都要 Luna 操作密码和 2FA。Luna 提出：agent 应该自己管理凭证，加密存储，不依赖人类。

## 目标
- CLI 友好的密码/凭证管理
- 加密存储（GPG/age）
- Git 私有 repo 备份
- Agent 可自主完成日常 auth

## Repo
- GitHub: kagura-agent/agent-identity (private)
- Discord: #agent-identity (1496666666099019857)

## 待调研工具
- **pass** — Unix 哲学，GPG + git，最轻量
- **gopass** — pass 增强版，team 功能，age 支持
- **sops** — Mozilla 出品，YAML/JSON 加密，适合 config
- **Bitwarden CLI** — 功能全但需要 server
- **age** — 现代加密，比 GPG 简单，但太底层

## 评估维度
1. Agent 可操作性（无 GUI，纯 CLI）
2. 加密强度
3. Git 友好度
4. 安装复杂度
5. 社区活跃度

## 状态
🔍 调研中
